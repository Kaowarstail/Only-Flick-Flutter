class User {
  final String id;
  final String email;
  final String username;
  final String? profilePicture;
  final String? role; // Pour gérer les rôles utilisateur/créateur/admin
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.profilePicture,
    this.role,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'profile_picture': profilePicture,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Méthodes utilitaires pour les rôles
  bool get isAdmin => role == 'admin';
  bool get isCreator => role == 'creator';
  bool get isSubscriber => role == 'subscriber' || role == null;
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
