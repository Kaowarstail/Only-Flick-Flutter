import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/admin_models.dart';
import '../../services/admin_api_service.dart';
import '../../theme/app_theme.dart';

class ContentManagementWidget extends StatefulWidget {
  const ContentManagementWidget({super.key});

  @override
  State<ContentManagementWidget> createState() => _ContentManagementWidgetState();
}

class _ContentManagementWidgetState extends State<ContentManagementWidget> {
  AdminContentsResponse? _contentsResponse;
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedType;
  String? _selectedStatus;
  String? _selectedCreatorId;
  int _currentPage = 1;

  final List<String> _types = ['image', 'video', 'text', 'audio'];
  final List<String> _statuses = ['published', 'unpublished', 'flagged'];

  @override
  void initState() {
    super.initState();
    _loadContents();
  }

  Future<void> _loadContents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await AdminApiService.getContents(
        page: _currentPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        type: _selectedType,
        status: _selectedStatus,
        creatorId: _selectedCreatorId,
      );
      setState(() {
        _contentsResponse = response;
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
    _loadContents();
  }

  void _onFilterChanged() {
    setState(() {
      _currentPage = 1;
    });
    _loadContents();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadContents();
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
          else if (_contentsResponse != null)
            _buildContentsGrid()
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
        Text(
          'Gestion des Contenus',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gérez tous les contenus publiés sur la plateforme',
          style: TextStyle(
            fontSize: 14,
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
                  hintText: 'Rechercher par titre...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: _onSearch,
              ),
            ),
            const SizedBox(width: 16),

            // Type de contenu
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                value: _selectedType,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Tous'),
                  ),
                  ..._types.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(_getTypeDisplayName(type)),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                  _onFilterChanged();
                },
              ),
            ),
            const SizedBox(width: 16),

            // Statut
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                value: _selectedStatus,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Tous'),
                  ),
                  ..._statuses.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(_getStatusDisplayName(status)),
                    );
                  }).toList(),
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

  Widget _buildContentsGrid() {
    final contents = _contentsResponse!.contents;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Statistiques
        Row(
          children: [
            Text(
              '${_contentsResponse!.totalCount} contenu(s) trouvé(s)',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              'Page ${_contentsResponse!.currentPage} sur ${_contentsResponse!.totalPages}',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Grille de contenus
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: contents.length,
          itemBuilder: (context, index) {
            return _buildContentCard(contents[index]);
          },
        ),

        const SizedBox(height: 24),

        // Pagination
        if (_contentsResponse!.totalPages > 1) _buildPagination(),
      ],
    );
  }

  Widget _buildContentCard(AdminContentItem content) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showContentDetailsDialog(content.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du contenu
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    content.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image, size: 50),
                      );
                    },
                  ),
                ),
                // Badges (premium, type)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(content.type).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      content.typeDisplayName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (content.isPremium)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade700.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Premium',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (content.isFlagged)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Signalé',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Infos du contenu
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Par ${content.creatorName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Statistiques du contenu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.visibility, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${content.viewCount}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.favorite, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${content.likesCount}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.comment, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${content.commentsCount}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _contentsResponse!.hasPreviousPage ? () => _onPageChanged(_contentsResponse!.currentPage - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        const SizedBox(width: 16),
        Text(
          'Page ${_contentsResponse!.currentPage} sur ${_contentsResponse!.totalPages}',
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: _contentsResponse!.hasNextPage ? () => _onPageChanged(_contentsResponse!.currentPage + 1) : null,
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
              onPressed: _loadContents,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
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
              Icons.slideshow_rounded,
              size: 64,
              color: Colors.blue.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun contenu trouvé',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez de modifier vos filtres ou d\'effectuer une autre recherche',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showContentDetailsDialog(int contentId) async {
    try {
      final contentDetails = await AdminApiService.getContentDetails(contentId.toString());
      if (contentDetails != null && mounted) {
        showDialog(
          context: context,
          builder: (context) => ContentDetailsDialog(contentDetails: contentDetails),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des détails: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getTypeDisplayName(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return 'Image';
      case 'video':
        return 'Vidéo';
      case 'text':
        return 'Texte';
      case 'audio':
        return 'Audio';
      default:
        return type;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return 'Publié';
      case 'unpublished':
        return 'Non publié';
      case 'flagged':
        return 'Signalé';
      default:
        return status;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return Colors.blue;
      case 'video':
        return Colors.red;
      case 'text':
        return Colors.green;
      case 'audio':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

// Dialog pour afficher les détails d'un contenu
class ContentDetailsDialog extends StatelessWidget {
  final AdminContentDetails contentDetails;

  const ContentDetailsDialog({
    super.key,
    required this.contentDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 900,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec image de couverture
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 16 / 6,
                    child: contentDetails.coverUrl != null
                        ? Image.network(
                            contentDetails.coverUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.network(
                                contentDetails.thumbnailUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.broken_image, size: 50),
                                  );
                                },
                              );
                            },
                          )
                        : Image.network(
                            contentDetails.thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.broken_image, size: 50),
                              );
                            },
                          ),
                  ),
                ),
                // Bouton de fermeture
                Positioned(
                  top: 16,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                // Badges
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getTypeColor(contentDetails.type).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          contentDetails.typeDisplayName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (contentDetails.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade700.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Premium',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (contentDetails.isFlagged)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.shade700.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Signalé',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre et créateur
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contentDetails.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundImage: contentDetails.creatorProfilePicture != null
                                          ? NetworkImage(contentDetails.creatorProfilePicture!)
                                          : null,
                                      backgroundColor: Colors.grey.shade300,
                                      child: contentDetails.creatorProfilePicture == null
                                          ? Text(
                                              contentDetails.creatorUsername.isNotEmpty 
                                                  ? contentDetails.creatorUsername[0].toUpperCase()
                                                  : '?',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Par ${contentDetails.creatorName}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          _buildActionButtons(context, contentDetails),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'Description',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        contentDetails.description,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),

                      // Statistiques
                      Text(
                        'Statistiques',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard(
                            icon: Icons.visibility,
                            value: contentDetails.viewCount.toString(),
                            label: 'Vues',
                            color: Colors.blue,
                          ),
                          _buildStatCard(
                            icon: Icons.favorite,
                            value: contentDetails.likesCount.toString(),
                            label: 'J\'aime',
                            color: Colors.red,
                          ),
                          _buildStatCard(
                            icon: Icons.comment,
                            value: contentDetails.commentsCount.toString(),
                            label: 'Commentaires',
                            color: Colors.green,
                          ),
                          _buildStatCard(
                            icon: Icons.flag,
                            value: contentDetails.reportsCount.toString(),
                            label: 'Signalements',
                            color: Colors.orange,
                          ),
                        ],
                      ),

                      // Si le contenu a des commentaires
                      if (contentDetails.comments.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),

                        Text(
                          'Commentaires récents',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...contentDetails.comments.take(5).map(_buildCommentItem).toList(),
                      ],

                      // Si le contenu a des signalements
                      if (contentDetails.reports.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),

                        Text(
                          'Signalements',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...contentDetails.reports.map(_buildReportItem).toList(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AdminContentDetails content) {
    return Row(
      children: [
        // Modifier
        ElevatedButton.icon(
          onPressed: () => _showEditContentDialog(context, content),
          icon: const Icon(Icons.edit),
          label: const Text('Modifier'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        
        // Supprimer
        ElevatedButton.icon(
          onPressed: () => _showDeleteContentDialog(context, content),
          icon: const Icon(Icons.delete),
          label: const Text('Supprimer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        
        // Marquer/Démarquer comme inapproprié
        ElevatedButton.icon(
          onPressed: () => _showFlagContentDialog(context, content),
          icon: Icon(content.isFlagged ? Icons.flag_outlined : Icons.flag),
          label: Text(content.isFlagged ? 'Approuver' : 'Signaler'),
          style: ElevatedButton.styleFrom(
            backgroundColor: content.isFlagged ? Colors.green : Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(AdminContentComment comment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: comment.userProfilePicture != null
                  ? NetworkImage(comment.userProfilePicture!)
                  : null,
              backgroundColor: Colors.grey.shade300,
              child: comment.userProfilePicture == null
                  ? Text(
                      comment.username.isNotEmpty ? comment.username[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(comment.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (comment.isFlagged) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Signalé',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(comment.text),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(AdminContentReport report) {
    Color statusColor;
    switch (report.status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'reviewed':
        statusColor = Colors.blue;
        break;
      case 'resolved':
        statusColor = Colors.green;
        break;
      case 'dismissed':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Signalé par ${report.reporterName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    report.statusDisplayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Raison: ${report.reason}'),
            if (report.resolution != null) ...[
              const SizedBox(height: 8),
              Text('Résolution: ${report.resolution}'),
            ],
            const SizedBox(height: 8),
            Text(
              'Signalé le ${_formatDate(report.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            if (report.resolvedAt != null)
              Text(
                'Résolu le ${_formatDate(report.resolvedAt!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showEditContentDialog(BuildContext context, AdminContentDetails content) {
    final titleController = TextEditingController(text: content.title);
    final descriptionController = TextEditingController(text: content.description);
    bool isPremium = content.isPremium;
    bool isPublished = content.isPublished;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le contenu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Contenu Premium'),
                        value: isPremium,
                        onChanged: (value) {
                          setState(() {
                            isPremium = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Publié'),
                        value: isPublished,
                        onChanged: (value) {
                          setState(() {
                            isPublished = value;
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final success = await AdminApiService.updateContent(
                  contentId: content.id.toString(),
                  title: titleController.text,
                  description: descriptionController.text,
                  isPremium: isPremium,
                  isPublished: isPublished,
                );
                
                if (success) {
                  // Fermer les deux dialogues
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  
                  // Afficher un message de succès
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contenu mis à jour avec succès')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteContentDialog(BuildContext context, AdminContentDetails content) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le contenu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Êtes-vous sûr de vouloir supprimer "${content.title}" ?'),
            const SizedBox(height: 16),
            const Text(
              'Cette action est irréversible et supprimera définitivement le contenu de la plateforme.',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Raison de la suppression (optionnel)',
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
            onPressed: () async {
              try {
                final success = await AdminApiService.deleteContent(
                  contentId: content.id.toString(),
                  reason: reasonController.text.isNotEmpty ? reasonController.text : null,
                );
                
                if (success) {
                  // Fermer les deux dialogues
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  
                  // Afficher un message de succès
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contenu supprimé avec succès')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showFlagContentDialog(BuildContext context, AdminContentDetails content) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(content.isFlagged ? 'Approuver le contenu' : 'Signaler le contenu'),
        content: content.isFlagged
            ? const Text('Êtes-vous sûr de vouloir approuver ce contenu et retirer le signalement ?')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pour quelle raison souhaitez-vous signaler ce contenu ?'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Raison du signalement',
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
            onPressed: () async {
              try {
                final success = await AdminApiService.flagContent(
                  contentId: content.id.toString(),
                  isFlagged: !content.isFlagged,
                  reason: content.isFlagged ? null : reasonController.text,
                );
                
                if (success) {
                  // Fermer les deux dialogues
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  
                  // Afficher un message de succès
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(content.isFlagged
                          ? 'Contenu approuvé avec succès'
                          : 'Contenu signalé avec succès'),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: content.isFlagged ? Colors.green : Colors.orange,
            ),
            child: Text(content.isFlagged ? 'Approuver' : 'Signaler'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return Colors.blue;
      case 'video':
        return Colors.red;
      case 'text':
        return Colors.green;
      case 'audio':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
