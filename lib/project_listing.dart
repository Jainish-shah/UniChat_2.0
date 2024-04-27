import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chat_gpt/constants/api_consts.dart';
import 'main_home_page.dart';

class Project {
  final String id;
  final String projectName;
  final String projectDescription;
  final String discordServerId;

  Project({
    required this.id,
    required this.projectName,
    required this.projectDescription,
    required this.discordServerId,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['_id'],
      projectName: json['projectName'],
      projectDescription: json['projectDescription'],
      discordServerId: json['discordServerId'],
    );
  }
}

class ProjectListingPage extends StatefulWidget {
  final String studentId;
  ProjectListingPage({Key? key, required this.studentId}) : super(key:key);

  @override
  _ProjectListingPageState createState() => _ProjectListingPageState();
}

class _ProjectListingPageState extends State<ProjectListingPage> {
  late Future<List<Project>> futureProjects;

  @override
  void initState() {
    super.initState();
    futureProjects = fetchProjects(widget.studentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Projects'),
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () {
        //     // Pop the current route off the stack
        //     Navigator.of(context).pushReplacement(MaterialPageRoute(
        //       builder: (context) => MainHomePage(studentId: widget.studentId), // Navigate to success page
        //     ));
        //   },
        // ),
      ),
      body: FutureBuilder<List<Project>>(
        future: futureProjects,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitFoldingCube(color: Colors.blue, size: 50.0),
            );
          } else if (snapshot.hasError) {
            // return Text("Error: ${snapshot.error}");
            return Text("No projects found !!!");
          }

          return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              Project project = snapshot.data![index];
              return ListTile(
                title: Text(project.projectName),
                subtitle: Text(project.projectDescription),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiscordDetailPage(
                        projectName: project.projectName,
                        id: project.id,
                        studentId: widget.studentId,
                        discordServerId: project.discordServerId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
