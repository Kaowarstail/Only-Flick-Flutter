import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../config/api_config.dart';

class MessagingService {
  static const String baseUrl = '${ApiConfig.baseUrl}/api/v1';
  
  // Headers avec token d'authentification
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Récupérer les conversations de l'utilisateur
  Future<ConversationsResponse> getUserConversations({
    int page = 1,
    int limit = 20,
  }) async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/conversations?page=$page&limit=$limit'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ConversationsResponse.fromJson(data['data']);
    } else {
      throw Exception('Erreur lors de la récupération des conversations: ${response.statusCode}');
    }
  }

  // Créer ou récupérer une conversation
  Future<Conversation> createConversation(String otherUserId) async {
    final headers = await _getHeaders();
    
    final response = await http.post(
      Uri.parse('$baseUrl/conversations'),
      headers: headers,
      body: json.encode({
        'other_user_id': otherUserId,
      }),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return Conversation.fromJson(data['data']);
    } else {
      throw Exception('Erreur lors de la création de la conversation: ${response.statusCode}');
    }
  }

  // Récupérer les messages d'une conversation
  Future<MessagesResponse> getConversationMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/conversations/$conversationId/messages?page=$page&limit=$limit'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MessagesResponse.fromJson(data['data']);
    } else {
      throw Exception('Erreur lors de la récupération des messages: ${response.statusCode}');
    }
  }

  // Envoyer un message
  Future<Message> sendMessage(SendMessageRequest request) async {
    final headers = await _getHeaders();
    
    final response = await http.post(
      Uri.parse('$baseUrl/messages'),
      headers: headers,
      body: json.encode(request.toJson()),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return Message.fromJson(data['data']);
    } else {
      throw Exception('Erreur lors de l\'envoi du message: ${response.statusCode}');
    }
  }

  // Marquer une conversation comme lue
  Future<void> markConversationAsRead(String conversationId) async {
    final headers = await _getHeaders();
    
    final response = await http.put(
      Uri.parse('$baseUrl/conversations/$conversationId/mark-read'),
      headers: headers,
    );
    
    if (response.statusCode != 200) {
      throw Exception('Erreur lors du marquage comme lu: ${response.statusCode}');
    }
  }

  // Envoyer un message payant
  Future<Message> sendPaidMessage(SendPaidMessageRequest request) async {
    final headers = await _getHeaders();
    
    final response = await http.post(
      Uri.parse('$baseUrl/messages/paid'),
      headers: headers,
      body: json.encode(request.toJson()),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return Message.fromJson(data['data']);
    } else {
      throw Exception('Erreur lors de l\'envoi du message payant: ${response.statusCode}');
    }
  }

  // Déverrouiller un message payant
  Future<void> unlockPaidMessage(String messageId) async {
    final headers = await _getHeaders();
    
    final response = await http.post(
      Uri.parse('$baseUrl/messages/$messageId/unlock'),
      headers: headers,
    );
    
    if (response.statusCode != 200) {
      throw Exception('Erreur lors du déverrouillage du message: ${response.statusCode}');
    }
  }

  // Récupérer les statistiques de messagerie
  Future<MessageStatsResponse> getMessagingStats() async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/messages/stats'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return MessageStatsResponse.fromJson(data['data']);
    } else {
      throw Exception('Erreur lors de la récupération des statistiques: ${response.statusCode}');
    }
  }
}

// Classe pour gérer les réponses paginées des messages
class MessagesResponse {
  final List<Message> messages;
  final int total;
  final int unreadCount;
  final int page;
  final int limit;
  final bool hasMore;

  MessagesResponse({
    required this.messages,
    required this.total,
    required this.unreadCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    return MessagesResponse(
      messages: (json['messages'] as List<dynamic>? ?? [])
          .map((m) => Message.fromJson(m as Map<String, dynamic>))
          .toList(),
      total: json['total'] ?? 0,
      unreadCount: json['unread_count'] ?? json['unreadCount'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 50,
      hasMore: json['has_more'] ?? json['hasMore'] ?? false,
    );
  }
}

// Classe pour les statistiques de messagerie
class MessageStatsResponse {
  final int totalConversations;
  final int unreadMessages;
  final int totalMessages;

  MessageStatsResponse({
    required this.totalConversations,
    required this.unreadMessages,
    required this.totalMessages,
  });

  factory MessageStatsResponse.fromJson(Map<String, dynamic> json) {
    return MessageStatsResponse(
      totalConversations: json['total_conversations'] ?? 0,
      unreadMessages: json['unread_messages'] ?? 0,
      totalMessages: json['total_messages'] ?? 0,
    );
  }
}

// Classe pour les messages payants
class SendPaidMessageRequest {
  final String conversationId;
  final String? content;
  final String? mediaUrl;
  final String? mediaType;
  final MessageType messageType;
  final double price;

  SendPaidMessageRequest({
    required this.conversationId,
    this.content,
    this.mediaUrl,
    this.mediaType,
    required this.messageType,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'content': content,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'message_type': _messageTypeToString(messageType),
      'price': price,
    };
  }

  String _messageTypeToString(MessageType type) {
    switch (type) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.video:
        return 'video';
      case MessageType.audio:
        return 'audio';
    }
  }
}
