import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/profile_models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../common/custom_text_field.dart';
import '../common/section_header.dart';

class CreatorSettingsSection extends StatelessWidget {
  final CreatorProfile creatorProfile;
  final TextEditingController subscriptionPriceController;
  final Map<String, String?> validationErrors;
  final Function(String field, String value) onFieldChanged;
  final CreatorEarnings? earnings;

  const CreatorSettingsSection({
    Key? key,
    required this.creatorProfile,
    required this.subscriptionPriceController,
    required this.validationErrors,
    required this.onFieldChanged,
    this.earnings,
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
              title: 'Paramètres créateur',
              icon: Icons.star,
            ),
            
            const SizedBox(height: 16),
            
            // Prix d'abonnement
            _buildSubscriptionPriceField(),
            
            const SizedBox(height: 16),
            
            // Calculateur de revenus
            _buildEarningsCalculator(),
            
            const SizedBox(height: 16),
            
            // Statistiques créateur
            if (earnings != null) _buildEarningsStats(),
            
            const SizedBox(height: 12),
            
            // Conseils pricing
            _buildPricingTips(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSubscriptionPriceField() {
    return CustomTextField(
      controller: subscriptionPriceController,
      label: 'Prix d\'abonnement mensuel',
      hintText: '9.99',
      prefixIcon: Icons.euro,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        LengthLimitingTextInputFormatter(6),
      ],
      onChanged: (value) => onFieldChanged('subscriptionPrice', value),
      errorText: validationErrors['subscriptionPrice'],
      isRequired: true,
      suffixText: '€',
      helperText: 'Prix minimum: 4.99€ - Prix maximum: 99.99€',
    );
  }
  
  Widget _buildEarningsCalculator() {
    final price = double.tryParse(subscriptionPriceController.text) ?? 0.0;
    final platformFee = price * 0.20; // 20% commission OnlyFlick
    final creatorEarning = price - platformFee;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.success.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calculate,
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              Text(
                'Calcul des revenus',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Lignes de calcul
          _buildCalculationRow('Prix d\'abonnement', '${price.toStringAsFixed(2)}€'),
          _buildCalculationRow('Commission OnlyFlick (20%)', '-${platformFee.toStringAsFixed(2)}€'),
          const Divider(color: AppColors.surfaceSecondary),
          _buildCalculationRow(
            'Vous recevez',
            '${creatorEarning.toStringAsFixed(2)}€',
            isTotal: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildCalculationRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: isTotal ? AppColors.success : AppColors.textSecondary,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEarningsStats() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Vos revenus',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Statistiques
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Ce mois',
                  '${earnings!.currentMonthEarnings.toStringAsFixed(2)}€',
                  Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total',
                  '${earnings!.totalEarnings.toStringAsFixed(2)}€',
                  Icons.account_balance_wallet,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Abonnés',
                  '${creatorProfile.subscribersCount}',
                  Icons.people,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Taux conversion',
                  '${((creatorProfile.subscribersCount / (creatorProfile.subscribersCount + 100)) * 100).toStringAsFixed(1)}%',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfacePrimary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(height: 4),
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
      ),
    );
  }
  
  Widget _buildPricingTips() {
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
                'Conseils de tarification',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._buildPricingTipsList(),
        ],
      ),
    );
  }
  
  List<Widget> _buildPricingTipsList() {
    final tips = [
      'Commencez avec un prix abordable pour attirer vos premiers abonnés',
      'Augmentez progressivement selon la qualité de votre contenu',
      'Observez les prix des créateurs similaires dans votre niche',
      'Proposez du contenu exclusif qui justifie le prix',
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
