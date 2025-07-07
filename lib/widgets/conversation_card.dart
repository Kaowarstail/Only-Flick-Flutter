/// Reusable widgets for OnlyFlick messaging system
/// Instagram-style UI components

import 'package:flutter/material.dart';
import '../models/message_models.dart';
import '../theme/app_theme.dart';

/// Conversation card widget for the conversations list
class ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final String currentUserId;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;

  const ConversationCard({
    Key? key,
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
    this.onDelete,
    this.onArchive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final otherUser = conversation.getOtherParticipant(currentUserId);
    final lastMessage = conversation.lastMessage;
    final hasUnread = conversation.unreadCount > 0;

    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteDialog(context);
      },
      onDismissed: (direction) {
        onDelete?.call();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: hasUnread ? AppTheme.secondaryColor.withOpacity(0.1) : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 0.5,
            ),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              // Avatar with online indicator
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.secondaryColor,
                    backgroundImage: otherUser?.profilePicture != null
                        ? NetworkImage(otherUser!.profilePicture!)
                        : null,
                    child: otherUser?.profilePicture == null
                        ? Text(
                            _getInitials(otherUser?.username ?? 'U'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  // Online indicator (future implementation)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppTheme.onlineIndicatorColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and timestamp
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            otherUser?.username ?? 'Unknown User',
                            style: TextStyle(
                              fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                              fontSize: 16,
                              color: AppTheme.textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatTimestamp(conversation.updatedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: hasUnread ? AppTheme.primaryColor : Colors.grey.shade600,
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Last message and unread badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getLastMessagePreview(lastMessage),
                            style: TextStyle(
                              fontSize: 14,
                              color: hasUnread ? AppTheme.textColor : Colors.grey.shade600,
                              fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasUnread)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.unreadBadgeColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              conversation.unreadCount > 99 
                                  ? '99+' 
                                  : conversation.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (lastMessage?.isPaid == true && lastMessage?.isUnlocked == false)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.paidMessageColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.lock,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Hier';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}j';
      } else {
        return '${timestamp.day}/${timestamp.month}';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'maintenant';
    }
  }

  String _getLastMessagePreview(Message? message) {
    if (message == null) return 'Aucun message';

    if (message.isPaid && !message.isUnlocked) {
      return '🔒 Message payant - ${message.price?.toStringAsFixed(2)} €';
    }

    switch (message.type) {
      case MessageType.text:
      case MessageType.paid_text:
        return message.content;
      case MessageType.image:
      case MessageType.paid_media:
        return '📷 Photo';
      case MessageType.video:
        return '🎥 Vidéo';
    }
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la conversation'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette conversation ? '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
