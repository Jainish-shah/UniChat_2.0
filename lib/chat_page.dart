import 'package:flutter/material.dart';
import 'package:unichat_poojan_project/main_home_page.dart';

import 'config/app_config.dart';
import 'realtime_chat/realtime_chat_screen.dart';

/// Class announcements: a realtime Socket.IO room shared by everyone in the class.
class ChatPage extends StatelessWidget {
  final String studentId;
  const ChatPage({Key? key, required this.studentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RealtimeChatScreen(
      roomId: AppConfig.announcementsRoom,
      title: 'Class Announcement',
      onBack: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainHomePage(studentId: studentId)),
      ),
    );
  }
}
