import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // OnlyFlick Brand Colors
  static const Color primaryColor = Color(0xFFCC0092);      // Rose fuchsia principal
  static const Color secondaryColor = Color(0xFFFFB2E9);    // Rose clair secondaire
  static const Color backgroundColor = Colors.white;         // Fond blanc
  static const Color textColor = Colors.black;              // Texte noir
  
  // Additional colors for messaging
  static const Color sentMessageColor = Color(0xFFCC0092);
  static const Color receivedMessageColor = Color(0xFFF5F5F5);
  static const Color paidMessageColor = Color(0xFFFFB2E9);
  static const Color unreadBadgeColor = Color(0xFFCC0092);
  static const Color onlineIndicatorColor = Color(0xFF4CAF50);

  // Legacy colors (kept for backward compatibility)
  static const Color cardColor = Colors.white;
  static const Color errorColor = Color(0xFFE17055);
  static const Color successColor = Color(0xFF00B894);
  static const Color textSecondaryColor = Color(0xFF636E72);

  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: MaterialColor(0xFFCC0092, const {
        50: Color(0xFFFCE4F6),
        100: Color(0xFFF8BBE8),
        200: Color(0xFFF38ED8),
        300: Color(0xFFEE60C8),
        400: Color(0xFFEA3DBC),
        500: Color(0xFFCC0092),
        600: Color(0xFFE5008A),
        700: Color(0xFFCC0092),
        800: Color(0xFFB8007D),
        900: Color(0xFF9C005F),
      }),
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.openSansTextTheme(), // Police d'accessibilité similaire à Luciole
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: textColor),
        titleTextStyle: GoogleFonts.openSans(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.openSans(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
