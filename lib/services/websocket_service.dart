import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../models/websocket_models.dart';

class WebSocketService extends ChangeNotifier {
  WebSocketChannel? _channel;
  StreamSubscription? _streamSubscription;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  
  // État de connexion
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _lastError;
  int _reconnectAttempts = 0;
  String? _currentToken;
  
  // Configuration
  static const String _wsUrl = 'ws://localhost:8080/api/v1/ws'; // TODO: Production: wss://
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const int _maxReconnectAttempts = 5;
  
  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get lastError => _lastError;
  int get reconnectAttempts => _reconnectAttempts;
  
  // Events stream
  final StreamController<WebSocketEvent> _eventController = 
      StreamController<WebSocketEvent>.broadcast();
  Stream<WebSocketEvent> get events => _eventController.stream;
  
  /// Connecter au WebSocket avec token JWT
  Future<void> connect(String authToken) async {
    if (_isConnected || _isConnecting) return;
    
    _isConnecting = true;
    _lastError = null;
    _currentToken = authToken;
    notifyListeners();
    
    try {
      print('WebSocket: Connecting to $_wsUrl');
      
      // Créer connexion WebSocket avec JWT
      final uri = Uri.parse('$_wsUrl?token=$authToken');
      
      _channel = WebSocketChannel.connect(uri);
      
      // Écouter les messages
      _streamSubscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );
      
      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      
      print('WebSocket: Connected successfully');
      
      // Démarrer heartbeat
      _startHeartbeat();
      
      // Émettre event de connexion établie
      _eventController.add(WebSocketEvent(
        type: WebSocketEventType.connectionEstablished,
        data: {'connected_at': DateTime.now().toIso8601String()},
        timestamp: DateTime.now(),
      ));
      
      notifyListeners();
      
    } catch (e) {
      print('WebSocket: Connection error: $e');
      _handleError(e);
    }
  }
  
  /// Déconnecter du WebSocket
  void disconnect() {
    print('WebSocket: Disconnecting');
    
    _stopHeartbeat();
    _stopReconnectTimer();
    _streamSubscription?.cancel();
    _channel?.sink.close(status.goingAway);
    
    _isConnected = false;
    _isConnecting = false;
    _currentToken = null;
    
    notifyListeners();
  }
  
  /// Gérer les messages WebSocket reçus
  void _handleMessage(dynamic data) {
    try {
      print('WebSocket: Received message: $data');
      
      final Map<String, dynamic> message = jsonDecode(data);
      final event = WebSocketEvent.fromJson(message);
      
      // Émettre l'event aux écouteurs
      _eventController.add(event);
      
    } catch (e) {
      print('WebSocket: Error parsing message: $e');
      _lastError = 'Error parsing message: $e';
      notifyListeners();
    }
  }
  
  /// Gérer les erreurs WebSocket
  void _handleError(dynamic error) {
    print('WebSocket: Error occurred: $error');
    
    _lastError = error.toString();
    _isConnected = false;
    _isConnecting = false;
    
    notifyListeners();
    
    // Tentative de reconnexion automatique
    if (_reconnectAttempts < _maxReconnectAttempts && _currentToken != null) {
      _scheduleReconnect();
    } else {
      print('WebSocket: Max reconnection attempts reached');
    }
  }
  
  /// Gérer la déconnexion WebSocket
  void _handleDisconnection() {
    print('WebSocket: Connection closed');
    
    _isConnected = false;
    _isConnecting = false;
    
    notifyListeners();
    
    // Auto-reconnect si pas volontaire et token disponible
    if (_reconnectAttempts < _maxReconnectAttempts && _currentToken != null) {
      _scheduleReconnect();
    }
  }
  
  /// Programmer une tentative de reconnexion
  void _scheduleReconnect() {
    _stopReconnectTimer();
    
    _reconnectAttempts++;
    final delay = Duration(seconds: min(30, 5 * _reconnectAttempts)); // Backoff exponentiel
    
    print('WebSocket: Reconnecting in ${delay.inSeconds} seconds (attempt $_reconnectAttempts)');
    
    _reconnectTimer = Timer(delay, () async {
      if (!_isConnected && _currentToken != null) {
        await connect(_currentToken!);
      }
    });
  }
  
  /// Démarrer le heartbeat
  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_isConnected && _channel != null) {
        try {
          // Envoyer ping via WebSocket
          final pingMessage = {
            'type': 'ping',
            'timestamp': DateTime.now().toIso8601String(),
          };
          
          _channel!.sink.add(jsonEncode(pingMessage));
          print('WebSocket: Sent ping');
          
        } catch (e) {
          print('WebSocket: Error sending ping: $e');
          _handleError(e);
        }
      } else {
        _stopHeartbeat();
      }
    });
  }
  
  /// Arrêter le heartbeat
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }
  
  /// Arrêter le timer de reconnexion
  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }
  
  /// Forcer une reconnexion (pour bouton retry dans l'UI)
  Future<void> forceReconnect() async {
    print('WebSocket: Force reconnecting');
    
    _reconnectAttempts = 0;
    disconnect();
    
    if (_currentToken != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      await connect(_currentToken!);
    }
  }
  
  /// Envoyer un typing indicator
  void sendTypingIndicator(String conversationId, bool isTyping) {
    if (!_isConnected || _channel == null) {
      print('WebSocket: Cannot send typing indicator - not connected');
      return;
    }
    
    try {
      final message = {
        'type': isTyping ? 'user_typing' : 'user_stopped_typing',
        'data': {
          'conversation_id': conversationId,
          'is_typing': isTyping,
        },
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      _channel!.sink.add(jsonEncode(message));
      print('WebSocket: Sent typing indicator: $isTyping for conversation $conversationId');
      
    } catch (e) {
      print('WebSocket: Error sending typing indicator: $e');
      _handleError(e);
    }
  }
  
  /// Marquer comme actif dans une conversation
  void markActiveInConversation(String conversationId) {
    if (!_isConnected || _channel == null) {
      print('WebSocket: Cannot mark active - not connected');
      return;
    }
    
    try {
      final message = {
        'type': 'user_active_in_conversation',
        'data': {
          'conversation_id': conversationId,
        },
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      _channel!.sink.add(jsonEncode(message));
      print('WebSocket: Marked active in conversation $conversationId');
      
    } catch (e) {
      print('WebSocket: Error marking active in conversation: $e');
      _handleError(e);
    }
  }
  
  /// Marquer un message comme lu
  void markMessageAsRead(String messageId, String conversationId) {
    if (!_isConnected || _channel == null) {
      print('WebSocket: Cannot mark message as read - not connected');
      return;
    }
    
    try {
      final message = {
        'type': 'message_read',
        'data': {
          'message_id': messageId,
          'conversation_id': conversationId,
        },
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      _channel!.sink.add(jsonEncode(message));
      print('WebSocket: Marked message $messageId as read');
      
    } catch (e) {
      print('WebSocket: Error marking message as read: $e');
      _handleError(e);
    }
  }
  
  /// Envoyer un message de statut utilisateur
  void sendUserStatus(bool isOnline) {
    if (!_isConnected || _channel == null) {
      print('WebSocket: Cannot send user status - not connected');
      return;
    }
    
    try {
      final message = {
        'type': isOnline ? 'user_online' : 'user_offline',
        'data': {
          'is_online': isOnline,
          'last_active_at': DateTime.now().toIso8601String(),
        },
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      _channel!.sink.add(jsonEncode(message));
      print('WebSocket: Sent user status: $isOnline');
      
    } catch (e) {
      print('WebSocket: Error sending user status: $e');
      _handleError(e);
    }
  }
  
  @override
  void dispose() {
    print('WebSocket: Disposing service');
    
    _stopHeartbeat();
    _stopReconnectTimer();
    _streamSubscription?.cancel();
    _channel?.sink.close();
    _eventController.close();
    
    super.dispose();
  }
}
