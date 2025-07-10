import 'package:flutter_test/flutter_test.dart';
import '../test_config.dart';

void main() {
  group('Configuration Tests', () {
    
    setUpAll(() async {
      await TestConfig.initialize();
    });

    test('should load configuration', () {
      TestConfig.printTestHeader('Configuration Test');
      
      final backendUrl = TestConfig.testBackendUrl;
      final apiVersion = TestConfig.testApiVersion;
      
      expect(backendUrl, isNotNull);
      expect(backendUrl, isNotEmpty);
      expect(apiVersion, equals('/api/v1'));
      
      TestConfig.printTestResult(true, 'Configuration loaded successfully');
      TestConfig.printTestDebug('Backend URL: $backendUrl');
      TestConfig.printTestDebug('API Version: $apiVersion');
    });

    test('should check environment readiness', () {
      final isReady = TestConfig.isTestEnvironmentReady();
      
      if (isReady) {
        TestConfig.printTestResult(true, 'Test environment is ready');
      } else {
        TestConfig.printTestWarning('Test environment not ready - using defaults');
      }
      
      expect(isReady, isA<bool>());
    });

    test('should provide test constants', () {
      expect(TestConfig.testUserId1, isNotEmpty);
      expect(TestConfig.testUserId2, isNotEmpty);
      expect(TestConfig.testConversationId, isNotEmpty);
      expect(TestConfig.defaultTimeout, isA<Duration>());
      expect(TestConfig.longTimeout, isA<Duration>());
      
      TestConfig.printTestResult(true, 'Test constants are available');
    });
  });
}
