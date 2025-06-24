import 'package:flutter/material.dart';
import '../models/content_models.dart';
import 'comment_service.dart';
import 'like_service.dart';

class ContentInteractionService with ChangeNotifier {
  // Maps pour stocker les commentaires et likes par contenu
  final Map<int, List<Comment>> _comments = {};
  final Map<int, bool> _likes = {};
  final Map<int, int> _likeCounts = {};
  final Map<int, int> _commentCounts = {};

  // Getters
  List<Comment> getComments(int contentId) {
    return _comments[contentId] ?? [];
  }

  bool isLiked(int contentId) {
    return _likes[contentId] ?? false;
  }

  int getLikeCount(int contentId) {
    return _likeCounts[contentId] ?? 0;
  }

  int getCommentCount(int contentId) {
    return _commentCounts[contentId] ?? 0;
  }

  // Méthodes pour les commentaires
  Future<void> loadComments(int contentId) async {
    try {
      final comments = await CommentService.getComments(contentId);
      _comments[contentId] = comments;
      _commentCounts[contentId] = comments.length;
      notifyListeners();
    } catch (e) {
      print('Error loading comments: $e');
    }
  }

  Future<bool> addComment(int contentId, String text) async {
    try {
      final newComment = await CommentService.addComment(contentId, text);
      if (newComment != null) {
        if (_comments[contentId] == null) {
          _comments[contentId] = [];
        }
        _comments[contentId]!.insert(0, newComment);
        _commentCounts[contentId] = (_commentCounts[contentId] ?? 0) + 1;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding comment: $e');
      return false;
    }
  }

  Future<bool> deleteComment(int contentId, int commentId) async {
    try {
      final success = await CommentService.deleteComment(commentId);
      if (success && _comments[contentId] != null) {
        _comments[contentId]!.removeWhere((comment) => comment.id == commentId);
        _commentCounts[contentId] = (_commentCounts[contentId] ?? 1) - 1;
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error deleting comment: $e');
      return false;
    }
  }

  // Méthodes pour les likes
  Future<void> loadLikeStatus(int contentId, String userId) async {
    try {
      final likeCount = await LikeService.getLikeCount(contentId);
      final isLiked = await LikeService.isLikedByUser(contentId, userId);
      
      _likeCounts[contentId] = likeCount;
      _likes[contentId] = isLiked;
      notifyListeners();
    } catch (e) {
      print('Error loading like status: $e');
    }
  }

  Future<bool> toggleLike(int contentId, String userId) async {
    try {
      final currentlyLiked = _likes[contentId] ?? false;
      final success = await LikeService.toggleLike(contentId, userId);

      if (success != currentlyLiked) {
        _likes[contentId] = success;
        _likeCounts[contentId] = (_likeCounts[contentId] ?? 0) + (success ? 1 : -1);
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error toggling like: $e');
      return false;
    }
  }

  // Méthode pour charger les statistiques d'un contenu
  Future<void> loadContentStats(int contentId, String userId) async {
    await Future.wait([
      loadComments(contentId),
      loadLikeStatus(contentId, userId),
    ]);
  }

  // Méthode pour nettoyer les données d'un contenu
  void clearContentData(int contentId) {
    _comments.remove(contentId);
    _likes.remove(contentId);
    _likeCounts.remove(contentId);
    _commentCounts.remove(contentId);
    notifyListeners();
  }

  // Méthode pour nettoyer toutes les données
  void clearAllData() {
    _comments.clear();
    _likes.clear();
    _likeCounts.clear();
    _commentCounts.clear();
    notifyListeners();
  }
}
