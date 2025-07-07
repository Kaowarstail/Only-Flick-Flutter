/// Profile models extension for OnlyFlick profile editing system
/// Extends existing User model with additional properties for profile management

import 'user.dart';

/// Social links model for user profiles
class SocialLinks {
  final String? instagram;
  final String? twitter;
  final String? tiktok;
  final String? youtube;
  final String? website;

  SocialLinks({
    this.instagram,
    this.twitter,
    this.tiktok,
    this.youtube,
    this.website,
  });

  factory SocialLinks.fromJson(Map<String, dynamic> json) {
    return SocialLinks(
      instagram: json['instagram'],
      twitter: json['twitter'],
      tiktok: json['tiktok'],
      youtube: json['youtube'],
      website: json['website'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instagram': instagram,
      'twitter': twitter,
      'tiktok': tiktok,
      'youtube': youtube,
      'website': website,
    };
  }

  SocialLinks copyWith({
    String? instagram,
    String? twitter,
    String? tiktok,
    String? youtube,
    String? website,
  }) {
    return SocialLinks(
      instagram: instagram ?? this.instagram,
      twitter: twitter ?? this.twitter,
      tiktok: tiktok ?? this.tiktok,
      youtube: youtube ?? this.youtube,
      website: website ?? this.website,
    );
  }
}

/// Extended user model with profile editing capabilities
class UserProfile extends User {
  final String? bio;
  final String? avatarUrl;
  final String? bannerUrl;
  final DateTime? lastActiveAt;
  final SocialLinks? socialLinks;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isPrivate;
  final bool isOnline;
  final bool isVerified;

  UserProfile({
    required super.id,
    required super.email,
    required super.username,
    super.profilePicture,
    super.role,
    required super.createdAt,
    super.updatedAt,
    this.bio,
    this.avatarUrl,
    this.bannerUrl,
    this.lastActiveAt,
    this.socialLinks,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.isPrivate = false,
    this.isOnline = false,
    this.isVerified = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      profilePicture: json['profile_picture'] ?? json['profilePicture'],
      role: json['role'],
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') 
          ?? DateTime.now(),
      updatedAt: json['updated_at'] != null || json['updatedAt'] != null
          ? DateTime.tryParse(json['updated_at'] ?? json['updatedAt'] ?? '')
          : null,
      bio: json['bio'],
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
      bannerUrl: json['banner_url'] ?? json['bannerUrl'],
      lastActiveAt: json['last_active_at'] != null 
          ? DateTime.tryParse(json['last_active_at'])
          : null,
      socialLinks: json['social_links'] != null 
          ? SocialLinks.fromJson(json['social_links'])
          : null,
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      postsCount: json['posts_count'] ?? 0,
      isPrivate: json['is_private'] ?? false,
      isOnline: json['is_online'] ?? false,
      isVerified: json['is_verified'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'bio': bio,
      'avatar_url': avatarUrl,
      'banner_url': bannerUrl,
      'last_active_at': lastActiveAt?.toIso8601String(),
      'social_links': socialLinks?.toJson(),
      'followers_count': followersCount,
      'following_count': followingCount,
      'posts_count': postsCount,
      'is_private': isPrivate,
      'is_online': isOnline,
      'is_verified': isVerified,
    });
    return json;
  }

