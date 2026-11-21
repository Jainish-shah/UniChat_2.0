import 'package:flutter/material.dart';
import 'package:unichat_poojan_project/main_home_page.dart';

import 'config/app_config.dart';
import 'realtime_chat/realtime_chat_screen.dart';

/// Realtime group chat for a project (Socket.IO room "project:<projectId>").
/// History is persisted in Firestore by the realtime server.
class ProjectChatHistoryScreen extends StatelessWidget {
  final String studentId;
  final String projectName;
  final String projectId;
  final String studentName;

  const ProjectChatHistoryScreen({
    Key? key,
    required this.studentId,
    required this.projectName,
    required this.projectId,
    required this.studentName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RealtimeChatScreen(
      roomId: AppConfig.projectRoom(projectId),
      title: projectName,
      onBack: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainHomePage(studentId: studentId)),
      ),
    );
  }
}
