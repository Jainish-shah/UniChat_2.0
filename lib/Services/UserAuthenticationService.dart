import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

import '../chat_gpt/constants/api_consts.dart';

class UserAuthenticationService {

  Future<Map<String, dynamic>> classifyUser(String email) async {
    final url = Uri.parse('$LOCALHOST/api/sessionSetup/classifyUser');

    // Send the POST request
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to classify user.');
    }
  }
}
