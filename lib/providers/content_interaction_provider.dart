import 'package:flutter/foundation.dart';
import '../models/content_models.dart';
import '../services/like_service.dart';
import '../services/comment_service.dart';

class ContentInteractionProvider extends ChangeNotifier {
  // Map to store content states by content ID
  final Map<int, ContentState> _contentStates = {};

  ContentState getContentState(int contentId) {
    return _contentStates[contentId] ?? ContentState();
  }

  void setContentState(int contentId, ContentState state) {
    _contentStates[contentId] = state;
    notifyListeners();
  }

  // Toggle like for a content
  Future<void> toggleLike(Content content, String userId) async {
    final contentId = content.id;
    final currentState = getContentState(contentId);
    
    // Optimistic update
    final newIsLiked = !currentState.isLiked;
    final newLikeCount = newIsLiked 
        ? currentState.likeCount + 1 
        : currentState.likeCount - 1;
    
    setContentState(contentId, currentState.copyWith(
      isLiked: newIsLiked,
      likeCount: newLikeCount,
      isLikeLoading: true,
    ));

    try {
      final actualIsLiked = await LikeService.toggleLike(contentId, userId);
      final actualLikeCount = await LikeService.getLikeCount(contentId);
      
      setContentState(contentId, currentState.copyWith(
        isLiked: actualIsLiked,
        likeCount: actualLikeCount,
        isLikeLoading: false,
      ));
    } catch (e) {
      // Revert optimistic update on error
      setContentState(contentId, currentState.copyWith(
        isLiked: !newIsLiked,
        likeCount: currentState.likeCount,
        isLikeLoading: false,
      ));
      rethrow;
    }
  }

  // Load initial content state
  Future<void> loadContentState(Content content, String? userId) async {
    final contentId = content.id;
    
    setContentState(contentId, ContentState(
      likeCount: content.likeCount ?? 0,
      commentCount: content.commentCount ?? 0,
      isLiked: content.isLikedByCurrentUser ?? false,
      isLoading: true,
    ));

    if (userId != null) {
      try {
        final isLiked = await LikeService.isLikedByUser(contentId, userId);
        final likeCount = await LikeService.getLikeCount(contentId);
        final commentCount = await CommentService.getCommentCount(contentId);
        
        setContentState(contentId, ContentState(
          isLiked: isLiked,
          likeCount: likeCount,
          commentCount: commentCount,
          isLoading: false,
        ));
      } catch (e) {
        setContentState(contentId, ContentState(
          likeCount: content.likeCount ?? 0,
          commentCount: content.commentCount ?? 0,
          isLiked: content.isLikedByCurrentUser ?? false,
          isLoading: false,
        ));
      }
    } else {
      setContentState(contentId, ContentState(
        likeCount: content.likeCount ?? 0,
        commentCount: content.commentCount ?? 0,
        isLiked: false,
        isLoading: false,
      ));
    }
  }

  // Update comment count when a comment is added/removed
  void updateCommentCount(int contentId, int delta) {
    final currentState = getContentState(contentId);
    setContentState(contentId, currentState.copyWith(
      commentCount: currentState.commentCount + delta,
    ));
  }
}

class ContentState {
  final bool isLiked;
  final int likeCount;
  final int commentCount;
  final bool isLoading;
  final bool isLikeLoading;

  const ContentState({
    this.isLiked = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLoading = false,
    this.isLikeLoading = false,
  });

  ContentState copyWith({
    bool? isLiked,
    int? likeCount,
    int? commentCount,
    bool? isLoading,
    bool? isLikeLoading,
  }) {
    return ContentState(
      isLiked: isLiked ?? this.isLiked,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLoading: isLoading ?? this.isLoading,
      isLikeLoading: isLikeLoading ?? this.isLikeLoading,
    );
  }
}
