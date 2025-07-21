import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class QuestionService {
  static const String baseUrl = '${AppConfig.apiBaseUrl}/api';

  static Future<Map<String, dynamic>?> getQuestionsForTrack(int trackId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print('🚫 No token found.');
      return null;
    }

    final url = Uri.parse('$baseUrl/test/trackquestions/$trackId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print('📡 GET /test/trackquestions/$trackId → ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      print('❌ Error fetching questions: ${response.body}');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> submitAnswers({
    required int testId,
    required Map<String, dynamic> answers,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print('🚫 No token found');
      return null;
    }

    final url = Uri.parse('$baseUrl/test/answers');
    final body = jsonEncode({
      "test": testId,
      "answers": answers,
    });

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print('📡 POST /test/answers → ${response.statusCode}');
    print('📝 Response: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 206) {
      return jsonDecode(response.body);
    } else {
      print('❌ Error submitting answers');
      return null;
    }
  }
}
