import 'user.dart';

class Content {
  final int id;
  final String creatorId;
  final User? creator;
  final String title;
  final String description;
  final String type;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? coverUrl;
  final bool isPremium;
  final bool isPublished;
  final int viewCount;
  final bool isFlagged;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Comment>? comments;
  final List<Like>? likes;
  final int? likesCount;
  final int? commentsCount;

  Content({
    required this.id,
    required this.creatorId,
    this.creator,
    required this.title,
    required this.description,
    required this.type,
    this.mediaUrl,
    this.thumbnailUrl,
    this.coverUrl,
    required this.isPremium,
    required this.isPublished,
    required this.viewCount,
    required this.isFlagged,
    required this.createdAt,
    required this.updatedAt,
    this.comments,
    this.likes,
    this.likesCount,
    this.commentsCount,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'] ?? 0,
      creatorId: json['creator_id'] ?? '',
      creator: json['Creator'] != null ? User.fromJson(json['Creator']) : null,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      mediaUrl: json['media_url'],
      thumbnailUrl: json['thumbnail_url'],
      coverUrl: json['cover_url'],
      isPremium: json['is_premium'] ?? false,
      isPublished: json['is_published'] ?? false,
      viewCount: json['view_count'] ?? 0,
      isFlagged: json['is_flagged'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      comments: json['Comments'] != null 
          ? (json['Comments'] as List).map((c) => Comment.fromJson(c)).toList()
          : null,
      likes: json['Likes'] != null 
          ? (json['Likes'] as List).map((l) => Like.fromJson(l)).toList()
          : null,
      likesCount: json['likes_count'],
      commentsCount: json['comments_count'],
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
}

class Comment {
  final int id;
  final int contentId;
  final String userId;
  final User? user;
  final String text;
  final bool isHidden;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment({
    required this.id,
    required this.contentId,
    required this.userId,
    this.user,
    required this.text,
    required this.isHidden,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      contentId: json['content_id'] ?? 0,
      userId: json['user_id'] ?? '',
      user: json['User'] != null ? User.fromJson(json['User']) : null,
      text: json['text'] ?? '',
      isHidden: json['is_hidden'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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
  final User? user;
  final DateTime createdAt;

  Like({
    required this.id,
    required this.contentId,
    required this.userId,
    this.user,
    required this.createdAt,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      id: json['id'] ?? 0,
      contentId: json['content_id'] ?? 0,
      userId: json['user_id'] ?? '',
      user: json['User'] != null ? User.fromJson(json['User']) : null,
      createdAt: DateTime.parse(json['created_at']),
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

class ContentFeedResponse {
  final List<Content> contents;
  final PaginationInfo pagination;

  ContentFeedResponse({
    required this.contents,
    required this.pagination,
  });

  factory ContentFeedResponse.fromJson(Map<String, dynamic> json) {
    return ContentFeedResponse(
      contents: (json['contents'] as List)
          .map((content) => Content.fromJson(content))
          .toList(),
      pagination: PaginationInfo.fromJson(json['pagination']),
    );
  }
}

class PaginationInfo {
  final int page;
  final int size;
  final int totalItems;
  final int totalPages;

  PaginationInfo({
    required this.page,
    required this.size,
    required this.totalItems,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] ?? 1,
      size: json['size'] ?? 10,
      totalItems: json['total_items'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
    );
  }
}

// FeedItem représente un élément du fil d'actualité avec métadonnées étendues
class FeedItem {
  final int id;
  final String creatorId;
  final FeedCreator creator;
  final String title;
  final String description;
  final String type;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final int viewCount;
  final int likesCount;
  final int commentsCount;
  final bool isLikedByUser;
  final DateTime createdAt;
  final DateTime updatedAt;

  FeedItem({
    required this.id,
    required this.creatorId,
    required this.creator,
    required this.title,
    required this.description,
    required this.type,
    this.mediaUrl,
    this.thumbnailUrl,
    required this.viewCount,
    required this.likesCount,
    required this.commentsCount,
    required this.isLikedByUser,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      id: json['id'] ?? 0,
      creatorId: json['creator_id'] ?? '',
      creator: FeedCreator.fromJson(json['creator'] ?? {}),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      mediaUrl: json['media_url'],
      thumbnailUrl: json['thumbnail_url'],
      viewCount: json['view_count'] ?? 0,
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      isLikedByUser: json['is_liked_by_user'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'creator': creator.toJson(),
      'title': title,
      'description': description,
      'type': type,
      'media_url': mediaUrl,
      'thumbnail_url': thumbnailUrl,
      'view_count': viewCount,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_liked_by_user': isLikedByUser,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// FeedCreator représente les informations simplifiées du créateur dans le feed
class FeedCreator {
  final String id;
  final String username;
  final String? profilePicture;
  final String role;

  FeedCreator({
    required this.id,
    required this.username,
    this.profilePicture,
    required this.role,
  });

  factory FeedCreator.fromJson(Map<String, dynamic> json) {
    return FeedCreator(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      profilePicture: json['profile_picture'],
      role: json['role'] ?? 'subscriber',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'profile_picture': profilePicture,
      'role': role,
    };
  }
}
