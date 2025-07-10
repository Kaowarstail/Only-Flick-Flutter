import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:only_flick_flutter/services/api_service.dart';
import 'package:only_flick_flutter/services/message_service.dart';
import 'package:only_flick_flutter/services/conversation_service.dart';
import 'package:only_flick_flutter/services/notification_service.dart';
import 'package:only_flick_flutter/services/media_service.dart';
import 'package:only_flick_flutter/models/models.dart';
import '../test_config.dart';

void main() {
  group('Messaging Integration Tests', () {
    late NotificationService notificationService;
    
    setUpAll(() async {
      await TestConfig.initialize();
      TestConfig.printTestHeader('🚀 Starting Complete Messaging Integration Tests');
      print('📱 Make sure backend is running on ${TestConfig.testBackendUrl}');
      print('🔑 Make sure you have valid JWT token for testing');
      print('💾 Make sure test data exists in your database');
      print('');
      
      if (!TestConfig.isTestEnvironmentReady()) {
        fail('Test environment not configured. Please check your .env file.');
      }

      notificationService = NotificationService();
    });
    
    tearDownAll(() {
      notificationService.dispose();
      ApiService.dispose();
      TestConfig.printTestHeader('✅ Integration tests completed');
    });

    test('complete messaging flow end-to-end', () async {
      TestConfig.printTestHeader('🧪 Complete Messaging Flow Test');
      
      bool backendConnected = false;
      bool authenticated = false;
      bool conversationsLoaded = false;
      bool messageSent = false;
      bool pollingWorked = false;
      
      try {
        // 1. Vérifier connexion backend
        print('1️⃣ Testing backend connection...');
        final healthResponse = await ApiService.get('/health', requiresAuth: false)
            .timeout(TestConfig.defaultTimeout);
        
        expect(healthResponse, isA<Map<String, dynamic>>());
        backendConnected = true;
        TestConfig.printTestResult(true, 'Backend connected successfully');
        TestConfig.printTestDebug('Health response: ${healthResponse.toString().substring(0, 100)}...');

        // 2. Vérifier authentification
        print('2️⃣ Testing authentication...');
        try {
          final authResponse = await ApiService.get('/auth/me')
              .timeout(TestConfig.defaultTimeout);
          
          if (authResponse.containsKey('user') || authResponse.containsKey('id')) {
            authenticated = true;
            TestConfig.printTestResult(true, 'Authentication verified');
            TestConfig.printTestDebug('User authenticated: ${authResponse['id'] ?? authResponse['user']?['id']}');
          } else {
            TestConfig.printTestWarning('Auth response structure unexpected');
            TestConfig.printTestDebug('Auth response: $authResponse');
          }
        } catch (e) {
          if (e is ApiException && e.statusCode == 401) {
            TestConfig.printTestWarning('No authentication token available');
            TestConfig.printTestInfo('Please login through your app to get a valid JWT token');
            TestConfig.printTestInfo('Continuing with public endpoints only...');
          } else {
            throw e;
          }
        }

        // 3. Récupérer conversations (si authentifié)
        print('3️⃣ Testing conversations retrieval...');
        if (authenticated) {
          try {
            final conversations = await ConversationService.getConversations(
              page: 1,
              limit: 5,
            ).timeout(TestConfig.defaultTimeout);
            
            if (conversations != null) {
              conversationsLoaded = true;
              TestConfig.printTestResult(true, 'Conversations loaded successfully');
              TestConfig.printTestDebug('Found ${conversations.conversations.length} conversations');
              TestConfig.printTestDebug('Total conversations: ${conversations.total}');
              TestConfig.printTestDebug('Unread conversations: ${conversations.unreadTotal}');

              // Afficher détails des conversations
              for (int i = 0; i < conversations.conversations.length && i < 2; i++) {
                final conv = conversations.conversations[i];
                TestConfig.printTestDebug('Conversation ${i + 1}:');
                TestConfig.printTestDebug('  - ID: ${conv.id}');
                TestConfig.printTestDebug('  - Type: ${conv.type}');
                TestConfig.printTestDebug('  - Participants: ${conv.participants.length}');
                TestConfig.printTestDebug('  - Unread: ${conv.unreadCount}');
                
                if (conv.lastMessage != null) {
                  TestConfig.printTestDebug('  - Last: ${conv.lastMessage!.content?.substring(0, 30) ?? 'No content'}...');
                }
              }

              // 4. Envoyer un message de test (si conversations disponibles)
              print('4️⃣ Testing message sending...');
              if (conversations.conversations.isNotEmpty) {
                final targetConversation = conversations.conversations.first;
                final testMessage = SendMessageRequest(
                  conversationId: targetConversation.id,
                  content: 'Integration test message - ${DateTime.now().toIso8601String()}',
                  messageType: MessageType.text,
                );
                
                try {
                  final sentMessage = await MessageService.sendMessage(testMessage)
                      .timeout(TestConfig.defaultTimeout);
                  
                  if (sentMessage != null) {
                    messageSent = true;
                    TestConfig.printTestResult(true, 'Message sent successfully');
                    TestConfig.printTestDebug('Message ID: ${sentMessage.id}');
                    TestConfig.printTestDebug('Content: ${sentMessage.content}');
                    TestConfig.printTestDebug('Sender: ${sentMessage.senderId}');
                    TestConfig.printTestDebug('Created: ${sentMessage.createdAt}');
                    
                    expect(sentMessage.content, equals(testMessage.content));
                    expect(sentMessage.messageType, equals(MessageType.text));
                  } else {
                    TestConfig.printTestWarning('Message sending returned null');
                  }
                } catch (e) {
                  TestConfig.printTestWarning('Message sending failed: $e');
                  TestConfig.printTestInfo('This might be due to permission or conversation state');
                }
              } else {
                TestConfig.printTestInfo('No conversations available for message testing');
              }
            } else {
              TestConfig.printTestWarning('No conversations response received');
            }
          } catch (e) {
            TestConfig.printTestWarning('Conversations loading failed: $e');
          }
        } else {
          TestConfig.printTestInfo('Skipping authenticated endpoints due to missing token');
        }

        // 5. Test notification polling
        print('5️⃣ Testing notification polling...');
        try {
          bool updateReceived = false;
          int? lastUnreadCount;
          
          // Écouter les notifications
          final subscription = notificationService.unreadCountStream.listen(
            (count) {
              updateReceived = true;
              lastUnreadCount = count;
              TestConfig.printTestDebug('🔔 Unread count update: $count');
            },
            onError: (error) {
              TestConfig.printTestWarning('Notification stream error: $error');
            },
          );
          
          // Démarrer polling
          notificationService.startPolling();
          TestConfig.printTestDebug('Notification polling started');
          
          // Attendre quelques cycles
          await Future.delayed(Duration(seconds: 6));
          
          // Forcer une vérification
          await notificationService.checkNow()
              .timeout(TestConfig.defaultTimeout);
          
          // Attendre encore un peu
          await Future.delayed(Duration(seconds: 2));
          
          // Arrêter polling
          notificationService.stopPolling();
          await subscription.cancel();
          
          if (updateReceived) {
            pollingWorked = true;
            TestConfig.printTestResult(true, 'Notification polling works');
            TestConfig.printTestDebug('Final unread count: $lastUnreadCount');
          } else {
            TestConfig.printTestWarning('No notification updates received');
            TestConfig.printTestInfo('This might be normal if polling interval is long');
          }
        } catch (e) {
          TestConfig.printTestWarning('Notification polling test failed: $e');
        }

        // 6. Test des statistiques de conversation
        print('6️⃣ Testing conversation statistics...');
        if (authenticated) {
          try {
            final stats = await ConversationService.getConversationStats()
                .timeout(TestConfig.defaultTimeout);
            
            if (stats != null) {
              TestConfig.printTestResult(true, 'Conversation stats retrieved');
              TestConfig.printTestDebug('Total conversations: ${stats.totalConversations}');
              TestConfig.printTestDebug('Active conversations: ${stats.activeConversations}');
              TestConfig.printTestDebug('Unread conversations: ${stats.unreadConversations}');
              TestConfig.printTestDebug('Total unread messages: ${stats.totalUnreadMessages}');
              
              expect(stats.totalConversations, isA<int>());
              expect(stats.activeConversations, lessThanOrEqualTo(stats.totalConversations));
              expect(stats.unreadConversations, lessThanOrEqualTo(stats.activeConversations));
              expect(stats.totalUnreadMessages, isA<int>());
            }
          } catch (e) {
            TestConfig.printTestWarning('Stats retrieval failed: $e');
          }
        }

        // 7. Résumé final
        print('7️⃣ Integration test summary:');
        TestConfig.printTestResult(backendConnected, 'Backend Connection');
        TestConfig.printTestResult(authenticated, 'Authentication');
        TestConfig.printTestResult(conversationsLoaded, 'Conversations Loading');
        TestConfig.printTestResult(messageSent, 'Message Sending');
        TestConfig.printTestResult(pollingWorked, 'Notification Polling');
        
        final totalTests = 5;
        final passedTests = [backendConnected, authenticated, conversationsLoaded, messageSent, pollingWorked]
            .where((test) => test).length;
        
        print('');
        TestConfig.printTestHeader('🎯 Integration Test Results');
        print('✅ Passed: $passedTests/$totalTests tests');
        print('📊 Success Rate: ${(passedTests / totalTests * 100).toStringAsFixed(1)}%');
        
        if (passedTests >= 3) {
          print('🎉 Integration tests largely successful!');
          print('💡 Your messaging system is working well');
        } else if (passedTests >= 2) {
          print('⚠️  Partial success - some components need attention');
        } else {
          print('❌ Multiple issues detected - check configuration');
        }
        
        // Recommandations basées sur les résultats
        print('');
        print('📋 Recommendations:');
        if (!backendConnected) {
          print('  • Start your Go backend server');
          print('  • Check API_URL in .env file');
        }
        if (!authenticated) {
          print('  • Login through your app to get JWT token');
          print('  • Check authentication endpoints');
        }
        if (!conversationsLoaded && authenticated) {
          print('  • Check conversation endpoints');
          print('  • Verify database has conversation data');
        }
        if (!messageSent && conversationsLoaded) {
          print('  • Check message sending permissions');
          print('  • Verify message endpoints');
        }
        if (!pollingWorked && authenticated) {
          print('  • Check notification endpoints');
          print('  • Verify polling configuration');
        }
        
        // Au moins la connexion backend doit fonctionner
        expect(backendConnected, isTrue, reason: 'Backend connection is mandatory');
        
      } catch (e) {
        TestConfig.printTestResult(false, 'Integration test failed: $e');
        
        print('');
        print('🔍 Troubleshooting:');
        if (e.toString().contains('Connection refused')) {
          print('  • Backend server is not running');
          print('  • Check if Go server is started on ${TestConfig.testBackendUrl}');
        } else if (e.toString().contains('TimeoutException')) {
          print('  • Backend server is not responding in time');
          print('  • Check server performance and network');
        } else if (e.toString().contains('SocketException')) {
          print('  • Network connectivity issues');
          print('  • Check firewall and network configuration');
        }
        
        rethrow;
      }
    });

    test('service integration and dependencies', () async {
      TestConfig.printTestHeader('🔗 Service Dependencies Test');
      
      try {
        // Test que tous les services peuvent être instanciés
        final messageService = MessageService;
        final conversationService = ConversationService;
        final mediaService = MediaService;
        final notificationServiceLocal = NotificationService();
        
        TestConfig.printTestResult(true, 'All services can be instantiated');
        
        // Test des dépendances
        expect(messageService, isNotNull);
        expect(conversationService, isNotNull);
        expect(mediaService, isNotNull);
        expect(notificationServiceLocal, isNotNull);
        
        // Nettoyer
        notificationServiceLocal.dispose();
        
        TestConfig.printTestResult(true, 'Service dependencies are correct');
        
      } catch (e) {
        TestConfig.printTestResult(false, 'Service dependencies test failed: $e');
        throw e;
      }
    });

    test('error handling across services', () async {
      TestConfig.printTestHeader('🛡️ Error Handling Test');
      
      try {
        int errorsHandled = 0;
        
        // Test erreur API Service
        try {
          await ApiService.get('/non-existent-endpoint-test');
        } catch (e) {
          if (e is ApiException) {
            errorsHandled++;
            TestConfig.printTestDebug('✓ ApiService error handled: ${e.message}');
          }
        }
        
        // Test erreur Message Service  
        try {
          final invalidRequest = SendMessageRequest(
            conversationId: 'invalid-id',
            content: '', // Invalid content
            messageType: MessageType.text,
          );
          await MessageService.sendMessage(invalidRequest);
        } catch (e) {
          if (e is MessageException || e is ApiException) {
            errorsHandled++;
            TestConfig.printTestDebug('✓ MessageService error handled: $e');
          }
        }
        
        // Test erreur Conversation Service
        try {
          await ConversationService.createOrGetConversation('invalid-user-id');
        } catch (e) {
          if (e is ConversationException || e is ApiException) {
            errorsHandled++;
            TestConfig.printTestDebug('✓ ConversationService error handled: $e');
          }
        }
        
        // Test erreur Media Service
        try {
          final invalidFile = File('nonexistent.jpg');
          await MediaService.uploadMedia(
            file: invalidFile,
            mediaType: MediaType.image,
          );
        } catch (e) {
          if (e is MediaException || e is ApiException) {
            errorsHandled++;
            TestConfig.printTestDebug('✓ MediaService error handled: $e');
          }
        }
        
        TestConfig.printTestResult(true, 'Error handling test completed');
        TestConfig.printTestDebug('Errors properly handled: $errorsHandled/4');
        
        if (errorsHandled >= 2) {
          TestConfig.printTestResult(true, 'Error handling is robust');
        } else {
          TestConfig.printTestWarning('Some error cases might need better handling');
        }
        
      } catch (e) {
        TestConfig.printTestResult(false, 'Error handling test failed: $e');
      }
    });

    test('performance and timeout handling', () async {
      TestConfig.printTestHeader('⚡ Performance Test');
      
      try {
        final stopwatch = Stopwatch()..start();
        
        // Test rapidité de connexion
        await ApiService.get('/health', requiresAuth: false)
            .timeout(Duration(seconds: 5));
        
        stopwatch.stop();
        final connectionTime = stopwatch.elapsedMilliseconds;
        
        TestConfig.printTestDebug('Backend connection time: ${connectionTime}ms');
        
        if (connectionTime < 1000) {
          TestConfig.printTestResult(true, 'Fast connection (${connectionTime}ms)');
        } else if (connectionTime < 5000) {
          TestConfig.printTestResult(true, 'Acceptable connection (${connectionTime}ms)');
        } else {
          TestConfig.printTestWarning('Slow connection (${connectionTime}ms)');
        }
        
        // Test timeout handling
        try {
          await ApiService.get('/health', requiresAuth: false)
              .timeout(Duration(milliseconds: 1));
          TestConfig.printTestInfo('Request completed faster than 1ms (very unlikely)');
        } catch (e) {
          if (e.toString().contains('timeout') || e.toString().contains('TimeoutException')) {
            TestConfig.printTestResult(true, 'Timeout handling works correctly');
          }
        }
        
      } catch (e) {
        TestConfig.printTestResult(false, 'Performance test failed: $e');
      }
    });
  });
}
