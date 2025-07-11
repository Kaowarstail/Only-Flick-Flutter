import 'user.dart';
import 'message.dart';

class Conversation {
  final String id;
  final List<User> participants;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Conversation({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id']?.toString() ?? '',
      participants: (json['participants'] as List<dynamic>? ?? [])
          .map((p) => User.fromJson(p as Map<String, dynamic>))
          .toList(),
      lastMessage: json['last_message'] != null
          ? Message.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unread_count'] ?? json['unreadCount'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') 
          ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? json['updatedAt'] ?? '') 
          ?? DateTime.now(),
      isActive: json['is_active'] ?? json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants.map((p) => p.toJson()).toList(),
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  // Helper pour obtenir l'autre participant (pas l'utilisateur actuel)
  User? getOtherParticipant(String currentUserId) {
    return participants.firstWhere(
      (participant) => participant.id != currentUserId,
      orElse: () => participants.isNotEmpty ? participants.first : participants.first,
    );
  }

  // Nom d'affichage de la conversation
  String getDisplayName(String currentUserId) {
    final otherUser = getOtherParticipant(currentUserId);
    if (otherUser != null) {
      return otherUser.username;
    }
    return 'Conversation';
  }

  // Avatar de la conversation (l'autre participant)
  String? getDisplayAvatar(String currentUserId) {
    final otherUser = getOtherParticipant(currentUserId);
    return otherUser?.profilePicture;
  }

  // Aperçu du dernier message
  String get lastMessagePreview {
    if (lastMessage == null) {
      return 'Aucun message';
    }
    return lastMessage!.displayContent;
  }

  // Statut en ligne (peut être étendu plus tard)
  bool get hasUnreadMessages => unreadCount > 0;

  // Copie avec modifications
  Conversation copyWith({
    String? id,
    List<User>? participants,
    Message? lastMessage,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Conversation(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Réduire le nombre de messages non lus
  Conversation markAsRead() {
    return copyWith(unreadCount: 0);
  }

  // Mettre à jour avec un nouveau message
  Conversation updateWithNewMessage(Message newMessage) {
    return copyWith(
      lastMessage: newMessage,
      updatedAt: newMessage.createdAt,
      unreadCount: newMessage.senderId != getCurrentUserId() 
          ? unreadCount + 1 
          : unreadCount,
    );
  }

  // TODO: Implémenter la gestion de l'utilisateur actuel
  String getCurrentUserId() {
    // Cette méthode devrait retourner l'ID de l'utilisateur connecté
    // Pour l'instant, on retourne une chaîne vide
    return '';
  }
}
