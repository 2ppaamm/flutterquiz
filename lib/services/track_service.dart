import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'auth_service.dart';

/// Service for fetching tracks and track-related data
class TrackService {
  /// Fetch all available tracks from the API
  /// GET /api/tracks
  static Future<List<dynamic>?> getTracks() async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http
          .get(
            Uri.parse('${AppConfig.apiBaseUrl}/api/tracks'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Handle different response formats
        if (data is List) {
          return data;
        } else if (data is Map && data['tracks'] is List) {
          return data['tracks'] as List;
        } else if (data is Map && data['data'] is List) {
          return data['data'] as List;
        }
        
        return null;
      } else {
        print('Failed to fetch tracks: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching tracks: $e');
      return null;
    }
  }

  /// Fetch a specific track by ID
  /// GET /api/tracks/{id}
  static Future<Map<String, dynamic>?> getTrack(int trackId) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http
          .get(
            Uri.parse('${AppConfig.apiBaseUrl}/api/tracks/$trackId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Failed to fetch track: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching track: $e');
      return null;
    }
  }
}