/// Chat page for OnlyFlick messaging
/// Instagram-style 1-on-1 chat with paid messages support

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/message_models.dart';
import '../../models/user.dart';
import '../../providers/message_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/paid_message_composer.dart';
import '../../theme/app_theme.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final User otherUser;

  const ChatPage({
    Key? key,
    required this.conversationId,
    required this.otherUser,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isTyping = false;
  bool _isLoadingMore = false;
  String? _replyingToMessage;
  
  late AnimationController _typingAnimationController;
  late AnimationController _sendButtonAnimationController;
  late Animation<double> _sendButtonScaleAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupAnimations();
    _setupScrollListener();
    _initializeChat();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    _sendButtonAnimationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _sendButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _sendButtonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _sendButtonAnimationController,
      curve: Curves.easeInOut,
    ));

    _typingAnimationController.repeat(reverse: true);
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreMessages();
      }
    });
  }

  void _initializeChat() {
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    messageProvider.loadMessages(widget.conversationId);
  }

  void _loadMoreMessages() {
    if (_isLoadingMore) return;
    
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    if (messageProvider.hasMoreMessages(widget.conversationId)) {
      setState(() => _isLoadingMore = true);
      messageProvider.loadMoreMessages(widget.conversationId).then((_) {
        setState(() => _isLoadingMore = false);
      });
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.user == null) return;

    _messageController.clear();
    _setReplyingTo(null);
    _animateSendButton();

    messageProvider.sendMessage(
      widget.conversationId,
      text,
      MessageType.text,
    ).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _sendMediaMessage(XFile file, MessageType type) {
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.user == null) return;

    _setReplyingTo(null);

    // For now, we'll just send the file path as mediaUrl
    // In a real app, you'd upload the file first and get a URL
    messageProvider.sendMessage(
      widget.conversationId,
      '',
      type,
      mediaUrl: file.path,
    ).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send media: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _animateSendButton() {
    _sendButtonAnimationController.forward().then((_) {
      _sendButtonAnimationController.reverse();
    });
  }

  void _setReplyingTo(String? messageId) {
    setState(() {
      _replyingToMessage = messageId;
    });
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMediaPicker(),
    );
  }

  void _showPaidMessageComposer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaidMessageComposer(
        conversationId: widget.conversationId,
        onSend: (content, price, type) {
          _sendPaidMessage(content, price);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _sendPaidMessage(String content, double price) {
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.user == null) return;

    _setReplyingTo(null);

    messageProvider.sendPaidMessage(
      widget.conversationId,
      content,
      price,
      type: MessageType.paid_text,
    ).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send paid message: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _pickImage() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      Navigator.pop(context);
      _sendMediaMessage(file, MessageType.image);
    }
  }

  void _pickVideo() async {
    final file = await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      Navigator.pop(context);
      _sendMediaMessage(file, MessageType.video);
    }
  }

  void _takePicture() async {
    final file = await _imagePicker.pickImage(source: ImageSource.camera);
    if (file != null) {
      Navigator.pop(context);
      _sendMediaMessage(file, MessageType.image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildMessagesList(),
          ),
          _buildReplyingToBar(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: widget.otherUser.profilePicture != null
                ? NetworkImage(widget.otherUser.profilePicture!)
                : null,
            child: widget.otherUser.profilePicture == null
                ? Text(
                    widget.otherUser.username[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUser.username,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Remove isOnline check for now
                const Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam_outlined),
          onPressed: () {
            // TODO: Implement video call
          },
        ),
        IconButton(
          icon: const Icon(Icons.call_outlined),
          onPressed: () {
            // TODO: Implement voice call
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // TODO: Implement chat options
          },
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        final messages = messageProvider.getMessages(widget.conversationId);
        
        if (messageProvider.isLoading && messages.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          );
        }

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start a conversation with ${widget.otherUser.username}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: messages.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == messages.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                ),
              );
            }

            final message = messages[index];
            final isMe = message.senderId == 
                Provider.of<AuthProvider>(context, listen: false).user?.id;

            return MessageBubble(
              message: message,
              isOwnMessage: isMe,
              onTap: () => _setReplyingTo(message.id),
              onUnlock: message.isPaid && !message.isUnlocked
                  ? () => _unlockMessage(message)
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _buildReplyingToBar() {
    if (_replyingToMessage == null) return const SizedBox.shrink();

    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        final messages = messageProvider.getMessages(widget.conversationId);
        final replyMessage = messages.firstWhere(
          (m) => m.id == _replyingToMessage,
          orElse: () => messages.first,
        );

        return Container(
          color: Colors.grey[100],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 32,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Replying to ${replyMessage.senderId}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      replyMessage.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => _setReplyingTo(null),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showMediaPicker,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Message...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {
                setState(() {
                  _isTyping = value.isNotEmpty;
                });
              },
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          if (_isTyping)
            ScaleTransition(
              scale: _sendButtonScaleAnimation,
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
                color: AppTheme.primaryColor,
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.attach_money),
              onPressed: _showPaidMessageComposer,
              color: AppTheme.secondaryColor,
            ),
        ],
      ),
    );
  }

  Widget _buildMediaPicker() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Share media',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMediaOption(
                icon: Icons.photo_library,
                label: 'Gallery',
                onTap: _pickImage,
              ),
              _buildMediaOption(
                icon: Icons.videocam,
                label: 'Video',
                onTap: _pickVideo,
              ),
              _buildMediaOption(
                icon: Icons.camera_alt,
                label: 'Camera',
                onTap: _takePicture,
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              size: 30,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _unlockMessage(Message message) {
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlock Message'),
        content: Text(
          'This message costs \$${message.price?.toStringAsFixed(2)}. '
          'Do you want to unlock it?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              messageProvider.unlockPaidMessage(message.id).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to unlock message: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }
}
