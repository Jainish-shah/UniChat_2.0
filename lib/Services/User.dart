// user_authentication_service.dart
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../chat_gpt/constants/api_consts.dart';

class UserAuthenticationService {
  final FirebaseAuth _firebaseAuth;


  UserAuthenticationService(this._firebaseAuth);

  // Authentication methods
  Future<void> logoutUser() async {
    await _firebaseAuth.signOut();
  }

  User? getLoggedInUserDetails() {
    return _firebaseAuth.currentUser;
  }

  // User service methods
  Future<dynamic> classifyUser(String email) async {
    final response = await http.post(
      Uri.parse('$LOCALHOST/api/sessionSetup/classifyUser'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{'email': email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to classify user.');
    }
  }

  Future<dynamic> updateFirstTimeLogin(String email) async {
    final response = await http.put(
      Uri.parse('$LOCALHOST/api/sessionSetup/updateFirstTimeLogin'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{'email': email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update first-time login.');
    }
  }

}
