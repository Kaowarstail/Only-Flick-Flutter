import '../models/content_models.dart';
import 'api_service.dart';

class LikeService {
  /// Toggle like on a content (like if not liked, unlike if liked)
  static Future<bool> toggleLike(int contentId, String userId) async {
    try {
      final response = await ApiService.post(
        '/contents/$contentId/toggle-like',
        body: {
          'user_id': userId,
        },
        requiresAuth: true,
      );

      return response['liked'] ?? false;
    } catch (e) {
      print('Error toggling like: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to toggle like');
    }
  }

  /// Get likes for a content
  static Future<List<Like>> getLikes(int contentId) async {
    try {
      final response = await ApiService.get(
        '/contents/$contentId/likes',
        requiresAuth: false,
      );

      final List<dynamic> data = response['likes'] ?? response;
      return data.map((json) => Like.fromJson(json)).toList();
    } catch (e) {
      print('Error getting likes: $e');
      return [];
    }
  }

  /// Check if user liked a content
  static Future<bool> isLikedByUser(int contentId, String userId) async {
    try {
      final response = await ApiService.get(
        '/contents/$contentId/is-liked?user_id=$userId',
        requiresAuth: true,
      );

      return response['liked'] ?? false;
    } catch (e) {
      print('Error checking like status: $e');
      return false;
    }
  }

  /// Get like count for a content
  static Future<int> getLikeCount(int contentId) async {
    try {
      final response = await ApiService.get(
        '/contents/$contentId/likes/count',
        requiresAuth: false,
      );

      return response['count'] ?? 0;
    } catch (e) {
      print('Error getting like count: $e');
      return 0;
    }
  }
}
