import 'message_models.dart';

// WebSocket Event Types
enum WebSocketEventType {
  // Messages
  messageSent,
  messageDelivered,
  messageRead,
  paidMessageSent,
  paidMessageUnlocked,
  
  // Typing indicators
  userTyping,
  userStoppedTyping,
  typingStart,
  typingStop,
  
  // User status
  userOnline,
  userOffline,
  userActiveInConversation,
  userPresence,
  
  // Conversations
  conversationUpdated,
  newConversation,
  
  // System
  connectionEstablished,
  heartbeat,
  error,
}

// Main WebSocket Event Model
class WebSocketEvent {
  final WebSocketEventType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String? userId;
  final String? conversationId;

  WebSocketEvent({
    required this.type,
    required this.data,
    required this.timestamp,
    this.userId,
    this.conversationId,
  });

  factory WebSocketEvent.fromJson(Map<String, dynamic> json) {
    return WebSocketEvent(
      type: _parseEventType(json['type'] ?? ''),
      data: json['data'] ?? {},
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      userId: json['user_id'],
      conversationId: json['conversation_id'],
    );
  }

  static WebSocketEventType _parseEventType(String type) {
    switch (type) {
      case 'message_sent':
        return WebSocketEventType.messageSent;
      case 'message_delivered':
        return WebSocketEventType.messageDelivered;
      case 'message_read':
        return WebSocketEventType.messageRead;
      case 'paid_message_sent':
        return WebSocketEventType.paidMessageSent;
      case 'paid_message_unlocked':
        return WebSocketEventType.paidMessageUnlocked;
      case 'user_typing':
        return WebSocketEventType.userTyping;
      case 'user_stopped_typing':
        return WebSocketEventType.userStoppedTyping;
      case 'typing_start':
        return WebSocketEventType.typingStart;
      case 'typing_stop':
        return WebSocketEventType.typingStop;
      case 'user_online':
        return WebSocketEventType.userOnline;
      case 'user_offline':
        return WebSocketEventType.userOffline;
      case 'user_active_in_conversation':
        return WebSocketEventType.userActiveInConversation;
      case 'user_presence':
        return WebSocketEventType.userPresence;
      case 'conversation_updated':
        return WebSocketEventType.conversationUpdated;
      case 'new_conversation':
        return WebSocketEventType.newConversation;
      case 'connection_established':
        return WebSocketEventType.connectionEstablished;
      case 'heartbeat':
        return WebSocketEventType.heartbeat;
      default:
        return WebSocketEventType.error;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'type': _eventTypeToString(type),
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      if (userId != null) 'user_id': userId,
      if (conversationId != null) 'conversation_id': conversationId,
    };
  }

  static String _eventTypeToString(WebSocketEventType type) {
    switch (type) {
      case WebSocketEventType.messageSent:
        return 'message_sent';
      case WebSocketEventType.messageDelivered:
        return 'message_delivered';
      case WebSocketEventType.messageRead:
        return 'message_read';
      case WebSocketEventType.paidMessageSent:
        return 'paid_message_sent';
      case WebSocketEventType.paidMessageUnlocked:
        return 'paid_message_unlocked';
      case WebSocketEventType.userTyping:
        return 'user_typing';
      case WebSocketEventType.userStoppedTyping:
        return 'user_stopped_typing';
      case WebSocketEventType.typingStart:
        return 'typing_start';
      case WebSocketEventType.typingStop:
        return 'typing_stop';
      case WebSocketEventType.userOnline:
        return 'user_online';
      case WebSocketEventType.userOffline:
        return 'user_offline';
      case WebSocketEventType.userActiveInConversation:
        return 'user_active_in_conversation';
      case WebSocketEventType.userPresence:
        return 'user_presence';
      case WebSocketEventType.conversationUpdated:
        return 'conversation_updated';
      case WebSocketEventType.newConversation:
        return 'new_conversation';
      case WebSocketEventType.connectionEstablished:
        return 'connection_established';
      case WebSocketEventType.heartbeat:
        return 'heartbeat';
      case WebSocketEventType.error:
        return 'error';
    }
  }
}

// Message Sent Event
class MessageSentEvent extends WebSocketEvent {
  final String messageId;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String content;
  final MessageType messageType;
  final DateTime timestamp;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final double? price;
  final bool isUnlocked;

  MessageSentEvent({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.messageType,
    required this.timestamp,
    this.mediaUrl,
    this.thumbnailUrl,
    this.price,
    this.isUnlocked = true,
  }) : super(
    type: WebSocketEventType.messageSent,
    data: {
      'message_id': messageId,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_name': senderName,
      'content': content,
      'message_type': messageType.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'media_url': mediaUrl,
      'thumbnail_url': thumbnailUrl,
      'price': price,
      'is_unlocked': isUnlocked,
    },
    timestamp: timestamp,
    userId: senderId,
    conversationId: conversationId,
  );

