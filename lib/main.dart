import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/content_interaction_provider.dart';
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
        ChangeNotifierProvider(create: (_) => AuthProvider()..initAuth()),
        ChangeNotifierProvider(create: (_) => ContentInteractionProvider()),
        ChangeNotifierProvider(create: (_) => ContentInteractionService()),
        // Ajout du service CloudinaryService (via Provider.value car ce n'est pas un ChangeNotifier)
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