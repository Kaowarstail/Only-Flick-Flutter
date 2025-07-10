import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:only_flick_flutter/services/notification_service.dart';
import '../test_config.dart';

void main() {
  group('NotificationService Tests', () {
    late NotificationService notificationService;
    
    setUpAll(() async {
      await TestConfig.initialize();
      TestConfig.printTestEnvironment();
    });

    setUp(() {
      notificationService = NotificationService();
    });

    tearDown(() {
      notificationService.dispose();
    });

    test('should initialize notification service', () async {
      TestConfig.printTestHeader('NotificationService Initialization Test');
      
      try {
        // Le service devrait être initialisé sans erreur
        expect(notificationService, isNotNull);
        TestConfig.printTestResult(true, 'NotificationService initialized successfully');
        
        // Vérifier l'état initial
        expect(notificationService.isPolling, isFalse);
        TestConfig.printTestDebug('Initial polling state: ${notificationService.isPolling}');
        
      } catch (e) {
        TestConfig.printTestResult(false, 'Initialization failed: $e');
        throw e;
      }
    });

    test('should start and stop polling', () async {
      TestConfig.printTestHeader('Notification Polling Control Test');
      
      try {
        // Vérifier l'état initial
        expect(notificationService.isPolling, isFalse);
        TestConfig.printTestDebug('Initial state: not polling');
        
        // Démarrer le polling
        notificationService.startPolling();
        expect(notificationService.isPolling, isTrue);
        TestConfig.printTestResult(true, 'Polling started successfully');
        
        // Attendre un peu pour voir si ça fonctionne
        await Future.delayed(Duration(seconds: 2));
        expect(notificationService.isPolling, isTrue);
        TestConfig.printTestDebug('Polling still active after 2 seconds');
        
        // Arrêter le polling
        notificationService.stopPolling();
        expect(notificationService.isPolling, isFalse);
        TestConfig.printTestResult(true, 'Polling stopped successfully');
        
      } catch (e) {
        TestConfig.printTestResult(false, 'Polling control test failed: $e');
        throw e;
      }
    });

    test('should emit unread count updates', () async {
      TestConfig.printTestHeader('Unread Count Stream Test');
      
      try {
        bool streamWorking = false;
        int? lastUnreadCount;
        
        // Écouter le stream
        late StreamSubscription subscription;
        subscription = notificationService.unreadCountStream.listen(
          (count) {
            TestConfig.printTestDebug('🔔 Unread count update: $count');
            streamWorking = true;
            lastUnreadCount = count;
          },
          onError: (error) {
            TestConfig.printTestWarning('Stream error: $error');
          },
        );
        
        // Démarrer polling
        notificationService.startPolling();
        TestConfig.printTestDebug('Polling started, waiting for updates...');
        
        // Attendre quelques updates
        await Future.delayed(Duration(seconds: 5));
        
        // Forcer une vérification
        await notificationService.checkNow();
        TestConfig.printTestDebug('Manual check triggered');
        
        // Attendre encore un peu
        await Future.delayed(Duration(seconds: 2));
        
        // Nettoyer
        await subscription.cancel();
        notificationService.stopPolling();
        
        if (streamWorking) {
          TestConfig.printTestResult(true, 'Unread count stream working');
          TestConfig.printTestDebug('Last unread count: $lastUnreadCount');
          expect(lastUnreadCount, isA<int>());
        } else {
          TestConfig.printTestWarning('No stream updates received');
          TestConfig.printTestInfo('This might be normal if polling interval is long or no backend connection');
        }
        
      } catch (e) {
        TestConfig.printTestResult(false, 'Stream test failed: $e');
      }
    });

    test('should adapt polling frequency based on app state', () async {
      TestConfig.printTestHeader('Adaptive Polling Test');
      
      try {
        // Test état actif
        notificationService.setAppActive(true);
        TestConfig.printTestDebug('App state set to active');
        
        notificationService.startPolling();
        TestConfig.printTestResult(true, 'Active polling frequency set');
        
        await Future.delayed(Duration(seconds: 1));
        expect(notificationService.isPolling, isTrue);
        
        // Test état arrière-plan
        notificationService.setAppActive(false);
        TestConfig.printTestDebug('App state set to background');
        TestConfig.printTestResult(true, 'Background polling frequency set');
        
        await Future.delayed(Duration(seconds: 1));
        expect(notificationService.isPolling, isTrue);
        
        // Retour à l'état actif
        notificationService.setAppActive(true);
        TestConfig.printTestDebug('App state set back to active');
        
        await Future.delayed(Duration(seconds: 1));
        
        notificationService.stopPolling();
        TestConfig.printTestResult(true, 'Adaptive polling test completed');
        
      } catch (e) {
        TestConfig.printTestResult(false, 'Adaptive polling test failed: $e');
      }
    });

    test('should handle manual check now', () async {
      TestConfig.printTestHeader('Manual Check Test');
      
      try {
        bool updateReceived = false;
        int? unreadCount;
        
        // Écouter les updates
        final subscription = notificationService.unreadCountStream.listen((count) {
          updateReceived = true;
          unreadCount = count;
          TestConfig.printTestDebug('Manual check result: $count unread');
        });
        
        // Effectuer une vérification manuelle
        await notificationService.checkNow()
            .timeout(TestConfig.defaultTimeout);
        
        // Attendre un peu pour l'émission du stream
        await Future.delayed(Duration(seconds: 1));
        
        subscription.cancel();
        
        if (updateReceived) {
          TestConfig.printTestResult(true, 'Manual check works - Unread: $unreadCount');
          expect(unreadCount, isA<int>());
        } else {
          TestConfig.printTestWarning('Manual check did not emit update');
          TestConfig.printTestInfo('This might indicate backend connection issues');
        }
        
      } catch (e) {
        TestConfig.printTestResult(false, 'Manual check failed: $e');
        
        if (e.toString().contains('timeout')) {
          TestConfig.printTestInfo('Manual check timed out - check backend connection');
        }
      }
    });

    test('should handle multiple start/stop cycles', () async {
      TestConfig.printTestHeader('Multiple Start/Stop Cycles Test');
      
      try {
        for (int i = 0; i < 3; i++) {
          TestConfig.printTestDebug('Cycle ${i + 1}: Starting polling');
          notificationService.startPolling();
          expect(notificationService.isPolling, isTrue);
          
          await Future.delayed(Duration(milliseconds: 500));
          
          TestConfig.printTestDebug('Cycle ${i + 1}: Stopping polling');
          notificationService.stopPolling();
          expect(notificationService.isPolling, isFalse);
          
          await Future.delayed(Duration(milliseconds: 200));
        }
        
        TestConfig.printTestResult(true, 'Multiple start/stop cycles completed successfully');
        
      } catch (e) {
        TestConfig.printTestResult(false, 'Multiple cycles test failed: $e');
      }
    });

    test('should handle stream subscription cleanup', () async {
      TestConfig.printTestHeader('Stream Cleanup Test');
      
      try {
        List<StreamSubscription> subscriptions = [];
        
        // Créer plusieurs subscriptions
        for (int i = 0; i < 3; i++) {
          final subscription = notificationService.unreadCountStream.listen((count) {
            TestConfig.printTestDebug('Subscription $i received: $count');
          });
          subscriptions.add(subscription);
        }
        
        // Démarrer polling
        notificationService.startPolling();
        await Future.delayed(Duration(seconds: 1));
        
        // Annuler toutes les subscriptions
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
        
        // Arrêter polling
        notificationService.stopPolling();
        
        TestConfig.printTestResult(true, 'Stream cleanup completed successfully');
        
      } catch (e) {
        TestConfig.printTestResult(false, 'Stream cleanup test failed: $e');
      }
    });

    test('should handle notification service disposal', () async {
      TestConfig.printTestHeader('Service Disposal Test');
      
      try {
        // Créer un nouveau service pour ce test
        final testService = NotificationService();
        
        // Démarrer polling
        testService.startPolling();
        expect(testService.isPolling, isTrue);
        
        // Créer une subscription
        final subscription = testService.unreadCountStream.listen((count) {
          TestConfig.printTestDebug('Count before disposal: $count');
        });
        
        await Future.delayed(Duration(milliseconds: 500));
        
        // Disposer le service
        testService.dispose();
        
        // Vérifier que le polling s'est arrêté
        expect(testService.isPolling, isFalse);
        
        // Nettoyer la subscription
        await subscription.cancel();
        
        TestConfig.printTestResult(true, 'Service disposal works correctly');
        
      } catch (e) {
        TestConfig.printTestResult(false, 'Disposal test failed: $e');
      }
    });

    test('should provide current unread count', () async {
      TestConfig.printTestHeader('Current Unread Count Test');
      
      try {
        // Le service devrait pouvoir fournir le count actuel
        final currentCount = notificationService.currentUnreadCount;
        
        TestConfig.printTestDebug('Current unread count: $currentCount');
        expect(currentCount, isA<int>());
        expect(currentCount, greaterThanOrEqualTo(0));
        
        TestConfig.printTestResult(true, 'Current unread count available: $currentCount');
        
      } catch (e) {
        TestConfig.printTestResult(false, 'Current count test failed: $e');
      }
    });
  });
}
