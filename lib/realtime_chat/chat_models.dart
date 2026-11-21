/// A message in a group / project / direct chat room (server: rooms/{roomId}/messages).
class RoomMessage {
  final String id;
  final String roomId;
  final String text;
  final String type; // 'user' | 'ai'
  final String senderId;
  final String senderName;
  final String senderEmail;
  final String senderPhoto;
  final DateTime createdAt;

  RoomMessage({
    required this.id,
    required this.roomId,
    required this.text,
    required this.type,
    required this.senderId,
    required this.senderName,
    required this.senderEmail,
    required this.senderPhoto,
    required this.createdAt,
  });

  bool get isAi => type == 'ai';

  factory RoomMessage.fromJson(Map<String, dynamic> json) => RoomMessage(
        id: '${json['id'] ?? ''}',
        roomId: '${json['roomId'] ?? ''}',
        text: '${json['text'] ?? ''}',
        type: '${json['type'] ?? 'user'}',
        senderId: '${json['senderId'] ?? ''}',
        senderName: '${json['senderName'] ?? 'Unknown'}',
        senderEmail: '${json['senderEmail'] ?? ''}',
        senderPhoto: '${json['senderPhoto'] ?? ''}',
        createdAt: DateTime.tryParse('${json['createdAt']}')?.toLocal() ?? DateTime.now(),
      );
}

/// A turn in the user's private AI assistant conversation (server: users/{uid}/aiMessages).
class AiMessage {
  final String id;
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime createdAt;

  AiMessage({required this.id, required this.role, required this.content, required this.createdAt});

  bool get isUser => role == 'user';

  factory AiMessage.fromJson(Map<String, dynamic> json) => AiMessage(
        id: '${json['id'] ?? ''}',
        role: '${json['role'] ?? 'assistant'}',
        content: '${json['content'] ?? ''}',
        createdAt: DateTime.tryParse('${json['createdAt']}')?.toLocal() ?? DateTime.now(),
      );
}

class TypingEvent {
  final String roomId;
  final String uid;
  final String name;
  final bool isTyping;

  TypingEvent({required this.roomId, required this.uid, required this.name, required this.isTyping});

  factory TypingEvent.fromJson(Map<String, dynamic> json) => TypingEvent(
        roomId: '${json['roomId'] ?? ''}',
        uid: '${json['uid'] ?? ''}',
        name: '${json['name'] ?? ''}',
        isTyping: json['isTyping'] == true,
      );
}

Map<String, dynamic> asMap(dynamic data) =>
    data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
