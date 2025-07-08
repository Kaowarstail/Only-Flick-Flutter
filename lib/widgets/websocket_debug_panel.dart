import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/message_provider.dart';
import '../services/connectivity_service.dart';

class WebSocketDebugPanel extends StatefulWidget {
  const WebSocketDebugPanel({Key? key}) : super(key: key);

  @override
  State<WebSocketDebugPanel> createState() => _WebSocketDebugPanelState();
}

class _WebSocketDebugPanelState extends State<WebSocketDebugPanel> {
  bool _isExpanded = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(messageProvider),
              if (_isExpanded) _buildContent(messageProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(MessageProvider messageProvider) {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.developer_mode,
              color: Colors.green[400],
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'WebSocket Debug',
              style: TextStyle(
                color: Colors.green[400],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            _buildStatusDot(messageProvider),
            const SizedBox(width: 8),
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDot(MessageProvider messageProvider) {
    final isConnected = messageProvider.isWebSocketConnected;
    final isOnline = messageProvider.isOnline;
    
    Color color;
    if (!isOnline) {
      color = Colors.red;
    } else if (isConnected) {
      color = Colors.green;
    } else {
      color = Colors.orange;
    }
    
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildContent(MessageProvider messageProvider) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConnectionInfo(messageProvider),
          const Divider(color: Colors.grey, height: 20),
          _buildControls(messageProvider),
          const Divider(color: Colors.grey, height: 20),
          _buildRealTimeInfo(messageProvider),
        ],
      ),
    );
  }

  Widget _buildConnectionInfo(MessageProvider messageProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connection Status',
          style: TextStyle(
            color: Colors.grey[300],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('WebSocket', messageProvider.isWebSocketConnected ? 'Connected' : 'Disconnected'),
        _buildInfoRow('Network', messageProvider.connectionStatus),
        _buildInfoRow('Mode', messageProvider.isWebSocketEnabled ? 'Real-time' : 'REST only'),
        _buildInfoRow('Reconnect Attempts', '${messageProvider.error?.contains('connection') == true ? '1+' : '0'}'),
      ],
    );
  }

  Widget _buildControls(MessageProvider messageProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Controls',
          style: TextStyle(
            color: Colors.grey[300],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildControlButton(
              'Reconnect',
              Icons.refresh,
              Colors.blue,
              messageProvider.isOnline,
              () => messageProvider.forceReconnect(),
            ),
            _buildControlButton(
              messageProvider.isWebSocketEnabled ? 'Disable WS' : 'Enable WS',
              messageProvider.isWebSocketEnabled ? Icons.stop : Icons.play_arrow,
              messageProvider.isWebSocketEnabled ? Colors.red : Colors.green,
              true,
              () => messageProvider.setWebSocketEnabled(!messageProvider.isWebSocketEnabled),
            ),
            _buildControlButton(
              'Clear Error',
              Icons.clear,
              Colors.orange,
              messageProvider.error != null,
              () => messageProvider.error = null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRealTimeInfo(MessageProvider messageProvider) {
    final currentConversation = messageProvider.currentConversationId;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Real-time Features',
          style: TextStyle(
            color: Colors.grey[300],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('Current Conversation', currentConversation ?? 'None'),
        if (currentConversation != null) ...[
          _buildInfoRow(
            'Typing Users',
            '${messageProvider.getTypingUsers(currentConversation).length}',
          ),
          _buildInfoRow(
            'Online Users',
            '${messageProvider.isUserOnline(currentConversation) ? 1 : 0}',
          ),
        ],
        _buildInfoRow('Unread Count', '${messageProvider.unreadCount}'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    String label,
    IconData icon,
    Color color,
    bool enabled,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: const Size(0, 32),
      ),
    );
  }
}

/// Debug overlay for easy access during development
class DebugOverlay extends StatefulWidget {
  final Widget child;
  
  const DebugOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {
  bool _showDebugPanel = false;
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showDebugPanel)
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: const WebSocketDebugPanel(),
          ),
        Positioned(
          top: 50,
          right: 16,
          child: FloatingActionButton.small(
            onPressed: () {
              setState(() {
                _showDebugPanel = !_showDebugPanel;
              });
            },
            backgroundColor: Colors.black.withOpacity(0.7),
            child: Icon(
              _showDebugPanel ? Icons.close : Icons.bug_report,
              color: Colors.green[400],
            ),
          ),
        ),
      ],
    );
  }
}

/// Connection metrics widget
class ConnectionMetrics extends StatelessWidget {
  const ConnectionMetrics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Connection Metrics',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              _buildMetricRow(
                'WebSocket Status',
                messageProvider.isWebSocketConnected ? 'Connected' : 'Disconnected',
                messageProvider.isWebSocketConnected ? Colors.green : Colors.red,
              ),
              _buildMetricRow(
                'Network Status',
                messageProvider.connectionStatus,
                messageProvider.isOnline ? Colors.green : Colors.red,
              ),
              _buildMetricRow(
                'Mode',
                messageProvider.isWebSocketEnabled ? 'Real-time' : 'REST only',
                messageProvider.isWebSocketEnabled ? Colors.blue : Colors.orange,
              ),
              _buildMetricRow(
                'Active Conversations',
                messageProvider.currentConversationId != null ? '1' : '0',
                Colors.grey[600]!,
              ),
              _buildMetricRow(
                'Unread Messages',
                '${messageProvider.unreadCount}',
                messageProvider.unreadCount > 0 ? Colors.red : Colors.grey[600]!,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
