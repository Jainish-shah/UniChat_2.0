// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:unichat_poojan_project/chat_gpt/constants/api_consts.dart';
// import 'package:unichat_poojan_project/main_home_page.dart';
// import 'dart:developer';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'Services/UserAuthenticationService.dart';
// import 'loginform.dart'; // For SVG icons
// import 'package:http/http.dart' as http;
//
// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//
//   // Future<void> updatePhotoUrl(String email, String photoUrl) async {
//   //   String apiUrl = '$LOCALHOST/api/students/updatePhotoUrl';
//   //
//   //   try {
//   //     final response = await http.put(
//   //       Uri.parse(apiUrl),
//   //       headers: <String, String>{
//   //         'Content-Type': 'application/json',
//   //       },
//   //       body: jsonEncode({
//   //         'databasename': "universityatalbanyDB",
//   //         'studentemail': email,
//   //         'photoUrl': photoUrl,
//   //       }),
//   //     );
//   //
//   //     if (response.statusCode == 200) {
//   //       final data = jsonDecode(response.body);
//   //       Fluttertoast.showToast(
//   //         msg: data['message'],
//   //         backgroundColor: Colors.green,
//   //         textColor: Colors.white,
//   //       );
//   //     } else {
//   //       Fluttertoast.showToast(
//   //         msg: "Failed to update photo URL: ${response.body}",
//   //         backgroundColor: Colors.red,
//   //         textColor: Colors.white,
//   //       );
//   //     }
//   //   } catch (e) {
//   //     print(e); // Print the error to the console.
//   //     Fluttertoast.showToast(
//   //       msg: "Error updating photo URL: $e",
//   //       backgroundColor: Colors.red,
//   //       textColor: Colors.white,
//   //     );
//   //   }
//   // }
//
//   bool _isSigningIn = false;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//
//   Future<void> _signInWithGoogle() async {
//     setState(() {
//       _isSigningIn = true;
//     });
//
//     try {
//       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//       if (googleUser == null) {
//         setState(() {
//           _isSigningIn = false;
//         });
//         Fluttertoast.showToast(
//             msg: "Google sign-in was aborted",
//             toastLength: Toast.LENGTH_LONG,
//             gravity: ToastGravity.BOTTOM,
//             timeInSecForIosWeb: 5,
//             backgroundColor: Colors.red,
//             textColor: Colors.white,
//             fontSize: 16.0
//         );
//         return; // User cancelled the sign-in process, exit the function.
//       }
//       final GoogleSignInAuthentication googleAuth =
//       await googleUser.authentication;
//
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth?.accessToken,
//         idToken: googleAuth?.idToken,
//       );
//       await FirebaseAuth.instance.signInWithCredential(credential);
//
//       // Instantiate your user authentication service
//       final authService = UserAuthenticationService();
//
//       // Call your classifyUser function with the user's email
//       final userInfo = await authService.classifyUser(googleUser.email);
//
//       // Check the user type and act accordingly
//       if (userInfo['type'] == 'Registered') {
//         if (userInfo['isFirstTimeLogin']) {
//           // await updatePhotoUrl(googleUser.email, googleUser.photoUrl);
//           Navigator.pushReplacement(
//               context, MaterialPageRoute(builder: (context) => loginform(studentId: userInfo['studentId'])));
//         } else {
//           // await updatePhotoUrl(googleUser.email, googleUser.photoUrl);
//           // Navigate to main home page
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => MainHomePage(studentId: userInfo['studentId']),
//             ),
//           );
//         }
//       } else {
//         // Handle unregistered user case
//         Fluttertoast.showToast(
//             msg: "User is Not Authorized",
//             toastLength: Toast.LENGTH_LONG,
//             gravity: ToastGravity.BOTTOM,
//             timeInSecForIosWeb: 5,
//             backgroundColor: Colors.red,
//             textColor: Colors.white,
//             fontSize: 16.0
//         );
//         // Sign out from current Google account and allow re-sign in
//         await _googleSignIn.signOut();
//       }
//     } catch (error) {
//       _showSignInError(context, error.toString());
//     } finally {
//       if (!mounted) return;
//       setState(() {
//         _isSigningIn = false;
//       });
//     }
//   }
//
//   void _showSignInError(BuildContext context, String errorMessage) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Sign In Error'),
//         content: Text(errorMessage),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Image.asset(
//                   'assets/loginimage1.png', // Make sure this image is in your assets directory
//                   width: 400,
//                   height: 300,
//                 ),
//               ),
//               SizedBox(
//                   height: 20), // Space between the image and the login button
//               _isSigningIn
//                   ? CircularProgressIndicator() // Show a loading indicator during sign-in
//                   : ElevatedButton.icon(
//                 icon: Image.asset(
//                   'assets/google.png', // Make sure this SVG is in your assets directory
//                   height: 24,
//                   width: 24,
//                 ),
//                 label: Text('Sign in with Google'),
//                 onPressed: _signInWithGoogle,
//                 style: ElevatedButton.styleFrom(
//                   primary: Colors.white, // Button background color
//                   onPrimary: Colors.black, // Button text color
//                   minimumSize: Size(240, 40), // Button size
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  Future<void> updatePhotoUrl(String email, String photoUrl) async {
    String apiUrl = 'https://5dbd-208-125-91-130.ngrok-free.app/api/students/updatePhotoUrl';
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
                child: Image.asset('assets/loginimage1.png', width: 400, height: 300),
              ),
              SizedBox(height: 20),
              _isSigningIn
                  ? CircularProgressIndicator()
                  : ElevatedButton.icon(
                icon: Image.asset('assets/google.png', height: 24, width: 24),
                label: Text('Sign in with Google'),
                onPressed: _signInWithGoogle,
                style: ElevatedButton.styleFrom(
                  // primary: Colors.white,
                  // onPrimary: Colors.black,
                  minimumSize: Size(240, 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
