import 'package:flutter/material.dart';
import 'package:unichat_poojan_project/home_navbar.dart';
import 'google_drive.dart';
import 'sidebar.dart';
import 'discord_widget.dart';

enum HomePageBody {
  discord,
  portToKf,
  googleDrive,
  // Add more as needed
}


class MainHomePage extends StatefulWidget {
  @override
  _MainHomePageState createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomePageBody _selectedPage = HomePageBody.discord;

  void _updateBody(HomePageBody selectedPage) {
    setState(() {
      _selectedPage = selectedPage;
    });
  }

  Widget _getBodyWidget() {
    switch (_selectedPage) {
      case HomePageBody.discord:
        return DiscordWidget();
      case HomePageBody.portToKf:
      //  return PortToKfWidget();
      case HomePageBody.googleDrive:
        return GoogleDrive();
      default:
        return DiscordWidget();
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
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        child: Icon(Icons.menu),
      ),
    );
  }
}