  factory MessageSentEvent.fromJson(Map<String, dynamic> json) {
    return MessageSentEvent(
      messageId: json['message_id'] ?? json['id'] ?? '',
      conversationId: json['conversation_id'] ?? '',
      senderId: json['sender_id'] ?? json['sender']?['id'] ?? '',
      senderName: json['sender_name'] ?? json['sender']?['name'] ?? '',
      content: json['content'] ?? '',
      messageType: _parseMessageType(json['message_type'] ?? json['type'] ?? ''),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      mediaUrl: json['media_url'],
      thumbnailUrl: json['thumbnail_url'],
      price: json['price']?.toDouble(),
      isUnlocked: json['is_unlocked'] ?? true,
    );
  }

  static MessageType _parseMessageType(String type) {
    switch (type.toLowerCase()) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'paid_text':
        return MessageType.paid_text;
      case 'paid_media':
        return MessageType.paid_media;
      default:
        return MessageType.text;
    }
  }
}

// Typing Event
class TypingEvent {
  final String userId;
  final String username;
  final String conversationId;
  final bool isTyping;

  TypingEvent({
    required this.userId,
    required this.username,
    required this.conversationId,
    required this.isTyping,
  });

  factory TypingEvent.fromJson(Map<String, dynamic> json) {
    return TypingEvent(
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
      conversationId: json['conversation_id'] ?? '',
      isTyping: json['is_typing'] ?? false,
    );
  }
}

// User Status Event
class UserStatusEvent {
  final String userId;
  final String username;
  final bool isOnline;
  final DateTime lastActiveAt;

  UserStatusEvent({
    required this.userId,
    required this.username,
    required this.isOnline,
    required this.lastActiveAt,
  });

  factory UserStatusEvent.fromJson(Map<String, dynamic> json) {
    return UserStatusEvent(
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
      isOnline: json['is_online'] ?? false,
      lastActiveAt: DateTime.tryParse(json['last_active_at'] ?? '') ?? DateTime.now(),
    );
  }
}

// Conversation Updated Event
class ConversationUpdatedEvent extends WebSocketEvent {
  final String conversationId;
  final Map<String, dynamic> conversation;
  final Map<String, dynamic>? lastMessage;
  final int unreadCount;

  ConversationUpdatedEvent({
    required this.conversationId,
    required this.conversation,
    this.lastMessage,
    required this.unreadCount,
  }) : super(
    type: WebSocketEventType.conversationUpdated,
    data: {
      'conversation_id': conversationId,
      'conversation': conversation,
      'last_message': lastMessage,
      'unread_count': unreadCount,
    },
    timestamp: DateTime.now(),
    conversationId: conversationId,
  );

  factory ConversationUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return ConversationUpdatedEvent(
      conversationId: json['conversation_id'] ?? json['conversation']?['id'] ?? '',
      conversation: json['conversation'] ?? {},
      lastMessage: json['last_message'],
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}

// Paid Message Unlocked Event
class PaidMessageUnlockedEvent extends WebSocketEvent {
  final String messageId;
  final String conversationId;
  final String userId;
  final double amount;

  PaidMessageUnlockedEvent({
    required this.messageId,
    required this.conversationId,
    required this.userId,
    required this.amount,
  }) : super(
    type: WebSocketEventType.paidMessageUnlocked,
    data: {
      'message_id': messageId,
      'conversation_id': conversationId,
      'user_id': userId,
      'amount': amount,
    },
    timestamp: DateTime.now(),
    userId: userId,
    conversationId: conversationId,
  );

  factory PaidMessageUnlockedEvent.fromJson(Map<String, dynamic> json) {
    return PaidMessageUnlockedEvent(
      messageId: json['message_id'] ?? '',
      conversationId: json['conversation_id'] ?? '',
      userId: json['user_id'] ?? '',
      amount: json['amount']?.toDouble() ?? 0.0,
    );
  }
}

// Connection Established Event
class ConnectionEstablishedEvent {
  final String userId;
  final DateTime serverTime;
  final String connectionId;
  final List<String> capabilities;

  ConnectionEstablishedEvent({
    required this.userId,
    required this.serverTime,
    required this.connectionId,
    required this.capabilities,
  });

  factory ConnectionEstablishedEvent.fromJson(Map<String, dynamic> json) {
    return ConnectionEstablishedEvent(
      userId: json['user_id'] ?? '',
      serverTime: DateTime.tryParse(json['server_time'] ?? '') ?? DateTime.now(),
      connectionId: json['connection_id'] ?? '',
      capabilities: List<String>.from(json['capabilities'] ?? []),
    );
  }
}

// Error Event
class ErrorEvent {
  final String code;
  final String message;
  final String? details;

