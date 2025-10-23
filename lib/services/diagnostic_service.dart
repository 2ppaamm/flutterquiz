import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config.dart';
import 'auth_service.dart';

/// Response type enum
enum DiagnosticResponseType {
  questions,  // Navigate to diagnostic_screen
  results,    // Navigate to result_screen
  outOfLives, // Show out of lives screen
  error,      // Show error
  unknown,    // Handle as needed
}

class DiagnosticService {
  /// Store user hint (birthdate, age, or grade)
  static Future<Map<String, dynamic>?> storeHint(Map<String, dynamic> hint) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/diagnostic/hint'),
        headers: headers,
        body: jsonEncode(hint),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) {
        await AuthService.clearToken();
        return null;
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error storing hint: $e');
      }
      return null;
    }
  }

  /// Get diagnostic status
  static Future<Map<String, dynamic>?> getStatus() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/diagnostic/status'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) {
        await AuthService.clearToken();
        return null;
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting diagnostic status: $e');
      }
      return null;
    }
  }

  /// Common method for both starting and continuing diagnostic
  /// Returns questions, results, or lives data based on backend response
  static Future<Map<String, dynamic>?> _diagnosticRequest({
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/diagnostic/$endpoint'),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('✅ Diagnostic $endpoint Response: ${response.statusCode}');
        print('📦 Response Body: ${response.body}');
      }

      // Handle authentication error
      if (response.statusCode == 401) {
        await AuthService.clearToken();
        return null;
      }

      // ✅ HANDLE 403 - Out of Lives
      if (response.statusCode == 403) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (kDebugMode) {
          print('⚠️ Out of lives: ${data['message']}');
        }
        return data; // Return lives data even though status is 403
      }

      // Handle success
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      
      if (kDebugMode) {
        print('❌ Diagnostic request failed: ${response.statusCode}');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Diagnostic request error: $e');
      }
      return null;
    }
  }

  /// Helper to determine response type
  static DiagnosticResponseType getResponseType(Map<String, dynamic>? data) {
    if (data == null) return DiagnosticResponseType.error;
    
    // Check if out of lives (ok: false with lives data)
    if (data.containsKey('ok') && data['ok'] == false) {
      if (data.containsKey('can_answer') && data['can_answer'] == false) {
        return DiagnosticResponseType.outOfLives;
      }
    }
    
    // Check if there are questions (more questions to answer)
    if (data.containsKey('questions') && data['questions'] != null) {
      final questions = data['questions'];
      if (questions is List && questions.isNotEmpty) {
        return DiagnosticResponseType.questions;
      }
    }
    
    // Check for next_questions (after submission)
    if (data.containsKey('next_questions') && data['next_questions'] != null) {
      final questions = data['next_questions'];
      if (questions is List && questions.isNotEmpty) {
        return DiagnosticResponseType.questions;
      }
    }
    
    // Check if diagnostic is completed with results
    if (data.containsKey('diagnostic_completed') && data['diagnostic_completed'] == true) {
      return DiagnosticResponseType.results;
    }
    
    // Also check for 'results' or 'result' key as fallback
    if (data.containsKey('results') || data.containsKey('result')) {
      return DiagnosticResponseType.results;
    }
    
    return DiagnosticResponseType.unknown;
  }

  /// Start diagnostic test - gets first batch of questions
  static Future<Map<String, dynamic>?> startDiagnostic() async {
    return _diagnosticRequest(endpoint: 'start');
  }

  /// Submit diagnostic answers - gets next batch or results
  static Future<Map<String, dynamic>?> submitDiagnostic(
    int sessionId,
    List<Map<String, dynamic>> answers,
  ) async {
    return _diagnosticRequest(
      endpoint: 'submit',
      body: {
        'session_id': sessionId,
        'answers': answers,
      },
    );
  }

  /// Get diagnostic result
  static Future<Map<String, dynamic>?> getResult() async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/diagnostic/result'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) {
        await AuthService.clearToken();
        return null;
      }

      // ✅ HANDLE 403 - Out of Lives
      if (response.statusCode == 403) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (kDebugMode) {
          print('⚠️ Out of lives when getting result: ${data['message']}');
        }
        return data;
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting result: $e');
      }
      return null;
    }
  }

  /// Abandon incomplete diagnostic
  static Future<bool> abandonDiagnostic(int sessionId) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/diagnostic/abandon/$sessionId'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) {
        await AuthService.clearToken();
        return false;
      }

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('✅ Diagnostic abandoned successfully');
        }
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error abandoning diagnostic: $e');
      }
      return false;
    }
  }
}