import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/message_provider.dart';
import '../services/connectivity_service.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final bool showDetails;
  final bool isMinimized;
  
  const ConnectionStatusWidget({
    Key? key,
    this.showDetails = false,
    this.isMinimized = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        final isWebSocketConnected = messageProvider.isWebSocketConnected;
        final isOnline = messageProvider.isOnline;
        final connectionStatus = messageProvider.connectionStatus;
        
        // Determine connection state
        final ConnectionState connectionState = _getConnectionState(
          isOnline,
          isWebSocketConnected,
          messageProvider.isWebSocketEnabled,
        );
        
        if (isMinimized) {
          return _buildMinimizedWidget(connectionState);
        }
        
        return _buildFullWidget(context, connectionState, connectionStatus, showDetails);
      },
    );
  }
  
  ConnectionState _getConnectionState(bool isOnline, bool isWebSocketConnected, bool isWebSocketEnabled) {
    if (!isOnline) {
      return ConnectionState.offline;
    }
    
    if (!isWebSocketEnabled) {
      return ConnectionState.restOnly;
    }
    
    if (isWebSocketConnected) {
      return ConnectionState.realtime;
    }
    
    return ConnectionState.fallback;
  }
  
  Widget _buildMinimizedWidget(ConnectionState state) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: _getStateColor(state),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
    );
  }
  
  Widget _buildFullWidget(
    BuildContext context,
    ConnectionState state,
    String statusText,
    bool showDetails,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getStateColor(state).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStateColor(state).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStateIcon(state),
            size: 16,
            color: _getStateColor(state),
          ),
          const SizedBox(width: 8),
          Text(
            _getStateText(state),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getStateColor(state),
            ),
          ),
          if (showDetails) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _showDetailsDialog(context, state, statusText),
              child: Icon(
                Icons.info_outline,
                size: 14,
                color: _getStateColor(state).withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Color _getStateColor(ConnectionState state) {
    switch (state) {
      case ConnectionState.realtime:
        return Colors.green;
      case ConnectionState.fallback:
        return Colors.orange;
      case ConnectionState.restOnly:
        return Colors.blue;
      case ConnectionState.offline:
        return Colors.red;
    }
  }
  
  IconData _getStateIcon(ConnectionState state) {
    switch (state) {
      case ConnectionState.realtime:
        return Icons.flash_on;
      case ConnectionState.fallback:
        return Icons.sync;
      case ConnectionState.restOnly:
        return Icons.http;
      case ConnectionState.offline:
        return Icons.cloud_off;
    }
  }
  
  String _getStateText(ConnectionState state) {
    switch (state) {
      case ConnectionState.realtime:
        return 'Real-time';
      case ConnectionState.fallback:
        return 'Fallback';
      case ConnectionState.restOnly:
        return 'REST mode';
      case ConnectionState.offline:
        return 'Offline';
    }
  }
  
  void _showDetailsDialog(
    BuildContext context,
    ConnectionState state,
    String statusText,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connection Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Mode', _getStateText(state), _getStateColor(state)),
            const SizedBox(height: 8),
            _buildDetailRow('Network', statusText, Colors.grey[600]!),
            const SizedBox(height: 8),
            _buildDetailRow('Features', _getFeatureDescription(state), Colors.grey[600]!),
            const SizedBox(height: 16),
            Text(
              _getStateDescription(state),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (state == ConnectionState.fallback || state == ConnectionState.offline)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<MessageProvider>(context, listen: false).forceReconnect();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
  
  String _getFeatureDescription(ConnectionState state) {
    switch (state) {
      case ConnectionState.realtime:
        return 'Instant messaging, typing indicators, presence';
      case ConnectionState.fallback:
        return 'Messaging with periodic updates';
      case ConnectionState.restOnly:
        return 'Basic messaging only';
      case ConnectionState.offline:
        return 'No messaging available';
    }
  }
  
  String _getStateDescription(ConnectionState state) {
    switch (state) {
      case ConnectionState.realtime:
        return 'You\'re connected to our real-time messaging service. Messages are delivered instantly.';
      case ConnectionState.fallback:
        return 'Real-time connection is unavailable. Messages are synced periodically.';
      case ConnectionState.restOnly:
        return 'Real-time features are disabled. Only basic messaging is available.';
      case ConnectionState.offline:
        return 'No internet connection. Messages will be sent when connection is restored.';
    }
  }
}

enum ConnectionState {
  realtime,
  fallback,
  restOnly,
  offline,
}

/// Quick access widget for connection status
class QuickConnectionStatus extends StatelessWidget {
  const QuickConnectionStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        final isWebSocketConnected = messageProvider.isWebSocketConnected;
        final isOnline = messageProvider.isOnline;
        
        if (isOnline && isWebSocketConnected) {
          return const SizedBox.shrink(); // Hide when everything is working
        }
        
        return GestureDetector(
          onTap: () => _showStatusBottomSheet(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOnline ? Icons.sync : Icons.cloud_off,
                  size: 16,
                  color: isOnline ? Colors.orange : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  isOnline ? 'Limited connectivity' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOnline ? Colors.orange : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _showStatusBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Connection Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const ConnectionStatusWidget(
              showDetails: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Provider.of<MessageProvider>(context, listen: false).forceReconnect();
              },
              child: const Text('Retry Connection'),
            ),
          ],
        ),
      ),
    );
  }
}