  ErrorEvent({
    required this.code,
    required this.message,
    this.details,
  });

  factory ErrorEvent.fromJson(Map<String, dynamic> json) {
    return ErrorEvent(
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      details: json['details'],
    );
  }
}

// Missing event classes

class MessageReadEvent extends WebSocketEvent {
  final String messageId;
  final String conversationId;
  final String userId;

  MessageReadEvent({
    required this.messageId,
    required this.conversationId,
    required this.userId,
  }) : super(
    type: WebSocketEventType.messageRead,
    data: {
      'message_id': messageId,
      'conversation_id': conversationId,
      'user_id': userId,
    },
    timestamp: DateTime.now(),
    userId: userId,
    conversationId: conversationId,
  );

  factory MessageReadEvent.fromJson(Map<String, dynamic> json) {
    return MessageReadEvent(
      messageId: json['message_id'] ?? '',
      conversationId: json['conversation_id'] ?? '',
      userId: json['user_id'] ?? '',
    );
  }
}

class TypingStartEvent extends WebSocketEvent {
  final String conversationId;
  final String userId;
  final String username;

  TypingStartEvent({
    required this.conversationId,
    required this.userId,
    required this.username,
  }) : super(
    type: WebSocketEventType.typingStart,
    data: {
      'conversation_id': conversationId,
      'user_id': userId,
      'username': username,
    },
    timestamp: DateTime.now(),
    userId: userId,
    conversationId: conversationId,
  );

  factory TypingStartEvent.fromJson(Map<String, dynamic> json) {
    return TypingStartEvent(
      conversationId: json['conversation_id'] ?? '',
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
    );
  }
}

class TypingStopEvent extends WebSocketEvent {
  final String conversationId;
  final String userId;
  final String username;

  TypingStopEvent({
    required this.conversationId,
    required this.userId,
    required this.username,
  }) : super(
    type: WebSocketEventType.typingStop,
    data: {
      'conversation_id': conversationId,
      'user_id': userId,
      'username': username,
    },
    timestamp: DateTime.now(),
    userId: userId,
    conversationId: conversationId,
  );

  factory TypingStopEvent.fromJson(Map<String, dynamic> json) {
    return TypingStopEvent(
      conversationId: json['conversation_id'] ?? '',
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
    );
  }
}

class UserPresenceEvent extends WebSocketEvent {
  final String userId;
  final String username;
  final bool isOnline;
  final DateTime lastActiveAt;

  UserPresenceEvent({
    required this.userId,
    required this.username,
    required this.isOnline,
    required this.lastActiveAt,
  }) : super(
    type: WebSocketEventType.userPresence,
    data: {
      'user_id': userId,
      'username': username,
      'is_online': isOnline,
      'last_active_at': lastActiveAt.toIso8601String(),
    },
    timestamp: DateTime.now(),
    userId: userId,
  );

  factory UserPresenceEvent.fromJson(Map<String, dynamic> json) {
    return UserPresenceEvent(
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
      isOnline: json['is_online'] ?? false,
      lastActiveAt: DateTime.tryParse(json['last_active_at'] ?? '') ?? DateTime.now(),
    );
  }
}

// Additional models for user presence
enum UserPresenceStatus {
  online,
  away,
  busy,
  offline,
}

class UserPresence {
  final String userId;
  final UserPresenceStatus status;
  final DateTime lastActiveAt;
  final String? customMessage;

  UserPresence({
    required this.userId,
    required this.status,
    required this.lastActiveAt,
    this.customMessage,
  });

  bool get isOnline => status == UserPresenceStatus.online;
  bool get isAway => status == UserPresenceStatus.away;
  bool get isBusy => status == UserPresenceStatus.busy;
  bool get isOffline => status == UserPresenceStatus.offline;

  factory UserPresence.fromJson(Map<String, dynamic> json) {
    return UserPresence(
      userId: json['user_id'] ?? '',
      status: _parsePresenceStatus(json['status'] ?? ''),
      lastActiveAt: DateTime.tryParse(json['last_active_at'] ?? '') ?? DateTime.now(),
      customMessage: json['custom_message'],
    );
  }

  static UserPresenceStatus _parsePresenceStatus(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return UserPresenceStatus.online;
      case 'away':
        return UserPresenceStatus.away;
      case 'busy':
        return UserPresenceStatus.busy;
      case 'offline':
      default:
        return UserPresenceStatus.offline;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'status': status.toString().split('.').last,
      'last_active_at': lastActiveAt.toIso8601String(),
      'custom_message': customMessage,
    };
  }
}
