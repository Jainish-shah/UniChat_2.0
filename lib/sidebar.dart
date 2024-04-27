import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unichat_poojan_project/main_home_page.dart';
import 'chat_page.dart';
import 'google_drive.dart'; // If you plan to use SVG icons

class CustomSidebar extends StatefulWidget {
  final Function(HomePageBody) updateBody;

  CustomSidebar({required this.updateBody});
  @override
  _CustomSidebarState createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {


  @override
  Widget build(BuildContext context) {
    // Theme data to dynamically change theme properties
    var currentTheme = Theme.of(context);
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // To space out the top and bottom sections
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
                    widget.updateBody(HomePageBody.discord); // Use the callback to update the body
                    Navigator.pop(context);
                  },
                ),


                ExpansionTile(
                  leading: SvgPicture.asset('assets/icons/dvr_outlined.svg', color: Colors.white), // Example for using SVG
                  title: Text('All Projects', style: TextStyle(color: Colors.white)),
                  children: [
                    // Dynamic list of projects or other items
                  ],
                ),
                ListTile(
                  leading: Icon(Icons.flight_takeoff, color: Colors.white), // Example icon for "Port to KF"
                  title: Text('Port to KF', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    // widget.updateBody(HomePageBody.portToKf);
                    // Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.folder_open, color: Colors.white), // Example icon for "My Google Drive"
                  title: Text('My Google Drive', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    widget.updateBody(HomePageBody.googleDrive);
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => GoogleDrive(  ), // Navigate to success page
                    ));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.chat, color: Colors.white), // Chat icon
                  title: Text('Chat', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => ChatPage(), // Navigate to ChatPage without receiverId
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
                leading: Icon(Icons.help_outline, color: Colors.blue), // Example icon
                title: Text('Help & Getting Started', style: TextStyle(color: Colors.blue)),
                onTap: () {
                  // Implement what happens when the user taps on "Help & Getting Started"
                },
              ),
              ListTile(
                leading: Icon(Icons.chat, color: Colors.white), // Chat icon
                title: Text('Chat', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChatPage(), // Navigate to the ChatPage
                  ));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}