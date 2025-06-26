import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/content_models.dart';
import '../models/user_models.dart';
import '../models/user.dart' as auth_user;
import '../providers/auth_provider.dart';
import '../services/content_interaction_service.dart';
import '../theme/app_theme.dart';

class CommentsBottomSheet extends StatefulWidget {
  final Content content;

  const CommentsBottomSheet({
    super.key,
    required this.content,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isSubmitting = false;
  bool _isLoading = true;

  // Helper method to convert auth User to content User
  User? _convertAuthUser(auth_user.User? authUser) {
    if (authUser == null) return null;
    
    return User(
      id: authUser.id,
      username: authUser.username,
      email: authUser.email,
      profilePicture: authUser.profilePicture,
      role: UserRole.subscriber, // Default role
      createdAt: authUser.createdAt,
      updatedAt: authUser.updatedAt ?? DateTime.now(),
    );
  }

  @override
  void initState() {
    super.initState();
    // Charger les commentaires existants
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<ContentInteractionService>().loadComments(widget.content.id);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ContentInteractionService, AuthProvider>(
      builder: (context, interactionService, authProvider, child) {
        final comments = interactionService.getComments(widget.content.id);
        final authUser = authProvider.user;
        final currentUser = _convertAuthUser(authUser);

        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Commentaires',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Comments list
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : comments.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              return _buildCommentItem(comment, currentUser);
                            },
                          ),
              ),

              // Comment input
              if (currentUser != null) _buildCommentInput(currentUser, interactionService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Chargement des commentaires...',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Pas encore de commentaires',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Soyez le premier à commenter !',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, User? currentUser) {
    final isOwnComment = currentUser?.id == comment.userId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            backgroundImage: comment.user?.profilePicture != null
                ? NetworkImage(comment.user!.profilePicture!)
                : null,
            child: comment.user?.profilePicture == null
                ? Icon(
                    Icons.person,
                    size: 16,
                    color: AppTheme.primaryColor,
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username and time
                Row(
                  children: [
                    Text(
                      comment.user?.username ?? 'Utilisateur',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(comment.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    if (isOwnComment) ...[
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _showDeleteDialog(comment),
                        child: Icon(
                          Icons.more_horiz,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),

                // Comment text
                Text(
                  comment.text,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(User currentUser, ContentInteractionService interactionService) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            backgroundImage: currentUser.profilePicture != null
                ? NetworkImage(currentUser.profilePicture!)
                : null,
            child: currentUser.profilePicture == null
                ? Icon(
                    Icons.person,
                    size: 16,
                    color: AppTheme.primaryColor,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _commentController,
              focusNode: _commentFocusNode,
              decoration: InputDecoration(
                hintText: 'Ajouter un commentaire...',
                hintStyle: GoogleFonts.inter(
                  color: AppTheme.textSecondaryColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (value) => _submitComment(interactionService, currentUser),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isSubmitting ? null : () => _submitComment(interactionService, currentUser),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _commentController.text.trim().isEmpty || _isSubmitting
                    ? Colors.grey.shade300
                    : AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send,
                size: 20,
                color: _commentController.text.trim().isEmpty || _isSubmitting
                    ? Colors.grey.shade600
                    : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitComment(ContentInteractionService interactionService, User currentUser) async {
    if (_commentController.text.trim().isEmpty || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await interactionService.addComment(
        widget.content.id,
        _commentController.text,
      );
      _commentController.clear();
      _commentFocusNode.unfocus();
      
      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Commentaire ajouté avec succès'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Afficher un message d'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout du commentaire: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showDeleteDialog(Comment comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Supprimer le commentaire',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ce commentaire ?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Annuler',
              style: GoogleFonts.inter(color: AppTheme.textSecondaryColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                await context.read<ContentInteractionService>().deleteComment(
                  widget.content.id,
                  comment.id,
                );
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Commentaire supprimé avec succès'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la suppression: ${e.toString()}'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            child: Text(
              'Supprimer',
              style: GoogleFonts.inter(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${difference.inDays}j';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'maintenant';
    }
  }
}
