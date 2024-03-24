import 'package:flutter/material.dart';
import 'package:unichat_poojan_project/splash_page.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'instructor_login_page.dart';
import 'school_registration_page.dart';


void main() {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black.withOpacity(0.1),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black.withOpacity(0.1),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
        ),
      ),
      themeMode: ThemeMode.dark,
      home: splash_page(),
      // home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.login), text: 'Login'),
              Tab(icon: Icon(Icons.school), text: 'Instructor Login'),
              Tab(icon: Icon(Icons.app_registration), text: 'School Registration'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HomePage(),
            LoginScreen(),
            InstructorLoginPage(),
            RegisterSchoolPage(),
          ],
        ),
      ),
    );
  }
}
