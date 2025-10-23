import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class UserService {
  /// Get user subscription status and stats
  static Future<Map<String, dynamic>?> getSubscriptionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null || token.isEmpty) {
        print('No auth token found');
        return null;
      }

      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/user/subscription-status'), // ✅
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        print('Unauthorized - token may be expired');
        return null;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception in getSubscriptionStatus: $e');
      return null;
    }
  }

  /// Get user profile info
  static Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null || token.isEmpty) {
        print('No auth token found');
        return null;
      }

      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/user/profile'), // ✅
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception in getUserInfo: $e');
      return null;
    }
  }

  /// Update user profile
  static Future<Map<String, dynamic>?> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null || token.isEmpty) {
        return null;
      }

      final body = <String, dynamic>{};
      if (firstName != null) body['firstname'] = firstName;
      if (lastName != null) body['lastname'] = lastName;
      if (email != null) body['email'] = email;

      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/api/user/profile'), // ✅
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception in updateProfile: $e');
      return null;
    }
  }
}