// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// import 'discord.dart';
//
// class Project {
//   final String id;
//   final String projectName;
//   final String projectDescription;
//   final String discordServerId;
//
//   Project({
//     required this.id,
//     required this.projectName,
//     required this.projectDescription,
//     required this.discordServerId,
//   });
//
//   factory Project.fromJson(Map<String, dynamic> json) {
//     return Project(
//       id: json['_id'],
//       projectName: json['projectName'],
//       projectDescription: json['projectDescription'],
//       discordServerId: json['discordServerId'],
//     );
//   }
// }
//
// class ShowProjects extends StatefulWidget {
//   final String studentId;
//   ShowProjects({Key? key, required this.studentId}) : super(key: key);
//
//   @override
//   _ShowProjectsState createState() => _ShowProjectsState();
// }
//
// class _ShowProjectsState extends State<ShowProjects> {
//   late Future<List<Project>> futureProjects;
//
//   @override
//   void initState() {
//     super.initState();
//     futureProjects = fetchProjects(widget.studentId);
//   }
//
//   Future<List<Project>> fetchProjects(String studentId) async {
//     String databasename = "universityatalbanyDB";
//     final response = await http.get(Uri.parse(
//         'https://9023-2603-7080-b1f0-6390-fcf3-a348-dfe3-7430.ngrok-free.app/api/students/projects/getStudentProjects?databasename=$databasename&studentId=$studentId'));
//
//     if (response.statusCode == 200) {
//       List<Project> projects = [];
//       var jsonData = jsonDecode(response.body);
//       for (var proj in jsonData['projects']) {
//         projects.add(Project.fromJson(proj));
//       }
//       return projects;
//     } else {
//       throw Exception('Failed to load projects');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Student Projects'),
//       ),
//       body: FutureBuilder<List<Project>>(
//         future: futureProjects,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: SpinKitFoldingCube(color: Colors.blue, size: 50.0));
//           } else if (snapshot.hasError) {
//             return Center(child: Text("No projects found or error fetching projects"));
//           }
//
//           return ListView.builder(
//             itemCount: snapshot.data?.length ?? 0,
//             itemBuilder: (context, index) {
//               Project project = snapshot.data![index];
//               return ListTile(
//                 title: Text(project.projectName),
//                 subtitle: Text(project.projectDescription),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => DiscordWidget(
//                         discordServerId: project.discordServerId,
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
