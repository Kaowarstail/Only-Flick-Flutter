import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/message_provider.dart';
import '../../widgets/connection_status_widget.dart';
import '../../widgets/typing_indicator_widget.dart';
import '../../widgets/websocket_debug_panel.dart';

class MessagingTestPage extends StatefulWidget {
  const MessagingTestPage({Key? key}) : super(key: key);

  @override
  State<MessagingTestPage> createState() => _MessagingTestPageState();
}

class _MessagingTestPageState extends State<MessagingTestPage> {
  final TextEditingController _messageController = TextEditingController();
  final String _testConversationId = 'test-conversation-id';
  bool _isTyping = false;
  
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Test'),
        actions: [
          IconButton(
            onPressed: () => _showDebugInfo(context),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status
          Container(
            padding: const EdgeInsets.all(16),
            child: const ConnectionStatusWidget(showDetails: true),
          ),
          
          // Connection metrics
          const ConnectionMetrics(),
          
          // Message input for testing
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'WebSocket Integration Test',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Test typing indicator
                  TypingIndicatorWidget(
                    conversationId: _testConversationId,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Message input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: _onTextChanged,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _sendTestMessage,
                        child: const Text('Send'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Test buttons
                  Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: _testTyping,
                        child: const Text('Test Typing'),
                      ),
                      ElevatedButton(
                        onPressed: _testReconnect,
                        child: const Text('Reconnect'),
                      ),
                      ElevatedButton(
                        onPressed: _toggleWebSocket,
                        child: const Text('Toggle WS'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _onTextChanged(String text) {
    final messageProvider = context.read<MessageProvider>();
    
    if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      messageProvider.sendTypingIndicator(_testConversationId, true);
    } else if (text.isEmpty && _isTyping) {
      _isTyping = false;
      messageProvider.sendTypingIndicator(_testConversationId, false);
    }
  }
  
  void _sendTestMessage() {
    final messageProvider = context.read<MessageProvider>();
    final message = _messageController.text.trim();
    
    if (message.isNotEmpty) {
      // Simuler l'envoi d'un message (normalement via REST API)
      print('Sending message: $message');
      
      // Arrêter le typing
      if (_isTyping) {
        _isTyping = false;
        messageProvider.sendTypingIndicator(_testConversationId, false);
      }
      
      _messageController.clear();
    }
  }
  
  void _testTyping() {
    final messageProvider = context.read<MessageProvider>();
    messageProvider.sendTypingIndicator(_testConversationId, true);
    
    // Arrêter après 3 secondes
    Future.delayed(const Duration(seconds: 3), () {
      messageProvider.sendTypingIndicator(_testConversationId, false);
    });
  }
  
  void _testReconnect() {
    final messageProvider = context.read<MessageProvider>();
    messageProvider.forceReconnect();
  }
  
  void _toggleWebSocket() {
    final messageProvider = context.read<MessageProvider>();
    messageProvider.setWebSocketEnabled(!messageProvider.isWebSocketEnabled);
  }
  
  void _showDebugInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('WebSocket Debug'),
        content: SizedBox(
          width: double.maxFinite,
          child: WebSocketDebugPanel(),
        ),
      ),
    );
  }
}

/// Widget pour afficher les informations sur les services WebSocket
class WebSocketServicesInfo extends StatelessWidget {
  const WebSocketServicesInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WebSocket Services Status',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _buildStatusRow(
                  'WebSocket Connection',
                  messageProvider.isWebSocketConnected ? 'Connected' : 'Disconnected',
                  messageProvider.isWebSocketConnected ? Colors.green : Colors.red,
                ),
                _buildStatusRow(
                  'Network Status',
                  messageProvider.connectionStatus,
                  messageProvider.isOnline ? Colors.green : Colors.red,
                ),
                _buildStatusRow(
                  'WebSocket Enabled',
                  messageProvider.isWebSocketEnabled ? 'Yes' : 'No',
                  messageProvider.isWebSocketEnabled ? Colors.green : Colors.orange,
                ),
                _buildStatusRow(
                  'Current Conversation',
                  messageProvider.currentConversationId ?? 'None',
                  Colors.blue,
                ),
                _buildStatusRow(
                  'Unread Messages',
                  '${messageProvider.unreadCount}',
                  messageProvider.unreadCount > 0 ? Colors.red : Colors.green,
                ),
                if (messageProvider.error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Error: ${messageProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
