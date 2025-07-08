import 'dart:async';
import 'dart:convert';
import 'dart:math';
import '../models/websocket_models.dart';

/// Service pour simuler des événements WebSocket pendant le développement
class WebSocketSimulatorService {
  static final WebSocketSimulatorService _instance = WebSocketSimulatorService._internal();
  factory WebSocketSimulatorService() => _instance;
  WebSocketSimulatorService._internal();
  
  final StreamController<WebSocketEvent> _eventController = 
      StreamController<WebSocketEvent>.broadcast();
  
  Timer? _simulationTimer;
  final Random _random = Random();
  bool _isSimulating = false;
  
  Stream<WebSocketEvent> get events => _eventController.stream;
  bool get isSimulating => _isSimulating;
  
  /// Démarrer la simulation d'événements WebSocket
  void startSimulation() {
    if (_isSimulating) return;
    
    _isSimulating = true;
    print('WebSocketSimulator: Starting simulation...');
    
    // Simuler des événements toutes les 5-15 secondes
    _simulationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _simulateRandomEvent();
    });
    
    // Événement de connexion établie
    _eventController.add(WebSocketEvent(
      type: WebSocketEventType.connectionEstablished,
      data: {'connected_at': DateTime.now().toIso8601String()},
      timestamp: DateTime.now(),
    ));
  }
  
  /// Arrêter la simulation
  void stopSimulation() {
    if (!_isSimulating) return;
    
    _isSimulating = false;
    _simulationTimer?.cancel();
    _simulationTimer = null;
    
    print('WebSocketSimulator: Stopping simulation...');
  }
  
  /// Simuler un événement aléatoire
  void _simulateRandomEvent() {
    final eventTypes = [
      WebSocketEventType.messageSent,
      WebSocketEventType.userTyping,
      WebSocketEventType.userStoppedTyping,
      WebSocketEventType.userStatusChanged,
      WebSocketEventType.paidMessageUnlocked,
    ];
    
    final eventType = eventTypes[_random.nextInt(eventTypes.length)];
    
    switch (eventType) {
      case WebSocketEventType.messageSent:
        _simulateMessageSent();
        break;
      case WebSocketEventType.userTyping:
        _simulateUserTyping();
        break;
      case WebSocketEventType.userStoppedTyping:
        _simulateUserStoppedTyping();
        break;
      case WebSocketEventType.userStatusChanged:
        _simulateUserStatusChanged();
        break;
      case WebSocketEventType.paidMessageUnlocked:
        _simulatePaidMessageUnlocked();
        break;
      default:
        break;
    }
  }
  
  /// Simuler un nouveau message
  void _simulateMessageSent() {
    final conversationId = 'test-conversation-${_random.nextInt(3) + 1}';
    final messages = [
      'Hello! How are you?',
      'Just checking in 👋',
      'Hope you\'re having a great day!',
      'What are you up to?',
      'Miss you! 💕',
      'Check out this cool thing I found',
      'Are you free tonight?',
      'Thanks for your message!',
    ];
    
    final event = WebSocketEvent(
      type: WebSocketEventType.messageSent,
      data: {
        'message_id': 'msg-${_random.nextInt(10000)}',
        'conversation_id': conversationId,
        'sender_id': 'user-${_random.nextInt(5) + 1}',
        'sender_name': 'User ${_random.nextInt(5) + 1}',
        'content': messages[_random.nextInt(messages.length)],
        'message_type': 'text',
        'timestamp': DateTime.now().toIso8601String(),
        'is_read': false,
        'is_unlocked': true,
      },
      timestamp: DateTime.now(),
      conversationId: conversationId,
    );
    
    _eventController.add(event);
    print('WebSocketSimulator: Simulated message sent');
  }
  
  /// Simuler un utilisateur en train de taper
  void _simulateUserTyping() {
    final conversationId = 'test-conversation-${_random.nextInt(3) + 1}';
    final userId = 'user-${_random.nextInt(5) + 1}';
    
    final event = WebSocketEvent(
      type: WebSocketEventType.userTyping,
      data: {
        'user_id': userId,
        'username': 'User ${_random.nextInt(5) + 1}',
        'conversation_id': conversationId,
        'is_typing': true,
      },
      timestamp: DateTime.now(),
      conversationId: conversationId,
      userId: userId,
    );
    
    _eventController.add(event);
    print('WebSocketSimulator: Simulated user typing');
    
    // Arrêter le typing après 3-8 secondes
    Future.delayed(Duration(seconds: 3 + _random.nextInt(5)), () {
      _simulateUserStoppedTyping(conversationId, userId);
    });
  }
  
  /// Simuler un utilisateur qui arrête de taper
  void _simulateUserStoppedTyping([String? conversationId, String? userId]) {
    conversationId ??= 'test-conversation-${_random.nextInt(3) + 1}';
    userId ??= 'user-${_random.nextInt(5) + 1}';
    
    final event = WebSocketEvent(
      type: WebSocketEventType.userStoppedTyping,
      data: {
        'user_id': userId,
        'username': 'User ${_random.nextInt(5) + 1}',
        'conversation_id': conversationId,
        'is_typing': false,
      },
      timestamp: DateTime.now(),
      conversationId: conversationId,
      userId: userId,
    );
    
    _eventController.add(event);
    print('WebSocketSimulator: Simulated user stopped typing');
  }
  
  /// Simuler un changement de statut utilisateur
  void _simulateUserStatusChanged() {
    final userId = 'user-${_random.nextInt(5) + 1}';
    final isOnline = _random.nextBool();
    
    final event = WebSocketEvent(
      type: WebSocketEventType.userStatusChanged,
      data: {
        'user_id': userId,
        'username': 'User ${_random.nextInt(5) + 1}',
        'is_online': isOnline,
        'last_active_at': DateTime.now().toIso8601String(),
      },
      timestamp: DateTime.now(),
      userId: userId,
    );
    
    _eventController.add(event);
    print('WebSocketSimulator: Simulated user status changed - $isOnline');
  }
  
  /// Simuler un message payant déverrouillé
  void _simulatePaidMessageUnlocked() {
    final conversationId = 'test-conversation-${_random.nextInt(3) + 1}';
    final amount = (_random.nextDouble() * 50 + 5).roundToDouble();
    
    final event = WebSocketEvent(
      type: WebSocketEventType.paidMessageUnlocked,
      data: {
        'message_id': 'msg-${_random.nextInt(10000)}',
        'conversation_id': conversationId,
        'amount': amount,
        'currency': 'EUR',
        'unlocked_at': DateTime.now().toIso8601String(),
      },
      timestamp: DateTime.now(),
      conversationId: conversationId,
    );
    
    _eventController.add(event);
    print('WebSocketSimulator: Simulated paid message unlocked - €$amount');
  }
  
  /// Simuler un événement d'erreur
  void simulateError(String errorMessage) {
    final event = WebSocketEvent(
      type: WebSocketEventType.error,
      data: {
        'error': errorMessage,
        'error_code': 'SIMULATION_ERROR',
        'timestamp': DateTime.now().toIso8601String(),
      },
      timestamp: DateTime.now(),
    );
    
    _eventController.add(event);
    print('WebSocketSimulator: Simulated error - $errorMessage');
  }
  
  /// Simuler une mise à jour de conversation
  void simulateConversationUpdate(String conversationId) {
    final event = WebSocketEvent(
      type: WebSocketEventType.conversationUpdated,
      data: {
        'conversation_id': conversationId,
        'last_message_at': DateTime.now().toIso8601String(),
        'unread_count': _random.nextInt(10),
        'updated_at': DateTime.now().toIso8601String(),
      },
      timestamp: DateTime.now(),
      conversationId: conversationId,
    );
    
    _eventController.add(event);
    print('WebSocketSimulator: Simulated conversation update');
  }
  
  /// Simuler une séquence de messages
  void simulateMessageSequence(String conversationId, int messageCount) {
    final messages = [
      'Hey there! 👋',
      'How\'s your day going?',
      'I was just thinking about you',
      'Want to grab coffee sometime?',
      'This is so exciting!',
      'Can\'t wait to see you again',
      'You always make me smile 😊',
      'Thanks for being amazing!',
    ];
    
    for (int i = 0; i < messageCount; i++) {
      Future.delayed(Duration(seconds: i * 2), () {
        final event = WebSocketEvent(
          type: WebSocketEventType.messageSent,
          data: {
            'message_id': 'msg-seq-${DateTime.now().millisecondsSinceEpoch}-$i',
            'conversation_id': conversationId,
            'sender_id': 'user-simulation',
            'sender_name': 'Simulation User',
            'content': messages[i % messages.length],
            'message_type': 'text',
            'timestamp': DateTime.now().toIso8601String(),
            'is_read': false,
            'is_unlocked': true,
          },
          timestamp: DateTime.now(),
          conversationId: conversationId,
        );
        
        _eventController.add(event);
      });
    }
  }
  
  void dispose() {
    stopSimulation();
    _eventController.close();
  }
}
