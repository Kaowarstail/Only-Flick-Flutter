import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/admin_models.dart';
import '../../services/admin_api_service.dart';

class UserManagementWidget extends StatefulWidget {
  const UserManagementWidget({super.key});

  @override
  State<UserManagementWidget> createState() => _UserManagementWidgetState();
}

class _UserManagementWidgetState extends State<UserManagementWidget> {
  AdminUsersResponse? _usersResponse;
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedRole;
  String? _selectedStatus;
  int _currentPage = 1;

  final List<String> _roles = ['admin', 'creator', 'subscriber'];
  final List<String> _statuses = ['active', 'inactive', 'banned'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await AdminApiService.getUsers(
        page: _currentPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        role: _selectedRole,
        status: _selectedStatus,
      );
      setState(() {
        _usersResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1;
    });
    _loadUsers();
  }

  void _onFilterChanged() {
    setState(() {
      _currentPage = 1;
    });
    _loadUsers();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec filtres
          _buildHeader(),
          const SizedBox(height: 24),

          // Contenu
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null)
            _buildErrorState()
          else if (_usersResponse != null)
            _buildUsersTable()
          else
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '👥',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Gestion des utilisateurs',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Gérez les utilisateurs, leurs rôles et leurs accès',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 24),

        // Barre de recherche et filtres
        Row(
          children: [
            // Recherche
            Expanded(
              flex: 2,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher par nom, email, username...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: _onSearch,
              ),
            ),
            const SizedBox(width: 16),

            // Filtre par rôle
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'Rôle',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Tous les rôles')),
                  ..._roles.map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(_getRoleText(role)),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                  _onFilterChanged();
                },
              ),
            ),
            const SizedBox(width: 16),

            // Filtre par statut
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Tous les statuts')),
                  ..._statuses.map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusText(status)),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                  _onFilterChanged();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUsersTable() {
    final users = _usersResponse!.users;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistiques
            Row(
              children: [
                Text(
                  '${_usersResponse!.totalCount} utilisateur(s) trouvé(s)',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  'Page ${_usersResponse!.currentPage} sur ${_usersResponse!.totalPages}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Table
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2), // Utilisateur
                1: FlexColumnWidth(1), // Rôle
                2: FlexColumnWidth(1), // Statut
                3: FlexColumnWidth(1), // Dernière connexion
                4: FlexColumnWidth(2), // Actions
              },
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                  ),
                  children: [
                    _buildTableHeader('Utilisateur'),
                    _buildTableHeader('Rôle'),
                    _buildTableHeader('Statut'),
                    _buildTableHeader('Dernière connexion'),
                    _buildTableHeader('Actions'),
                  ],
                ),
                // Données
                ...users.map((user) => _buildUserRow(user)),
              ],
            ),

            const SizedBox(height: 16),

            // Pagination
            if (_usersResponse!.totalPages > 1) _buildPagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  TableRow _buildUserRow(AdminUserItem user) {
    return TableRow(
      children: [
        // Utilisateur
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: user.profilePicture != null
                    ? NetworkImage(user.profilePicture!)
                    : null,
                backgroundColor: Colors.purple.shade100,
                child: user.profilePicture == null
                    ? Text(
                        user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
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
                      user.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      user.email,
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

        // Rôle
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getRoleColor(user.role).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getRoleColor(user.role).withValues(alpha: 0.3)),
            ),
            child: Text(
              user.roleDisplayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getRoleColor(user.role),
              ),
            ),
          ),
        ),

        // Statut
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(user).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getStatusColor(user).withValues(alpha: 0.3)),
            ),
            child: Text(
              user.statusDisplayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(user),
              ),
            ),
          ),
        ),

        // Dernière connexion
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            user.lastLogin != null
                ? _formatDate(user.lastLogin!)
                : 'Jamais',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),

        // Actions
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user.role != 'admin') ...[
                // Changer le rôle
                IconButton(
                  onPressed: () => _showRoleDialog(user),
                  icon: const Icon(Icons.person_outline, size: 18),
                  tooltip: 'Changer le rôle',
                ),
                // Bannir/Débannir
                if (!user.isBanned)
                  IconButton(
                    onPressed: () => _showBanDialog(user),
                    icon: const Icon(Icons.block, size: 18),
                    tooltip: 'Bannir',
                  )
                else
                  IconButton(
                    onPressed: () => _unbanUser(user),
                    icon: const Icon(Icons.check_circle, size: 18),
                    tooltip: 'Débannir',
                  ),
                // Supprimer
                IconButton(
                  onPressed: () => _showDeleteDialog(user),
                  icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade600),
                  tooltip: 'Supprimer',
                ),
              ] else ...[
                Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _usersResponse!.hasPreviousPage ? () => _onPageChanged(_usersResponse!.currentPage - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        const SizedBox(width: 16),
        Text(
          'Page ${_usersResponse!.currentPage} sur ${_usersResponse!.totalPages}',
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: _usersResponse!.hasNextPage ? () => _onPageChanged(_usersResponse!.currentPage + 1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Une erreur inattendue s\'est produite',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadUsers,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun utilisateur trouvé',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialogs et actions
  void _showRoleDialog(AdminUserItem user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Changer le rôle de ${user.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Rôle actuel: ${user.roleDisplayName}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: user.role,
              decoration: const InputDecoration(
                labelText: 'Nouveau rôle',
                border: OutlineInputBorder(),
              ),
              items: _roles.map((role) => DropdownMenuItem(
                value: role,
                child: Text(_getRoleText(role)),
              )).toList(),
              onChanged: (newRole) {
                if (newRole != null && newRole != user.role) {
                  Navigator.of(context).pop();
                  _updateUserRole(user, newRole);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showBanDialog(AdminUserItem user) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bannir ${user.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Êtes-vous sûr de vouloir bannir cet utilisateur ?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Raison du bannissement',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _banUser(user, reasonController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Bannir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(AdminUserItem user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer ${user.displayName}'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer définitivement cet utilisateur ? '
          'Cette action est irréversible et supprimera toutes ses données.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteUser(user);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Actions
  Future<void> _updateUserRole(AdminUserItem user, String newRole) async {
    try {
      await AdminApiService.updateUserRole(userId: user.id, newRole: newRole);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rôle mis à jour avec succès')),
        );
      }
      _loadUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _banUser(AdminUserItem user, String reason) async {
    try {
      await AdminApiService.updateUserStatus(userId: user.id, isBanned: true, reason: reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilisateur banni avec succès')),
        );
      }
      _loadUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _unbanUser(AdminUserItem user) async {
    try {
      await AdminApiService.updateUserStatus(userId: user.id, isBanned: false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilisateur débanni avec succès')),
        );
      }
      _loadUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteUser(AdminUserItem user) async {
    try {
      await AdminApiService.deleteUser(userId: user.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilisateur supprimé avec succès')),
        );
      }
      _loadUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Utilitaires
  String _getRoleText(String role) {
    switch (role) {
      case 'admin':
        return 'Administrateur';
      case 'creator':
        return 'Créateur';
      case 'subscriber':
        return 'Abonné';
      default:
        return role;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Actifs';
      case 'inactive':
        return 'Inactifs';
      case 'banned':
        return 'Bannis';
      default:
        return status;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'creator':
        return Colors.purple;
      case 'subscriber':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(AdminUserItem user) {
    if (user.isBanned) return Colors.red;
    if (!user.isActive) return Colors.orange;
    return Colors.green;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour(s)';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure(s)';
    } else {
      return 'Il y a ${difference.inMinutes} minute(s)';
    }
  }
}
