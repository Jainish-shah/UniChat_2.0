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
        backgroundColor: Color(0xFF120136), // Adjusted to match the darker shade of the background
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
        child: FutureBuilder<Map<String, dynamic>>(
          future: studentData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            var user = snapshot.data?['studentData'][0]; // Assuming 'studentData' is an array

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
                    color: Colors.white.withOpacity(0.3), // Semi-transparent card to match the background
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person, color: Colors.white),
                            title: Text('Name: ${user?['name'] ?? 'Not Available'}', style: TextStyle(color: Colors.white)),
                          ),
                          ListTile(
                            leading: const Icon(Icons.email, color: Colors.white),
                            title: Text('Email: ${user?['email'] ?? 'Not Available'}', style: TextStyle(color: Colors.white)),
                          ),
                          // Add more ListTiles for other information as needed
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
