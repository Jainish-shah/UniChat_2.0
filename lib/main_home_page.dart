import 'package:flutter/material.dart';
import 'package:unichat_poojan_project/home_navbar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'discord.dart';
import 'google_drive.dart';
import 'sidebar.dart';
import 'discord_widget.dart';

enum HomePageBody {
  discord,
  portToKf,
  googleDrive,
}


class MainHomePage extends StatefulWidget {

  // MainHomePage({Key? key, this.currentUser, required GoogleSignInAccount googleUser}) : super(key: key);

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

  HomePageBody _selectedPage = HomePageBody.discord;
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
      case HomePageBody.discord:
        return DiscordWidget(channelId: _channelId);
    // Add cases for other pages...
      default:
        return Center(child: Text('No Project, Add project +'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomNavBar(),
      drawer: CustomSidebar(updateBody: _updateBody), // Pass the update function to the sidebar
      body: _getBodyWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Assuming _selectedPage is used to determine what project to add
          // Implement the logic for adding a new project
          // For now, let's just open the drawer for demonstration
          _scaffoldKey.currentState?.openDrawer();
        },
        child: Icon(Icons.add),
        tooltip: 'Add Project', // Tooltip for the FAB
      ),
    );
  }
}