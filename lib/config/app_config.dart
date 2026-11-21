import 'package:flutter/foundation.dart';

/// Runtime configuration, supplied at build time with --dart-define, e.g.
///
///   flutter run --dart-define=CHAT_SERVER_URL=http://10.0.2.2:3000
///   flutter build apk --dart-define=CHAT_SERVER_URL=https://unichat-realtime.example.com
///
/// No secrets belong here: AI provider keys live only on the realtime server.
class AppConfig {
  static const String _chatServerUrl = String.fromEnvironment('CHAT_SERVER_URL');

  /// Base URL of the Socket.IO + AI server in /server.
  static String get chatServerUrl {
    if (_chatServerUrl.isNotEmpty) return _chatServerUrl;
    // Sensible local defaults: the Android emulator reaches the host machine via 10.0.2.2.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  /// Existing Next.js/MongoDB API used for schools, students and projects.
  static const String legacyApiUrl = String.fromEnvironment(
    'LEGACY_API_URL',
    defaultValue: 'https://unichat-caffeinecoders.vercel.app',
  );

  /// Room used by the "Class Announcements" screen.
  static const String announcementsRoom = 'announcements';

  /// Room id for a project's group chat.
  static String projectRoom(String projectId) => 'project:$projectId';

  /// Room id for a 1:1 chat between two Firebase uids (order-independent).
  static String directRoom(String uidA, String uidB) {
    final ids = [uidA, uidB]..sort();
    return 'dm:${ids[0]}_${ids[1]}';
  }

  /// Prefix that makes the AI answer inside a group/project chat.
  static const String aiRoomTrigger = '@ai';
}
