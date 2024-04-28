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

  Students({
    required this.id,
    required this.name,
  });

  factory Students.fromJson(Map<String, dynamic> json) {
    return Students(
      id: json['_id'],
      name: json['name'],
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
      body: Column(
        children: [
          // Expanded(
          //   child:  FutureBuilder<List<Students>>(
          //     future: futureStudents,
          //     builder: (context, snapshot) {
          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return Center(
          //           child: SpinKitFoldingCube(color: Colors.blue, size: 50.0),
          //         );
          //       } else if (snapshot.hasError) {
          //         // return Text("Error: ${snapshot.error}");
          //         return Text("No projects found !!!");
          //       }
          //
          //       return ListView.builder(
          //         itemCount: snapshot.data?.length ?? 0,
          //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          //         itemBuilder: (context, index) {
          //           Students project = snapshot.data![index];
          //           return InkWell(
          //             onTap: () {
          //               Navigator.push(
          //                 context,
          //                 MaterialPageRoute(
          //                   builder: (context) => ProjectChatHistoryScreen(
          //                     studentId: widget.studentId,
          //                     projectName: widget.projectName,
          //                     projectId: widget.projectId,
          //                   ),
          //                 ),
          //               );
          //             },
          //             child: Container(
          //               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          //               child: Column(
          //                 children: [
          //                   Text(project.name, style: TextStyle(fontSize: 16, color: Colors.white),)
          //                 ],
          //               ),
          //             ),
          //           );
          //         },
          //       );
          //     },
          //   ),
          // ),

          Expanded(
            child:  ListView.builder(
              itemCount: listStudentData.length ?? 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemBuilder: (context, index) {
                // Students project = snapshot.data![index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectChatHistoryScreen(
                          studentId: widget.studentId ,
                          projectName: widget.projectName,
                          projectId: widget.projectId,
                          studentName: listStudentData[index].name,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        Text(listStudentData[index].name, style: TextStyle(fontSize: 16, color: Colors.white),),
                        const Divider(),
                      ],
                    ),
                  ),
                );
              },
            )
          ),
        ],
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
