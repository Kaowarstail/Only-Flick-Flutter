import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/admin_models.dart';

class UserManagementCard extends StatelessWidget {
  final AdminUserItem user;
  final VoidCallback onViewDetails;
  final VoidCallback onChangeRole;
  final VoidCallback onBanUser;
  final VoidCallback onUnbanUser;
  final VoidCallback onDeleteUser;

  const UserManagementCard({
    super.key,
    required this.user,
    required this.onViewDetails,
    required this.onChangeRole,
    required this.onBanUser,
    required this.onUnbanUser,
    required this.onDeleteUser,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec informations principales
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundImage: user.profilePicture != null
                      ? NetworkImage(user.profilePicture!)
                      : null,
                  backgroundColor: Colors.grey.shade300,
                  child: user.profilePicture == null
                      ? Text(
                          user.username.isNotEmpty 
                              ? user.username[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                
                // Informations utilisateur
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.displayName,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildRoleBadge(),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Badge de statut
                _buildStatusBadge(),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Informations complémentaires
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.calendar_today,
                  label: 'Inscrit ${_formatDate(user.createdAt)}',
                ),
                const SizedBox(width: 12),
                if (user.lastLogin != null)
                  _buildInfoChip(
                    icon: Icons.access_time,
                    label: 'Dernière connexion ${_formatDate(user.lastLogin!)}',
                  ),
                if (user.role == 'creator') ...[
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    icon: Icons.people,
                    label: '${user.subscriberCount ?? 0} abonnés',
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    icon: Icons.content_copy,
                    label: '${user.contentCount ?? 0} contenus',
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Actions
            Row(
              children: [
                // Voir détails
                ElevatedButton.icon(
                  onPressed: onViewDetails,
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Détails'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade700,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Changer rôle
                ElevatedButton.icon(
                  onPressed: onChangeRole,
                  icon: const Icon(Icons.admin_panel_settings, size: 16),
                  label: const Text('Rôle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade50,
                    foregroundColor: Colors.purple.shade700,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Bannir/Débannir
                if (user.isBanned)
                  ElevatedButton.icon(
                    onPressed: onUnbanUser,
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text('Débannir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade50,
                      foregroundColor: Colors.green.shade700,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: onBanUser,
                    icon: const Icon(Icons.block, size: 16),
                    label: const Text('Bannir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade50,
                      foregroundColor: Colors.orange.shade700,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                
                const Spacer(),
                
                // Supprimer (bouton dangereux)
                IconButton(
                  onPressed: onDeleteUser,
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade400,
                  ),
                  tooltip: 'Supprimer l\'utilisateur',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge() {
    Color color;
    String emoji;
    
    switch (user.role) {
      case 'admin':
        color = Colors.red;
        emoji = '👑';
        break;
      case 'creator':
        color = Colors.purple;
        emoji = '🧑‍🎨';
        break;
      case 'subscriber':
        color = Colors.blue;
        emoji = '👤';
        break;
      default:
        color = Colors.grey;
        emoji = '❓';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            user.roleDisplayName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _getColorShade700(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;
    IconData icon;
    
    if (user.isBanned) {
      color = Colors.red;
      text = 'Banni';
      icon = Icons.block;
    } else if (!user.isActive) {
      color = Colors.grey;
      text = 'Inactif';
      icon = Icons.pause_circle_outline;
    } else if (!user.isEmailVerified) {
      color = Colors.orange;
      text = 'Email non vérifié';
      icon = Icons.email_outlined;
    } else {
      color = Colors.green;
      text = 'Actif';
      icon = Icons.check_circle;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: _getColorShade700(color),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _getColorShade700(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorShade700(Color color) {
    if (color == Colors.red) return Colors.red.shade700;
    if (color == Colors.purple) return Colors.purple.shade700;
    if (color == Colors.blue) return Colors.blue.shade700;
    if (color == Colors.green) return Colors.green.shade700;
    if (color == Colors.orange) return Colors.orange.shade700;
    if (color == Colors.grey) return Colors.grey.shade700;
    return color;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return 'il y a ${difference.inMinutes}min';
      }
      return 'il y a ${difference.inHours}h';
    } else if (difference.inDays < 30) {
      return 'il y a ${difference.inDays}j';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'il y a ${months}mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'il y a ${years}an${years > 1 ? 's' : ''}';
    }
  }
}
