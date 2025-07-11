import '../conversation.dart';

class CreateConversationRequest {
  final String otherUserId;

  CreateConversationRequest({
    required this.otherUserId,
  });

  Map<String, dynamic> toJson() {
    return {
      'other_user_id': otherUserId,
    };
  }

  bool get isValid => otherUserId.isNotEmpty;

  String? get validationError {
    if (otherUserId.isEmpty) {
      return 'ID de l\'utilisateur requis';
    }
    return null;
  }
}

class ConversationsResponse {
  final List<Conversation> conversations;
  final int total;
  final int unreadTotal;
  final int page;
  final int limit;
  final bool hasMore;

  ConversationsResponse({
    required this.conversations,
    required this.total,
    required this.unreadTotal,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory ConversationsResponse.fromJson(Map<String, dynamic> json) {
    return ConversationsResponse(
      conversations: (json['conversations'] as List<dynamic>? ?? [])
          .map((c) => Conversation.fromJson(c as Map<String, dynamic>))
          .toList(),
      total: json['total'] ?? 0,
      unreadTotal: json['unread_total'] ?? json['unreadTotal'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      hasMore: json['has_more'] ?? json['hasMore'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversations': conversations.map((c) => c.toJson()).toList(),
      'total': total,
      'unread_total': unreadTotal,
      'page': page,
      'limit': limit,
      'has_more': hasMore,
    };
  }

  // Helper pour obtenir les statistiques
  int get totalUnreadMessages {
    return conversations.fold(0, (sum, conv) => sum + conv.unreadCount);
  }

  // Filtrer les conversations actives
  List<Conversation> get activeConversations {
    return conversations.where((conv) => conv.isActive).toList();
  }

  // Trier par dernière activité
  List<Conversation> get sortedByLastActivity {
    final sorted = List<Conversation>.from(conversations);
    sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }
}
