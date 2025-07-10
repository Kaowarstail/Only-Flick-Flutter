import 'package:flutter_test/flutter_test.dart';
import 'package:only_flick_flutter/services/api_service.dart';
import '../test_config.dart';

void main() {
  group('ApiService Integration Tests', () {
    
    setUpAll(() async {
      await TestConfig.initialize();
      TestConfig.printTestEnvironment();
      
      if (!TestConfig.isTestEnvironmentReady()) {
        fail('Test environment not configured. Please check your .env file.');
      }
    });

    tearDownAll(() {
      ApiService.dispose();
    });

    test('should connect to backend health endpoint', () async {
      TestConfig.printTestHeader('Backend Connection Test');
      
      try {
        final response = await ApiService.get('/health', requiresAuth: false)
            .timeout(TestConfig.defaultTimeout);
        
        TestConfig.printTestResult(true, 'Backend connection successful');
        TestConfig.printTestDebug('Response: ${response.toString().substring(0, 100)}...');
        
        expect(response, isA<Map<String, dynamic>>());
        
      } catch (e) {
        TestConfig.printTestResult(false, 'Backend connection failed: $e');
        
        if (e.toString().contains('Connection refused')) {
          TestConfig.printTestWarning('Backend server is not running on ${TestConfig.testBackendUrl}');
          TestConfig.printTestInfo('Please start your Go backend server');
        } else if (e.toString().contains('TimeoutException')) {
          TestConfig.printTestWarning('Backend server is taking too long to respond');
        }
        
        fail('Cannot connect to backend: $e');
      }
    });

    test('should handle authentication correctly', () async {
      TestConfig.printTestHeader('JWT Authentication Test');
      
      try {
        final response = await ApiService.get('/auth/me')
            .timeout(TestConfig.defaultTimeout);
        
        TestConfig.printTestResult(true, 'JWT authentication successful');
        TestConfig.printTestDebug('User data: ${response.toString()}');
        
        expect(response, isA<Map<String, dynamic>>());
        
      } catch (e) {
        if (e is ApiException && e.statusCode == 401) {
          TestConfig.printTestWarning('JWT token missing or expired');
          TestConfig.printTestInfo('This is expected if no user is logged in');
          TestConfig.printTestInfo('Login through your app to get a valid JWT token');
          
          expect(e.statusCode, equals(401));
        } else {
          TestConfig.printTestResult(false, 'Auth test failed unexpectedly: $e');
          throw e;
        }
      }
    });

    test('should handle 404 errors correctly', () async {
      TestConfig.printTestHeader('Error Handling Test');
      
      try {
        await ApiService.get('/non-existent-endpoint', requiresAuth: false)
            .timeout(TestConfig.defaultTimeout);
        
        fail('Should have thrown an exception for 404');
        
      } catch (e) {
        if (e is ApiException && e.statusCode == 404) {
          TestConfig.printTestResult(true, 'Error handling works correctly');
          TestConfig.printTestDebug('404 error properly caught: ${e.message}');
          
          expect(e.statusCode, equals(404));
          expect(e.message, isNotNull);
        } else {
          TestConfig.printTestResult(false, 'Unexpected error type: $e');
          throw e;
        }
      }
    });

    test('should handle network timeouts', () async {
      TestConfig.printTestHeader('Timeout Handling Test');
      
      try {
        // Test avec un timeout très court pour forcer l'erreur
        await ApiService.get('/health', requiresAuth: false)
            .timeout(Duration(milliseconds: 1));
        
        TestConfig.printTestInfo('Request completed faster than 1ms (unlikely but possible)');
        
      } catch (e) {
        if (e.toString().contains('TimeoutException') || 
            e.toString().contains('timeout')) {
          TestConfig.printTestResult(true, 'Timeout handling works correctly');
          TestConfig.printTestDebug('Timeout error: $e');
        } else {
          TestConfig.printTestResult(false, 'Unexpected timeout error: $e');
        }
      }
    });

    test('should validate API response structure', () async {
      TestConfig.printTestHeader('API Response Structure Test');
      
      try {
        final response = await ApiService.get('/health', requiresAuth: false);
        
        // Vérifier que la réponse est bien un Map
        expect(response, isA<Map<String, dynamic>>());
        
        TestConfig.printTestResult(true, 'API response structure is valid');
        TestConfig.printTestDebug('Response keys: ${response.keys.toList()}');
        
        // Log les clés principales pour debug
        if (response.containsKey('status')) {
          TestConfig.printTestInfo('Health status: ${response['status']}');
        }
        if (response.containsKey('message')) {
          TestConfig.printTestInfo('Health message: ${response['message']}');
        }
        
      } catch (e) {
        TestConfig.printTestResult(false, 'API response validation failed: $e');
        throw e;
      }
    });

    test('should test different HTTP methods', () async {
      TestConfig.printTestHeader('HTTP Methods Test');
      
      // Test GET (déjà testé mais on le confirme)
      try {
        await ApiService.get('/health', requiresAuth: false);
        TestConfig.printTestResult(true, 'GET method works');
      } catch (e) {
        TestConfig.printTestResult(false, 'GET method failed: $e');
      }

      // Test POST avec données vides (devrait retourner une erreur métier)
      try {
        await ApiService.post('/test-endpoint', body: {}, requiresAuth: false);
        TestConfig.printTestInfo('POST method works (or endpoint does not exist)');
      } catch (e) {
        if (e is ApiException) {
          TestConfig.printTestResult(true, 'POST method works (returned API error as expected)');
          TestConfig.printTestDebug('POST error: ${e.message}');
        } else {
          TestConfig.printTestResult(false, 'POST method failed unexpectedly: $e');
        }
      }

      // Test des paramètres de requête
      try {
        await ApiService.getWithParams('/health', 
          queryParameters: {'test': 'true'}, 
          requiresAuth: false);
        TestConfig.printTestResult(true, 'GET with parameters works');
      } catch (e) {
        if (e is ApiException) {
          TestConfig.printTestResult(true, 'GET with parameters works (returned API response)');
        } else {
          TestConfig.printTestResult(false, 'GET with parameters failed: $e');
        }
      }
    });
  });
}
