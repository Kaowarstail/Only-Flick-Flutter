import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/admin_models.dart';

class UserDetailsDialog extends StatelessWidget {
  final AdminUserDetails userDetails;

  const UserDetailsDialog({
    super.key,
    required this.userDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: userDetails.profilePicture != null
                      ? NetworkImage(userDetails.profilePicture!)
                      : null,
                  backgroundColor: Colors.grey.shade300,
                  child: userDetails.profilePicture == null
                      ? Text(
                          userDetails.username.isNotEmpty 
                              ? userDetails.username[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userDetails.displayName,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '@${userDetails.username}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        userDetails.email,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informations générales
                    _buildSection(
                      title: '📋 Informations générales',
                      children: [
                        _buildInfoRow('ID', userDetails.id),
                        _buildInfoRow('Nom complet', userDetails.displayName),
                        _buildInfoRow('Nom d\'utilisateur', userDetails.username),
                        _buildInfoRow('Email', userDetails.email),
                        _buildInfoRow('Rôle', userDetails.roleDisplayName),
                        _buildInfoRow('Statut', userDetails.statusDisplayName),
                        if (userDetails.biography != null && userDetails.biography!.isNotEmpty)
                          _buildInfoRow('Biographie', userDetails.biography!),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Dates importantes
                    _buildSection(
                      title: '📅 Dates importantes',
                      children: [
                        _buildInfoRow('Inscrit le', _formatDateTime(userDetails.createdAt)),
                        if (userDetails.lastLogin != null)
                          _buildInfoRow('Dernière connexion', _formatDateTime(userDetails.lastLogin!)),
                        if (userDetails.bannedAt != null)
                          _buildInfoRow('Banni le', _formatDateTime(userDetails.bannedAt!)),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Statistiques (si créateur)
                    if (userDetails.role == 'creator') ...[
                      _buildSection(
                        title: '📊 Statistiques créateur',
                        children: [
                          _buildInfoRow('Abonnés', '${userDetails.subscriberCount ?? 0}'),
                          _buildInfoRow('Contenus publiés', '${userDetails.contentCount ?? 0}'),
                          _buildInfoRow('Revenus mensuels', '€${userDetails.monthlyRevenue?.toStringAsFixed(2) ?? '0.00'}'),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Statut de ban
                    if (userDetails.isBanned) ...[
                      _buildSection(
                        title: '🚫 Informations de bannissement',
                        children: [
                          if (userDetails.banReason != null)
                            _buildInfoRow('Raison', userDetails.banReason!),
                          if (userDetails.bannedAt != null)
                            _buildInfoRow('Date de bannissement', _formatDateTime(userDetails.bannedAt!)),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Historique de connexion (dernières entrées)
                    if (userDetails.loginHistory.isNotEmpty) ...[
                      _buildSection(
                        title: '🕒 Historique récent',
                        children: userDetails.loginHistory.take(5).map((login) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                login,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fermer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
           '${dateTime.month.toString().padLeft(2, '0')}/'
           '${dateTime.year} à '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
