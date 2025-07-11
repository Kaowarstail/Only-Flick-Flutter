import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/messaging_provider.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class MessagingTestPage extends StatefulWidget {
  const MessagingTestPage({super.key});

  @override
  State<MessagingTestPage> createState() => _MessagingTestPageState();
}

class _MessagingTestPageState extends State<MessagingTestPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _testMessagingAPI();
    });
  }

  Future<void> _testMessagingAPI() async {
    final messagingProvider = context.read<MessagingProvider>();
    
    // Test de chargement des conversations
    print('🧪 Test: Chargement des conversations...');
    await messagingProvider.loadConversations();
    
    if (messagingProvider.conversationsError != null) {
      print('❌ Erreur lors du chargement des conversations: ${messagingProvider.conversationsError}');
    } else {
      print('✅ Conversations chargées: ${messagingProvider.conversations.length} conversations trouvées');
      
      // Si on a des conversations, testons le chargement des messages
      if (messagingProvider.conversations.isNotEmpty) {
        final firstConversation = messagingProvider.conversations.first;
        print('🧪 Test: Chargement des messages pour la conversation ${firstConversation.id}...');
        
        await messagingProvider.loadMessages(firstConversation.id);
        
        if (messagingProvider.messagesError != null) {
          print('❌ Erreur lors du chargement des messages: ${messagingProvider.messagesError}');
        } else {
          final messages = messagingProvider.getCurrentMessages(firstConversation.id);
          print('✅ Messages chargés: ${messages.length} messages trouvés');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Messagerie API'),
        backgroundColor: Colors.blue,
      ),
      body: Consumer<MessagingProvider>(
        builder: (context, messagingProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'État de la Messagerie',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                // État des conversations
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conversations',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text('Nombre: ${messagingProvider.conversations.length}'),
                        Text('Chargement: ${messagingProvider.isLoadingConversations ? "Oui" : "Non"}'),
                        if (messagingProvider.conversationsError != null)
                          Text(
                            'Erreur: ${messagingProvider.conversationsError}',
                            style: const TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // État des messages
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Messages',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text('Chargement: ${messagingProvider.isLoadingMessages ? "Oui" : "Non"}'),
                        if (messagingProvider.messagesError != null)
                          Text(
                            'Erreur: ${messagingProvider.messagesError}',
                            style: const TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Liste des conversations
                Expanded(
                  child: Card(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Liste des Conversations',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Expanded(
                          child: messagingProvider.conversations.isEmpty
                              ? const Center(
                                  child: Text('Aucune conversation trouvée'),
                                )
                              : ListView.builder(
                                  itemCount: messagingProvider.conversations.length,
                                  itemBuilder: (context, index) {
                                    final conversation = messagingProvider.conversations[index];
                                    return ListTile(
                                      title: Text(conversation.title.isNotEmpty 
                                          ? conversation.title 
                                          : 'Conversation ${conversation.id}'),
                                      subtitle: Text(conversation.lastMessage ?? 'Aucun message'),
                                      trailing: conversation.unreadCount > 0
                                          ? CircleAvatar(
                                              radius: 10,
                                              child: Text(
                                                conversation.unreadCount.toString(),
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                            )
                                          : null,
                                      onTap: () => _loadMessagesForConversation(conversation),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Boutons d'action
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => messagingProvider.loadConversations(),
                      child: const Text('Recharger Conversations'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _testMessagingAPI,
                      child: const Text('Test Complet'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _loadMessagesForConversation(Conversation conversation) async {
    final messagingProvider = context.read<MessagingProvider>();
    await messagingProvider.loadMessages(conversation.id);
    
    final messages = messagingProvider.getCurrentMessages(conversation.id);
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Messages de ${conversation.title}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: messages.isEmpty
              ? const Center(child: Text('Aucun message'))
              : ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ListTile(
                      title: Text(message.content),
                      subtitle: Text('De: ${message.senderName ?? "Inconnu"}'),
                      trailing: Text(
                        '${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
