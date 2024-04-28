import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Services/fetchStudentData.dart';

class ProfilePage extends StatefulWidget {
  final String studentId;

  ProfilePage({Key? key, required this.studentId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<Map<String, dynamic>>? studentData;

  @override
  void initState() {
    super.initState();
    studentData = fetchStudentDataAPI().fetchStudentData(widget.studentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
          future: studentData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            var user = snapshot.data?['studentData'][0];  // Assuming 'studentData' is an array

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user?['photoUrl'] ?? 'https://via.placeholder.com/150'),
                    radius: 50,
                  ),
                  const SizedBox(height: 20),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person),
                            title: Text('Name: ${user?['name'] ?? 'Not Available'}'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: Text('Email: ${user?['email'] ?? 'Not Available'}'),
                          ),
                          // Assuming you have a way to fetch Discord ID or any other data
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
      ),
    );
  }
}
