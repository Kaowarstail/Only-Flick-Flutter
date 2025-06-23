class Creator {
  final String id;
  final String userId;
  final String username;
  final String? profilePicture;
  final String? banner;
  final String? bio;
  final String? website;
  final Map<String, dynamic>? socialLinks;
  final int subscribersCount;
  final int contentsCount;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Creator({
    required this.id,
    required this.userId,
    required this.username,
    this.profilePicture,
    this.banner,
    this.bio,
    this.website,
    this.socialLinks,
    required this.subscribersCount,
    required this.contentsCount,
    this.isFeatured = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      username: json['username'] ?? '',
      profilePicture: json['profile_picture'] ?? json['profilePicture'],
      banner: json['banner'],
      bio: json['bio'],
      website: json['website'],
      socialLinks: json['social_links'] ?? json['socialLinks'],
      subscribersCount: json['subscribers_count'] ?? json['subscribersCount'] ?? 0,
      contentsCount: json['contents_count'] ?? json['contentsCount'] ?? 0,
      isFeatured: json['is_featured'] ?? json['isFeatured'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') 
          ?? DateTime.now(),
      updatedAt: json['updated_at'] != null || json['updatedAt'] != null
          ? DateTime.tryParse(json['updated_at'] ?? json['updatedAt'] ?? '')
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': username,
      'profile_picture': profilePicture,
      'banner': banner,
      'bio': bio,
      'website': website,
      'social_links': socialLinks,
      'subscribers_count': subscribersCount,
      'contents_count': contentsCount,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class CreatorStats {
  final int totalSubscribers;
  final int totalContents;
  final int totalLikes;
  final int totalViews;
  final double totalEarnings;
  final Map<String, dynamic> monthlyStats;

  CreatorStats({
    required this.totalSubscribers,
    required this.totalContents,
    required this.totalLikes,
    required this.totalViews,
    required this.totalEarnings,
    required this.monthlyStats,
  });

  factory CreatorStats.fromJson(Map<String, dynamic> json) {
    return CreatorStats(
      totalSubscribers: json['total_subscribers'] ?? json['totalSubscribers'] ?? 0,
      totalContents: json['total_contents'] ?? json['totalContents'] ?? 0,
      totalLikes: json['total_likes'] ?? json['totalLikes'] ?? 0,
      totalViews: json['total_views'] ?? json['totalViews'] ?? 0,
      totalEarnings: (json['total_earnings'] ?? json['totalEarnings'] ?? 0).toDouble(),
      monthlyStats: json['monthly_stats'] ?? json['monthlyStats'] ?? {},
    );
  }
}
