import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/content_interaction_provider.dart';
import '../services/content_interaction_service.dart';
import '../theme/app_theme.dart';
import '../services/content_service.dart';
import '../models/content_models.dart';
import '../widgets/comments_bottom_sheet.dart';
import 'profile_page.dart';
import 'create_content_page.dart';

class InstagramStyleHomePage extends StatefulWidget {
  const InstagramStyleHomePage({super.key});

  @override
  State<InstagramStyleHomePage> createState() => _InstagramStyleHomePageState();
}

class _InstagramStyleHomePageState extends State<InstagramStyleHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const FeedPage(),
    const ExplorePage(),
    const CreateContentPage(),
    const ActivityPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Navbar en haut (seulement pour la page Feed)
            if (_currentIndex == 0) _buildTopNavBar(),
            // Contenu principal
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
            ),
          ],
        ),
      ),
      // Navbar en bas comme Instagram
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTopNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo OnlyFlick
          Text(
            'OnlyFlick',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          
          // Actions de droite
          Row(
            children: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications bientôt disponibles')),
                  );
                },
                icon: Icon(
                  Icons.favorite_outline,
                  color: AppTheme.textColor,
                  size: 24,
                ),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Messages bientôt disponibles')),
                  );
                },
                icon: Icon(
                  Icons.messenger_outline,
                  color: AppTheme.textColor,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: _currentIndex == 0 ? Icons.home : Icons.home_outlined,
            index: 0,
          ),
          _buildNavItem(
            icon: _currentIndex == 1 ? Icons.search : Icons.search_outlined,
            index: 1,
          ),
          _buildNavItem(
            icon: _currentIndex == 2 ? Icons.add_box : Icons.add_box_outlined,
            index: 2,
          ),
          _buildNavItem(
            icon: _currentIndex == 3 ? Icons.favorite : Icons.favorite_outline,
            index: 3,
          ),
          _buildProfileNavItem(),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: isSelected ? AppTheme.textColor : Colors.grey,
          size: 26,
        ),
      ),
    );
  }

  Widget _buildProfileNavItem() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final isSelected = _currentIndex == 4;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentIndex = 4;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected 
                  ? Border.all(color: AppTheme.textColor, width: 2)
                  : null,
            ),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              backgroundImage: user?.profilePicture != null
                  ? NetworkImage(user!.profilePicture!)
                  : null,
              child: user?.profilePicture == null
                  ? Icon(
                      Icons.person,
                      size: 16,
                      color: AppTheme.primaryColor,
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}

// Page Feed (contenu principal)
class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  void initState() {
    super.initState();
    // Initialiser les données d'interaction
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final feedContent = ContentService.getMockFeedContent();
      // Initialisation du provider d'interaction
      final provider = context.read<ContentInteractionProvider>();
      for (var content in feedContent) {
        provider.loadContentState(content, null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Stories (horizontal scroll)
          _buildStoriesSection(),
          
          // Feed posts
          _buildFeedPosts(),
        ],
      ),
    );
  }

  Widget _buildStoriesSection() {
    final storiesUsers = ContentService.getStoriesUsers();
    
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: storiesUsers.length + 1, // +1 for "Your story"
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: index == 0 ? null : LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                        ),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: index == 0
                          ? CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.grey.shade200,
                              child: Icon(
                                Icons.person,
                                color: Colors.grey.shade600,
                              ),
                            )
                          : CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 26,
                                backgroundImage: storiesUsers[index - 1].profilePicture != null
                                    ? NetworkImage(storiesUsers[index - 1].profilePicture!)
                                    : null,
                                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                child: storiesUsers[index - 1].profilePicture == null
                                    ? Icon(
                                        Icons.person,
                                        color: AppTheme.primaryColor,
                                      )
                                    : null,
                              ),
                            ),
                    ),
                    if (index == 0)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 60,
                  child: Text(
                    index == 0 ? 'Votre story' : storiesUsers[index - 1].username,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeedPosts() {
    final feedContent = ContentService.getMockFeedContent();
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: feedContent.length,
      itemBuilder: (context, index) {
        return _buildFeedPost(feedContent[index]);
      },
    );
  }

  Widget _buildFeedPost(Content content) {
    final creator = content.creator;
    if (creator == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header du post
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                backgroundImage: creator.profilePicture != null
                    ? NetworkImage(creator.profilePicture!)
                    : null,
                child: creator.profilePicture == null
                    ? Icon(
                        Icons.person,
                        size: 18,
                        color: AppTheme.primaryColor,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      creator.username,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                    ),
                    if (content.type == 'video')
                      Text(
                        '${ContentService.formatViewCount(content.viewCount)} vues',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.more_vert,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        
        // Media du post
        Stack(
          children: [
            Container(
              width: double.infinity,
              height: 300,
              color: Colors.grey.shade100,
              child: content.mediaUrl != null && content.mediaUrl!.isNotEmpty
                  ? Image.network(
                      content.mediaUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          content.isVideo ? Icons.play_circle_outline : Icons.image,
                          size: 50,
                          color: Colors.grey.shade400,
                        );
                      },
                    )
                  : Icon(
                      content.isVideo ? Icons.play_circle_outline : Icons.image,
                      size: 50,
                      color: Colors.grey.shade400,
                    ),
            ),
            // Video play button overlay
            if (content.isVideo)
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            // Premium badge
            if (content.isPremium)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PREMIUM',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        
        // Actions (like, comment, share, save)
        Consumer2<ContentInteractionService, AuthProvider>(
          builder: (context, interactionService, authProvider, child) {
            final isLiked = interactionService.isLiked(content.id);
            final user = authProvider.user;
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      if (user != null) {
                        await interactionService.toggleLike(content.id, user.id);
                      }
                    },
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_outline,
                      color: isLiked ? Colors.red : AppTheme.textColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => CommentsBottomSheet(
                          content: content,
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      color: AppTheme.textColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Implement share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Partage en cours de développement'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.send_outlined,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      // TODO: Implement save functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sauvegarde en cours de développement'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.bookmark_outline,
                      color: AppTheme.textColor,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        
        // Likes et description
        Consumer<ContentInteractionService>(
          builder: (context, interactionService, child) {
            final likeCount = interactionService.getLikeCount(content.id);
            final commentCount = interactionService.getCommentCount(content.id);
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (likeCount > 0)
                    Text(
                      ContentService.formatLikeCount(likeCount),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                    ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.textColor,
                      ),
                      children: [
                        TextSpan(
                          text: '${creator.username} ',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: content.description ?? content.title,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (commentCount > 0)
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => CommentsBottomSheet(
                            content: content,
                          ),
                        );
                      },
                      child: Text(
                        ContentService.formatCommentCount(commentCount),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    ContentService.getTimeAgo(content.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// Pages temporaires pour les autres onglets
class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Page Explorer'),
    );
  }
}

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Activités'),
    );
  }
}
