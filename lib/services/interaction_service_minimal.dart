import 'package:flutter/foundation.dart';

class InteractionServiceProvider extends ChangeNotifier {
  final Map<int, bool> _likedPosts = {};
  final Map<int, int> _likeCounts = {};
  final Map<int, int> _commentCounts = {};

  bool isLiked(int contentId) => _likedPosts[contentId] ?? false;
  int getLikeCount(int contentId) => _likeCounts[contentId] ?? 0;
  int getCommentCount(int contentId) => _commentCounts[contentId] ?? 0;

  Future<void> toggleLike(int contentId) async {
    final wasLiked = _likedPosts[contentId] ?? false;
    _likedPosts[contentId] = !wasLiked;
    _likeCounts[contentId] = (_likeCounts[contentId] ?? 0) + (wasLiked ? -1 : 1);
    notifyListeners();
  }

  void initializeContent(List<dynamic> contentList) {
    for (var content in contentList) {
      if (content is Map<String, dynamic> && content['id'] != null) {
        final id = content['id'] as int;
        _likedPosts[id] = false;
        _likeCounts[id] = 0;
        _commentCounts[id] = 0;
      }
    }
    notifyListeners();
  }

  List<dynamic> getComments(int contentId) => [];

  Future<void> loadComments(int contentId) async {
    notifyListeners();
  }

  Future<void> addComment(int contentId, String text, dynamic currentUser) async {
    _commentCounts[contentId] = (_commentCounts[contentId] ?? 0) + 1;
    notifyListeners();
  }

  Future<void> deleteComment(int commentId) async {
    notifyListeners();
  }

  void reset() {
    _likedPosts.clear();
    _likeCounts.clear();
    _commentCounts.clear();
    notifyListeners();
  }
}
