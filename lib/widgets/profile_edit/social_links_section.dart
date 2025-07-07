import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../common/custom_text_field.dart';
import '../common/section_header.dart';

class SocialLinksSection extends StatelessWidget {
  final TextEditingController twitterController;
  final TextEditingController instagramController;
  final TextEditingController tiktokController;
  final TextEditingController youtubeController;
  final TextEditingController websiteController;
  final Map<String, String?> validationErrors;
  final Function(String field, String value) onFieldChanged;

  const SocialLinksSection({
    Key? key,
    required this.twitterController,
    required this.instagramController,
    required this.tiktokController,
    required this.youtubeController,
    required this.websiteController,
    required this.validationErrors,
    required this.onFieldChanged,
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Réseaux sociaux',
              icon: Icons.share,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Ajoutez vos liens pour que vos abonnés puissent vous retrouver',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Twitter
            _buildSocialLinkField(
              controller: twitterController,
              label: 'Twitter',
              hintText: 'votre_nom_utilisateur',
              prefix: '@',
              icon: Icons.alternate_email,
              color: const Color(0xFF1DA1F2),
              fieldName: 'twitter',
            ),
            
            const SizedBox(height: 16),
            
            // Instagram
            _buildSocialLinkField(
              controller: instagramController,
              label: 'Instagram',
              hintText: 'votre_nom_utilisateur',
              prefix: '@',
              icon: Icons.camera_alt,
              color: const Color(0xFFE4405F),
              fieldName: 'instagram',
            ),
            
            const SizedBox(height: 16),
            
            // TikTok
            _buildSocialLinkField(
              controller: tiktokController,
              label: 'TikTok',
              hintText: 'votre_nom_utilisateur',
              prefix: '@',
              icon: Icons.music_note,
              color: const Color(0xFF000000),
              fieldName: 'tiktok',
            ),
            
            const SizedBox(height: 16),
            
            // YouTube
            _buildSocialLinkField(
              controller: youtubeController,
              label: 'YouTube',
              hintText: 'votre_chaine',
              prefix: 'youtube.com/',
              icon: Icons.play_circle_fill,
              color: const Color(0xFFFF0000),
              fieldName: 'youtube',
            ),
            
            const SizedBox(height: 16),
            
            // Site web
            _buildSocialLinkField(
              controller: websiteController,
              label: 'Site web',
              hintText: 'https://votre-site.com',
              prefix: '',
              icon: Icons.language,
              color: AppColors.primary,
              fieldName: 'website',
              keyboardType: TextInputType.url,
            ),
            
            const SizedBox(height: 12),
            
            // Note sur la confidentialité
            _buildPrivacyNote(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSocialLinkField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String prefix,
    required IconData icon,
    required Color color,
    required String fieldName,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return CustomTextField(
      controller: controller,
      label: label,
      hintText: hintText,
      prefixIcon: icon,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        LengthLimitingTextInputFormatter(100),
      ],
      onChanged: (value) => onFieldChanged(fieldName, value),
      errorText: validationErrors[fieldName],
      prefixText: prefix.isNotEmpty ? prefix : null,
      suffixIcon: controller.text.isNotEmpty
          ? IconButton(
              icon: Icon(Icons.clear, size: 18),
              onPressed: () {
                controller.clear();
                onFieldChanged(fieldName, '');
              },
            )
          : null,
      decoration: InputDecoration(
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }
  
  Widget _buildPrivacyNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.privacy_tip_outlined,
            size: 16,
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visibilité publique',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ces liens seront visibles sur votre profil public. Assurez-vous qu\'ils correspondent à vos comptes officiels.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
