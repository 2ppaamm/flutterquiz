import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config.dart';

class QuestionService {
  /// Get questions for a specific track (Browse Topics)
  static Future<Map<String, dynamic>?> getQuestionsForTrack(String trackId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token == null) {
      print('❌ No token found');
      return null;
    }

    try {
      // FIXED: Correct endpoint /tracks/{track}/questions
      final url = Uri.parse('${AppConfig.apiBaseUrl}/api/tracks/$trackId/questions');
      print('📡 GET $url');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📥 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Questions loaded: ${data['questions']?.length ?? 0}');
        return data;
      } else if (response.statusCode == 403) {
        print('🔒 403 - Premium required');
        return {'error': 'premium_required'};
      } else if (response.statusCode == 205) {
        // Out of lives
        final data = json.decode(response.body);
        return data;
      } else {
        print('❌ Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception in getQuestionsForTrack: $e');
      return null;
    }
  }

  /// Start Kiasu Path (adaptive AI-guided practice)
  static Future<Map<String, dynamic>?> startKiasuPath() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token == null) {
      print('❌ No token found');
      return null;
    }

    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}/api/kiasu-path/start');
      print('📡 GET $url');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📥 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Kiasu Path started: ${data['questions']?.length ?? 0} questions');
        
        // Save that user has started Kiasu Path
        await prefs.setBool('has_started_kiasu_path', true);
        
        return data;
      } else if (response.statusCode == 403) {
        print('🔒 403 - Premium required');
        return {'error': 'premium_required', 'code': 403};
      } else if (response.statusCode == 205) {
        // Out of lives
        final data = json.decode(response.body);
        return data;
      } else {
        print('❌ Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception in startKiasuPath: $e');
      return null;
    }
  }

  /// Continue Kiasu Path (get next set of questions)
  static Future<Map<String, dynamic>?> continueKiasuPath() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token == null) {
      print('❌ No token found');
      return null;
    }

    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}/api/kiasu-path/continue');
      print('📡 GET $url');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📥 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Kiasu Path continued: ${data['questions']?.length ?? 0} questions');
        return data;
      } else if (response.statusCode == 403) {
        print('🔒 403 - Premium required');
        return {'error': 'premium_required', 'code': 403};
      } else {
        print('❌ Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception in continueKiasuPath: $e');
      return null;
    }
  }

  /// Submit answers for questions
  static Future<Map<String, dynamic>?> submitAnswers(
    List<Map<String, dynamic>> answers,
    String sessionType, // 'kiasu_path' or 'track'
    String? trackId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token == null) {
      print('❌ No token found');
      return null;
    }

    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}/api/questions/submit');
      print('📡 POST $url');
      
      final body = {
        'answers': answers,
        'session_type': sessionType,
        if (trackId != null) 'track_id': trackId,
      };
      
      print('📤 Submitting ${answers.length} answers');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      print('📥 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Answers submitted successfully');
        return data;
      } else {
        print('❌ Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception in submitAnswers: $e');
      return null;
    }
  }
}