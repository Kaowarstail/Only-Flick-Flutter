// Admin dashboard models matching Go backend structures

class DashboardStats {
  final int totalUsers;
  final int totalCreators;
  final int totalSubscribers;
  final double totalRevenue;
  final double monthlyRevenue;
  final double weeklyRevenue;
  final int totalContents;
  final int newUsersWeek;
  final int newUsersMonth;
  final int pendingReports;

  DashboardStats({
    required this.totalUsers,
    required this.totalCreators,
    required this.totalSubscribers,
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.weeklyRevenue,
    required this.totalContents,
    required this.newUsersWeek,
    required this.newUsersMonth,
    required this.pendingReports,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['total_users'] ?? 0,
      totalCreators: json['total_creators'] ?? 0,
      totalSubscribers: json['total_subscribers'] ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      monthlyRevenue: (json['monthly_revenue'] as num?)?.toDouble() ?? 0.0,
      weeklyRevenue: (json['weekly_revenue'] as num?)?.toDouble() ?? 0.0,
      totalContents: json['total_contents'] ?? 0,
      newUsersWeek: json['new_users_week'] ?? 0,
      newUsersMonth: json['new_users_month'] ?? 0,
      pendingReports: json['pending_reports'] ?? 0,
    );
  }
}

class RevenueStats {
  final String period;
  final double amount;
  final String date;

  RevenueStats({
    required this.period,
    required this.amount,
    required this.date,
  });

  factory RevenueStats.fromJson(Map<String, dynamic> json) {
    return RevenueStats(
      period: json['period'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] ?? '',
    );
  }
}

class UserGrowthStats {
  final String date;
  final int newUsers;
  final int totalUsers;
  final int newCreators;

  UserGrowthStats({
    required this.date,
    required this.newUsers,
    required this.totalUsers,
    required this.newCreators,
  });

  factory UserGrowthStats.fromJson(Map<String, dynamic> json) {
    return UserGrowthStats(
      date: json['date'] ?? '',
      newUsers: json['new_users'] ?? 0,
      totalUsers: json['total_users'] ?? 0,
      newCreators: json['new_creators'] ?? 0,
    );
  }
}

class ContentStats {
  final int totalContents;
  final int freeContents;
  final int premiumContents;
  final int contentsToday;
  final int contentsWeek;
  final int contentsMonth;

  ContentStats({
    required this.totalContents,
    required this.freeContents,
    required this.premiumContents,
    required this.contentsToday,
    required this.contentsWeek,
    required this.contentsMonth,
  });

  factory ContentStats.fromJson(Map<String, dynamic> json) {
    return ContentStats(
      totalContents: json['total_contents'] ?? 0,
      freeContents: json['free_contents'] ?? 0,
      premiumContents: json['premium_contents'] ?? 0,
      contentsToday: json['contents_today'] ?? 0,
      contentsWeek: json['contents_week'] ?? 0,
      contentsMonth: json['contents_month'] ?? 0,
    );
  }
}

class ReportStats {
  final int totalReports;
  final int pendingReports;
  final int resolvedReports;
  final int reportsToday;
  final int reportsWeek;

  ReportStats({
    required this.totalReports,
    required this.pendingReports,
    required this.resolvedReports,
    required this.reportsToday,
    required this.reportsWeek,
  });

  factory ReportStats.fromJson(Map<String, dynamic> json) {
    return ReportStats(
      totalReports: json['total_reports'] ?? 0,
      pendingReports: json['pending_reports'] ?? 0,
      resolvedReports: json['resolved_reports'] ?? 0,
      reportsToday: json['reports_today'] ?? 0,
      reportsWeek: json['reports_week'] ?? 0,
    );
  }
}

class TopCreatorStats {
  final String userId;
  final String username;
  final String firstName;
  final String lastName;
  final String profilePicture;
  final int subscriberCount;
  final int contentCount;
  final double monthlyRevenue;

  TopCreatorStats({
    required this.userId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.profilePicture,
    required this.subscriberCount,
    required this.contentCount,
    required this.monthlyRevenue,
  });

