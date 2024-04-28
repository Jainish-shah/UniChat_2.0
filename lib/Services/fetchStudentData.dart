import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../chat_gpt/constants/api_consts.dart';

class fetchStudentDataAPI {
  Future<Map<String, dynamic>> fetchStudentData(String studentId) async {

    final url = Uri.parse('$LOCALHOST/api/students/getStudentData?databasename=universityatalbanyDB&studentId=$studentId');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load student data');
    }
  }
}
