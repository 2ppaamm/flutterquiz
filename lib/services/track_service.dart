import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class TrackService {
  static const String baseUrl = '${AppConfig.apiBaseUrl}/api';

  static Future<List<dynamic>?> getTracks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      print('⚠️ No token found');
      return null;
    }

    print('🔐 Using Bearer Token: $token');

    final response = await http.get(
      Uri.parse('$baseUrl/tracks'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // ✅ Must start with "Bearer "
      },
    );

    print('📡 GET /tracks → Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('❌ Error: ${response.body}');
      return null;
    }
  }
}