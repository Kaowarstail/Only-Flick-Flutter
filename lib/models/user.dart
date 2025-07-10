class User {
  final String id;
  final String email;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? bio;
  final String? profilePicture;
  final String? role; // Pour gérer les rôles utilisateur/créateur/admin
  final bool isPrivate;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.firstName,
    this.lastName,
    this.bio,
    this.profilePicture,
    this.role,
    this.isPrivate = false,
    this.isVerified = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? json['firstName'],
      lastName: json['last_name'] ?? json['lastName'],
      bio: json['bio'],
      profilePicture: json['profile_picture'] ?? json['profilePicture'] ?? json['avatar_url'],
      role: json['role'],
      isPrivate: json['is_private'] ?? json['isPrivate'] ?? false,
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
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
      'email': email,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'bio': bio,
      'profile_picture': profilePicture,
      'avatar_url': profilePicture,
      'role': role,
      'is_private': isPrivate,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Méthodes utilitaires pour les rôles
  bool get isAdmin => role == 'admin';
  bool get isCreator => role == 'creator';
  bool get isSubscriber => role == 'subscriber' || role == null;

  // Méthodes utilitaires pour la messagerie
  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (firstName != null) {
      return firstName!;
    }
    return username;
  }

  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    }
    return username[0].toUpperCase();
  }

  String get avatarUrl => profilePicture ?? '';

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? bio,
    String? profilePicture,
    String? role,
    bool? isPrivate,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      bio: bio ?? this.bio,
      profilePicture: profilePicture ?? this.profilePicture,
      role: role ?? this.role,
      isPrivate: isPrivate ?? this.isPrivate,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User(id: $id, username: $username, role: $role)';
}

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}
