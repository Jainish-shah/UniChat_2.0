import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../config/app_config.dart';
import '../realtime_chat/chat_models.dart';

enum SocketStatus { disconnected, connecting, connected, error }

/// Single Socket.IO connection to the UniChat realtime server, authenticated with the
/// signed-in user's Firebase ID token. Exposes broadcast streams for screens to listen to.
class SocketService extends ChangeNotifier {
  SocketService._();
  static final SocketService instance = SocketService._();

  io.Socket? _socket;
  SocketStatus status = SocketStatus.disconnected;
  String? lastError;
  Map<String, dynamic>? profile;
  final Set<String> _joinedRooms = {};
  bool _retriedAuth = false;

  final _roomMessages = StreamController<RoomMessage>.broadcast();
  final _roomSync = StreamController<MapEntry<String, List<RoomMessage>>>.broadcast();
  final _typing = StreamController<TypingEvent>.broadcast();
  final _aiMessages = StreamController<AiMessage>.broadcast();
  final _aiTyping = StreamController<bool>.broadcast();
  final _aiErrors = StreamController<String>.broadcast();
  final _aiCleared = StreamController<void>.broadcast();
  final _presence = StreamController<Map<String, dynamic>>.broadcast();

  Stream<RoomMessage> get roomMessages => _roomMessages.stream;
  /// Fresh history for a room after a reconnect (roomId -> messages).
  Stream<MapEntry<String, List<RoomMessage>>> get roomSync => _roomSync.stream;
  Stream<TypingEvent> get typing => _typing.stream;
  Stream<AiMessage> get aiMessages => _aiMessages.stream;
  Stream<bool> get aiTyping => _aiTyping.stream;
  Stream<String> get aiErrors => _aiErrors.stream;
  Stream<void> get aiCleared => _aiCleared.stream;
  Stream<Map<String, dynamic>> get presence => _presence.stream;

  bool get isConnected => status == SocketStatus.connected;
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  void _setStatus(SocketStatus s, [String? error]) {
    status = s;
    lastError = error;
    notifyListeners();
  }

  /// Connects (or reuses the connection). Safe to call from every screen.
  Future<void> ensureConnected() async {
    if (_socket != null && (status == SocketStatus.connected || status == SocketStatus.connecting)) {
      if (status == SocketStatus.connected) return;
      return _waitForConnection();
    }
    await connect();
  }

  Future<void> connect({bool forceRefreshToken = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _setStatus(SocketStatus.error, 'Please sign in first');
      throw StateError('Not signed in');
    }
    final token = await user.getIdToken(forceRefreshToken);
    _socket?.dispose();
    _setStatus(SocketStatus.connecting);

    final socket = io.io(
      AppConfig.chatServerUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableForceNew()
          .enableReconnection()
          .disableAutoConnect()
          .build(),
    );
    _socket = socket;

    socket.onConnect((_) {
      _retriedAuth = false;
      _setStatus(SocketStatus.connected);
      for (final roomId in _joinedRooms.toList()) {
        _rejoin(roomId);
      }
    });
    socket.onDisconnect((_) => _setStatus(SocketStatus.disconnected));
    socket.onConnectError((err) async {
      final msg = '$err';
      _setStatus(SocketStatus.error, msg);
      // ID tokens expire after an hour: refresh once and rebuild the connection.
      if (msg.contains('unauthorized') && !_retriedAuth) {
        _retriedAuth = true;
        try {
          await connect(forceRefreshToken: true);
        } catch (_) {}
      }
    });

    socket.on('session', (data) {
      profile = asMap(asMap(data)['user']);
      notifyListeners();
    });
    socket.on('message:new', (data) => _roomMessages.add(RoomMessage.fromJson(asMap(data))));
    socket.on('typing', (data) => _typing.add(TypingEvent.fromJson(asMap(data))));
    socket.on('ai:message', (data) => _aiMessages.add(AiMessage.fromJson(asMap(data))));
    socket.on('ai:typing', (data) => _aiTyping.add(asMap(data)['isTyping'] == true));
    socket.on('ai:error', (data) => _aiErrors.add('${asMap(data)['error']}'));
    socket.on('ai:cleared', (_) => _aiCleared.add(null));
    socket.on('presence', (data) => _presence.add(asMap(data)));

    socket.connect();
    await _waitForConnection();
  }

  Future<void> _waitForConnection({Duration timeout = const Duration(seconds: 10)}) async {
    if (status == SocketStatus.connected) return;
    final c = Completer<void>();
    void listener() {
      if (status == SocketStatus.connected && !c.isCompleted) c.complete();
    }
    addListener(listener);
    try {
      await c.future.timeout(timeout, onTimeout: () {
        throw TimeoutException('Could not reach chat server at ${AppConfig.chatServerUrl}'
            '${lastError != null ? ' ($lastError)' : ''}');
      });
    } finally {
      removeListener(listener);
    }
  }

  /// Emits [event] and waits for the server's acknowledgement.
  Future<Map<String, dynamic>> _request(String event, Map<String, dynamic> payload,
      {Duration timeout = const Duration(seconds: 60)}) async {
    await ensureConnected();
    final c = Completer<Map<String, dynamic>>();
    _socket!.emitWithAck(event, payload, ack: (data) {
      if (!c.isCompleted) c.complete(asMap(data));
    });
    final res = await c.future.timeout(timeout, onTimeout: () => {'ok': false, 'error': 'Request timed out'});
    if (res['ok'] != true) throw Exception(res['error'] ?? 'Request failed');
    return res;
  }

  // ---------- Rooms ----------

  Future<List<RoomMessage>> joinRoom(String roomId) async {
    final res = await _request('room:join', {'roomId': roomId});
    _joinedRooms.add(roomId);
    return (res['messages'] as List? ?? []).map((m) => RoomMessage.fromJson(asMap(m))).toList();
  }

  Future<void> _rejoin(String roomId) async {
    final c = Completer<Map<String, dynamic>>();
    _socket?.emitWithAck('room:join', {'roomId': roomId}, ack: (d) => c.complete(asMap(d)));
    final res = await c.future.timeout(const Duration(seconds: 15), onTimeout: () => {});
    if (res['ok'] == true) {
      _roomSync.add(MapEntry(roomId,
          (res['messages'] as List? ?? []).map((m) => RoomMessage.fromJson(asMap(m))).toList()));
    }
  }

  void leaveRoom(String roomId) {
    _joinedRooms.remove(roomId);
    _socket?.emit('room:leave', {'roomId': roomId});
  }

  Future<RoomMessage> sendRoomMessage(String roomId, String text) async {
    final res = await _request('message:send', {'roomId': roomId, 'text': text});
    return RoomMessage.fromJson(asMap(res['message']));
  }

  void setTyping(String roomId, bool isTyping) {
    if (isConnected) _socket!.emit('typing', {'roomId': roomId, 'isTyping': isTyping});
  }

  // ---------- Private AI assistant ----------

  Future<List<AiMessage>> aiHistory() async {
    final res = await _request('ai:history', {});
    return (res['messages'] as List? ?? []).map((m) => AiMessage.fromJson(asMap(m))).toList();
  }

  Future<AiMessage> askAi(String text) async {
    final res = await _request('ai:send', {'text': text}, timeout: const Duration(seconds: 120));
    return AiMessage.fromJson(asMap(res['message']));
  }

  Future<void> clearAi() => _request('ai:clear', {});

  /// Call on sign-out.
  void disconnect() {
    _joinedRooms.clear();
    _socket?.dispose();
    _socket = null;
    profile = null;
    _setStatus(SocketStatus.disconnected);
  }
}
