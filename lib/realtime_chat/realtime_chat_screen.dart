import 'dart:async';

import 'package:flutter/material.dart';

import '../Services/socket_service.dart';
import '../config/app_config.dart';
import 'chat_models.dart';

const _bgGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF16043F), Color(0xFF0C0101)],
);

/// Realtime group / project / direct chat backed by Socket.IO.
/// Messages starting with "@ai" get an answer from the AI assistant inside the room.
class RealtimeChatScreen extends StatefulWidget {
  final String roomId;
  final String title;
  final VoidCallback? onBack;
  final bool showAppBar;

  const RealtimeChatScreen({
    super.key,
    required this.roomId,
    required this.title,
    this.onBack,
    this.showAppBar = true,
  });

  @override
  State<RealtimeChatScreen> createState() => _RealtimeChatScreenState();
}

class _RealtimeChatScreenState extends State<RealtimeChatScreen> {
  final _socket = SocketService.instance;
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<RoomMessage> _messages = [];
  final Set<String> _ids = {};
  final Map<String, String> _typingUsers = {}; // uid -> name
  final List<StreamSubscription> _subs = [];

  bool _loading = true;
  bool _sending = false;
  String? _error;
  Timer? _typingTimer;
  bool _typingSent = false;

  @override
  void initState() {
    super.initState();
    _socket.addListener(_onStatus);
    _subs.add(_socket.roomMessages.where((m) => m.roomId == widget.roomId).listen(_addMessage));
    _subs.add(_socket.roomSync.where((e) => e.key == widget.roomId).listen((e) => _replaceAll(e.value)));
    _subs.add(_socket.typing.where((t) => t.roomId == widget.roomId).listen((t) {
      setState(() => t.isTyping ? _typingUsers[t.uid] = t.name : _typingUsers.remove(t.uid));
    }));
    _join();
  }

  void _onStatus() {
    if (mounted) setState(() {});
  }

  Future<void> _join() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _replaceAll(await _socket.joinRoom(widget.roomId));
    } catch (e) {
      _error = '$e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _replaceAll(List<RoomMessage> msgs) {
    if (!mounted) return;
    setState(() {
      _messages
        ..clear()
        ..addAll(msgs);
      _ids
        ..clear()
        ..addAll(msgs.map((m) => m.id));
    });
    _scrollToBottom();
  }

  void _addMessage(RoomMessage m) {
    if (!mounted || _ids.contains(m.id)) return;
    setState(() {
      _ids.add(m.id);
      _messages.add(m);
      if (m.isAi) _typingUsers.remove('ai');
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  void _onChanged(String text) {
    if (!_typingSent && text.isNotEmpty) {
      _typingSent = true;
      _socket.setTyping(widget.roomId, true);
    }
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), _stopTyping);
  }

  void _stopTyping() {
    if (_typingSent) {
      _typingSent = false;
      _socket.setTyping(widget.roomId, false);
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _stopTyping();
    try {
      _addMessage(await _socket.sendRoomMessage(widget.roomId, text));
      _controller.clear();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Not sent: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _stopTyping();
    _typingTimer?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    _socket.removeListener(_onStatus);
    _socket.leaveRoom(widget.roomId);
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = Container(
      decoration: const BoxDecoration(gradient: _bgGradient),
      child: Column(
        children: [
          if (_socket.status != SocketStatus.connected) _statusBanner(),
          Expanded(child: _buildList()),
          if (_typingUsers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('${_typingUsers.values.join(', ')} typing…',
                    style: const TextStyle(color: Colors.white54, fontStyle: FontStyle.italic, fontSize: 12)),
              ),
            ),
          _buildInput(),
        ],
      ),
    );

    if (!widget.showAppBar) return body;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 18)),
        centerTitle: true,
        backgroundColor: const Color(0xFF120136),
        leading: widget.onBack == null
            ? null
            : IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: widget.onBack),
      ),
      body: body,
    );
  }

  Widget _statusBanner() {
    final connecting = _socket.status == SocketStatus.connecting;
    return Container(
      width: double.infinity,
      color: connecting ? Colors.orange.withOpacity(0.25) : Colors.red.withOpacity(0.25),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              connecting ? 'Connecting to chat…' : 'Offline${_socket.lastError != null ? ': ${_socket.lastError}' : ''}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!connecting) TextButton(onPressed: _join, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null && _messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(_error!, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _join, child: const Text('Retry')),
          ]),
        ),
      );
    }
    if (_messages.isEmpty) {
      return Center(
        child: Text('No messages yet.\nTip: start with "${AppConfig.aiRoomTrigger}" to ask the AI.',
            textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54)),
      );
    }
    final myUid = _socket.uid;
    return ListView.builder(
      controller: _scroll,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final m = _messages[_messages.length - 1 - i];
        return _Bubble(message: m, isMe: m.senderId == myUid);
      },
    );
  }

  Widget _buildInput() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                onSubmitted: (_) => _send(),
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Message (${AppConfig.aiRoomTrigger} to ask AI)…',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.black38,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white38),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              heroTag: 'send-${widget.roomId}',
              mini: true,
              backgroundColor: Colors.deepPurple[300],
              elevation: 0,
              onPressed: _sending ? null : _send,
              child: _sending
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final RoomMessage message;
  final bool isMe;

  const _Bubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final color = message.isAi
        ? const Color(0xFF0E5E4E)
        : isMe
            ? Colors.deepPurple[700]!
            : Colors.white.withOpacity(0.12);
    final t = message.createdAt;
    final time = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(isMe ? 14 : 2),
              bottomRight: Radius.circular(isMe ? 2 : 14),
            ),
          ),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  if (message.isAi) const Icon(Icons.smart_toy, size: 14, color: Colors.white70),
                  if (message.isAi) const SizedBox(width: 4),
                  Text(message.senderName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white70)),
                ]),
              SelectableText(message.text, style: const TextStyle(fontSize: 15, color: Colors.white)),
              const SizedBox(height: 2),
              Text(time, style: const TextStyle(fontSize: 10, color: Colors.white54)),
            ],
          ),
        ),
      ),
    );
  }
}
