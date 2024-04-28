import 'package:flutter/material.dart';
import 'package:unichat_poojan_project/chat_page.dart';
import 'package:unichat_poojan_project/chat_page2.dart';
import 'package:unichat_poojan_project/home_navbar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:unichat_poojan_project/project_listing.dart';
import 'discord.dart';
import 'google_drive.dart';
import 'sidebar.dart';

enum HomePageBody {
  MainHomePage,
  portToKf,
  googleDrive,
  chat,
  chat2,
}

class MainHomePage extends StatefulWidget {
  final String studentId;

  MainHomePage({Key? key, required this.studentId,}) : super(key: key);

  @override
  _MainHomePageState createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {

  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  //
  // HomePageBody _selectedPage = HomePageBody.discord;
  //
  // void _updateBody(HomePageBody selectedPage) {
  //   setState(() {
  //     _selectedPage = selectedPage;
  //   });
  // }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomePageBody _selectedPage = HomePageBody.MainHomePage;
  String _channelId = "0"; // Set the default or fetch dynamically

  void _updateBody(HomePageBody selectedPage) {
    setState(() {
      _selectedPage = selectedPage;
    });
  }

  // Widget _getBodyWidget() {
  //   switch (_selectedPage) {
  //     case HomePageBody.discord:
  //       return DiscordWidget();
  //     case HomePageBody.portToKf:
  //     //  return PortToKfWidget();
  //     case HomePageBody.googleDrive:
  //       return GoogleDrive();
  //     default:
  //       return DiscordWidget();
  //   }
  // }


  // Widget _getBodyWidget() {
  //   switch (_selectedPage) {
  //     case HomePageBody.discord:
  //        return DiscordWidget();
  //     case HomePageBody.portToKf:
  //     // return PortToKfWidget(); // Uncomment and provide the appropriate widget
  //       break; // Added a break statement to prevent fall-through
  //     case HomePageBody.googleDrive:
  //       return GoogleDrive(); // Assuming GoogleDrive is a widget that shows the drive files
  //     default:
  //       return Center(child: Text('No Project, Add project +')); // Default message when no projects are available
  //   }
  //   // If no page is selected or the selected page case isn't handled, show this message
  //   return Center(child: ElevatedButton(
  //     onPressed: () {a
  //       // TODO: Implement project addition logic
  //     },
  //     child: Text('No Project, Add project +'),
  //   ));
  // }

  Widget _getBodyWidget() {
    switch (_selectedPage) {
      case HomePageBody.MainHomePage:
        return ProjectListingPage(studentId: widget.studentId);
      case HomePageBody.chat2:
        return ChatPage2(studentId: widget.studentId);
      case HomePageBody.googleDrive:
         return GoogleDrive(studentId: widget.studentId);
      case HomePageBody.chat :
         return ChatPage(studentId: widget.studentId);
      case HomePageBody.chat2 :
         return ChatPage2(studentId: widget.studentId);
      default:
        return Center(child: Text('No Project, Add project +'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomNavBar(studentId: widget.studentId),
      drawer: CustomSidebar(updateBody: _updateBody, studentId: widget.studentId), // Pass the update function to the sidebar
      body: _getBodyWidget(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Assuming _selectedPage is used to determine what project to add
      //     // Implement the logic for adding a new project
      //     // For now, let's just open the drawer for demonstration
      //     _scaffoldKey.currentState?.openDrawer();
      //   },
      //   child: Icon(Icons.add),
      //   tooltip: 'Add Project', // Tooltip for the FAB
      // ),
    );
  }
}