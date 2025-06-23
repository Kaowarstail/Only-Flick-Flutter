// Script de debug pour tester l'authentification
import 'package:flutter/material.dart';
import 'lib/services/api_service.dart';
import 'lib/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔍 Test de connexion à l\'API...');
  
  try {
    print('📝 Tentative de connexion avec des identifiants de test...');
    
    // Test avec des identifiants fictifs pour voir la gestion des erreurs
    final response = await AuthService.login('test@example.com', 'password123');
    print('✅ Connexion réussie: ${response.user.username}');
    
  } catch (e) {
    print('❌ Erreur capturée: $e');
    print('Type d\'erreur: ${e.runtimeType}');
    
    if (e.toString().contains('Timeout')) {
      print('🕒 L\'erreur est liée au timeout');
    } else if (e.toString().contains('serveur')) {
      print('🖥️ L\'erreur est liée au serveur');
    } else {
      print('🌐 Autre type d\'erreur réseau');
    }
  }
  
  print('🧪 Test terminé');
}
