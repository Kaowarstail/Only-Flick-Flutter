import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/content_api_service.dart';
import '../models/user_models.dart';
import '../theme/app_theme.dart';

class CreateContentPage extends StatefulWidget {
  const CreateContentPage({super.key});

  @override
  State<CreateContentPage> createState() => _CreateContentPageState();
}

class _CreateContentPageState extends State<CreateContentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedType = 'image';
  bool _isPremium = false;
  bool _isPublished = true;
  bool _isLoading = false;
  File? _selectedMedia;
  XFile? _selectedXFile; // Pour Web compatibility
  
  final ImagePicker _picker = ImagePicker();

  // Méthode pour construire une image compatible Web
  Widget _buildWebImage() {
    if (_selectedXFile == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image, size: 48),
      );
    }

    if (kIsWeb) {
      // Sur le Web, on affiche juste un indicateur que l'image est sélectionnée
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey.shade200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              size: 48,
              color: Colors.green.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              'Image sélectionnée',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.green.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _selectedXFile!.name,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image, size: 48),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    try {
      XFile? pickedFile;
      
      if (_selectedType == 'image') {
        pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
      } else if (_selectedType == 'video') {
        pickedFile = await _picker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(minutes: 10),
        );
      }
      
      if (pickedFile != null) {
        setState(() {
          _selectedXFile = pickedFile;
          // Pour la compatibilité non-Web, on garde aussi File
          if (!kIsWeb) {
            _selectedMedia = File(pickedFile!.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection du média: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createContent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur non connecté'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validation selon le rôle utilisateur
    final validationError = ContentApiService.validateContentData(
      title: _titleController.text,
      description: _descriptionController.text,
      type: _selectedType,
      userRole: user.role,
      isPremium: _isPremium,
    );

    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Créer le contenu
      final createResponse = await ContentApiService.createContent(
        title: _titleController.text,
        description: _descriptionController.text,
        type: _selectedType,
        isPremium: _isPremium,
        isPublished: _isPublished,
      );

      // Vérifier si la création a réussi
      if (createResponse['success'] != true) {
        throw Exception(createResponse['error'] ?? 'Erreur lors de la création du contenu');
      }

      // 2. Si un média est sélectionné, l'uploader
      if ((_selectedMedia != null || _selectedXFile != null) && (_selectedType == 'image' || _selectedType == 'video')) {
        final contentId = createResponse['id'] as int;
        
        Map<String, dynamic> uploadResult;
        
        if (kIsWeb && _selectedXFile != null) {
          // Sur Web, utiliser XFile
          uploadResult = await ContentApiService.uploadContentMediaFromXFile(
            contentId: contentId,
            mediaFile: _selectedXFile!,
          );
        } else if (_selectedMedia != null) {
          // Sur mobile/desktop, utiliser File
          uploadResult = await ContentApiService.uploadContentMedia(
            contentId: contentId,
            mediaFile: _selectedMedia!,
          );
        } else {
          throw Exception('Aucun fichier sélectionné');
        }
        
        // Vérifier le résultat de l'upload
        if (uploadResult['success'] != true) {
          throw Exception(uploadResult['error'] ?? 'Erreur lors de l\'upload du média');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contenu créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Retour à la page précédente
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Créer du contenu',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textColor),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          if (user == null) {
            return const Center(
              child: Text('Utilisateur non connecté'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Information sur les permissions
                  _buildPermissionInfo(user),
                  const SizedBox(height: 24),

                  // Type de contenu
                  _buildContentTypeSelector(),
                  const SizedBox(height: 24),

                  // Titre
                  _buildTitleField(),
                  const SizedBox(height: 16),

                  // Description
                  _buildDescriptionField(),
                  const SizedBox(height: 24),

                  // Sélection de média (pour image et vidéo)
                  if (_selectedType != 'text') ...[
                    _buildMediaSelector(),
                    const SizedBox(height: 24),
                  ],

                  // Options de publication
                  _buildPublishingOptions(user),
                  const SizedBox(height: 32),

                  // Bouton de création
                  _buildCreateButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPermissionInfo(User user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: user.role == UserRole.creator 
            ? AppTheme.primaryColor.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: user.role == UserRole.creator 
              ? AppTheme.primaryColor.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                user.role == UserRole.creator ? Icons.star : Icons.info,
                color: user.role == UserRole.creator 
                    ? AppTheme.primaryColor 
                    : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                user.role == UserRole.creator 
                    ? 'Compte Créateur' 
                    : 'Compte Abonné',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: user.role == UserRole.creator 
                      ? AppTheme.primaryColor 
                      : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            user.role == UserRole.creator
                ? 'Vous pouvez publier du contenu gratuit et premium.'
                : 'Vous pouvez uniquement publier du contenu gratuit.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type de contenu',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildTypeChip('image', 'Photo', Icons.image),
            const SizedBox(width: 12),
            _buildTypeChip('video', 'Vidéo', Icons.videocam),
            const SizedBox(width: 12),
            _buildTypeChip('text', 'Texte', Icons.article),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(String type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
            if (type == 'text') {
              _selectedMedia = null; // Reset media for text type
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryColor.withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? AppTheme.primaryColor
                  : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected 
                    ? AppTheme.primaryColor
                    : Colors.grey.shade600,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected 
                      ? AppTheme.primaryColor
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Titre *',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'Donnez un titre accrocheur à votre contenu',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryColor),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le titre est requis';
            }
            if (value.length > 200) {
              return 'Le titre ne peut pas dépasser 200 caractères';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          maxLength: 2000,
          decoration: InputDecoration(
            hintText: 'Décrivez votre contenu...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryColor),
            ),
          ),
          validator: (value) {
            if (value != null && value.length > 2000) {
              return 'La description ne peut pas dépasser 2000 caractères';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMediaSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Média',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickMedia,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: _selectedXFile != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _selectedType == 'image'
                            ? kIsWeb
                                ? _buildWebImage()
                                : _selectedMedia != null
                                    ? Image.file(
                                        _selectedMedia!,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        color: Colors.grey.shade200,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.image,
                                              size: 48,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Image sélectionnée',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                            : Container(
                                width: double.infinity,
                                height: double.infinity,
                                color: Colors.black,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.play_circle_outline,
                                      color: Colors.white,
                                      size: 64,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Vidéo sélectionnée',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMedia = null;
                              _selectedXFile = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _selectedType == 'image' 
                            ? Icons.add_photo_alternate
                            : Icons.videocam,
                        size: 48,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedType == 'image'
                            ? 'Appuyez pour ajouter une photo'
                            : 'Appuyez pour ajouter une vidéo',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPublishingOptions(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Options de publication',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 12),
        
        // Option Premium (uniquement pour les créateurs)
        if (ContentApiService.canPublishPremium(user.role))
          CheckboxListTile(
            value: _isPremium,
            onChanged: (value) {
              setState(() {
                _isPremium = value ?? false;
              });
            },
            title: Text(
              'Contenu Premium',
              style: GoogleFonts.inter(fontSize: 14),
            ),
            subtitle: Text(
              'Accessible uniquement aux abonnés payants',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        
        // Option Publier immédiatement
        CheckboxListTile(
          value: _isPublished,
          onChanged: (value) {
            setState(() {
              _isPublished = value ?? true;
            });
          },
          title: Text(
            'Publier immédiatement',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          subtitle: Text(
            _isPublished 
                ? 'Le contenu sera visible immédiatement'
                : 'Le contenu sera sauvé en brouillon',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _createContent,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                _isPublished ? 'Publier le contenu' : 'Sauvegarder en brouillon',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
