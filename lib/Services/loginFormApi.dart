import 'package:http/http.dart' as http;
import 'dart:convert';

import '../chat_gpt/constants/api_consts.dart';

class ApiService {
  Future<Map<String, dynamic>> updateFirstTimeLogin(String email) async {
    final url = Uri.parse(
        '$LOCALHOST/api/sessionSetup/updateFirstTimeLogin'); // Adjust path to match your actual API route.

    try {
      final response = await http.put(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // Handle the case when the server did not return a 200 OK response.
        throw Exception(
            'Failed to update user data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions thrown during the request.
      throw Exception('Failed to connect to the API: $e');
    }
  }
}
