import 'package:flutter_dotenv/flutter_dotenv.dart';

class TestConfig {
  // Configuration pour tests
  static String get testBackendUrl {
    try {
      return dotenv.env['API_URL'] ?? 'http://localhost:8080';
    } catch (e) {
      // Si dotenv n'est pas initialisé, utiliser la valeur par défaut
      return 'http://localhost:8080';
    }
  }
  
  static const String testApiVersion = '/api/v1';
  
  // IDs de test (à adapter selon votre backend)
  static const String testUserId1 = 'test-user-1';
  static const String testUserId2 = 'test-user-2';
  static const String testConversationId = 'test-conversation-1';
  
  // Configuration pour mocks
  static const bool useMockData = false; // true pour tests offline
  
  // Timeouts
  static const Duration defaultTimeout = Duration(seconds: 10);
  static const Duration longTimeout = Duration(seconds: 30);
  
  static void printTestHeader(String testName) {
    print('\n${'='*60}');
    print('🧪 $testName');
    print('='*60);
  }
  
  static void printTestResult(bool success, String message) {
    final icon = success ? '✅' : '❌';
    print('$icon $message');
  }
  
  static void printTestInfo(String message) {
    print('💡 $message');
  }
  
  static void printTestWarning(String message) {
    print('⚠️  $message');
  }
  
  static void printTestDebug(String message) {
    print('🔍 $message');
  }
  
  /// Initialise l'environnement de test
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
      print('💡 .env file loaded successfully');
    } catch (e) {
      print('⚠️  Could not load .env file: $e');
      print('💡 Using default configuration');
    }
  }
  
  /// Vérifie si l'environnement de test est configuré
  static bool isTestEnvironmentReady() {
    try {
      final url = testBackendUrl;
      return url.isNotEmpty && url.startsWith('http');
    } catch (e) {
      return false;
    }
  }
  
  /// Affiche les informations de configuration
  static void printTestEnvironment() {
    printTestHeader('Configuration des Tests');
    print('🌐 Backend URL: $testBackendUrl');
    print('📡 API Version: $testApiVersion');
    print('🔧 Mock Data: ${useMockData ? "Enabled" : "Disabled"}');
    print('⏱️  Default Timeout: ${defaultTimeout.inSeconds}s');
    print('⏱️  Long Timeout: ${longTimeout.inSeconds}s');
    print('');
  }
}
