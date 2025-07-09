import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/admin_models.dart';
import '../../services/admin_api_service.dart';

class UserActionDialog extends StatefulWidget {
  final AdminUserItem user;
  final String action;

  const UserActionDialog({
    super.key,
    required this.user,
    required this.action,
  });

  @override
  State<UserActionDialog> createState() => _UserActionDialogState();
}

class _UserActionDialogState extends State<UserActionDialog> {
  bool _isLoading = false;
  String? _selectedRole;
  String _reason = '';
  
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          _getActionIcon(),
          const SizedBox(width: 12),
          Text(
            _getActionTitle(),
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations utilisateur
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: widget.user.profilePicture != null
                        ? NetworkImage(widget.user.profilePicture!)
                        : null,
                    backgroundColor: Colors.grey.shade300,
                    child: widget.user.profilePicture == null
                        ? Text(
                            widget.user.username.isNotEmpty 
                                ? widget.user.username[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.displayName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '@${widget.user.username}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Contenu spécifique à l'action
            _buildActionContent(),
            
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _performAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: _getActionColor(),
            foregroundColor: Colors.white,
          ),
          child: Text(_getActionButtonText()),
        ),
      ],
    );
  }

  Widget _buildActionContent() {
    switch (widget.action) {
      case 'change_role':
        return _buildChangeRoleContent();
      case 'ban':
        return _buildBanContent();
      case 'unban':
        return _buildUnbanContent();
      case 'delete':
        return _buildDeleteContent();
      default:
        return const SizedBox();
    }
  }

  Widget _buildChangeRoleContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Changer le rôle de l\'utilisateur',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Rôle actuel: ${widget.user.roleDisplayName}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          decoration: InputDecoration(
            labelText: 'Nouveau rôle',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: 'subscriber',
              child: Row(
                children: [
                  Text('👤'),
                  SizedBox(width: 8),
                  Text('Abonné'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'creator',
              child: Row(
                children: [
                  Text('🧑‍🎨'),
                  SizedBox(width: 8),
                  Text('Créateur'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'admin',
              child: Row(
                children: [
                  Text('👑'),
                  SizedBox(width: 8),
                  Text('Administrateur'),
                ],
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedRole = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildBanContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '⚠️ Bannir cet utilisateur',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.red.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'L\'utilisateur ne pourra plus se connecter à la plateforme.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _reasonController,
          decoration: InputDecoration(
            labelText: 'Raison du bannissement',
            hintText: 'Expliquez pourquoi vous bannissez cet utilisateur...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          maxLines: 3,
          onChanged: (value) {
            setState(() {
              _reason = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildUnbanContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '✅ Débannir cet utilisateur',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'L\'utilisateur pourra de nouveau se connecter à la plateforme.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🗑️ Supprimer définitivement cet utilisateur',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.red.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning,
                    size: 16,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ATTENTION: Cette action est irréversible',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• Tous les contenus de l\'utilisateur seront supprimés\n'
                '• Les abonnements et paiements seront annulés\n'
                '• Cette action ne peut pas être annulée',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _reasonController,
          decoration: InputDecoration(
            labelText: 'Raison de la suppression (obligatoire)',
            hintText: 'Expliquez pourquoi vous supprimez cet utilisateur...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          maxLines: 3,
          onChanged: (value) {
            setState(() {
              _reason = value;
            });
          },
        ),
      ],
    );
  }

  Widget _getActionIcon() {
    switch (widget.action) {
      case 'change_role':
        return const Icon(Icons.admin_panel_settings, color: Colors.purple);
      case 'ban':
        return const Icon(Icons.block, color: Colors.red);
      case 'unban':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'delete':
        return const Icon(Icons.delete_forever, color: Colors.red);
      default:
        return const Icon(Icons.help_outline);
    }
  }

  String _getActionTitle() {
    switch (widget.action) {
      case 'change_role':
        return 'Changer le rôle';
      case 'ban':
        return 'Bannir l\'utilisateur';
      case 'unban':
        return 'Débannir l\'utilisateur';
      case 'delete':
        return 'Supprimer l\'utilisateur';
      default:
        return 'Action';
    }
  }

  String _getActionButtonText() {
    switch (widget.action) {
      case 'change_role':
        return 'Changer le rôle';
      case 'ban':
        return 'Bannir';
      case 'unban':
        return 'Débannir';
      case 'delete':
        return 'Supprimer définitivement';
      default:
        return 'Confirmer';
    }
  }

  Color _getActionColor() {
    switch (widget.action) {
      case 'change_role':
        return Colors.purple;
      case 'ban':
        return Colors.red;
      case 'unban':
        return Colors.green;
      case 'delete':
        return Colors.red.shade800;
      default:
        return Colors.blue;
    }
  }

  Future<void> _performAction() async {
    // Validation
    if (widget.action == 'delete' && _reason.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une raison est obligatoire pour supprimer un utilisateur'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.action == 'change_role' && _selectedRole == widget.user.role) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le rôle sélectionné est identique au rôle actuel'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool success = false;

      switch (widget.action) {
        case 'change_role':
          success = await AdminApiService.updateUserRole(
            userId: widget.user.id,
            newRole: _selectedRole!,
          );
          break;
        case 'ban':
          success = await AdminApiService.updateUserStatus(
            userId: widget.user.id,
            isBanned: true,
            reason: _reason.isNotEmpty ? _reason : null,
          );
          break;
        case 'unban':
          success = await AdminApiService.updateUserStatus(
            userId: widget.user.id,
            isBanned: false,
          );
          break;
        case 'delete':
          success = await AdminApiService.deleteUser(
            userId: widget.user.id,
            reason: _reason,
          );
          break;
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getSuccessMessage()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getSuccessMessage() {
    switch (widget.action) {
      case 'change_role':
        return 'Rôle mis à jour avec succès';
      case 'ban':
        return 'Utilisateur banni avec succès';
      case 'unban':
        return 'Utilisateur débanni avec succès';
      case 'delete':
        return 'Utilisateur supprimé avec succès';
      default:
        return 'Action effectuée avec succès';
    }
  }
}
