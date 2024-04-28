import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unichat_poojan_project/chat_page2.dart';
import 'package:unichat_poojan_project/main_home_page.dart';
import 'package:unichat_poojan_project/project_listing.dart';
import 'chat_gpt/constants/api_consts.dart';
import 'chat_page.dart';
import 'google_drive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<String>> fetchProjects(studentId) async {
  String databasename = "universityatalbanyDB";
  var url = Uri.parse(
      '$LOCALHOST/api/students/projects/getStudentProjects?databasename=${databasename}&studentId=${studentId}');
  var response = await http.get(url);
  if (response.statusCode == 200) {
    var jsonData = jsonDecode(response.body);
    List<String> projects = [];
    for (var proj in jsonData['projects']) {
      projects.add(proj[
          'projectName']); // Assuming 'projectName' is the key for the project name
    }
    return projects;
  } else {
    throw Exception('Failed to load projects');
  }
}

class CustomSidebar extends StatefulWidget {
  final Function(HomePageBody) updateBody;
  final String studentId;
  CustomSidebar({Key? key, required this.studentId, required this.updateBody,}) : super(key:key);
  @override
  _CustomSidebarState createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  Future<List<String>>? projectNames;

  @override
  void initState() {
    super.initState();
    projectNames = fetchProjects(widget.studentId); // Fetch projects on initialization
  }

  @override
  Widget build(BuildContext context) {
    // Theme data to dynamically change theme properties
    var currentTheme = Theme.of(context);
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment
            .spaceBetween, // To space out the top and bottom sections
        children: [
          Flexible(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "UniChat",
                    style: TextStyle(
                      fontFamily: 'Kode Mono',
                      fontWeight: FontWeight.w300,
                      fontSize: 24.0,
                      letterSpacing: 2.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.home, color: Colors.white),
                  title: Text('Home', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    widget.updateBody(HomePageBody.MainHomePage); // Use the callback to update the body
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) =>
                          MainHomePage(studentId: widget.studentId), // Navigate to success page
                    ));
                  },
                ),
                FutureBuilder<List<String>>(
                  future: projectNames,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(title: Text('Loading Projects...'));
                    } else if (snapshot.hasError) {
                      return ListTile(title: Text('Error loading projects'));
                    } else {
                      return ExpansionTile(
                        title: Text('All Projects',
                            style: TextStyle(color: Colors.white)),
                        children: snapshot.data!
                            .map((name) => ListTile(
                          title: Text(name,
                              style: TextStyle(color: Colors.white)),
                          onTap: () {
                            // Handle project tap
                          },
                        ))
                            .toList(),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.flight_takeoff,
                      color: Colors.white), // Example icon for "Port to KF"
                  title:
                      Text('Port to KF', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    widget.updateBody(HomePageBody.googleDrive);
                    // Navigator.of(context).pushReplacement(MaterialPageRoute(
                    //   builder: (context) =>
                    //       ProjectListingPage(studentId: widget.studentId), // Navigate to success page
                    // ));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.folder_open,
                      color:
                          Colors.white), // Example icon for "My Google Drive"
                  title: Text('My Google Drive',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    widget.updateBody(HomePageBody.googleDrive);
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) =>
                          GoogleDrive(studentId: widget.studentId), // Navigate to success page
                    ));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.chat, color: Colors.white), // Chat icon
                  title: Text('Class Announcements', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) =>
                          ChatPage(studentId: widget.studentId), // Navigate to ChatPage without receiverId
                    ));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.home, color: Colors.white),
                  title: Text('Chat', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    widget.updateBody(HomePageBody.chat); // Use the callback to update the body
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) =>
                          ChatPage2(studentId: widget.studentId), // Navigate to success page
                    ));
                  },
                ),
              ],
            ),
          ),
          Column(
            children: [
              Divider(color: Colors.grey),
              // Help & Getting Started List Item
              ListTile(
                leading: Icon(Icons.help_outline,
                    color: Colors.blue), // Example icon
                title: Text('Help & Getting Started',
                    style: TextStyle(color: Colors.blue)),
                onTap: () {
                  // Implement what happens when the user taps on "Help & Getting Started"
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
