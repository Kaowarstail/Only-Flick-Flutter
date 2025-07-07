/// Conversations list page for OnlyFlick messaging
/// Instagram-style conversations list with search and actions

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/message_models.dart';
import '../../models/user.dart';
import '../../providers/message_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/conversation_card.dart';
import '../../theme/app_theme.dart';
import 'chat_page.dart';

class ConversationsListPage extends StatefulWidget {
  const ConversationsListPage({Key? key}) : super(key: key);

  @override
  State<ConversationsListPage> createState() => _ConversationsListPageState();
}

class _ConversationsListPageState extends State<ConversationsListPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<User> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;
  
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeData();
    _setupScrollListener();
  }

  void _setupAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageProvider>().initialize();
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection.index == 1) {
        // Scrolling down
        _fabAnimationController.forward();
      } else {
        // Scrolling up
        _fabAnimationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: _showSearchResults 
                  ? _buildSearchResults()
                  : _buildConversationsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Messages',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    if (messageProvider.unreadCount > 0)
                      Text(
                        '${messageProvider.unreadCount} non lu${messageProvider.unreadCount > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              if (messageProvider.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    messageProvider.unreadCount > 99 
                        ? '99+' 
                        : messageProvider.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Rechercher des utilisateurs...',
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade600,
          ),
          suffixIcon: _showSearchResults
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildConversationsList() {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        if (messageProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          );
        }

        if (messageProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erreur de chargement',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  messageProvider.error!,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => messageProvider.loadConversations(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        final conversations = messageProvider.conversations;
        
        if (conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 24),
                Text(
                  'Aucune conversation',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Commencez une nouvelle conversation\navec un créateur',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _focusSearchBar(),
                  icon: const Icon(Icons.search),
                  label: const Text('Rechercher'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => messageProvider.loadConversations(),
          color: AppTheme.primaryColor,
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final currentUserId = context.read<AuthProvider>().user?.id ?? '';
              
              return ConversationCard(
                conversation: conversation,
                currentUserId: currentUserId,
                onTap: () => _openChat(conversation),
                onDelete: () => _deleteConversation(conversation.id),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      );
    }

    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun utilisateur trouvé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez avec un autre nom',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.secondaryColor,
            backgroundImage: user.profilePicture != null
                ? NetworkImage(user.profilePicture!)
                : null,
            child: user.profilePicture == null
                ? Text(
                    user.username.isNotEmpty 
                        ? user.username[0].toUpperCase() 
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          title: Text(
            user.username,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: user.isCreator
              ? Text(
                  'Créateur',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : null,
          trailing: Icon(
            Icons.chat,
            color: AppTheme.primaryColor,
          ),
          onTap: () => _startConversation(user),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _fabScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabScaleAnimation.value,
          child: FloatingActionButton(
            onPressed: _focusSearchBar,
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  // Event handlers
  
  void _onSearchChanged(String query) async {
    setState(() {
      _showSearchResults = query.isNotEmpty;
      _isSearching = query.isNotEmpty;
    });

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    // Debounce search
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_searchController.text == query) {
      final messageProvider = context.read<MessageProvider>();
      final results = await messageProvider.searchUsers(query);
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _showSearchResults = false;
      _searchResults = [];
      _isSearching = false;
    });
  }

  void _focusSearchBar() {
    FocusScope.of(context).requestFocus(FocusNode());
    // Move cursor to search bar
  }

  void _openChat(Conversation conversation) {
    final authProvider = context.read<AuthProvider>();
    final currentUserId = authProvider.user?.id;
    
    // Find the other user in the conversation
    final otherUser = conversation.participants.firstWhere(
      (user) => user.id != currentUserId,
      orElse: () => conversation.participants.first,
    );
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatPage(
          conversationId: conversation.id,
          otherUser: otherUser,
        ),
      ),
    );
  }

  void _startConversation(User user) async {
    final messageProvider = context.read<MessageProvider>();
    final conversationId = await messageProvider.createConversation(user.id);
    
    if (conversationId != null) {
      // Find the conversation and navigate to it
      final conversation = messageProvider.conversations.firstWhere(
        (c) => c.id == conversationId,
      );
      
      _clearSearch();
      _openChat(conversation);
    }
  }

  void _deleteConversation(String conversationId) async {
    final confirmed = await showDialog<bool>(
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

    if (confirmed == true) {
      await context.read<MessageProvider>().deleteConversation(conversationId);
    }
  }
}
