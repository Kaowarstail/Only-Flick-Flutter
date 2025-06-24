import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/content_models.dart';

class LikeService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Toggle like on a content (like if not liked, unlike if liked)
  static Future<bool> toggleLike(int contentId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/content/$contentId/toggle-like'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['liked'] ?? false;
      } else {
        throw Exception('Failed to toggle like: ${response.statusCode}');
      }
    } catch (e) {
      print('Error toggling like: $e');
      throw Exception('Failed to toggle like');
    }
  }

  /// Get likes for a content
  static Future<List<Like>> getLikes(int contentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/content/$contentId/likes'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Like.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get likes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting likes: $e');
      return [];
    }
  }

  /// Check if user liked a content
  static Future<bool> isLikedByUser(int contentId, String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/content/$contentId/is-liked?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['liked'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('Error checking like status: $e');
      return false;
    }
  }

  /// Get like count for a content
  static Future<int> getLikeCount(int contentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/content/$contentId/likes/count'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error getting like count: $e');
      return 0;
    }
  }
}
