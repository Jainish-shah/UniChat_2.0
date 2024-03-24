import 'package:flutter/material.dart';

class GoogleDrive extends StatefulWidget {
  const GoogleDrive({super.key});

  @override
  State<GoogleDrive> createState() => _GoogleDriveState();
}

class _GoogleDriveState extends State<GoogleDrive> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Drive'),
      ),
      body: Center(
        child: Text(
          "Google Drive Widget",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
