// Content models matching GORM structures
import 'user_models.dart';

class Content {
  final int id;
  final String creatorId;
  final String title;
  final String? description;
  final String type; // image, video, text, etc.
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? coverUrl;
  final bool isPremium;
  final bool isPublished;
  final int viewCount;
  final bool isFlagged;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional fields for UI
  final User? creator;
  final List<Comment>? comments;
  final List<Like>? likes;
  final int? likeCount;
  final int? commentCount;
  final bool? isLikedByCurrentUser;

  Content({
    required this.id,
    required this.creatorId,
    required this.title,
    this.description,
    required this.type,
    this.mediaUrl,
    this.thumbnailUrl,
    this.coverUrl,
    this.isPremium = false,
    this.isPublished = true,
    this.viewCount = 0,
    this.isFlagged = false,
    required this.createdAt,
    required this.updatedAt,
    this.creator,
    this.comments,
    this.likes,
    this.likeCount,
    this.commentCount,
    this.isLikedByCurrentUser,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'],
      creatorId: json['creator_id'],
      title: json['title'] ?? '',
      description: json['description'],
      type: json['type'] ?? 'image',
      mediaUrl: json['media_url'],
      thumbnailUrl: json['thumbnail_url'],
      coverUrl: json['cover_url'],
      isPremium: json['is_premium'] ?? false,
      isPublished: json['is_published'] ?? true,
      viewCount: json['view_count'] ?? 0,
      isFlagged: json['is_flagged'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      creator: json['creator'] != null ? User.fromJson(json['creator']) : null,
      likeCount: json['like_count'],
      commentCount: json['comment_count'],
      isLikedByCurrentUser: json['is_liked_by_current_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'title': title,
      'description': description,
      'type': type,
      'media_url': mediaUrl,
      'thumbnail_url': thumbnailUrl,
      'cover_url': coverUrl,
      'is_premium': isPremium,
      'is_published': isPublished,
      'view_count': viewCount,
      'is_flagged': isFlagged,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isVideo => type == 'video';
  bool get isImage => type == 'image';
  bool get isText => type == 'text';
}

class Comment {
  final int id;
  final int contentId;
  final String userId;
  final String text;
  final bool isHidden;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional fields for UI
  final User? user;

  Comment({
    required this.id,
    required this.contentId,
    required this.userId,
    required this.text,
    this.isHidden = false,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      contentId: json['content_id'],
      userId: json['user_id'],
      text: json['text'] ?? '',
      isHidden: json['is_hidden'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content_id': contentId,
      'user_id': userId,
      'text': text,
      'is_hidden': isHidden,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Like {
  final int id;
  final int contentId;
  final String userId;
  final DateTime createdAt;

  // Additional fields for UI
  final User? user;

  Like({
    required this.id,
    required this.contentId,
    required this.userId,
    required this.createdAt,
    this.user,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      id: json['id'],
      contentId: json['content_id'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content_id': contentId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
