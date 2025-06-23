import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/content.dart';
import '../theme/app_theme.dart';
import '../services/feed_service.dart';
import 'comments_bottom_sheet.dart';

class FeedCard extends StatefulWidget {
  final FeedItem feedItem;
  final VoidCallback? onLikeToggle;
  final VoidCallback? onCommentTap;

  const FeedCard({
    super.key,
    required this.feedItem,
    this.onLikeToggle,
    this.onCommentTap,
  });

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> with SingleTickerProviderStateMixin {
  late bool _isLiked;
  late int _likesCount;
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;
  bool _isLikeLoading = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.feedItem.isLikedByUser;
    _likesCount = widget.feedItem.likesCount;
    
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _likeAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _likeAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    if (_isLikeLoading) return;
    
    setState(() {
      _isLikeLoading = true;
    });

    try {
      final response = await FeedService.toggleLike(widget.feedItem.id);
      
      if (!_isLiked) {
        _likeAnimationController.forward().then((_) {
          _likeAnimationController.reverse();
        });
      }

      setState(() {
        _isLiked = !_isLiked;
        _likesCount = response['likes_count'] ?? (_isLiked ? _likesCount + 1 : _likesCount - 1);
      });

      widget.onLikeToggle?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLikeLoading = false;
        });
      }
    }
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(
        contentId: widget.feedItem.id,
        initialCommentsCount: widget.feedItem.commentsCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec informations du créateur
          _buildHeader(),
          
          // Contenu principal
          _buildContent(),
          
          // Média (si présent)
          if (widget.feedItem.mediaUrl != null) _buildMedia(),
          
          // Actions (like, comment, partage)
          _buildActions(),
          
          // Statistiques
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Photo de profil du créateur
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            backgroundImage: widget.feedItem.creator.profilePicture != null
                ? NetworkImage(widget.feedItem.creator.profilePicture!)
                : null,
            child: widget.feedItem.creator.profilePicture == null
                ? Icon(
                    Icons.person,
                    size: 20,
                    color: AppTheme.primaryColor,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          
          // Nom et rôle du créateur
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.feedItem.creator.username,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor,
                  ),
                ),
                if (widget.feedItem.creator.role == 'creator')
                  Row(
                    children: [
                      Icon(
                        Icons.verified,
                        size: 14,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Créateur',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // Date de publication
          Text(
            _formatDate(widget.feedItem.createdAt),
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text(
            widget.feedItem.title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textColor,
            ),
          ),
          
          if (widget.feedItem.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.feedItem.description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedia() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade200,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: widget.feedItem.thumbnailUrl != null
            ? Image.network(
                widget.feedItem.thumbnailUrl!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildMediaPlaceholder();
                },
              )
            : _buildMediaPlaceholder(),
      ),
    );
  }

  Widget _buildMediaPlaceholder() {
    IconData icon;
    switch (widget.feedItem.type) {
      case 'video':
        icon = Icons.play_circle_filled;
        break;
      case 'image':
        icon = Icons.image;
        break;
      case 'gallery':
        icon = Icons.photo_library;
        break;
      default:
        icon = Icons.article;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            widget.feedItem.type.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Bouton Like
          AnimatedBuilder(
            animation: _likeAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _likeAnimation.value,
                child: IconButton(
                  onPressed: _isLikeLoading ? null : _toggleLike,
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : AppTheme.textSecondaryColor,
                  ),
                ),
              );
            },
          ),
          
          // Bouton Commentaire
          IconButton(
            onPressed: _showComments,
            icon: Icon(
              Icons.comment_outlined,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          
          // Bouton Partage (placeholder)
          IconButton(
            onPressed: () {
              // TODO: Implémenter le partage
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Partage bientôt disponible'),
                ),
              );
            },
            icon: Icon(
              Icons.share_outlined,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          
          const Spacer(),
          
          // Nombre de vues
          Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 16,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.feedItem.viewCount}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    if (_likesCount == 0 && widget.feedItem.commentsCount == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_likesCount > 0) ...[
            GestureDetector(
              onTap: () {
                // TODO: Afficher la liste des utilisateurs qui ont liké
              },
              child: Text(
                _likesCount == 1 ? '1 j\'aime' : '$_likesCount j\'aimes',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
            ),
          ],
          
          if (widget.feedItem.commentsCount > 0) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: _showComments,
              child: Text(
                widget.feedItem.commentsCount == 1
                    ? 'Voir le commentaire'
                    : 'Voir les ${widget.feedItem.commentsCount} commentaires',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Maintenant';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
