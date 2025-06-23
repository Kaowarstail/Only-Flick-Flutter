import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/auth/forgot_password_page.dart';
import '../pages/auth/reset_password_page.dart';
import 'package:only_flick_flutter/pages/home_page.dart';
import '../providers/auth_provider.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      
      case resetPassword:
        final args = settings.arguments as Map<String, dynamic>?;
        final token = args?['token'] as String?;
        if (token == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('Token de réinitialisation manquant'),
              ),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => ResetPasswordPage(resetToken: token),
        );
      
      case home:
        return MaterialPageRoute(
          builder: (_) => Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isAuthenticated) {
                return const HomePage();
              } else {
                return const LoginPage();
              }
            },
          ),
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page non trouvée'),
            ),
          ),
        );
    }
  }

  static String get initialRoute {
    return login;
  }
}
