import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Script de débogage pour tester la connectivité API
class DebugApiTest {
  static Future<void> runTests() async {
    debugPrint('🔍 === DÉBUT DES TESTS DE CONNECTIVITÉ API ===');
    
    // Test 1: Vérifier les variables d'environnement
    debugPrint('📋 Test 1: Variables d\'environnement');
    final apiUrl = dotenv.env['API_URL'] ?? 'VARIABLE NON TROUVÉE';
    debugPrint('API_URL: $apiUrl');
    
    // Test 2: Test de connectivité de base
    debugPrint('\n🌐 Test 2: Connectivité de base');
    try {
      final url = Uri.parse('$apiUrl/api/v1/health');
      debugPrint('URL de test: $url');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout après 10 secondes');
        },
      );
      
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('Headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        debugPrint('✅ Connexion de base réussie');
      } else {
        debugPrint('❌ Échec de la connexion de base');
      }
    } catch (e) {
      debugPrint('❌ Erreur de connexion de base: $e');
    }
    
    // Test 3: Test d'inscription avec des données invalides (pour tester les erreurs)
    debugPrint('\n📝 Test 3: Test d\'inscription (données invalides)');
    try {
      final url = Uri.parse('$apiUrl/api/v1/auth/register');
      debugPrint('URL d\'inscription: $url');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': 'test',
          'email': 'invalid-email',
          'password': 'weak',
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout après 10 secondes');
        },
      );
      
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      
      final responseData = jsonDecode(response.body);
      if (responseData.containsKey('error')) {
        debugPrint('✅ Gestion d\'erreur fonctionnelle: ${responseData['error']}');
      } else {
        debugPrint('⚠️ Format de réponse inattendu');
      }
    } catch (e) {
      debugPrint('❌ Erreur lors du test d\'inscription: $e');
    }
    
    // Test 4: Test avec des données valides
    debugPrint('\n✅ Test 4: Test d\'inscription (données valides)');
    try {
      final url = Uri.parse('$apiUrl/api/v1/auth/register');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': 'debugtest$timestamp',
          'email': 'debug$timestamp@test.com',
          'password': 'DebugTest123!',
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout après 10 secondes');
        },
      );
      
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey('token') && responseData.containsKey('user')) {
          debugPrint('✅ Inscription réussie avec token');
        } else {
          debugPrint('⚠️ Inscription réussie mais format inattendu');
        }
      } else {
        debugPrint('❌ Échec de l\'inscription valide');
      }
    } catch (e) {
      debugPrint('❌ Erreur lors du test d\'inscription valide: $e');
    }
    
    debugPrint('\n🔍 === FIN DES TESTS DE CONNECTIVITÉ API ===');
  }
}