  factory TopCreatorStats.fromJson(Map<String, dynamic> json) {
    return TopCreatorStats(
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      profilePicture: json['profile_picture'] ?? '',
      subscriberCount: json['subscriber_count'] ?? 0,
      contentCount: json['content_count'] ?? 0,
      monthlyRevenue: (json['monthly_revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get displayName {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    }
    return username;
  }
}

class AdminDashboardData {
  final DashboardStats overview;
  final List<RevenueStats> revenueChart;
  final List<UserGrowthStats> userGrowth;
  final ContentStats contentStats;
  final ReportStats reportStats;
  final List<TopCreatorStats> topCreators;
  final DateTime generatedAt;

  AdminDashboardData({
    required this.overview,
    required this.revenueChart,
    required this.userGrowth,
    required this.contentStats,
    required this.reportStats,
    required this.topCreators,
    required this.generatedAt,
  });

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    return AdminDashboardData(
      overview: DashboardStats.fromJson(json['overview'] ?? {}),
      revenueChart: (json['revenue_chart'] as List<dynamic>?)
          ?.map((item) => RevenueStats.fromJson(item))
          .toList() ?? [],
      userGrowth: (json['user_growth'] as List<dynamic>?)
          ?.map((item) => UserGrowthStats.fromJson(item))
          .toList() ?? [],
      contentStats: ContentStats.fromJson(json['content_stats'] ?? {}),
      reportStats: ReportStats.fromJson(json['report_stats'] ?? {}),
      topCreators: (json['top_creators'] as List<dynamic>?)
          ?.map((item) => TopCreatorStats.fromJson(item))
          .toList() ?? [],
      generatedAt: DateTime.tryParse(json['generated_at'] ?? '') ?? DateTime.now(),
    );
  }
}

// Modèles pour la gestion des utilisateurs admin
class AdminUsersResponse {
  final List<AdminUserItem> users;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  AdminUsersResponse({
    required this.users,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory AdminUsersResponse.fromJson(Map<String, dynamic> json) {
    return AdminUsersResponse(
      users: (json['users'] as List<dynamic>?)
          ?.map((item) => AdminUserItem.fromJson(item))
          .toList() ?? [],
      totalCount: json['total_count'] ?? 0,
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      hasNextPage: json['has_next_page'] ?? false,
      hasPreviousPage: json['has_previous_page'] ?? false,
    );
  }
}

class AdminUserItem {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final bool isActive;
  final bool isBanned;
  final bool isEmailVerified;
  final String? profilePicture;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final int? subscriberCount;
  final int? contentCount;
  final double? monthlyRevenue;

  AdminUserItem({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.isActive,
    required this.isBanned,
    required this.isEmailVerified,
    this.profilePicture,
    required this.createdAt,
    this.lastLogin,
    this.subscriberCount,
    this.contentCount,
    this.monthlyRevenue,
  });

  factory AdminUserItem.fromJson(Map<String, dynamic> json) {
    return AdminUserItem(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? 'subscriber',
      isActive: json['is_active'] ?? true,
      isBanned: json['is_banned'] ?? false,
      isEmailVerified: json['is_email_verified'] ?? false,
      profilePicture: json['profile_picture'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      lastLogin: json['last_login'] != null 
          ? DateTime.tryParse(json['last_login'])
          : null,
      subscriberCount: json['subscriber_count'],
      contentCount: json['content_count'],
      monthlyRevenue: (json['monthly_revenue'] as num?)?.toDouble(),
    );
  }

  String get displayName {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    }
    return username;
  }

  String get roleDisplayName {
    switch (role) {
      case 'admin':
        return 'Administrateur';
      case 'creator':
        return 'Créateur';
      case 'subscriber':
        return 'Abonné';
      default:
        return role;
    }
  }

  String get statusDisplayName {
    if (isBanned) return 'Banni';
    if (!isActive) return 'Inactif';
    if (!isEmailVerified) return 'Email non vérifié';
    return 'Actif';
  }
}

class AdminUserDetails extends AdminUserItem {
  final String? biography;
  final String? banReason;
  final DateTime? bannedAt;
  final List<String> loginHistory;
  final Map<String, dynamic> stats;

  AdminUserDetails({
    required super.id,
    required super.username,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.role,
    required super.isActive,
    required super.isBanned,
    required super.isEmailVerified,
    super.profilePicture,
    required super.createdAt,
    super.lastLogin,
    super.subscriberCount,
    super.contentCount,
    super.monthlyRevenue,
    this.biography,
    this.banReason,
    this.bannedAt,
    this.loginHistory = const [],
    this.stats = const {},
  });

  factory AdminUserDetails.fromJson(Map<String, dynamic> json) {
    return AdminUserDetails(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? 'subscriber',
      isActive: json['is_active'] ?? true,
      isBanned: json['is_banned'] ?? false,
      isEmailVerified: json['is_email_verified'] ?? false,
      profilePicture: json['profile_picture'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      lastLogin: json['last_login'] != null 
          ? DateTime.tryParse(json['last_login'])
          : null,
      subscriberCount: json['subscriber_count'],
      contentCount: json['content_count'],
      monthlyRevenue: (json['monthly_revenue'] as num?)?.toDouble(),
      biography: json['biography'],
      banReason: json['ban_reason'],
      bannedAt: json['banned_at'] != null 
          ? DateTime.tryParse(json['banned_at'])
          : null,
      loginHistory: (json['login_history'] as List<dynamic>?)
          ?.cast<String>() ?? [],
      stats: json['stats'] ?? {},
    );
  }
}

// Modèles pour la gestion des contenus admin
class AdminContentsResponse {
  final List<AdminContentItem> contents;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  AdminContentsResponse({
    required this.contents,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory AdminContentsResponse.fromJson(Map<String, dynamic> json) {
    return AdminContentsResponse(
      contents: (json['contents'] as List<dynamic>?)
          ?.map((item) => AdminContentItem.fromJson(item))
          .toList() ?? [],
      totalCount: json['total_count'] ?? 0,
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      hasNextPage: json['has_next_page'] ?? false,
      hasPreviousPage: json['has_previous_page'] ?? false,
    );
  }
}

class AdminContentItem {
  final int id;
  final String creatorId;
  final String creatorName;
  final String creatorUsername;
  final String? creatorProfilePicture;
  final String title;
  final String description;
  final String type;
  final String mediaUrl;
  final String thumbnailUrl;
  final String? coverUrl;
  final String? publicId;
  final bool isPremium;
  final bool isPublished;
  final int viewCount;
  final bool isFlagged;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likesCount;
  final int commentsCount;
  final int reportsCount;

  AdminContentItem({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.creatorUsername,
    this.creatorProfilePicture,
    required this.title,
    required this.description,
    required this.type,
    required this.mediaUrl,
    required this.thumbnailUrl,
    this.coverUrl,
    this.publicId,
    required this.isPremium,
    required this.isPublished,
    required this.viewCount,
    required this.isFlagged,
    required this.createdAt,
    required this.updatedAt,
    required this.likesCount,
    required this.commentsCount,
    required this.reportsCount,
  });

  factory AdminContentItem.fromJson(Map<String, dynamic> json) {
    return AdminContentItem(
      id: json['id'] ?? 0,
      creatorId: json['creator_id'] ?? '',
      creatorName: json['creator_name'] ?? '',
      creatorUsername: json['creator_username'] ?? '',
      creatorProfilePicture: json['creator_profile_picture'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      mediaUrl: json['media_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      coverUrl: json['cover_url'],
      publicId: json['public_id'],
      isPremium: json['is_premium'] ?? false,
      isPublished: json['is_published'] ?? true,
      viewCount: json['view_count'] ?? 0,
      isFlagged: json['is_flagged'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      reportsCount: json['reports_count'] ?? 0,
    );
  }

  String get typeDisplayName {
    switch (type.toLowerCase()) {
      case 'image':
        return 'Image';
      case 'video':
        return 'Vidéo';
      case 'text':
        return 'Texte';
      case 'audio':
        return 'Audio';
      default:
        return type;
    }
  }

  String get statusDisplayName {
    if (isFlagged) return 'Signalé';
    if (!isPublished) return 'Non publié';
    return 'Publié';
  }
}

class AdminContentDetails extends AdminContentItem {
  final List<AdminContentComment> comments;
  final List<AdminContentReport> reports;
  final Map<String, dynamic> stats;

  AdminContentDetails({
    required super.id,
    required super.creatorId,
    required super.creatorName,
    required super.creatorUsername,
    super.creatorProfilePicture,
    required super.title,
    required super.description,
    required super.type,
    required super.mediaUrl,
    required super.thumbnailUrl,
    super.coverUrl,
    super.publicId,
    required super.isPremium,
    required super.isPublished,
    required super.viewCount,
    required super.isFlagged,
    required super.createdAt,
    required super.updatedAt,
    required super.likesCount,
    required super.commentsCount,
    required super.reportsCount,
    required this.comments,
    required this.reports,
    required this.stats,
  });

  factory AdminContentDetails.fromJson(Map<String, dynamic> json) {
    var baseItem = AdminContentItem.fromJson(json);
    
    return AdminContentDetails(
      id: baseItem.id,
      creatorId: baseItem.creatorId,
      creatorName: baseItem.creatorName,
      creatorUsername: baseItem.creatorUsername,
      creatorProfilePicture: baseItem.creatorProfilePicture,
      title: baseItem.title,
      description: baseItem.description,
      type: baseItem.type,
      mediaUrl: baseItem.mediaUrl,
      thumbnailUrl: baseItem.thumbnailUrl,
      coverUrl: baseItem.coverUrl,
      publicId: baseItem.publicId,
      isPremium: baseItem.isPremium,
      isPublished: baseItem.isPublished,
      viewCount: baseItem.viewCount,
      isFlagged: baseItem.isFlagged,
      createdAt: baseItem.createdAt,
      updatedAt: baseItem.updatedAt,
      likesCount: baseItem.likesCount,
      commentsCount: baseItem.commentsCount,
      reportsCount: baseItem.reportsCount,
      comments: (json['comments'] as List<dynamic>?)
          ?.map((item) => AdminContentComment.fromJson(item))
          .toList() ?? [],
      reports: (json['reports'] as List<dynamic>?)
          ?.map((item) => AdminContentReport.fromJson(item))
          .toList() ?? [],
      stats: json['stats'] ?? {},
    );
  }
}

class AdminContentComment {
  final int id;
  final int contentId;
  final String userId;
  final String username;
  final String? userProfilePicture;
  final String text;
  final DateTime createdAt;
  final bool isFlagged;

  AdminContentComment({
    required this.id,
    required this.contentId,
    required this.userId,
    required this.username,
    this.userProfilePicture,
    required this.text,
    required this.createdAt,
    required this.isFlagged,
  });

  factory AdminContentComment.fromJson(Map<String, dynamic> json) {
    return AdminContentComment(
      id: json['id'] ?? 0,
      contentId: json['content_id'] ?? 0,
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
      userProfilePicture: json['user_profile_picture'],
      text: json['text'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isFlagged: json['is_flagged'] ?? false,
    );
  }
}

class AdminContentReport {
  final int id;
  final int contentId;
  final String reporterId;
  final String reporterName;
  final String reason;
  final String status; // pending, reviewed, resolved, dismissed
  final String? resolution;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  AdminContentReport({
    required this.id,
    required this.contentId,
    required this.reporterId,
    required this.reporterName,
    required this.reason,
    required this.status,
    this.resolution,
    required this.createdAt,
    this.resolvedAt,
  });

  factory AdminContentReport.fromJson(Map<String, dynamic> json) {
    return AdminContentReport(
      id: json['id'] ?? 0,
      contentId: json['content_id'] ?? 0,
      reporterId: json['reporter_id'] ?? '',
      reporterName: json['reporter_name'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      resolution: json['resolution'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.tryParse(json['resolved_at'])
          : null,
    );
  }

  String get statusDisplayName {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'En attente';
      case 'reviewed':
        return 'Examiné';
      case 'resolved':
        return 'Résolu';
      case 'dismissed':
        return 'Rejeté';
      default:
        return status;
    }
  }
}
