import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mon Profil',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              // Logout
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            icon: Icon(
              Icons.logout,
              color: AppTheme.textColor,
            ),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          
          if (user == null) {
            return const Center(
              child: Text('Aucune donnée utilisateur'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Photo de profil
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  backgroundImage: user.profilePicture != null
                      ? NetworkImage(user.profilePicture!)
                      : null,
                  child: user.profilePicture == null
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: AppTheme.primaryColor,
                        )
                      : null,
                ),
                const SizedBox(height: 24),

                // Nom d'utilisateur
                Text(
                  '@${user.username}',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 8),

                // Email
                Text(
                  user.email,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Statistiques
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('Publications', '0'),
                    _buildStatItem('Abonnés', '0'),
                    _buildStatItem('Abonnements', '0'),
                  ],
                ),
                const SizedBox(height: 32),

                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Édition du profil bientôt disponible'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Modifier le profil',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Partage bientôt disponible'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: AppTheme.textColor,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Icon(Icons.share),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Section Bio/À propos
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'À propos',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Bienvenue sur mon profil OnlyFlick ! 🎬\nPassionné(e) de contenu créatif.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Informations du compte
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations du compte',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('ID', user.id),
                      _buildInfoRow('Rôle', user.role.name),
                      _buildInfoRow('Créé le', _formatDate(user.createdAt)),
                      if (user.updatedAt != null)
                        _buildInfoRow('Modifié le', _formatDate(user.updatedAt!)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textColor,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
