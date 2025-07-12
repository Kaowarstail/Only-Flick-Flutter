import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/content_interaction_provider.dart';
import 'providers/providers.dart'; // Import des providers de messagerie
import 'services/content_interaction_service.dart';
import 'services/cloudinary_service.dart';
import 'routes/app_routes.dart';
import 'pages/auth/login_page.dart';
import 'pages/instagram_style_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Charger les variables d'environnement
  await dotenv.load(fileName: ".env");
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider d'authentification
        ChangeNotifierProvider(create: (_) => AuthProvider()..initAuth()),
        
        // Providers de contenu
        ChangeNotifierProvider(create: (_) => ContentInteractionProvider()),
        ChangeNotifierProvider(create: (_) => ContentInteractionService()),
        
        // Providers de messagerie
        ChangeNotifierProvider(create: (_) => ConversationProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ChatMediaProvider()),
        
        // Contrôleur principal de messagerie
        ChangeNotifierProxyProvider4<ConversationProvider, MessageProvider, 
            NotificationProvider, ChatMediaProvider, MessagingController>(
          create: (context) => MessagingController(
            conversationProvider: Provider.of<ConversationProvider>(context, listen: false),
            messageProvider: Provider.of<MessageProvider>(context, listen: false),
            notificationProvider: Provider.of<NotificationProvider>(context, listen: false),
            chatMediaProvider: Provider.of<ChatMediaProvider>(context, listen: false),
          ),
          update: (context, conversationProvider, messageProvider, 
                  notificationProvider, chatMediaProvider, previous) =>
              previous ?? MessagingController(
                conversationProvider: conversationProvider,
                messageProvider: messageProvider,
                notificationProvider: notificationProvider,
                chatMediaProvider: chatMediaProvider,
              ),
        ),
        
        // Service Cloudinary
        Provider.value(
          value: CloudinaryService(
            baseUrl: dotenv.env['API_URL'] ?? 'http://localhost:8080',
            authToken: '', // Sera mis à jour dans l'écran d'upload
          ),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            title: 'OnlyFlick',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: AppRoutes.login,
            onGenerateRoute: AppRoutes.generateRoute,
            home: authProvider.isLoading
                ? const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : authProvider.isAuthenticated 
                    ? const InstagramStyleHomePage() 
                    : const LoginPage(),
          );
        },
      ),
    );
  }
}