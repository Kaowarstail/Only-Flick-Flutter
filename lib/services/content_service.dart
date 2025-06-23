import '../models/content.dart';
import '../models/user.dart';
import 'api_service.dart';

class ContentService {
  // Récupérer le fil d'actualité (contenus publics)
  static Future<ContentFeedResponse> getPublicFeed({
    int page = 1,
    int pageSize = 10,
    String? type,
    String? creatorId,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': pageSize.toString(),
      };
      
      if (type != null && type.isNotEmpty) queryParams['type'] = type;
      if (creatorId != null && creatorId.isNotEmpty) queryParams['creator_id'] = creatorId;
      
      final query = Uri(queryParameters: queryParams).query;
      final responseData = await ApiService.get('/contents?$query', requiresAuth: false);
      
      return ContentFeedResponse.fromJson(responseData);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la récupération du fil d\'actualité.');
    }
  }

  // Récupérer un contenu spécifique
  static Future<Content> getContent(int contentId) async {
    try {
      final responseData = await ApiService.get('/contents/$contentId', requiresAuth: false);
      return Content.fromJson(responseData);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la récupération du contenu.');
    }
  }

  // Récupérer les commentaires d'un contenu
  static Future<List<Comment>> getContentComments(int contentId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': pageSize.toString(),
      };
      
      final query = Uri(queryParameters: queryParams).query;
      final responseData = await ApiService.get('/contents/$contentId/comments?$query', requiresAuth: false);
      
      if (responseData['comments'] != null) {
        return (responseData['comments'] as List)
            .map((comment) => Comment.fromJson(comment))
            .toList();
      }
      return [];
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la récupération des commentaires.');
    }
  }

  // Liker un contenu
  static Future<void> likeContent(int contentId) async {
    try {
      await ApiService.post('/contents/$contentId/likes', requiresAuth: true);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de l\'ajout du like.');
    }
  }

  // Retirer un like
  static Future<void> unlikeContent(int contentId) async {
    try {
      await ApiService.delete('/contents/$contentId/likes', requiresAuth: true);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la suppression du like.');
    }
  }

  // Ajouter un commentaire
  static Future<Comment> addComment(int contentId, String text) async {
    try {
      final responseData = await ApiService.post('/contents/$contentId/comments', 
          body: {'text': text}, requiresAuth: true);
      return Comment.fromJson(responseData);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de l\'ajout du commentaire.');
    }
  }

  // Supprimer un commentaire
  static Future<void> deleteComment(int commentId) async {
    try {
      await ApiService.delete('/comments/$commentId', requiresAuth: true);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la suppression du commentaire.');
    }
  }

  // Récupérer les statistiques d'un contenu (likes, commentaires)
  static Future<Map<String, int>> getContentStats(int contentId) async {
    try {
      final responseData = await ApiService.get('/contents/$contentId/stats', requiresAuth: false);
      return {
        'likes_count': responseData['likes_count'] ?? 0,
        'comments_count': responseData['comments_count'] ?? 0,
        'views_count': responseData['views_count'] ?? 0,
      };
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la récupération des statistiques.');
    }
  }

  // Vérifier si l'utilisateur connecté a liké un contenu
  static Future<bool> hasUserLikedContent(int contentId) async {
    try {
      final responseData = await ApiService.get('/contents/$contentId/likes/check', requiresAuth: true);
      return responseData['has_liked'] ?? false;
    } catch (e) {
      if (e is ApiException) rethrow;
      return false;
    }
  }
}
