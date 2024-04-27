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
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        Fluttertoast.showToast(msg: "Google sign-in was aborted");
        setState(() {
          _isSigningIn = false;
        });
        return;
      }

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
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => loginform(studentId: userInfo['studentId'])));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainHomePage(studentId: userInfo['studentId'])));
          }
        } else {
          Fluttertoast.showToast(msg: "User is Not Authorized");
          await _googleSignIn.signOut();
        }
      }
    } catch (error) {
      Fluttertoast.showToast(msg: "Sign in failed: $error");
      // Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => MainHomePage(studentId: "66229420d1498ccc2e429dea"),
      //         ),
      //       );
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