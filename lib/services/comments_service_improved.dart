import '../models/content_models.dart';
import 'api_service.dart';

/// Service pour gérer les commentaires via l'API OnlyFlick
class CommentsServiceImproved {
  
  /// Récupérer les commentaires d'un contenu
  static Future<List<Comment>> getComments(int contentId, {int page = 1, int size = 20}) async {
    try {
      final response = await ApiService.get(
        '/contents/$contentId/comments?page=$page&size=$size',
        requiresAuth: false
      );

      if (response['success'] == true) {
        final commentsData = response['data']['comments'] as List? ?? 
                            response['comments'] as List? ?? [];
        
        return commentsData.map((commentJson) {
          return Comment.fromJson(commentJson as Map<String, dynamic>);
        }).toList();
      }
      
      return [];
    } catch (e) {
      print('Erreur lors de la récupération des commentaires: $e');
      return [];
    }
  }

  /// Ajouter un commentaire
  static Future<Comment?> addComment(int contentId, String content) async {
    try {
      final response = await ApiService.post(
        '/contents/$contentId/comments',
        body: {'content': content},
        requiresAuth: true
      );

      if (response['success'] == true) {
        final commentData = response['data'] ?? response;
        return Comment.fromJson(commentData as Map<String, dynamic>);
      }
      
      throw ApiException(response['error']?['message'] ?? 'Erreur lors de l\'ajout du commentaire');
    } catch (e) {
      print('Erreur lors de l\'ajout du commentaire: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Impossible d\'ajouter le commentaire');
    }
  }

  /// Supprimer un commentaire
  static Future<bool> deleteComment(int commentId) async {
    try {
      final response = await ApiService.delete(
        '/comments/$commentId',
        requiresAuth: true
      );

      return response['success'] == true;
    } catch (e) {
      print('Erreur lors de la suppression du commentaire: $e');
      return false;
    }
  }

  /// Modifier un commentaire
  static Future<Comment?> updateComment(int commentId, String content) async {
    try {
      final response = await ApiService.put(
        '/comments/$commentId',
        body: {'content': content},
        requiresAuth: true
      );

      if (response['success'] == true) {
        final commentData = response['data'] ?? response;
        return Comment.fromJson(commentData as Map<String, dynamic>);
      }
      
      return null;
    } catch (e) {
      print('Erreur lors de la modification du commentaire: $e');
      return null;
    }
  }

  /// Obtenir le nombre de commentaires d'un contenu
  static Future<int> getCommentCount(int contentId) async {
    try {
      final response = await ApiService.get(
        '/contents/$contentId/comments?page=1&size=1',
        requiresAuth: false
      );

      if (response['success'] == true) {
        return response['data']?['pagination']?['total_items'] ?? 
               response['pagination']?['total_items'] ?? 0;
      }
      
      return 0;
    } catch (e) {
      print('Erreur lors de la récupération du nombre de commentaires: $e');
      return 0;
    }
  }

  /// Marquer un commentaire comme masqué (modération)
  static Future<bool> hideComment(int commentId) async {
    try {
      final response = await ApiService.put(
        '/comments/$commentId',
        body: {'is_hidden': true},
        requiresAuth: true
      );

      return response['success'] == true;
    } catch (e) {
      print('Erreur lors du masquage du commentaire: $e');
      return false;
    }
  }
}
