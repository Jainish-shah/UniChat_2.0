import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

import '../chat_gpt/constants/api_consts.dart';

class UserAuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // Replace with your actual server API endpoint URL
  // static const String _baseUrl =
  //     'https://9023-2603-7080-b1f0-6390-fcf3-a348-dfe3-7430.ngrok-free.app';

  Future<Map<String, dynamic>> classifyUser(String email) async {
    final url = Uri.parse('$LOCALHOST/api/sessionSetup/classifyUser');

    // Send the POST request
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    // Check the response status and return the JSON body if successful
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // Handle error or throw an exception
      throw Exception('Failed to classify user.');
    }
  }
}
