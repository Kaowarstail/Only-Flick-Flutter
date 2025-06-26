// User models matching GORM structures

enum UserRole {
  admin,
  creator,
  subscriber,
}

class User {
  final String id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final UserRole role;
  final String? biography;
  final String? profilePicture;
  final bool isActive;
  final bool isBanned;
  final String? banReason;
  final bool isEmailVerified;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.role = UserRole.subscriber,
    this.biography,
    this.profilePicture,
    this.isActive = true,
    this.isBanned = false,
    this.banReason,
    this.isEmailVerified = false,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      role: _parseUserRole(json['role']),
      biography: json['biography'],
      profilePicture: json['profile_picture'],
      isActive: json['is_active'] ?? true,
      isBanned: json['is_banned'] ?? false,
      banReason: json['ban_reason'],
      isEmailVerified: json['is_email_verified'] ?? false,
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role.name,
      'biography': biography,
      'profile_picture': profilePicture,
      'is_active': isActive,
      'is_banned': isBanned,
      'ban_reason': banReason,
      'is_email_verified': isEmailVerified,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static UserRole _parseUserRole(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'creator':
        return UserRole.creator;
      case 'subscriber':
      default:
        return UserRole.subscriber;
    }
  }

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return username;
  }

  bool get isCreator => role == UserRole.creator;
  bool get isAdmin => role == UserRole.admin;
  bool get isSubscriber => role == UserRole.subscriber;
}

class CreatorProfile {
  final int id;
  final String userId;
  final String? bannerImage;
  final String? websiteUrl;
  final String? socialLinks;
  final DateTime createdAt;
  final DateTime updatedAt;

  CreatorProfile({
    required this.id,
    required this.userId,
    this.bannerImage,
    this.websiteUrl,
    this.socialLinks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CreatorProfile.fromJson(Map<String, dynamic> json) {
    return CreatorProfile(
      id: json['id'],
      userId: json['user_id'],
      bannerImage: json['banner_image'],
      websiteUrl: json['website_url'],
      socialLinks: json['social_links'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'banner_image': bannerImage,
      'website_url': websiteUrl,
      'social_links': socialLinks,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
