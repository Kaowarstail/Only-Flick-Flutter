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
}

class ConversationStatsResponse {
  final int totalConversations;
  final int activeConversations;
  final int unreadConversations;
  final int totalUnreadMessages;

  ConversationStatsResponse({
    required this.totalConversations,
    required this.activeConversations,
    required this.unreadConversations,
    required this.totalUnreadMessages,
  });

  factory ConversationStatsResponse.fromJson(Map<String, dynamic> json) {
    return ConversationStatsResponse(
      totalConversations: json['total_conversations'] ?? json['totalConversations'] ?? 0,
      activeConversations: json['active_conversations'] ?? json['activeConversations'] ?? 0,
      unreadConversations: json['unread_conversations'] ?? json['unreadConversations'] ?? 0,
      totalUnreadMessages: json['total_unread_messages'] ?? json['totalUnreadMessages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_conversations': totalConversations,
      'active_conversations': activeConversations,
      'unread_conversations': unreadConversations,
      'total_unread_messages': totalUnreadMessages,
    };
  }
}
