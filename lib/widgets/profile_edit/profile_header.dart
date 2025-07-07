import 'package:flutter/material.dart';
import 'dart:io';

import '../../models/profile_models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../common/cached_network_image.dart';
import '../common/image_picker_bottom_sheet.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile? userProfile;
  final CreatorProfile? creatorProfile;
  final File? tempAvatarFile;
  final File? tempBannerFile;
  final VoidCallback onPickAvatar;
  final VoidCallback onPickBanner;
  final VoidCallback onRemoveAvatar;
  final VoidCallback onRemoveBanner;

  const ProfileHeader({
    Key? key,
    required this.userProfile,
    required this.creatorProfile,
    required this.tempAvatarFile,
    required this.tempBannerFile,
    required this.onPickAvatar,
    required this.onPickBanner,
    required this.onRemoveAvatar,
    required this.onRemoveBanner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Bannière (pour les créateurs)
          if (creatorProfile != null) ...[
            _buildBannerSection(context),
            const SizedBox(height: 16),
          ],
          
          // Photo de profil
          _buildAvatarSection(context),
          
          const SizedBox(height: 16),
          
          // Informations de base
          _buildInfoSection(context),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildBannerSection(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        color: AppColors.backgroundSecondary,
      ),
      child: Stack(
        children: [
          // Image de bannière
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              height: 120,
              child: _buildBannerImage(),
            ),
          ),
          
          // Overlay et boutons
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bouton modifier bannière
                  _buildImageActionButton(
                    icon: Icons.camera_alt,
                    onPressed: () => _showBannerOptions(context),
                  ),
                  if (tempBannerFile != null || creatorProfile?.bannerUrl != null) ...[
                    const SizedBox(width: 8),
                    _buildImageActionButton(
                      icon: Icons.delete,
                      onPressed: onRemoveBanner,
                      isDelete: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBannerImage() {
    if (tempBannerFile != null) {
      return Image.file(
        tempBannerFile!,
        fit: BoxFit.cover,
      );
    } else if (creatorProfile?.bannerUrl != null) {
      return CachedNetworkImage(
        imageUrl: creatorProfile!.bannerUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.backgroundSecondary,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.backgroundSecondary,
          child: const Center(
            child: Icon(Icons.error, color: Colors.grey),
          ),
        ),
      );
    } else {
      return Container(
        color: AppColors.backgroundSecondary,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image,
                size: 32,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                'Ajouter une bannière',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
  
  Widget _buildAvatarSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Photo de profil
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surfaceSecondary,
                    width: 3,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: _buildAvatarImage(),
                ),
              ),
              
              // Bouton modifier avatar
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showAvatarOptions(context),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.surfacePrimary,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Informations rapides
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userProfile?.displayName ?? userProfile?.username ?? 'Utilisateur',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (userProfile?.username != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '@${userProfile!.username}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (creatorProfile != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Créateur',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAvatarImage() {
    if (tempAvatarFile != null) {
      return Image.file(
        tempAvatarFile!,
        fit: BoxFit.cover,
      );
    } else if (userProfile?.avatarUrl != null) {
      return CachedNetworkImage(
        imageUrl: userProfile!.avatarUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.backgroundSecondary,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => _buildDefaultAvatar(),
      );
    } else {
      return _buildDefaultAvatar();
    }
  }
  
  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.backgroundSecondary,
      child: Center(
        child: Icon(
          Icons.person,
          size: 32,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
  
  Widget _buildInfoSection(BuildContext context) {
    if (userProfile == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (userProfile!.bio != null && userProfile!.bio!.isNotEmpty) ...[
            Text(
              userProfile!.bio!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],
          
          // Statistiques
          Row(
            children: [
              _buildStatItem(
                'Abonnés',
                userProfile!.subscribersCount.toString(),
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                'Abonnements',
                userProfile!.subscriptionsCount.toString(),
              ),
              if (creatorProfile != null) ...[
                const SizedBox(width: 24),
                _buildStatItem(
                  'Prix',
                  '${creatorProfile!.subscriptionPrice.toStringAsFixed(2)}€',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildImageActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isDelete = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDelete ? AppColors.error : AppColors.surfacePrimary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDelete ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }
  
  void _showAvatarOptions(BuildContext context) {
    ImagePickerBottomSheet.show(
      context,
      title: 'Photo de profil',
      onCamera: onPickAvatar,
      onGallery: onPickAvatar,
      showDelete: tempAvatarFile != null || userProfile?.avatarUrl != null,
      onDelete: onRemoveAvatar,
    );
  }
  
  void _showBannerOptions(BuildContext context) {
    ImagePickerBottomSheet.show(
      context,
      title: 'Bannière',
      onCamera: onPickBanner,
      onGallery: onPickBanner,
      showDelete: tempBannerFile != null || creatorProfile?.bannerUrl != null,
      onDelete: onRemoveBanner,
    );
  }
}
