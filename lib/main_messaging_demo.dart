/// Example integration of OnlyFlick messaging system
/// This demonstrates how to integrate the messaging system into the main app

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/message_provider.dart';
import 'pages/messaging/conversations_list_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const OnlyFlickMessagingApp());
}

class OnlyFlickMessagingApp extends StatelessWidget {
  const OnlyFlickMessagingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => MessageProvider()),
      ],
      child: MaterialApp(
        title: 'OnlyFlick Messaging',
        theme: AppTheme.lightTheme,
        home: const MessagingDemoPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MessagingDemoPage extends StatefulWidget {
  const MessagingDemoPage({Key? key}) : super(key: key);

  @override
  State<MessagingDemoPage> createState() => _MessagingDemoPageState();
}

class _MessagingDemoPageState extends State<MessagingDemoPage> {
  @override
  void initState() {
    super.initState();
    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initAuth();
      context.read<MessageProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('OnlyFlick Messaging Demo'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.message,
              size: 100,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 20),
            const Text(
              'OnlyFlick Messaging System',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Modern 1-on-1 messaging with paid content',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ConversationsListPage(),
                  ),
                );
              },
              child: const Text('Open Conversations'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Features:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            _buildFeatureList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      '💬 Instagram-style messaging',
      '💰 Paid message system',
      '🖼️ Media sharing (images, videos)',
      '🔔 Real-time notifications',
      '📱 Modern UI with animations',
      '🔒 Secure with JWT authentication',
      '⚡ HTTP polling for real-time updates',
      '📊 Message status indicators',
      '🎨 OnlyFlick brand colors',
      '♿ Accessible design',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: features.map((feature) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            feature,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
        )).toList(),
      ),
    );
  }
}
