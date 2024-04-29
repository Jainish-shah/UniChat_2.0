import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:unichat_poojan_project/chat_gpt/constants/api_consts.dart';
import 'package:unichat_poojan_project/main_home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Services/UserAuthenticationService.dart';
import 'loginform.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSigningIn = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  Future<void> updatePhotoUrl(String email, String? photoUrl) async {
    String apiUrl = '$LOCALHOST/api/students/updatePhotoUrl';
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'databasename': "universityatalbanyDB",
          'studentemail': email,
          'photoUrl': photoUrl,
        }),
      );

      if (response.statusCode == 200) {
        print('Photo URL updated successfully');
      } else {
        print('Failed to update photo URL: ${response.body}');
      }
    } catch (e) {
      print('Error updating photo URL: $e');
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        Fluttertoast.showToast(msg: "Google sign-in was aborted");
        setState(() {
          _isSigningIn = false;
        });
        return;
      }

      final firebaseUser = FirebaseAuth.instance.currentUser;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        final authService = UserAuthenticationService();
        final userInfo = await authService.classifyUser(user.email!);

        if (userInfo['type'] == 'Registered') {
          if (userInfo['isFirstTimeLogin']) {
            await updatePhotoUrl(googleUser.email, firebaseUser?.photoURL);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => loginform(studentId: userInfo['studentId'])));
          } else {
            await updatePhotoUrl(googleUser.email, firebaseUser?.photoURL);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainHomePage(studentId: userInfo['studentId'])));
          }
        } else {
          Fluttertoast.showToast(msg: "User is Not Authorized");
          await _googleSignIn.signOut();
        }
      }
    } catch (error) {
      Fluttertoast.showToast(msg: "Sign in failed: $error");
      Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainHomePage(studentId: "66229420d1498ccc2e429dea"),
              ),
            );
    } finally {
      setState(() {
        _isSigningIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Bottom layer with one color
          Container(
            color: Color(0xFF16043F), // Darker shade
            height: MediaQuery.of(context).size.height,
          ),
          // Top layer with gradient to transparent
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0C0101).withOpacity(0.6), // Lighter shade with opacity
                  Colors.transparent,
                ],
              ),
            ),
            height: MediaQuery.of(context).size.height / 2, // Adjust height as needed
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'FIRST THINGS FIRST',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      letterSpacing: 7,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 50),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Image.asset('assets/loginimage1.png', width: MediaQuery.of(context).size.width * 0.8),
                        SizedBox(height: 30),
                        ElevatedButton(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset('assets/google.png', height: 35.0),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    'LOGIN WITH GOOGLE',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF6A4BBC)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.transparent),
                              ),
                            ),
                          ),
                          onPressed: _signInWithGoogle,
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
