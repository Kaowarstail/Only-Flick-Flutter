import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../common/custom_text_field.dart';
import '../common/section_header.dart';

class ProfileFormSection extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController displayNameController;
  final TextEditingController bioController;
  final Map<String, String?> validationErrors;
  final Function(String field, String value) onFieldChanged;
  final Function(String username) onUsernameChanged;

  const ProfileFormSection({
    Key? key,
    required this.usernameController,
    required this.displayNameController,
    required this.bioController,
    required this.validationErrors,
    required this.onFieldChanged,
    required this.onUsernameChanged,
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
              title: 'Informations de base',
              icon: Icons.person,
            ),
            
            const SizedBox(height: 16),
            
            // Nom d'utilisateur
            CustomTextField(
              controller: usernameController,
              label: 'Nom d\'utilisateur',
              hintText: 'votre_nom_utilisateur',
              prefixIcon: Icons.alternate_email,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                LengthLimitingTextInputFormatter(30),
              ],
              onChanged: (value) {
                onFieldChanged('username', value);
                onUsernameChanged(value);
              },
              errorText: validationErrors['username'],
              isRequired: true,
              helperText: 'Lettres, chiffres et tirets bas uniquement',
            ),
            
            const SizedBox(height: 16),
            
            // Nom d'affichage
            CustomTextField(
              controller: displayNameController,
              label: 'Nom d\'affichage',
              hintText: 'Votre nom public',
              prefixIcon: Icons.badge,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                LengthLimitingTextInputFormatter(50),
              ],
              onChanged: (value) => onFieldChanged('displayName', value),
              errorText: validationErrors['displayName'],
              helperText: 'Nom visible par les autres utilisateurs',
            ),
            
            const SizedBox(height: 16),
            
            // Biographie
            CustomTextField(
              controller: bioController,
              label: 'Biographie',
              hintText: 'Parlez-nous de vous...',
              prefixIcon: Icons.description,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              maxLines: 4,
              minLines: 3,
              inputFormatters: [
                LengthLimitingTextInputFormatter(500),
              ],
              onChanged: (value) => onFieldChanged('bio', value),
              errorText: validationErrors['bio'],
              helperText: 'Décrivez votre contenu et vos centres d\'intérêt',
              showCharacterCount: true,
              maxLength: 500,
            ),
            
            const SizedBox(height: 12),
            
            // Conseils
            _buildTips(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.info.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: AppColors.info,
              ),
              const SizedBox(width: 8),
              Text(
                'Conseils pour un bon profil',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._buildTipsList(),
        ],
      ),
    );
  }
  
  List<Widget> _buildTipsList() {
    final tips = [
      'Choisissez un nom d\'utilisateur mémorable et facile à écrire',
      'Utilisez un nom d\'affichage qui reflète votre identité',
      'Rédigez une biographie engageante qui décrit votre contenu',
      'Restez authentique et professionnel',
    ];
    
    return tips.map((tip) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 8, right: 8),
            decoration: BoxDecoration(
              color: AppColors.info,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              tip,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }
}
