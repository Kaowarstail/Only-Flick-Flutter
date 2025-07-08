import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/message_provider.dart';

class TypingIndicatorWidget extends StatefulWidget {
  final String conversationId;
  final EdgeInsets padding;
  
  const TypingIndicatorWidget({
    Key? key,
    required this.conversationId,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  }) : super(key: key);

  @override
  State<TypingIndicatorWidget> createState() => _TypingIndicatorWidgetState();
}

class _TypingIndicatorWidgetState extends State<TypingIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        final typingUsers = messageProvider.getTypingUsers(widget.conversationId);
        
        if (typingUsers.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Container(
          padding: widget.padding,
          child: Row(
            children: [
              _buildTypingAnimation(),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTypingText(typingUsers),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildTypingAnimation() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        );
      },
    );
  }
  
  Widget _buildDot(int index) {
    final delay = index * 0.2;
    final opacity = ((_animation.value + delay) % 1.0).clamp(0.0, 1.0);
    
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3 + (opacity * 0.7)),
        shape: BoxShape.circle,
      ),
    );
  }
  
  Widget _buildTypingText(List<String> typingUsers) {
    String text;
    
    if (typingUsers.length == 1) {
      // TODO: Get actual username from user ID
      text = 'Someone is typing...';
    } else if (typingUsers.length == 2) {
      text = 'Two people are typing...';
    } else {
      text = 'Multiple people are typing...';
    }
    
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

/// Compact typing indicator for message list
class CompactTypingIndicator extends StatelessWidget {
  final String conversationId;
  
  const CompactTypingIndicator({
    Key? key,
    required this.conversationId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        final typingUsers = messageProvider.getTypingUsers(conversationId);
        
        if (typingUsers.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMinimalTypingAnimation(),
                  const SizedBox(width: 8),
                  Text(
                    _getTypingText(typingUsers.length),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildMinimalTypingAnimation() {
    return SizedBox(
      width: 20,
      height: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildAnimatedDot(0),
          _buildAnimatedDot(200),
          _buildAnimatedDot(400),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedDot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 1200 + delay),
      builder: (context, value, child) {
        return Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3 + (value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
  
  String _getTypingText(int count) {
    if (count == 1) {
      return 'typing...';
    } else if (count == 2) {
      return '2 typing...';
    } else {
      return '$count typing...';
    }
  }
}

/// Typing indicator for conversation list
class ConversationTypingIndicator extends StatelessWidget {
  final String conversationId;
  
  const ConversationTypingIndicator({
    Key? key,
    required this.conversationId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        final typingUsers = messageProvider.getTypingUsers(conversationId);
        
        if (typingUsers.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'typing',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Presence indicator for users
class UserPresenceIndicator extends StatelessWidget {
  final String conversationId;
  final String userId;
  final double size;
  
  const UserPresenceIndicator({
    Key? key,
    required this.conversationId,
    required this.userId,
    this.size = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        final isOnline = messageProvider.isUserOnline(conversationId, userId);
        
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isOnline ? Colors.green : Colors.grey[400],
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
        );
      },
    );
  }
}

/// Presence badge for avatar
class PresenceBadge extends StatelessWidget {
  final String conversationId;
  final String userId;
  final Widget child;
  
  const PresenceBadge({
    Key? key,
    required this.conversationId,
    required this.userId,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        final isOnline = messageProvider.isUserOnline(conversationId, userId);
        
        return Stack(
          children: [
            this.child,
            if (isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
