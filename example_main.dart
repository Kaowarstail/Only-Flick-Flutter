import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'lib/providers/profile_provider.dart';
import 'lib/providers/auth_provider.dart';
import 'lib/pages/profile_edit_page.dart';
import 'lib/theme/app_colors.dart';
import 'lib/theme/app_text_styles.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
      ],
      child: MaterialApp(
        title: 'OnlyFlick Profile Edit',
        theme: ThemeData(
          primarySwatch: MaterialColor(0xFFCC0092, const {
            50: Color(0xFFFCE7F3),
            100: Color(0xFFF8BBD9),
            200: Color(0xFFF48FB1),
            300: Color(0xFFF06292),
            400: Color(0xFFEC407A),
            500: Color(0xFFCC0092),
            600: Color(0xFFAD1457),
            700: Color(0xFF880E4F),
            800: Color(0xFF6A1B33),
            900: Color(0xFF4A0E1A),
          }),
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.backgroundPrimary,
          fontFamily: AppTextStyles.fontFamily,
          textTheme: const TextTheme(
            displayLarge: AppTextStyles.heading1,
            displayMedium: AppTextStyles.heading2,
            displaySmall: AppTextStyles.heading3,
            headlineLarge: AppTextStyles.heading4,
            headlineMedium: AppTextStyles.heading5,
            headlineSmall: AppTextStyles.heading6,
            bodyLarge: AppTextStyles.bodyLarge,
            bodyMedium: AppTextStyles.bodyMedium,
            bodySmall: AppTextStyles.bodySmall,
            labelLarge: AppTextStyles.label,
            labelMedium: AppTextStyles.caption,
            labelSmall: AppTextStyles.caption,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const ProfileEditPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Example of how to navigate to the profile edit page
class NavigationExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OnlyFlick'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileEditPage(),
                  ),
                );
              },
              child: const Text('Éditer le profil'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example of how to use the ProfileProvider
class ProfileProviderExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profil'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileEditPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: profileProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile info
                      if (profileProvider.userProfile != null) ...[
                        Text(
                          profileProvider.userProfile!.displayName ?? 
                          profileProvider.userProfile!.username,
                          style: AppTextStyles.heading2,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '@${profileProvider.userProfile!.username}',
                          style: AppTextStyles.username,
                        ),
                        if (profileProvider.userProfile!.bio != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            profileProvider.userProfile!.bio!,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ],
                      
                      // Creator info
                      if (profileProvider.creatorProfile != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Créateur',
                                style: AppTextStyles.heading3.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Prix d\'abonnement: ${profileProvider.creatorProfile!.subscriptionPrice.toStringAsFixed(2)}€',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }
}
