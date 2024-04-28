import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:unichat_poojan_project/chat_gpt/screens/gpt_screen.dart';
import 'package:unichat_poojan_project/main.dart';
import 'package:unichat_poojan_project/profile_page.dart';

import 'Services/fetchStudentData.dart';

class CustomNavBar extends StatefulWidget implements PreferredSizeWidget {
  final String studentId;

  CustomNavBar({Key? key, required this.studentId}) : super(key: key);

  @override
  _CustomNavBarState createState() => _CustomNavBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // Customize the AppBar height as needed.
}

class _CustomNavBarState extends State<CustomNavBar> {
  bool _isSearchExpanded = false;
  final GoogleSignIn googleSignIn = GoogleSignIn(); // GoogleSignIn instance

  Future<Map<String, dynamic>>? studentData;

  @override
  void initState() {
    super.initState();
    studentData = fetchStudentDataAPI().fetchStudentData(widget.studentId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: studentData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AppBar(title: const Text('Loading...'));
        } else if (snapshot.hasError) {
          return AppBar(title: Text("Error: ${snapshot.error}"));
        }

        var user = snapshot.data?['studentData'][0];  // Assuming 'studentData' is an array

        return AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          title: Text('${user?['name'] ?? 'User'}'),
          // leading: _isSearchExpanded ? BackButton(onPressed: _toggleSearch) : null,
          actions: _buildActions(user),
        );
      },
    );
  }

  // TextField _searchTextField() {
  //   return TextField(
  //     autofocus: true,
  //     decoration: InputDecoration(
  //       hintText: "Search or type a command",
  //       border: InputBorder.none,
  //       filled: true,
  //       fillColor: Colors.white.withOpacity(0.1),
  //     ),
  //     style: TextStyle(color: Colors.white),
  //     onSubmitted: (value) => _toggleSearch(),
  //   );
  // }

  List<Widget> _buildActions(Map<String, dynamic>? user) {
    // if (_isSearchExpanded) return [];
    return [
      // IconButton(
      //   icon: Icon(Icons.search),
      //   onPressed: _toggleSearch,
      // ),
      // IconButton(
      //   icon: Image.asset("assets/ChatGPT_icon.png"), // Using the ChatGPT icon
      //   onPressed: () {
      //     // Implement your action for ChatGPT icon tap here
      //     debugPrint("ChatGPT icon tapped");
      //     Navigator.of(context).pushReplacement(MaterialPageRoute(
      //       builder: (context) => ChatScreen(studentId: widget.studentId), // Navigate to success page
      //     ));
      //   },
      // ),
      IconButton(
        icon: CircleAvatar(
          backgroundImage: user?['photoUrl'] != null
              ? NetworkImage(user?['photoUrl'])
              : AssetImage('assets/default_avatar.png') as ImageProvider, // Provide a default avatar if the URL is null
          radius: 24,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage(studentId: widget.studentId)),
          );
        },
      ),
      PopupMenuButton<int>(
        itemBuilder: (context) => [
          PopupMenuItem<int>(value: 1, child: Text('Settings')),
          PopupMenuItem<int>(value: 2, child: Text('Logout')),
        ],
        onSelected: (item) => item == 2 ? _handleSignOut() : null,
      ),
    ];
  }

  // void _toggleSearch() {
  //   setState(() {
  //     _isSearchExpanded = !_isSearchExpanded;
  //   });
  // }

  Future<void> _handleSignOut() async {
    await googleSignIn.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyHomePage()));
  }
}
