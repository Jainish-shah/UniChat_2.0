import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/io_client.dart';
import 'package:provider/provider.dart';
import 'package:unichat_poojan_project/chat_gpt/provider/models_provider.dart';
import 'package:unichat_poojan_project/splash_page.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'instructor_login_page.dart';
import 'school_registration_page.dart';


import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ModelsProvider(),
          ),
        ],
        child: MaterialApp(
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
          debugShowCheckedModeBanner: false,
          home: splash_page(),
          builder: EasyLoading.init(),
          // home: MyHomePage(),
        )
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
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80.0), // Set the height to the desired value
          child: AppBar(
            title: Padding(
              padding: const EdgeInsets.only(top: 8.0), // Adjust the padding as needed
              child: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.login), text: 'Login'),
                  Tab(icon: Icon(Icons.school), text: 'Instructor Login'),
                  Tab(icon: Icon(Icons.app_registration), text: 'School Registration'),
                ],
                isScrollable: true, // Set to true if tabs do not fit and need to scroll
              ),
            ),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.login), text: 'Login'),
                Tab(icon: Icon(Icons.school), text: 'Instructor Login'),
                Tab(icon: Icon(Icons.app_registration), text: 'School Registration'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            LoginScreen(),
            InstructorLoginPage(),
            RegisterSchoolPage(),
          ],
        ),
      ),
    );
  }
}