  UserProfile copyWith({
    String? bio,
    String? avatarUrl,
    String? bannerUrl,
    DateTime? lastActiveAt,
    SocialLinks? socialLinks,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    bool? isPrivate,
    bool? isOnline,
    bool? isVerified,
    String? username,
    String? email,
  }) {
    return UserProfile(
      id: id,
      email: email ?? this.email,
      username: username ?? this.username,
      profilePicture: profilePicture,
      role: role,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      socialLinks: socialLinks ?? this.socialLinks,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      isPrivate: isPrivate ?? this.isPrivate,
      isOnline: isOnline ?? this.isOnline,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

/// Creator profile model with subscription and earnings data
class CreatorProfile {
  final String userId;
  final String displayName;
  final double subscriptionPrice;
  final String? category;
  final bool isVerified;
  final bool acceptsCustomRequests;
  final int subscribersCount;
  final double totalEarnings;
  final double currentMonthEarnings;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CreatorProfile({
    required this.userId,
    required this.displayName,
    required this.subscriptionPrice,
    this.category,
    this.isVerified = false,
    this.acceptsCustomRequests = true,
    this.subscribersCount = 0,
    this.totalEarnings = 0.0,
    this.currentMonthEarnings = 0.0,
    required this.createdAt,
    this.updatedAt,
  });

  factory CreatorProfile.fromJson(Map<String, dynamic> json) {
    return CreatorProfile(
      userId: json['user_id']?.toString() ?? '',
      displayName: json['display_name'] ?? '',
      subscriptionPrice: (json['subscription_price'] ?? 0.0).toDouble(),
      category: json['category'],
      isVerified: json['is_verified'] ?? false,
      acceptsCustomRequests: json['accepts_custom_requests'] ?? true,
      subscribersCount: json['subscribers_count'] ?? 0,
      totalEarnings: (json['total_earnings'] ?? 0.0).toDouble(),
      currentMonthEarnings: (json['current_month_earnings'] ?? 0.0).toDouble(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'subscription_price': subscriptionPrice,
      'category': category,
      'is_verified': isVerified,
      'accepts_custom_requests': acceptsCustomRequests,
      'subscribers_count': subscribersCount,
      'total_earnings': totalEarnings,
      'current_month_earnings': currentMonthEarnings,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  CreatorProfile copyWith({
    String? displayName,
    double? subscriptionPrice,
    String? category,
    bool? isVerified,
    bool? acceptsCustomRequests,
    int? subscribersCount,
    double? totalEarnings,
    double? currentMonthEarnings,
  }) {
    return CreatorProfile(
      userId: userId,
      displayName: displayName ?? this.displayName,
      subscriptionPrice: subscriptionPrice ?? this.subscriptionPrice,
      category: category ?? this.category,
      isVerified: isVerified ?? this.isVerified,
      acceptsCustomRequests: acceptsCustomRequests ?? this.acceptsCustomRequests,
      subscribersCount: subscribersCount ?? this.subscribersCount,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      currentMonthEarnings: currentMonthEarnings ?? this.currentMonthEarnings,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// Request models for profile updates
class UpdateProfileRequest {
  final String? bio;
  final String? displayName;
  final String? username;
  final bool? isPrivate;

  UpdateProfileRequest({
    this.bio,
    this.displayName,
    this.username,
    this.isPrivate,
  });

  Map<String, dynamic> toJson() {
    return {
      'bio': bio,
      'display_name': displayName,
      'username': username,
      'is_private': isPrivate,
    };
  }
}

class SocialLinksRequest {
  final String? instagram;
  final String? twitter;
  final String? tiktok;
  final String? youtube;
  final String? website;

  SocialLinksRequest({
    this.instagram,
    this.twitter,
    this.tiktok,
    this.youtube,
    this.website,
  });

  Map<String, dynamic> toJson() {
    return {
      'instagram': instagram,
      'twitter': twitter,
      'tiktok': tiktok,
      'youtube': youtube,
      'website': website,
    };
  }
}

class UpdateCreatorRequest {
  final double? subscriptionPrice;
  final String? category;
  final String? bio;
  final bool? acceptsCustomRequests;

  UpdateCreatorRequest({
    this.subscriptionPrice,
    this.category,
    this.bio,
    this.acceptsCustomRequests,
  });

  Map<String, dynamic> toJson() {
    return {
      'subscription_price': subscriptionPrice,
      'category': category,
      'bio': bio,
      'accepts_custom_requests': acceptsCustomRequests,
    };
  }
}

/// User statistics model
class UserStats {
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final int likesCount;
  final int commentsCount;
  final double engagementRate;

  UserStats({
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
    required this.likesCount,
    required this.commentsCount,
    required this.engagementRate,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      postsCount: json['posts_count'] ?? 0,
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      engagementRate: (json['engagement_rate'] ?? 0.0).toDouble(),
    );
  }
}

/// Creator earnings model
class CreatorEarnings {
  final double totalEarnings;
  final double currentMonthEarnings;
  final double lastMonthEarnings;
  final double subscriptionEarnings;
  final double tipsEarnings;
  final double paidMessagesEarnings;
  final List<MonthlyEarning> monthlyBreakdown;

  CreatorEarnings({
    required this.totalEarnings,
    required this.currentMonthEarnings,
    required this.lastMonthEarnings,
    required this.subscriptionEarnings,
    required this.tipsEarnings,
    required this.paidMessagesEarnings,
    required this.monthlyBreakdown,
  });

  factory CreatorEarnings.fromJson(Map<String, dynamic> json) {
    return CreatorEarnings(
      totalEarnings: (json['total_earnings'] ?? 0.0).toDouble(),
      currentMonthEarnings: (json['current_month_earnings'] ?? 0.0).toDouble(),
      lastMonthEarnings: (json['last_month_earnings'] ?? 0.0).toDouble(),
      subscriptionEarnings: (json['subscription_earnings'] ?? 0.0).toDouble(),
      tipsEarnings: (json['tips_earnings'] ?? 0.0).toDouble(),
      paidMessagesEarnings: (json['paid_messages_earnings'] ?? 0.0).toDouble(),
      monthlyBreakdown: (json['monthly_breakdown'] as List<dynamic>?)
          ?.map((item) => MonthlyEarning.fromJson(item))
          .toList() ?? [],
    );
  }
}

class MonthlyEarning {
  final int month;
  final int year;
  final double amount;

  MonthlyEarning({
    required this.month,
    required this.year,
    required this.amount,
  });

  factory MonthlyEarning.fromJson(Map<String, dynamic> json) {
    return MonthlyEarning(
      month: json['month'] ?? 0,
      year: json['year'] ?? 0,
      amount: (json['amount'] ?? 0.0).toDouble(),
    );
  }
}
