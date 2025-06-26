import '../models/content_models.dart';
import 'api_service.dart';

class CommentService {
  /// Get comments for a content
  static Future<List<Comment>> getComments(int contentId, {int page = 1, int size = 20}) async {
    try {
      final response = await ApiService.get(
        '/contents/$contentId/comments?page=$page&size=$size',
        requiresAuth: false
      );

      // L'API Go retourne directement { "comments": [...], "pagination": {...} }
      final commentsData = response['comments'] as List? ?? [];
      return commentsData.map((commentJson) => Comment.fromJson(commentJson)).toList();
    } catch (e) {
      print('Error getting comments: $e');
      return [];
    }
  }

  /// Add a comment to content
  static Future<Comment?> addComment(int contentId, String text) async {
    try {
      final response = await ApiService.post(
        '/contents/$contentId/comments',
        body: {'content': text},
        requiresAuth: true
      );

      // L'API Go retourne directement l'objet commentaire créé
      return Comment.fromJson(response);
    } catch (e) {
      print('Error adding comment: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de l\'ajout du commentaire');
    }
  }

  /// Delete a comment
  static Future<bool> deleteComment(int commentId) async {
    try {
      final response = await ApiService.delete(
        '/comments/$commentId',
        requiresAuth: true
      );

      // L'API Go retourne { "message": "Commentaire supprimé avec succès" }
      return response['message'] != null;
    } catch (e) {
      print('Error deleting comment: $e');
      return false;
    }
  }

  /// Update a comment
  static Future<Comment?> updateComment(int commentId, String text) async {
    try {
      final response = await ApiService.put(
        '/comments/$commentId',
        body: {'content': text},
        requiresAuth: true
      );

      // L'API Go retourne directement l'objet commentaire mis à jour
      return Comment.fromJson(response);
    } catch (e) {
      print('Error updating comment: $e');
      return null;
    }
  }

  /// Get comment count for a content
  static Future<int> getCommentCount(int contentId) async {
    try {
      final response = await ApiService.get(
        '/contents/$contentId/comments?page=1&size=1',
        requiresAuth: false
      );

      // L'API Go retourne { "pagination": { "total_items": X } }
      return response['pagination']?['total_items'] ?? 0;
    } catch (e) {
      print('Error getting comment count: $e');
      return 0;
    }
  }
}
