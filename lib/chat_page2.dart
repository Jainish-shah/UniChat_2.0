import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:unichat_poojan_project/Services/SendMessageApi.dart';
import 'package:http/http.dart' as http;
import 'package:unichat_poojan_project/chat_gpt/constants/api_consts.dart';
import 'package:unichat_poojan_project/chat_page.dart';
import 'package:unichat_poojan_project/main_home_page.dart';
import 'package:unichat_poojan_project/project_chat_history.dart';
import 'package:unichat_poojan_project/project_wise_student_list_screen.dart';
import 'dart:convert';
import 'models/chatmodel.dart';

class ChatPage2 extends StatefulWidget {
  final String studentId;
  ChatPage2({Key? key, required this.studentId}) : super(key: key);

  @override
  _ChatPage2State createState() => _ChatPage2State();
}

class Project {
  Project({
    String? id,
    String? projectName,
    String? projectDescription,
    List<String>? studentIds,}){
    _id = id;
    _projectName = projectName;
    _projectDescription = projectDescription;
    _studentIds = studentIds;
  }

  Project.fromJson(dynamic json) {
    _id = json['_id'];
    _projectName = json['projectName'];
    _projectDescription = json['projectDescription'];
    _studentIds = json['studentIds'] != null ? json['studentIds'].cast<String>() : [];
  }
  String? _id;
  String? _projectName;
  String? _projectDescription;
  List<String>? _studentIds;

  String? get id => _id;
  String? get projectName => _projectName;
  String? get projectDescription => _projectDescription;
  List<String>? get studentIds => _studentIds;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['projectName'] = _projectName;
    map['projectDescription'] = _projectDescription;
    map['studentIds'] = _studentIds;
    return map;
  }
}

Future<List<Project>> fetchProjects(studentId) async {
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

class _ChatPage2State extends State<ChatPage2> {
  late Future<List<Project>> futureProjects;

  @override
  void initState() {
    super.initState();
    futureProjects = fetchProjects(widget.studentId);
  }
  String? selectedProjectId;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Chat', style: TextStyle(color: Colors.white)), // Adjust text color for visibility
        backgroundColor: Colors.transparent, // Makes AppBar transparent
        elevation: 0, // Removes shadow
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Adjust icon color for visibility
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => MainHomePage(studentId: widget.studentId),
            ));
          },
        ),
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
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Project>>(
                future: futureProjects,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SpinKitFoldingCube(color: Colors.blue, size: 50.0),
                    );
                  } else if (snapshot.hasError) {
                    return Text("No projects found !!!");
                  }

                  return ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    itemBuilder: (context, index) {
                      Project project = snapshot.data![index];
                      return Container(
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black, // Background color of container
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(project.projectName!),
                          subtitle: Text(project.projectDescription!),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjectWiseStudentListScreen(
                                  studentId: widget.studentId,
                                  projectName: project.projectName!,
                                  projectId: project.id!,
                                  studentIds: project.studentIds!,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
