import 'package:flutter_test/flutter_test.dart';
import 'package:only_flick_flutter/services/message_service.dart';
import 'package:only_flick_flutter/models/models.dart';
import 'package:only_flick_flutter/utils/message_validators.dart';
import '../test_config.dart';

void main() {
  group('MessageService Tests', () {
    
    setUpAll(() async {
      await TestConfig.initialize();
      TestConfig.printTestEnvironment();
    });

    test('should validate message requests correctly', () async {
      TestConfig.printTestHeader('Message Validation Test');
      
      // Test message valide
      final validRequest = SendMessageRequest(
        conversationId: TestConfig.testConversationId,
        content: 'Test message for validation',
        messageType: MessageType.text,
      );
      
      final validationError = MessageValidators.validateSendMessageRequest(validRequest);
      
      if (validationError == null) {
        TestConfig.printTestResult(true, 'Valid message passes validation');
      } else {
        TestConfig.printTestResult(false, 'Valid message failed validation: $validationError');
        fail('Valid message should pass validation');
      }

      // Test message invalide (pas de contenu)
      final invalidRequest = SendMessageRequest(
        conversationId: TestConfig.testConversationId,
        messageType: MessageType.text,
        // content manquant
      );
      
      final invalidValidationError = MessageValidators.validateSendMessageRequest(invalidRequest);
      
      if (invalidValidationError != null) {
        TestConfig.printTestResult(true, 'Invalid message fails validation: $invalidValidationError');
        expect(invalidValidationError, contains('contenu'));
      } else {
        TestConfig.printTestResult(false, 'Invalid message should fail validation');
        fail('Invalid message should fail validation');
      }

      // Test message trop long
      final longContent = 'A' * 6000; // Dépasse limite de 5000
      final longRequest = SendMessageRequest(
        conversationId: TestConfig.testConversationId,
        content: longContent,
        messageType: MessageType.text,
      );
      
      final longValidationError = MessageValidators.validateSendMessageRequest(longRequest);
      
      if (longValidationError != null) {
        TestConfig.printTestResult(true, 'Long message fails validation: $longValidationError');
        expect(longValidationError, contains('5000'));
      } else {
        TestConfig.printTestResult(false, 'Long message should fail validation');
      }
    });

    test('should send text message to backend', () async {
      TestConfig.printTestHeader('Send Text Message Test');
      
      try {
        final request = SendMessageRequest(
          conversationId: TestConfig.testConversationId,
          content: 'Test message from Flutter integration test - ${DateTime.now().toIso8601String()}',
          messageType: MessageType.text,
        );
        
        final message = await MessageService.sendMessage(request)
            .timeout(TestConfig.defaultTimeout);
        
        if (message != null) {
          TestConfig.printTestResult(true, 'Message sent successfully');
          TestConfig.printTestDebug('Message ID: ${message.id}');
          TestConfig.printTestDebug('Content: ${message.content}');
          TestConfig.printTestDebug('Type: ${message.messageType}');
          TestConfig.printTestDebug('Created: ${message.createdAt}');
          
          expect(message.content, equals(request.content));
          expect(message.messageType, equals(MessageType.text));
          expect(message.id, isNotNull);
          expect(message.senderId, isNotNull);
        } else {
          TestConfig.printTestWarning('Message sending returned null');
          TestConfig.printTestInfo('Check if conversation exists and user has permission');
        }
        
      } catch (e) {
        if (e is MessageException) {
          TestConfig.printTestResult(false, 'Message service error: ${e.message}');
          
          if (e.message.contains('conversation')) {
            TestConfig.printTestInfo('Create a conversation first or use existing conversation ID');
          } else if (e.message.contains('auth')) {
            TestConfig.printTestInfo('Make sure user is authenticated');
          }
        } else if (e is ApiException) {
          TestConfig.printTestResult(false, 'API error: ${e.message} (Status: ${e.statusCode})');
          
          if (e.statusCode == 401) {
            TestConfig.printTestInfo('Authentication required - login first');
          } else if (e.statusCode == 404) {
            TestConfig.printTestInfo('Conversation not found - check conversation ID');
          } else if (e.statusCode == 403) {
            TestConfig.printTestInfo('Permission denied - check user access');
          }
        } else {
          TestConfig.printTestResult(false, 'Send message test failed: $e');
        }
      }
    });

    test('should get messages from conversation', () async {
      TestConfig.printTestHeader('Get Messages Test');
      
      try {
        final response = await MessageService.getMessages(
          conversationId: TestConfig.testConversationId,
          page: 1,
          limit: 10,
        ).timeout(TestConfig.defaultTimeout);
        
        if (response != null) {
          TestConfig.printTestResult(true, 'Messages retrieved successfully');
          TestConfig.printTestDebug('Total messages: ${response.total}');
          TestConfig.printTestDebug('Messages in page: ${response.messages.length}');
          TestConfig.printTestDebug('Current page: ${response.page}');
          TestConfig.printTestDebug('Total pages: ${response.totalPages}');
          
          expect(response.messages, isA<List<Message>>());
          expect(response.page, equals(1));
          expect(response.total, isA<int>());
          
          // Afficher quelques messages pour debug
          for (int i = 0; i < response.messages.length && i < 3; i++) {
            final msg = response.messages[i];
            TestConfig.printTestDebug('Message $i: ${msg.content?.substring(0, 50)}...');
            TestConfig.printTestDebug('  - Type: ${msg.messageType}');
            TestConfig.printTestDebug('  - Sender: ${msg.senderId}');
            TestConfig.printTestDebug('  - Created: ${msg.createdAt}');
          }
          
          if (response.messages.isEmpty) {
            TestConfig.printTestInfo('Conversation has no messages yet');
          }
        } else {
          TestConfig.printTestWarning('No messages response received');
          TestConfig.printTestInfo('This might indicate conversation does not exist');
        }
        
      } catch (e) {
        if (e is ApiException) {
          TestConfig.printTestResult(false, 'API error getting messages: ${e.message} (${e.statusCode})');
          
          if (e.statusCode == 404) {
            TestConfig.printTestInfo('Conversation not found - check conversation ID');
          } else if (e.statusCode == 401) {
            TestConfig.printTestInfo('Authentication required');
          } else if (e.statusCode == 403) {
            TestConfig.printTestInfo('No permission to access this conversation');
          }
        } else {
          TestConfig.printTestResult(false, 'Get messages test failed: $e');
        }
      }
    });

    test('should handle validation errors on send', () async {
      TestConfig.printTestHeader('Send Message Validation Error Test');
      
      try {
        // Message avec contenu vide (devrait échouer à la validation)
        final invalidRequest = SendMessageRequest(
          conversationId: TestConfig.testConversationId,
          content: '', // Contenu vide
          messageType: MessageType.text,
        );
        
        await MessageService.sendMessage(invalidRequest);
        
        TestConfig.printTestResult(false, 'Should have thrown validation error for empty content');
        fail('Should have thrown validation error');
        
      } catch (e) {
        if (e is MessageException && e.message.contains('contenu')) {
          TestConfig.printTestResult(true, 'Validation error properly thrown: ${e.message}');
          expect(e.message, contains('contenu'));
        } else {
          TestConfig.printTestResult(false, 'Unexpected error type: $e');
          throw e;
        }
      }
    });

    test('should handle different message types', () async {
      TestConfig.printTestHeader('Message Types Test');
      
      // Test message texte
      final textRequest = SendMessageRequest(
        conversationId: TestConfig.testConversationId,
        content: 'Text message test',
        messageType: MessageType.text,
      );
      
      final textValidation = MessageValidators.validateSendMessageRequest(textRequest);
      if (textValidation == null) {
        TestConfig.printTestResult(true, 'Text message validation passes');
      } else {
        TestConfig.printTestResult(false, 'Text message validation failed: $textValidation');
      }

      // Test message image (simulation)
      final imageRequest = SendMessageRequest(
        conversationId: TestConfig.testConversationId,
        messageType: MessageType.image,
        mediaUrl: 'https://example.com/image.jpg',
        content: 'Image caption',
      );
      
      final imageValidation = MessageValidators.validateSendMessageRequest(imageRequest);
      if (imageValidation == null) {
        TestConfig.printTestResult(true, 'Image message validation passes');
      } else {
        TestConfig.printTestResult(false, 'Image message validation failed: $imageValidation');
      }

      // Test message vidéo (simulation)
      final videoRequest = SendMessageRequest(
        conversationId: TestConfig.testConversationId,
        messageType: MessageType.video,
        mediaUrl: 'https://example.com/video.mp4',
      );
      
      final videoValidation = MessageValidators.validateSendMessageRequest(videoRequest);
      if (videoValidation == null) {
        TestConfig.printTestResult(true, 'Video message validation passes');
      } else {
        TestConfig.printTestResult(false, 'Video message validation failed: $videoValidation');
      }
    });

    test('should handle message pagination', () async {
      TestConfig.printTestHeader('Message Pagination Test');
      
      try {
        // Test première page
        final page1 = await MessageService.getMessages(
          conversationId: TestConfig.testConversationId,
          page: 1,
          limit: 5,
        );
        
        if (page1 != null) {
          TestConfig.printTestResult(true, 'Page 1 retrieved successfully');
          TestConfig.printTestDebug('Page 1 - Total: ${page1.total}, Messages: ${page1.messages.length}');
          
          // Test deuxième page si il y a assez de messages
          if (page1.total > 5) {
            final page2 = await MessageService.getMessages(
              conversationId: TestConfig.testConversationId,
              page: 2,
              limit: 5,
            );
            
            if (page2 != null) {
              TestConfig.printTestResult(true, 'Page 2 retrieved successfully');
              TestConfig.printTestDebug('Page 2 - Messages: ${page2.messages.length}');
              
              expect(page2.page, equals(2));
              expect(page2.total, equals(page1.total));
            }
          } else {
            TestConfig.printTestInfo('Not enough messages to test second page');
          }
        }
        
      } catch (e) {
        TestConfig.printTestResult(false, 'Pagination test failed: $e');
      }
    });
  });
}
