// user_authentication_service.dart
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class UserAuthenticationService {
  final FirebaseAuth _firebaseAuth;
  static const String _baseUrl = 'https://10.252.1.17:3000/';

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
      Uri.parse('$_baseUrl/api/sessionSetup/classifyUser'),
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
      Uri.parse('$_baseUrl/api/sessionSetup/updateFirstTimeLogin'),
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
