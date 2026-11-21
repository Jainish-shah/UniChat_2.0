import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../constants/api_consts.dart';
import '../models/chat_model.dart';
import '../models/model_model.dart';

/// AI calls are proxied through the UniChat realtime server, authenticated with the
/// user's Firebase ID token. No provider API key is ever shipped in the app.
class ApiService {
  static Future<Map<String, String>> _headers() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw const HttpException('Please sign in to use the AI assistant');
    return {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
  }

  static Map _decode(http.Response response) {
    final Map json = jsonDecode(response.body);
    if (response.statusCode >= 400 || json['error'] != null) {
      throw HttpException('${json['error'] ?? 'AI request failed (${response.statusCode})'}');
    }
    return json;
  }

  /// Logical modes offered by the server: chat | vision | image (root = display label).
  static Future<List<ModelsModel>> getModels() async {
    try {
      final response = await http.get(Uri.parse('$AI_SERVER_URL/api/ai/models'), headers: await _headers());
      final json = _decode(response);
      return ModelsModel.modelsFromSnapshot(
          (json['models'] as List).map((m) => {'id': m['id'], 'root': m['label'], 'created': 0}).toList());
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }

  /// Sends a single prompt. In "image" mode an image URL is returned (isURL = 1).
  static Future<List<ChatModel>> sendMessage({required String message, required String modelId}) async {
    try {
      final response = await http.post(
        Uri.parse('$AI_SERVER_URL/api/ai/complete'),
        headers: await _headers(),
        body: jsonEncode({'message': message, 'model': modelId}),
      );
      final json = _decode(response);
      if (json['type'] == 'image') {
        return [ChatModel(msg: '${json['url']}', chatIndex: 1, isURL: 1)];
      }
      return [ChatModel(msg: '${json['reply']}', chatIndex: 1, isURL: 0)];
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }

  /// Ask a question about an image (base64 without the data: prefix).
  static Future<String> askAboutImage({required String imageBase64, required String prompt}) async {
    final response = await http.post(
      Uri.parse('$AI_SERVER_URL/api/ai/vision'),
      headers: await _headers(),
      body: jsonEncode({'imageBase64': imageBase64, 'prompt': prompt, 'mediaType': 'image/jpeg'}),
    );
    return '${_decode(response)['reply']}';
  }
}
