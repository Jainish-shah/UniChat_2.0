import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'chat_gpt/constants/api_consts.dart';
import 'discord.dart';
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

// class DiscordDetailPage extends StatelessWidget {
//   final String projectName;
//   final String discordServerId;
//   final String studentId;
//   final String id;
//
//   const DiscordDetailPage({
//     Key? key,
//     required this.projectName,
//     required this.discordServerId,
//     required this.studentId,
//     required this.id
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(projectName),
//       ),
//       body: GestureDetector(         // need to remove this tap
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => DiscordWidget(
//                 discordServerId:
//                     discordServerId,id : id, studentId : studentId// Pass the server ID to the Discord widget
//               ),
//             ),
//           );
//         },
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Icon(Icons.touch_app, size: 48.0), // Visual cue for tapping
//               Text(
//                 "Tap here to open Discord Server",
//                 style: TextStyle(fontSize: 16.0),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class DiscordDetailPage extends StatefulWidget {
  final String projectName;
  final String discordServerId;
  final String studentId;
  final String id;

  const DiscordDetailPage({
    Key? key,
    required this.projectName,
    required this.discordServerId,
    required this.studentId,
    required this.id
  }) : super(key: key);

  @override
  _DiscordDetailPageState createState() => _DiscordDetailPageState();
}

class _DiscordDetailPageState extends State<DiscordDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DiscordWidget(
            discordServerId: widget.discordServerId,
            id: widget.id,
            studentId: widget.studentId,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(), // Show loading indicator while navigating
            SizedBox(height: 20),
            Text(
              "Loading Discord...",
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
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
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
