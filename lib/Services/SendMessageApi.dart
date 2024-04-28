import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../chat_gpt/constants/api_consts.dart';
import '../models/chatmodel.dart';

class SendMessageApi {
  Future<List<Project>> fetchProjects(String studentId) async {
    String databasename = "universityatalbanyDB";
    final response = await http.get(Uri.parse(
        '$LOCALHOST/api/students/projects/getStudentProjects?databasename=${databasename}&studentId=${studentId}'));

    if (response.statusCode == 200) {
      List<Project> projects = [];
      var jsonData = jsonDecode(response.body);
      for (var proj in jsonData['projects']) {
        projects.add(Project.fromJson(proj));
      }
      return projects;
    } else {
      throw Exception('Failed to load projects');
    }
  }


  Future<void> sendMessage(String databaseName, String projectId, Message message) async {
    String databasename = "universityatalbanyDB";
    final url = Uri.parse('$LOCALHOST/api/NativeChat/AddMessageData');
    final response = await http.post(url, headers: {
      'Content-Type': 'application/json'
    }, body: json.encode({
      'databasename': databasename,
      'projectID': projectId,
      'message': {
        'messageData': message.message,
        'sender': message.sender,
        'sentTime': message.sentTime.toIso8601String(),
      }
    }));

    if (response.statusCode != 200) {
      throw Exception('Failed to send message');
    }
  }
}
