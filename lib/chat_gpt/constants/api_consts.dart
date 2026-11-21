import '../../config/app_config.dart';

// AI provider keys are NOT stored in the app any more: all AI calls go through the
// UniChat realtime server (see /server), which holds the keys in its environment.
String get AI_SERVER_URL => AppConfig.chatServerUrl;

// Existing Next.js/MongoDB API (schools, students, projects).
String LOCALHOST = AppConfig.legacyApiUrl;
