import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:unichat_poojan_project/main_home_page.dart';
import 'package:http/http.dart' as http;

import 'chat_gpt/constants/api_consts.dart';



class ProjectChatHistoryScreen extends StatefulWidget {
  final String studentId;
  final String projectName;
  final String projectId;
  final String studentName;
  ProjectChatHistoryScreen({Key? key,required this.studentId, required this.projectName, required this.projectId, required this.studentName}) : super(key: key);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ProjectChatHistoryScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];

  String databasename = "universityatalbanyDB";

  // Future<void> _sendMessage() async {
  //   if (_controller.text.isEmpty) {
  //     return;
  //   }
  //   final messageText = _controller.text;
  //   _controller.clear();
  //
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     await FirebaseFirestore.instance.collection('chats').add({
  //       'text': messageText,
  //       'createdAt': Timestamp.now(),
  //       'userId': user.uid,
  //       'userEmail': user.email, // User's email is stored for identification
  //     });
  //   }
  // }
  // void _sendMessage() {
  //   final messageText = _controller.text;
  //   if (messageText.isEmpty) {
  //     return;
  //   }
  //   _controller.clear();
  //
  //   // Add the message to our local messages list
  //   setState(() {
  //     messages.insert(0, {
  //       'text': messageText,
  //       'email': 'user@example.com', // Replace with actual user email
  //     });
  //   });
  // }
  //



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text("${widget.projectName} (${widget.studentName})", style: TextStyle(fontSize: 18)),
        title: Text("${widget.projectName}", style: TextStyle(fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainHomePage(studentId: widget.studentId))),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (ctx, index) => ListTile(
                leading: CircleAvatar(
                  child: Text(messages[index]['sender']![0].toUpperCase()),
                ),
                title: Text(messages[index]['text']!),
                subtitle: Text(messages[index]['timestamp'].toString()),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Send a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage ,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final messageText = _controller.text;
    if (messageText.isEmpty) {
      return;
    }
    _controller.clear();

    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? 'Anonymous';

    setState(() {
      messages.insert(0, {
        'text': messageText,
        'sender': userEmail,
        'timestamp': '',
      });
    });
    sendMessageRequest(context, sendMessageText: messageText);
  }


  Future<void> sendMessageRequest(BuildContext context, {
    required String sendMessageText,
  }) async {
    if (sendMessageText.isNotEmpty) {
      final url = '$LOCALHOST/api/NativeChat/AddMessageData'; // Replace with your actual server URL
      try {
        Map message = {
          'messageData': sendMessageText,
          'sender': widget.studentId,
          'sentTime': '2024-04-23T11:18:16.000Z'
        };
        final response = await http.put(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode({
            "databasename": databasename,
            "projectID": widget.projectId,
            "message": message
          }),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          // Success response handling
          // Navigator.of(context).pushReplacement(MaterialPageRoute(
          //   builder: (context) => RegistrationSuccessPage(), // Navigate to success page
          // ));
          final result = jsonDecode(response.body);
          EasyLoading.showSuccess(result['message']);
          _controller.text = "";
          setState(() {

          });
        } else {
          // Server error handling
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error'),
              content: Text('Registration Failed: ${response.body}'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        // Error handling
        print(e.toString());
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred: $e'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } else {
      // Validation failure handling
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please enter text to send message'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }
}