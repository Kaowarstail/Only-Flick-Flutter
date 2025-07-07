import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../providers/profile_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/profile_edit/profile_header.dart';
import '../widgets/profile_edit/profile_form_section.dart';
import '../widgets/profile_edit/social_links_section.dart';
import '../widgets/profile_edit/creator_settings_section.dart';
import '../widgets/common/loading_overlay.dart';
import '../widgets/common/error_dialog.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({Key? key}) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late ProfileProvider _profileProvider;
  late AuthProvider _authProvider;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }
  
  void _initializeProviders() {
    _profileProvider = context.read<ProfileProvider>();
    _authProvider = context.read<AuthProvider>();
    
    // Charger les données du profil
    _loadProfileData();
  }
  
  Future<void> _loadProfileData() async {
    final user = _authProvider.user;
    if (user != null) {
      await _profileProvider.loadUserProfile(user.id);
      
      // Si l'utilisateur est créateur, charger aussi le profil créateur
      if (user.isCreator) {
        // Assumons que l'ID créateur est le même que l'ID utilisateur
        await _profileProvider.loadCreatorProfile(user.id);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.backgroundPrimary,
          appBar: _buildAppBar(context, profileProvider),
          body: LoadingOverlay(
            isLoading: profileProvider.isWorking,
            child: _buildBody(context, profileProvider),
          ),
        );
      },
    );
  }
  
  PreferredSizeWidget _buildAppBar(BuildContext context, ProfileProvider profileProvider) {
    return AppBar(
      backgroundColor: AppColors.surfacePrimary,
      elevation: 0,
      title: Text(
        'Éditer le profil',
        style: AppTextStyles.heading2.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => _handleBackPressed(context, profileProvider),
      ),
      actions: [
        TextButton(
          onPressed: profileProvider.isFormValid && profileProvider.hasUnsavedChanges
              ? () => _handleSave(context, profileProvider)
              : null,
          child: Text(
            'Sauvegarder',
            style: AppTextStyles.bodyMedium.copyWith(
              color: profileProvider.isFormValid && profileProvider.hasUnsavedChanges
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBody(BuildContext context, ProfileProvider profileProvider) {
    if (profileProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (profileProvider.loadingState == ProfileLoadingState.error) {
      return _buildErrorState(context, profileProvider);
    }
    
    return RefreshIndicator(
      onRefresh: () => profileProvider.refresh(),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec photo de profil
            ProfileHeader(
              userProfile: profileProvider.userProfile,
              creatorProfile: profileProvider.creatorProfile,
              tempAvatarFile: profileProvider.tempAvatarFile,
              tempBannerFile: profileProvider.tempBannerFile,
              onPickAvatar: profileProvider.pickAvatar,
              onPickBanner: profileProvider.pickBanner,
              onRemoveAvatar: profileProvider.removeTempAvatar,
              onRemoveBanner: profileProvider.removeTempBanner,
            ),
            
            const SizedBox(height: 24),
            
            // Section informations de base
            ProfileFormSection(
              usernameController: profileProvider.usernameController,
              displayNameController: profileProvider.displayNameController,
              bioController: profileProvider.bioController,
              validationErrors: profileProvider.validationErrors,
              onFieldChanged: profileProvider.validateField,
              onUsernameChanged: _handleUsernameChanged,
            ),
            
            const SizedBox(height: 24),
            
            // Section liens sociaux
            SocialLinksSection(
              twitterController: profileProvider.twitterController,
              instagramController: profileProvider.instagramController,
              tiktokController: profileProvider.tiktokController,
              youtubeController: profileProvider.youtubeController,
              websiteController: profileProvider.websiteController,
              validationErrors: profileProvider.validationErrors,
              onFieldChanged: profileProvider.validateField,
            ),
            
            const SizedBox(height: 24),
            
            // Section paramètres créateur (si applicable)
            if (profileProvider.creatorProfile != null) ...[
              CreatorSettingsSection(
                creatorProfile: profileProvider.creatorProfile!,
                subscriptionPriceController: profileProvider.subscriptionPriceController,
                validationErrors: profileProvider.validationErrors,
                onFieldChanged: profileProvider.validateField,
                earnings: profileProvider.creatorEarnings,
              ),
              const SizedBox(height: 24),
            ],
            
            // Bouton de sauvegarde (version mobile)
            if (MediaQuery.of(context).size.width < 768) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: profileProvider.isFormValid && profileProvider.hasUnsavedChanges
                      ? () => _handleSave(context, profileProvider)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Sauvegarder les modifications',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorState(BuildContext context, ProfileProvider profileProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profileProvider.errorMessage ?? 'Une erreur inconnue est survenue',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => profileProvider.refresh(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Réessayer',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _handleUsernameChanged(String value) {
    // Valider en temps réel
    _profileProvider.validateField('username', value);
    
    // Vérifier la disponibilité avec debounce
    if (value.isNotEmpty && _profileProvider.validationErrors['username'] == null) {
      _debounceUsernameCheck(value);
    }
  }
  
  Timer? _usernameCheckTimer;
  void _debounceUsernameCheck(String username) {
    _usernameCheckTimer?.cancel();
    _usernameCheckTimer = Timer(const Duration(milliseconds: 500), () {
      _profileProvider.checkUsernameAvailability(username).then((isAvailable) {
        if (!isAvailable) {
          _profileProvider.validateField('username', '');
          _profileProvider.validationErrors['username'] = 'Ce nom d\'utilisateur n\'est pas disponible';
        }
      });
    });
  }
  
  void _handleBackPressed(BuildContext context, ProfileProvider profileProvider) {
    if (profileProvider.hasUnsavedChanges) {
      _showUnsavedChangesDialog(context, profileProvider);
    } else {
      Navigator.of(context).pop();
    }
  }
  
  void _showUnsavedChangesDialog(BuildContext context, ProfileProvider profileProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfacePrimary,
        title: Text(
          'Modifications non sauvegardées',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Vous avez des modifications non sauvegardées. Souhaitez-vous les sauvegarder avant de quitter ?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              profileProvider.clearTempChanges();
              Navigator.of(context).pop();
            },
            child: Text(
              'Ignorer',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Annuler',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await _handleSave(context, profileProvider);
              if (success) {
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Sauvegarder',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<bool> _handleSave(BuildContext context, ProfileProvider profileProvider) async {
    final success = await profileProvider.saveProfile();
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profil sauvegardé avec succès',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ErrorDialog.show(
        context,
        title: 'Erreur de sauvegarde',
        message: profileProvider.errorMessage ?? 'Impossible de sauvegarder le profil',
      );
    }
    
    return success;
  }
  
  @override
  void dispose() {
    _usernameCheckTimer?.cancel();
    super.dispose();
  }
}
