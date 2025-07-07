import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class ImagePickerBottomSheet extends StatelessWidget {
  final String title;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final bool showDelete;
  final VoidCallback? onDelete;

  const ImagePickerBottomSheet({
    Key? key,
    required this.title,
    required this.onCamera,
    required this.onGallery,
    this.showDelete = false,
    this.onDelete,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required String title,
    required VoidCallback onCamera,
    required VoidCallback onGallery,
    bool showDelete = false,
    VoidCallback? onDelete,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ImagePickerBottomSheet(
          title: title,
          onCamera: onCamera,
          onGallery: onGallery,
          showDelete: showDelete,
          onDelete: onDelete,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfacePrimary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Title
              Text(
                title,
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Options
              Column(
                children: [
                  // Camera option
                  _buildOption(
                    context,
                    icon: Icons.camera_alt,
                    title: 'Appareil photo',
                    subtitle: 'Prendre une nouvelle photo',
                    onTap: () {
                      Navigator.of(context).pop();
                      onCamera();
                    },
                  ),
                  
                  // Gallery option
                  _buildOption(
                    context,
                    icon: Icons.photo_library,
                    title: 'Galerie',
                    subtitle: 'Choisir depuis la galerie',
                    onTap: () {
                      Navigator.of(context).pop();
                      onGallery();
                    },
                  ),
                  
                  // Delete option
                  if (showDelete && onDelete != null) ...[
                    const Divider(
                      color: AppColors.surfaceSecondary,
                      height: 24,
                    ),
                    _buildOption(
                      context,
                      icon: Icons.delete,
                      title: 'Supprimer',
                      subtitle: 'Supprimer l\'image actuelle',
                      onTap: () {
                        Navigator.of(context).pop();
                        onDelete!();
                      },
                      isDestructive: true,
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Cancel button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Annuler',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.error.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDestructive ? AppColors.error : AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDestructive ? AppColors.error : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
