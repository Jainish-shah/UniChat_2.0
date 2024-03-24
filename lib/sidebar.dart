import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unichat_poojan_project/main_home_page.dart'; // If you plan to use SVG icons

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
                  leading: Icon(Icons.home, color: currentTheme.primaryColor),
                  title: Text('Home', style: TextStyle(color: currentTheme.primaryColor)),
                  onTap: () {
                    widget.updateBody(HomePageBody.discord); // Use the callback to update the body
                    Navigator.pop(context);
                  },
                ),


                ExpansionTile(
                  leading: SvgPicture.asset('assets/icons/dvr_outlined.svg', color: currentTheme.primaryColor), // Example for using SVG
                  title: Text('All Projects', style: TextStyle(color: currentTheme.primaryColor)),
                  children: [
                    // Dynamic list of projects or other items
                  ],
                ),
                ListTile(
                  leading: Icon(Icons.flight_takeoff, color: currentTheme.primaryColor), // Example icon for "Port to KF"
                  title: Text('Port to KF', style: TextStyle(color: currentTheme.primaryColor)),
                  onTap: () {
                    widget.updateBody(HomePageBody.portToKf);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.folder_open, color: currentTheme.primaryColor), // Example icon for "My Google Drive"
                  title: Text('My Google Drive', style: TextStyle(color: currentTheme.primaryColor)),
                  onTap: () {
                    widget.updateBody(HomePageBody.googleDrive);
                    Navigator.pop(context);
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
            ],
          ),
        ],
      ),
    );
  }
}
