import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class PasswordRequirements extends StatelessWidget {
  final String? password;

  const PasswordRequirements({
    super.key,
    this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Le mot de passe doit contenir :',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirement('Au moins 8 caractères', _hasMinLength(password)),
          _buildRequirement('Au moins une minuscule (a-z)', _hasLowercase(password)),
          _buildRequirement('Au moins une majuscule (A-Z)', _hasUppercase(password)),
          _buildRequirement('Au moins un chiffre (0-9)', _hasNumber(password)),
          _buildRequirement('Au moins un caractère spécial (!@#\$&*~)', _hasSpecialChar(password)),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isValid ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isValid ? Colors.green : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasMinLength(String? password) {
    return password != null && password.length >= 8;
  }

  bool _hasLowercase(String? password) {
    return password != null && RegExp(r'[a-z]').hasMatch(password);
  }

  bool _hasUppercase(String? password) {
    return password != null && RegExp(r'[A-Z]').hasMatch(password);
  }

  bool _hasNumber(String? password) {
    return password != null && RegExp(r'[0-9]').hasMatch(password);
  }

  bool _hasSpecialChar(String? password) {
    return password != null && RegExp(r'[\W_]').hasMatch(password);
  }
}
