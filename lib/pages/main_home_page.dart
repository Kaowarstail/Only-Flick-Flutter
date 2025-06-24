import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'profile_page.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Navbar en haut
            _buildNavBar(),
            // Contenu principal
            Expanded(
              child: _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo OnlyFlick
          Row(
            children: [
              Icon(
                Icons.movie_creation_outlined,
                size: 28,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'OnlyFlick',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
            ],
          ),
          
          // Actions de droite
          Row(
            children: [
              // Bouton de recherche
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recherche bientôt disponible')),
                  );
                },
                icon: Icon(
                  Icons.search,
                  color: AppTheme.textColor,
                  size: 24,
                ),
              ),
              
              // Bouton de notifications
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications bientôt disponibles')),
                  );
                },
                icon: Icon(
                  Icons.notifications_outlined,
                  color: AppTheme.textColor,
                  size: 24,
                ),
              ),
              
              // Bouton profil (comme Instagram)
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final user = authProvider.user;
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        backgroundImage: user?.profilePicture != null
                            ? NetworkImage(user!.profilePicture!)
                            : null,
                        child: user?.profilePicture == null
                            ? Icon(
                                Icons.person,
                                size: 18,
                                color: AppTheme.primaryColor,
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message de bienvenue
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenue, ${user?.username ?? 'Utilisateur'} ! 👋',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Découvrez et partagez vos contenus préférés avec la communauté',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Section Feed / Contenu
              Text(
                'Feed',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 16),
              
              // Cartes de contenu (placeholder)
              _buildFeedCard(
                username: 'creator_1',
                timeAgo: 'Il y a 2h',
                content: 'Nouveau contenu disponible ! Découvrez ma dernière création...',
                imageUrl: null,
              ),
              
              _buildFeedCard(
                username: 'creator_2',
                timeAgo: 'Il y a 5h',
                content: 'Merci pour tous vos messages de soutien ! Prochaine vidéo demain 🎬',
                imageUrl: null,
              ),
              
              _buildFeedCard(
                username: 'creator_3',
                timeAgo: 'Il y a 1j',
                content: 'Session de streaming ce soir à 20h, soyez au rendez-vous !',
                imageUrl: null,
              ),
              
              const SizedBox(height: 32),
              
              // Section Découvrir
              Text(
                'Découvrir',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 16),
              
              // Grille des catégories
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildCategoryCard(
                    icon: Icons.trending_up,
                    title: 'Tendances',
                    subtitle: 'Contenu populaire',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tendances bientôt disponibles')),
                      );
                    },
                  ),
                  _buildCategoryCard(
                    icon: Icons.favorite_outline,
                    title: 'Favoris',
                    subtitle: 'Vos préférés',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Favoris bientôt disponibles')),
                      );
                    },
                  ),
                  _buildCategoryCard(
                    icon: Icons.explore_outlined,
                    title: 'Explorer',
                    subtitle: 'Nouveautés',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Explorer bientôt disponible')),
                      );
                    },
                  ),
                  _buildCategoryCard(
                    icon: Icons.group_outlined,
                    title: 'Créateurs',
                    subtitle: 'Découvrir',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Créateurs bientôt disponibles')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeedCard({
    required String username,
    required String timeAgo,
    required String content,
    String? imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec avatar et nom
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 20,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@$username',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.more_horiz,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Contenu
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textColor,
              height: 1.5,
            ),
          ),
          
          if (imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Actions (like, comment, share)
          Row(
            children: [
              _buildActionButton(Icons.favorite_outline, '12'),
              _buildActionButton(Icons.chat_bubble_outline, '3'),
              _buildActionButton(Icons.share_outlined, ''),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.bookmark_outline,
                  color: AppTheme.textSecondaryColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String count) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () {},
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.textSecondaryColor,
              size: 20,
            ),
            if (count.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                count,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
