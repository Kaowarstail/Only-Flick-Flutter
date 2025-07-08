import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/content_interaction_provider.dart';
import 'providers/message_provider.dart';
import 'services/content_interaction_service.dart';
import 'services/websocket_service.dart';
import 'services/connectivity_service.dart';
import 'services/local_notification_service.dart';
import 'services/message_service.dart';
import 'services/conversation_service.dart';
import 'services/notification_service.dart';
import 'routes/app_routes.dart';
import 'pages/auth/login_page.dart';
import 'pages/instagram_style_home_page.dart';
import 'widgets/websocket_debug_panel.dart';

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
        ChangeNotifierProvider(create: (_) => AuthProvider()..initAuth()),
        ChangeNotifierProvider(create: (_) => ContentInteractionProvider()),
        ChangeNotifierProvider(create: (_) => ContentInteractionService()),
        ChangeNotifierProvider(create: (_) => WebSocketService()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        ChangeNotifierProvider(create: (_) => MessageProvider(
          messageService: MessageService(),
          conversationService: ConversationService(),
          notificationService: NotificationService(),
          webSocketService: WebSocketService(),
          connectivityService: ConnectivityService(),
          localNotificationService: LocalNotificationService(),
        )),
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
                    ? const AppWithWebSocket() 
                    : const LoginPage(),
          );
        },
      ),
    );
  }
}

class AppWithWebSocket extends StatefulWidget {
  const AppWithWebSocket({Key? key}) : super(key: key);

  @override
  State<AppWithWebSocket> createState() => _AppWithWebSocketState();
}

class _AppWithWebSocketState extends State<AppWithWebSocket> with WidgetsBindingObserver {
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    final messageProvider = context.read<MessageProvider>();
    final webSocketService = context.read<WebSocketService>();
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App est revenu au premier plan
        print('App resumed - reconnecting services');
        if (messageProvider.isWebSocketEnabled) {
          webSocketService.sendUserStatus(true);
        }
        break;
      case AppLifecycleState.paused:
        // App est en arrière-plan
        print('App paused - updating user status');
        if (messageProvider.isWebSocketEnabled) {
          webSocketService.sendUserStatus(false);
        }
        break;
      case AppLifecycleState.detached:
        // App est fermé
        print('App detached - disconnecting services');
        webSocketService.disconnect();
        break;
      default:
        break;
    }
  }
  
  Future<void> _initializeServices() async {
    try {
      print('Initializing WebSocket services...');
      
      final messageProvider = context.read<MessageProvider>();
      final authProvider = context.read<AuthProvider>();
      
      // Le MessageProvider s'initialise automatiquement dans son constructeur
      // Pas besoin d'appeler initialize() ou initializeWebSocket()
      print('MessageProvider initialized automatically in constructor');
      
      setState(() {
        _isInitialized = true;
      });
      
      print('WebSocket services initialized successfully');
      
    } catch (e) {
      print('Error initializing WebSocket services: $e');
      setState(() {
        _isInitialized = true; // Continue même en cas d'erreur
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing real-time services...'),
            ],
          ),
        ),
      );
    }
    
    // En mode debug, afficher le panneau de debug
    const bool kDebugMode = true; // TODO: Utiliser kDebugMode de Flutter
    
    if (kDebugMode) {
      return const DebugOverlay(
        child: InstagramStyleHomePage(),
      );
    }
    
    return const InstagramStyleHomePage();
  }
}