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

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Class Announcement"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainHomePage(studentId: widget.studentId))),
        ),
      ),
      body: Column(
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
                      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: isMe ? Colors.deepPurple[800] : Colors.black54,
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
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                chatDocs[index]['userEmail'],
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                chatDocs[index]['text'],
                                style: TextStyle(fontSize: 16, color: Colors.white),
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
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Send a message...',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      fillColor: Colors.black38,
                      filled: true,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  child: Icon(Icons.send),
                  onPressed: _sendMessage,
                  backgroundColor: Colors.deepPurple,
                  elevation: 0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
