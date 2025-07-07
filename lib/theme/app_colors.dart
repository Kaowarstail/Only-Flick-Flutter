import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales OnlyFlick
  static const Color primary = Color(0xFFCC0092);           // Rose fuchsia principal
  static const Color secondary = Color(0xFFFFB2E9);         // Rose clair secondaire
  
  // Couleurs de fond
  static const Color backgroundPrimary = Colors.white;      // Fond blanc principal
  static const Color backgroundSecondary = Color(0xFFF8F9FA); // Fond gris très clair
  
  // Couleurs de surface
  static const Color surfacePrimary = Colors.white;         // Surface blanche
  static const Color surfaceSecondary = Color(0xFFE9ECEF);  // Surface grise claire
  
  // Couleurs de texte
  static const Color textPrimary = Colors.black;            // Texte noir principal
  static const Color textSecondary = Color(0xFF666666);     // Texte gris secondaire
  static const Color textTertiary = Color(0xFF9CA3AF);      // Texte gris clair
  
  // Couleurs d'état
  static const Color success = Color(0xFF10B981);           // Vert succès
  static const Color error = Color(0xFFEF4444);             // Rouge erreur
  static const Color warning = Color(0xFFF59E0B);           // Orange warning
  static const Color info = Color(0xFF3B82F6);              // Bleu info
  
  // Couleurs de bordure
  static const Color borderPrimary = Color(0xFFE5E7EB);     // Bordure principale
  static const Color borderSecondary = Color(0xFFD1D5DB);   // Bordure secondaire
  
  // Couleurs d'interaction
  static const Color hoverPrimary = Color(0xFFF3F4F6);      // Hover gris clair
  static const Color activePrimary = Color(0xFFE5E7EB);     // Active gris
  
  // Couleurs de gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundPrimary, backgroundSecondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Couleurs avec opacité
  static Color get primaryLight => primary.withOpacity(0.1);
  static Color get primaryMedium => primary.withOpacity(0.2);
  static Color get primaryDark => primary.withOpacity(0.8);
  
  static Color get overlayLight => Colors.black.withOpacity(0.1);
  static Color get overlayMedium => Colors.black.withOpacity(0.3);
  static Color get overlayDark => Colors.black.withOpacity(0.7);
  
  // Couleurs pour les différents types de contenu
  static const Color premiumGold = Color(0xFFFFD700);       // Or premium
  static const Color liveRed = Color(0xFFFF0000);           // Rouge live
  static const Color verifiedBlue = Color(0xFF1DA1F2);      // Bleu vérifié
  
  // Couleurs pour les réseaux sociaux
  static const Color twitterBlue = Color(0xFF1DA1F2);
  static const Color instagramPink = Color(0xFFE4405F);
  static const Color tiktokBlack = Color(0xFF000000);
  static const Color youtubeRed = Color(0xFFFF0000);
  
  // Méthodes utilitaires
  static Color getStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'success':
        return success;
      case 'error':
        return error;
      case 'warning':
        return warning;
      case 'info':
        return info;
      default:
        return textSecondary;
    }
  }
  
  static Color getSocialColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'twitter':
        return twitterBlue;
      case 'instagram':
        return instagramPink;
      case 'tiktok':
        return tiktokBlack;
      case 'youtube':
        return youtubeRed;
      default:
        return primary;
    }
  }
}
