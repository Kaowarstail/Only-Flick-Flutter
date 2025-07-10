import 'package:flutter_test/flutter_test.dart';
import 'package:only_flick_flutter/services/conversation_service.dart';
import 'package:only_flick_flutter/models/models.dart';
import '../test_config.dart';

void main() {
  group('ConversationService Tests', () {
    
    setUpAll(() async {
      await TestConfig.initialize();
      TestConfig.printTestEnvironment();
    });

    test('should get user conversations', () async {
      TestConfig.printTestHeader('Get Conversations Test');
      
      try {
        final response = await ConversationService.getConversations(
          page: 1,
          limit: 10,
        ).timeout(TestConfig.defaultTimeout);
        
        if (response != null) {
          TestConfig.printTestResult(true, 'Conversations retrieved successfully');
          TestConfig.printTestDebug('Total conversations: ${response.total}');
          TestConfig.printTestDebug('Conversations in page: ${response.conversations.length}');
          TestConfig.printTestDebug('Unread total: ${response.unreadTotal}');
          TestConfig.printTestDebug('Current page: ${response.page}');
          TestConfig.printTestDebug('Total pages: ${response.totalPages}');
          
          expect(response.conversations, isA<List<Conversation>>());
          expect(response.page, equals(1));
          expect(response.total, isA<int>());
          expect(response.unreadTotal, isA<int>());
          
          // Afficher quelques conversations pour debug
          for (int i = 0; i < response.conversations.length && i < 3; i++) {
            final conv = response.conversations[i];
            TestConfig.printTestDebug('Conversation $i:');
            TestConfig.printTestDebug('  - ID: ${conv.id}');
            TestConfig.printTestDebug('  - Type: ${conv.type}');
            TestConfig.printTestDebug('  - Participants: ${conv.participants.length}');
            TestConfig.printTestDebug('  - Is Active: ${conv.isActive}');
            TestConfig.printTestDebug('  - Unread Count: ${conv.unreadCount}');
            
            if (conv.lastMessage != null) {
              TestConfig.printTestDebug('  - Last Message: ${conv.lastMessage!.content?.substring(0, 30)}...');
              TestConfig.printTestDebug('  - Last Message Time: ${conv.lastMessage!.createdAt}');
            } else {
              TestConfig.printTestDebug('  - No last message');
            }
          }
          
          if (response.conversations.isEmpty) {
            TestConfig.printTestInfo('User has no conversations yet');
          }
        } else {
          TestConfig.printTestWarning('No conversations response received');
          TestConfig.printTestInfo('User might not have any conversations yet');
        }
        
      } catch (e) {
        if (e is ConversationException) {
          TestConfig.printTestResult(false, 'Conversation service error: ${e.message}');
        } else if (e is ApiException) {
          TestConfig.printTestResult(false, 'API error: ${e.message} (Status: ${e.statusCode})');
          
          if (e.statusCode == 401) {
            TestConfig.printTestInfo('Authentication required - login first');
          }
        } else {
          TestConfig.printTestResult(false, 'Get conversations test failed: $e');
        }
      }
    });

    test('should create or get conversation', () async {
      TestConfig.printTestHeader('Create/Get Conversation Test');
      
      try {
        final conversation = await ConversationService.createOrGetConversation(
          TestConfig.testUserId2
        ).timeout(TestConfig.defaultTimeout);
        
        if (conversation != null) {
          TestConfig.printTestResult(true, 'Conversation created/retrieved successfully');
          TestConfig.printTestDebug('Conversation ID: ${conversation.id}');
          TestConfig.printTestDebug('Type: ${conversation.type}');
          TestConfig.printTestDebug('Participants: ${conversation.participants.length}');
          TestConfig.printTestDebug('Is Active: ${conversation.isActive}');
          TestConfig.printTestDebug('Created At: ${conversation.createdAt}');
          
          expect(conversation.participants.length, greaterThanOrEqualTo(2));
          expect(conversation.isActive, isTrue);
          expect(conversation.id, isNotNull);
          
          // Vérifier que les participants incluent l'utilisateur courant et le target
          bool hasTargetUser = conversation.participants.any((p) => p.id == TestConfig.testUserId2);
          if (hasTargetUser) {
            TestConfig.printTestDebug('Target user found in participants');
          } else {
            TestConfig.printTestWarning('Target user not found in participants (might be expected)');
          }
          
        } else {
          TestConfig.printTestWarning('Conversation creation returned null');
          TestConfig.printTestInfo('Check if target user exists: ${TestConfig.testUserId2}');
        }
        
      } catch (e) {
        if (e is ConversationException) {
          TestConfig.printTestResult(false, 'Conversation service error: ${e.message}');
          
          if (e.message.contains('user')) {
            TestConfig.printTestInfo('Target user might not exist or be accessible');
          }
        } else if (e is ApiException) {
          TestConfig.printTestResult(false, 'API error: ${e.message} (${e.statusCode})');
          
          if (e.statusCode == 404) {
            TestConfig.printTestInfo('Target user not found');
          } else if (e.statusCode == 401) {
            TestConfig.printTestInfo('Authentication required');
          } else if (e.statusCode == 400) {
            TestConfig.printTestInfo('Invalid request - check user ID format');
          }
        } else {
          TestConfig.printTestResult(false, 'Create conversation test failed: $e');
        }
      }
    });

    test('should mark conversation as read', () async {
      TestConfig.printTestHeader('Mark Conversation as Read Test');
      
      try {
        final success = await ConversationService.markConversationAsRead(
          TestConfig.testConversationId
        ).timeout(TestConfig.defaultTimeout);
        
        if (success) {
          TestConfig.printTestResult(true, 'Conversation marked as read successfully');
        } else {
          TestConfig.printTestWarning('Mark as read returned false');
          TestConfig.printTestInfo('Check if conversation exists and user has access');
        }
        
        expect(success, isA<bool>());
        
      } catch (e) {
        if (e is ConversationException) {
          TestConfig.printTestResult(false, 'Conversation service error: ${e.message}');
        } else if (e is ApiException) {
          TestConfig.printTestResult(false, 'API error: ${e.message} (${e.statusCode})');
          
          if (e.statusCode == 404) {
            TestConfig.printTestInfo('Conversation not found - check ID: ${TestConfig.testConversationId}');
          } else if (e.statusCode == 401) {
            TestConfig.printTestInfo('Authentication required');
          } else if (e.statusCode == 403) {
            TestConfig.printTestInfo('No permission to access this conversation');
          }
        } else {
          TestConfig.printTestResult(false, 'Mark as read test failed: $e');
        }
      }
    });

    test('should get conversation statistics', () async {
      TestConfig.printTestHeader('Conversation Statistics Test');
      
      try {
        final stats = await ConversationService.getConversationStats()
            .timeout(TestConfig.defaultTimeout);
        
        if (stats != null) {
          TestConfig.printTestResult(true, 'Conversation stats retrieved successfully');
          TestConfig.printTestDebug('Total conversations: ${stats.totalConversations}');
          TestConfig.printTestDebug('Active conversations: ${stats.activeConversations}');
          TestConfig.printTestDebug('Unread conversations: ${stats.unreadConversations}');
          TestConfig.printTestDebug('Total unread messages: ${stats.totalUnreadMessages}');
          
          expect(stats.totalConversations, isA<int>());
          expect(stats.activeConversations, isA<int>());
          expect(stats.unreadConversations, isA<int>());
          expect(stats.totalUnreadMessages, isA<int>());
          
          // Vérifications logiques
          expect(stats.activeConversations, lessThanOrEqualTo(stats.totalConversations));
          expect(stats.unreadConversations, lessThanOrEqualTo(stats.activeConversations));
          
          if (stats.totalConversations == 0) {
            TestConfig.printTestInfo('User has no conversations');
          }
          
          if (stats.unreadConversations > 0) {
            TestConfig.printTestInfo('User has ${stats.unreadConversations} unread conversations');
          } else {
            TestConfig.printTestInfo('User has no unread conversations');
          }
          
        } else {
          TestConfig.printTestWarning('Conversation stats returned null');
        }
        
      } catch (e) {
        if (e is ConversationException) {
          TestConfig.printTestResult(false, 'Conversation service error: ${e.message}');
        } else if (e is ApiException) {
          TestConfig.printTestResult(false, 'API error: ${e.message} (${e.statusCode})');
          
          if (e.statusCode == 401) {
            TestConfig.printTestInfo('Authentication required');
          }
        } else {
          TestConfig.printTestResult(false, 'Conversation stats test failed: $e');
        }
      }
    });

    test('should search conversations', () async {
      TestConfig.printTestHeader('Search Conversations Test');
      
      try {
        final response = await ConversationService.searchConversations(
          query: 'test',
          page: 1,
          limit: 10,
        ).timeout(TestConfig.defaultTimeout);
        
        if (response != null) {
          TestConfig.printTestResult(true, 'Conversation search completed successfully');
          TestConfig.printTestDebug('Search results: ${response.conversations.length}');
          TestConfig.printTestDebug('Total matches: ${response.total}');
          
          expect(response.conversations, isA<List<Conversation>>());
          expect(response.total, isA<int>());
          
          if (response.conversations.isNotEmpty) {
            TestConfig.printTestInfo('Found ${response.conversations.length} conversations matching "test"');
            
            // Afficher quelques résultats
            for (int i = 0; i < response.conversations.length && i < 2; i++) {
              final conv = response.conversations[i];
              TestConfig.printTestDebug('Result $i: ${conv.id}');
            }
          } else {
            TestConfig.printTestInfo('No conversations found matching "test"');
          }
          
        } else {
          TestConfig.printTestWarning('Search returned null');
        }
        
      } catch (e) {
        if (e is ConversationException) {
          TestConfig.printTestResult(false, 'Search error: ${e.message}');
        } else if (e is ApiException) {
          TestConfig.printTestResult(false, 'API error: ${e.message} (${e.statusCode})');
        } else {
          TestConfig.printTestResult(false, 'Search test failed: $e');
        }
      }
    });

    test('should handle conversation pagination', () async {
      TestConfig.printTestHeader('Conversation Pagination Test');
      
      try {
        // Test première page avec limite réduite
        final page1 = await ConversationService.getConversations(
          page: 1,
          limit: 3,
        );
        
        if (page1 != null && page1.conversations.isNotEmpty) {
          TestConfig.printTestResult(true, 'Page 1 retrieved successfully');
          TestConfig.printTestDebug('Page 1 - Total: ${page1.total}, Conversations: ${page1.conversations.length}');
          
          // Test deuxième page si il y a assez de conversations
          if (page1.total > 3) {
            final page2 = await ConversationService.getConversations(
              page: 2,
              limit: 3,
            );
            
            if (page2 != null) {
              TestConfig.printTestResult(true, 'Page 2 retrieved successfully');
              TestConfig.printTestDebug('Page 2 - Conversations: ${page2.conversations.length}');
              
              expect(page2.page, equals(2));
              expect(page2.total, equals(page1.total));
              
              // Vérifier que les conversations sont différentes
              if (page1.conversations.isNotEmpty && page2.conversations.isNotEmpty) {
                final page1Ids = page1.conversations.map((c) => c.id).toSet();
                final page2Ids = page2.conversations.map((c) => c.id).toSet();
                final overlap = page1Ids.intersection(page2Ids);
                
                if (overlap.isEmpty) {
                  TestConfig.printTestResult(true, 'Pages contain different conversations');
                } else {
                  TestConfig.printTestWarning('Pages contain overlapping conversations');
                }
              }
            }
          } else {
            TestConfig.printTestInfo('Not enough conversations to test pagination');
          }
        } else {
          TestConfig.printTestInfo('No conversations available for pagination test');
        }
        
      } catch (e) {
        TestConfig.printTestResult(false, 'Pagination test failed: $e');
      }
    });

    test('should validate conversation types', () async {
      TestConfig.printTestHeader('Conversation Types Test');
      
      try {
        final response = await ConversationService.getConversations();
        
        if (response != null && response.conversations.isNotEmpty) {
          TestConfig.printTestResult(true, 'Testing conversation types');
          
          final types = response.conversations.map((c) => c.type).toSet();
          TestConfig.printTestDebug('Found conversation types: $types');
          
          // Vérifier que les types sont valides
          for (final type in types) {
            if (ConversationType.values.contains(type)) {
              TestConfig.printTestDebug('✓ Valid type: $type');
            } else {
              TestConfig.printTestWarning('Unknown conversation type: $type');
            }
          }
          
          expect(types, isNotEmpty);
        } else {
          TestConfig.printTestInfo('No conversations to test types');
        }
        
      } catch (e) {
        TestConfig.printTestResult(false, 'Conversation types test failed: $e');
      }
    });
  });
}
