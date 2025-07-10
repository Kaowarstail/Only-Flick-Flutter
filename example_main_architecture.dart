import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/content_interaction_provider.dart';
import 'providers/messaging_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/notification_provider.dart';

void main() {
  runApp(OnlyFlickApp());
}

class OnlyFlickApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 🔐 Authentication Provider (ChangeNotifier)
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        
        // 💬 Messaging Provider (ChangeNotifier + Stream)
        ChangeNotifierProvider(
          create: (_) => MessagingProvider(),
        ),
        
        // ❤️ Content Interactions (ChangeNotifier)
        ChangeNotifierProvider(
          create: (_) => ContentInteractionProvider(),
        ),
        
        // 🔔 Notifications (StreamProvider pour temps réel)
        StreamProvider<List<NotificationModel>>(
          create: (context) => context.read<MessagingProvider>().notificationStream,
          initialData: const [],
        ),
        
        // 🎨 Theme Provider (ChangeNotifier)
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        
        // 📱 App State Provider (ChangeNotifier)
        ChangeNotifierProvider(
          create: (_) => AppStateProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'OnlyFlick',
            theme: themeProvider.currentTheme,
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                if (authProvider.isLoading) {
                  return const SplashScreen();
                }
                return authProvider.isAuthenticated 
                    ? const MainScreen() 
                    : const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
