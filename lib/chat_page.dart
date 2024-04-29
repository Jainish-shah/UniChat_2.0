import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unichat_poojan_project/main_home_page.dart';

class ChatPage extends StatefulWidget {
  final String studentId;
  ChatPage({Key? key, required this.studentId}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) {
      return;
    }
    final messageText = _controller.text;
    _controller.clear();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('chats').add({
        'text': messageText,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'userEmail': user.email,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Class Announcement"),
        backgroundColor: Color(0xFF120136), // Adjusted to match the darker shade of the background
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MainHomePage(studentId: widget.studentId)
            ),
          ),
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
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
                  if (chatSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final chatDocs = chatSnapshot.data?.docs ?? [];
                  return ListView.builder(
                    reverse: true,
                    itemCount: chatDocs.length,
                    itemBuilder: (ctx, index) {
                      bool isMe = chatDocs[index]['userId'] == currentUser?.uid;
                      return Row(
                        mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: isMe ? Colors.deepPurple[800] : Colors.grey[400],
                              borderRadius: isMe
                                  ? BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  topRight: Radius.circular(14),
                                  bottomLeft: Radius.circular(14))
                                  : BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  topRight: Radius.circular(14),
                                  bottomRight: Radius.circular(14)),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 16,
                            ),
                            margin: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            child: Column(
                              crossAxisAlignment:
                              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chatDocs[index]['userEmail'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 12, color: isMe ? Colors.grey[300] : Colors.grey[900]),
                                ),
                                Text(
                                  chatDocs[index]['text'],
                                  style: TextStyle(fontSize: 16, color: isMe ? Colors.white : Colors.grey[800]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'Send a message...',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54, width: 2),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        fillColor: Colors.black38,
                        filled: true,
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 8),
                  FloatingActionButton(
                    child: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                    backgroundColor: Colors.deepPurple[300],
                    elevation: 0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
