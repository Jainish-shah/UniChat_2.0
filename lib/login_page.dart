import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unichat_poojan_project/main_home_page.dart'; // For SVG icons

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSigningIn = false;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      Navigator.pushReplacement(context as BuildContext, MaterialPageRoute(builder: (context) => MainHomePage(googleUser: googleUser,)));

      // Navigate to your app's main screen upon successful sign-in
    } catch (e) {
      // Handle sign-in error
      // Navigator.pushReplacement(context as BuildContext, MaterialPageRoute(builder: (context) => MainHomePage()));
    } finally {
      setState(() {
        _isSigningIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset(
                  'assets/loginimage1.png', // Make sure this image is in your assets directory
                  width: 400,
                  height: 300,
                ),
              ),
              SizedBox(height: 20), // Space between the image and the login button
              _isSigningIn
                  ? CircularProgressIndicator() // Show a loading indicator during sign-in
                  : ElevatedButton.icon(
                icon: Image.asset(
                  'assets/google.png', // Make sure this SVG is in your assets directory
                  height: 24,
                  width: 24,
                ),
                label: Text('Sign in with Google'),
                onPressed: _signInWithGoogle,
                style: ElevatedButton.styleFrom(
                  primary: Colors.white, // Button background color
                  onPrimary: Colors.black, // Button text color
                  minimumSize: Size(240, 40), // Button size
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}