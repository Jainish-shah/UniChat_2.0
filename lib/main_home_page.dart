import 'package:flutter/material.dart';
import 'package:unichat_poojan_project/home_navbar.dart';
import 'sidebar.dart';
import 'discord_widget.dart';

class MainHomePage extends StatefulWidget {
  @override
  _MainHomePageState createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomNavBar(),
      drawer: CustomSidebar(),
      body: DiscordWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        child: Icon(Icons.menu),
      ),
    );
  }
}
