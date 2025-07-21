import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class AuthService {
  static const String _baseUrl = '${AppConfig.apiBaseUrl}/api/auth';
  static const String _protectedUrl = '${AppConfig.apiBaseUrl}/api';

  /// Request an OTP for the given contact (email or phone).
  static Future<bool> sendOTP(String contact) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/request-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'contact': contact}),
    );
    return response.statusCode == 200;
  }

  /// Verify OTP and, on success, persist session data.
  static Future<Map<String, dynamic>?> verifyOTP(
      String contact, String otpCode) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'contact': contact, 'otp_code': otpCode}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      await _saveSession(data);
      final dob = data['dob']?.toString();
      return data;
    } else {
      print('❌ OTP verify failed: ${response.body}');
      return null;
    }
  }

  /// Persist session info in SharedPreferences, safely handling nulls.
  static Future<void> _saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    // Token must be a non-null String
    final token = data['token'];
    if (token == null || token.toString().isEmpty) {
      print('⚠️ Missing token in response, aborting saveSession.');
      return;
    }
    await prefs.setString('auth_token', token.toString());

    // Optional: first name
    final firstName = data['first_name']?.toString();
    if (firstName != null && firstName.isNotEmpty) {
      await prefs.setString('first_name', firstName);
    }

    // Optional: contact
    final contact = data['contact']?.toString();
    if (contact != null && contact.isNotEmpty) {
      await prefs.setString('contact', contact);
    }

    final dob = data['dob']?.toString();
    if (dob != null && dob.isNotEmpty) {
      await prefs.setString('dob', dob);
    }
    final userId = data['user_id'];
    if (userId != null) {
      await prefs.setInt('user_id', userId);
    }
    final isSub = data['is_subscriber'] == true;
    await prefs.setBool('is_subscriber', isSub);
    await prefs.setBool('is_logged_in', true);

    // Store maxile_level if present
    final maxileLevel = data['maxile_level'];
    if (maxileLevel != null) {
      await prefs.setInt('maxile_level', maxileLevel);
    }

    // Store lexile_level if present
    final gameLevel = data['game_level'];
    if (gameLevel != null) {
      await prefs.setInt('game_level', gameLevel);
    }

    // Store lives and reset date
    final lives = data['lives'];
    if (lives != null) {
      await prefs.setInt('lives', lives);
      await prefs.setString(
          'lives_last_updated', DateTime.now().toIso8601String());
    }

    // Logged-in flag
    await prefs.setBool('is_logged_in', true);
  }

  /// Check if the stored token is valid (protected endpoint test).
  static Future<bool> continueLesson(String token) async {
    final response = await http.post(
      Uri.parse('$_protectedUrl/protected'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    return response.statusCode == 200;
  }

  /// Fetch subjects (example protected API).
  static Future<List<dynamic>?> getSubjects(String token) async {
    final response = await http.get(
      Uri.parse('$_protectedUrl/subjects'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      print('❌ Failed to fetch subjects: ${response.body}');
      return null;
    }
  }

  /// Verify if subscription is still active.
  static Future<bool> isSubscriptionActive(String token) async {
    final response = await http.get(
      Uri.parse('$_protectedUrl/users/subscription/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['active'] as bool;
    }
    return false;
  }

  /// Clears all session data (logout).
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
