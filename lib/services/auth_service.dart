import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config.dart';

/// Service for authentication and token management
class AuthService {
  /// Register or login with contact (email/phone)
  /// Uses your existing /api/loginInfo endpoint
  static Future<Map<String, dynamic>?> authenticate(String contact) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.apiBaseUrl}/api/loginInfo'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'contact': contact,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('Auth response: ${response.statusCode}');
      print('Auth body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Save token if present
        if (data['token'] != null) {
          await saveToken(data['token']);
          print('✅ Token saved: ${data['token'].substring(0, 20)}...');
        }
        
        // Save user data
        if (data['user'] != null && data['user']['id'] != null) {
          await saveUserId(data['user']['id']);
        }
        
        // Save email/contact for later use
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('contact', contact);
        if (contact.contains('@')) {
          await prefs.setString('email', contact);
        }
        
        return data;
      } else {
        print('❌ Auth failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error during authentication: $e');
      return null;
    }
  }

  /// Request OTP for phone/email
  static Future<Map<String, dynamic>?> requestOTP(String contact) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.apiBaseUrl}/api/auth/otp/request'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'contact': contact,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('OTP request failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error requesting OTP: $e');
      return null;
    }
  }

  /// Verify OTP and get token
  static Future<Map<String, dynamic>?> verifyOTP(String contact, String otp) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.apiBaseUrl}/api/auth/otp/verify'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'contact': contact,
              'otp': otp,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Save token
        if (data['token'] != null) {
          await saveToken(data['token']);
          print('✅ Token saved after OTP verification');
        }
        
        // Save user data
        if (data['user'] != null && data['user']['id'] != null) {
          await saveUserId(data['user']['id']);
        }
        
        return data;
      } else {
        print('OTP verification failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      return null;
    }
  }

  /// Guest token - create a guest session if backend supports it
  static Future<Map<String, dynamic>?> createGuestSession(String? contact) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.apiBaseUrl}/api/auth/guest'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              if (contact != null) 'contact': contact,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Save guest token
        if (data['token'] != null) {
          await saveToken(data['token']);
          print('✅ Guest token saved');
        }
        
        if (data['user'] != null && data['user']['id'] != null) {
          await saveUserId(data['user']['id']);
        }
        
        return data;
      } else {
        print('Guest session creation failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating guest session: $e');
      return null;
    }
  }

  /// Get the current auth token (checks both auth_token and pc_token)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    
    // First try auth_token (full token)
    final authToken = prefs.getString('auth_token');
    if (authToken != null && authToken.isNotEmpty) {
      return authToken;
    }
    
    // Fallback to pc_token (profile completion token)
    final pcToken = prefs.getString('pc_token');
    if (pcToken != null && pcToken.isNotEmpty) {
      return pcToken;
    }
    
    return null;
  }

  /// Save auth token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Clear auth token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get standard headers with authentication
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  /// Verify if the current token is valid
  static Future<bool> verifyToken() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        print('No token found');
        return false;
      }

      final headers = await getAuthHeaders();
      final response = await http
          .get(
            Uri.parse('${AppConfig.apiBaseUrl}/api/user'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        print('✅ Token is valid');
        return true;
      } else {
        print('❌ Token is invalid: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error verifying token: $e');
      return false;
    }
  }

  /// Get user ID
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  /// Save user ID
  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
  }

  /// Get current user info from API
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http
          .get(
            Uri.parse('${AppConfig.apiBaseUrl}/api/user'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Failed to get current user: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  /// Logout - clear all auth data
  static Future<void> logout() async {
    try {
      // Call backend logout endpoint if you have one
      final headers = await getAuthHeaders();
      await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/auth/logout'),
        headers: headers,
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      print('Error during logout: $e');
    }
    
    // Clear local storage
    await clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('email');
    await prefs.remove('contact');
  }
}