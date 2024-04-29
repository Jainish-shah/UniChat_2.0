import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:googleapis/classroom/v1.dart';
import 'package:unichat_poojan_project/Services/SendMessageApi.dart';
import 'package:http/http.dart' as http;
import 'package:unichat_poojan_project/chat_page.dart';
import 'package:unichat_poojan_project/project_chat_history.dart';
import 'dart:convert';


import 'chat_gpt/constants/api_consts.dart';
import 'models/chatmodel.dart';

class ProjectWiseStudentListScreen extends StatefulWidget {
  final String studentId;
  List<String> studentIds = [];
  final String projectName;
  final String projectId;
  ProjectWiseStudentListScreen({Key? key, required this.studentId, required this.studentIds,
    required this.projectId, required this.projectName}) : super(key: key);

  @override
  _ChatPage2State createState() => _ChatPage2State();
}

class Students {
  final String id;
  final String name;
  final String photoUrl;

  Students({
    required this.id,
    required this.name,
    this.photoUrl = '',
  });

  factory Students.fromJson(Map<String, dynamic> json) {
    return Students(
      id: json['_id'],
      name: json['name'],
      photoUrl: json['photoUrl'],
    );
  }
}

class _ChatPage2State extends State<ProjectWiseStudentListScreen> {
  late Future<List<Students>> futureStudents;
  List<Students> listStudentData = <Students>[];

  @override
  void initState() {
    super.initState();

    for(int i=0; i<widget.studentIds.length; i++) {
      fetchStudentDetails(widget.studentIds[i]);
    }

  }
  String? selectedProjectId;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student List'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF16043F), // Darker shade at the top
              Color(0xFF0C0101), // Lighter shade at the bottom
            ],
          ),
        ),
        child: ListView.builder(
          itemCount: listStudentData.length,
          itemBuilder: (context, index) {
            var photoUrl = listStudentData[index].photoUrl;
            ImageProvider? imageProvider = (photoUrl.isNotEmpty
                ? NetworkImage(photoUrl)
                : AssetImage('assets/default_profile.png')) as ImageProvider<Object>?; // Default image path in assets

            return Container(
              margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1), // Slight white with opacity
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: imageProvider,
                  radius: 30,
                  backgroundColor: Colors.transparent,
                ),
                title: Text(
                  listStudentData[index].name,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProjectChatHistoryScreen(
                        studentId: widget.studentId,
                        projectName: widget.projectName,
                        projectId: widget.projectId,
                        studentName: listStudentData[index].name,
                      ),
                    ),
                  );
                },
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                tileColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  fetchStudentDetails(studentId) async {
    String databasename = "universityatalbanyDB";
    final response = await http.get(Uri.parse(
        '$LOCALHOST/api/students/getStudentData?databasename=${databasename}&studentId=${studentId}'));

    if (response.statusCode == 200) {
      // final result = jsonDecode(response.body);
      // List<Students> studentData = [];
      var jsonData = jsonDecode(response.body);
      for (var proj in jsonData['studentData']) {
        listStudentData.add(Students.fromJson(proj));
      }
      // return listStudentData;
      // String studentName = result['studentData'][0]['name'];
      // EasyLoading.showSuccess("Name :: "+studentName);
      // return studentName;
      setState(() {

      });
    } else {
      throw Exception('Failed to load projects');
    }
  }
}

// Placeholder widget for the chat messages, replace with your actual chat UI
class ChatMessages extends StatelessWidget {
  final String projectId;

  ChatMessages({Key? key, required this.projectId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Chat messages for Project ID: $projectId"));
  }
}