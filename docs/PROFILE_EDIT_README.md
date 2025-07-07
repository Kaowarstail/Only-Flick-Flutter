# OnlyFlick Profile Edit System

Un système d'édition de profil moderne et robuste pour OnlyFlick, développé avec Flutter et l'architecture Provider.

## 🎯 Fonctionnalités

### ✨ Édition de profil complète
- **Informations de base** : nom d'utilisateur, nom d'affichage, biographie
- **Photo de profil** : upload, recadrage, compression automatique
- **Liens sociaux** : Instagram, Twitter, TikTok, YouTube, site web
- **Paramètres créateur** : prix d'abonnement, catégorie, bannière

### 🛡️ Validation robuste
- **Validation temps réel** : feedback immédiat pour chaque champ
- **Validation double** : côté client (Flutter) et serveur (Go)
- **Disponibilité username** : vérification en temps réel
- **Formats d'image** : validation automatique des uploads

### 📱 Interface moderne
- **Design OnlyFlick** : couleurs #CC0092, #FFB2E9, typographie Luciole
- **UX optimisée** : loading states, animations, micro-interactions
- **Responsive** : adapté à tous les écrans
- **Accessibilité** : font Luciole, contrastes optimisés

## 🏗️ Architecture

### Structure des fichiers
```
lib/
├── models/
│   ├── profile_models.dart          # Modèles étendus (UserProfile, CreatorProfile)
│   └── user.dart                    # Modèle utilisateur existant
├── services/
│   ├── user_service.dart           # Service utilisateur étendu
│   ├── creator_service.dart        # Service créateur étendu
│   ├── image_upload_service.dart   # Service upload d'images
│   └── api_service_new.dart        # Service API avec support multipart
├── providers/
│   └── profile_provider.dart       # Provider de gestion d'état
├── pages/
│   └── profile_edit_page.dart      # Page principale d'édition
├── widgets/
│   ├── profile_edit/
│   │   ├── profile_header.dart     # Header avec avatar/bannière
│   │   ├── profile_form_section.dart # Section informations de base
│   │   ├── social_links_section.dart # Section liens sociaux
│   │   └── creator_settings_section.dart # Section paramètres créateur
│   └── common/
│       ├── custom_text_field.dart  # Champ de texte personnalisé
│       ├── loading_overlay.dart    # Overlay de chargement
│       └── error_dialog.dart       # Dialog d'erreur
├── utils/
│   └── profile_validation.dart     # Utilitaires de validation
└── theme/
    ├── app_colors.dart             # Couleurs OnlyFlick
    └── app_text_styles.dart        # Styles de texte Luciole
```

## 🚀 Installation

### 1. Dépendances
Ajoutez ces dépendances à votre `pubspec.yaml` :

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  http: ^1.2.1
  image_picker: ^1.1.2
  image: ^4.1.7
  path_provider: ^2.1.1
  shared_preferences: ^2.2.3
```

### 2. Configuration des providers
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => AuthProvider()),
    ChangeNotifierProvider(create: (context) => ProfileProvider()),
  ],
  child: MyApp(),
)
```

### 3. Navigation vers l'édition
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ProfileEditPage(),
  ),
);
```

## 📋 Modèles de données

### UserProfile
```dart
class UserProfile {
  final String id;
  final String username;
  final String? displayName;
  final String? bio;
  final String? avatarUrl;
  final SocialLinks? socialLinks;
  final int subscribersCount;
  final int subscriptionsCount;
  // ...
}
```

### CreatorProfile  
```dart
class CreatorProfile {
  final String id;
  final String userId;
  final double subscriptionPrice;
  final String? category;
  final String? bannerUrl;
  final int subscribersCount;
  final bool isVerified;
  // ...
}
```

## 🔧 Services

### UserService - Méthodes étendues
```dart
// Profil utilisateur
static Future<UserProfile> getUserProfile(String userId)
static Future<ApiResponse<UserProfile>> updateUserProfile(String userId, UpdateProfileRequest request)
static Future<ApiResponse<String>> uploadProfileAvatar(String userId, File imageFile)
static Future<ApiResponse<SocialLinks>> updateSocialLinks(String userId, SocialLinksRequest request)
static Future<ApiResponse<UserStats>> getUserStats(String userId)
static Future<ApiResponse<bool>> checkUsernameAvailability(String username)
```

### CreatorService - Méthodes étendues
```dart
// Profil créateur
static Future<CreatorProfile> getCreatorProfile(String creatorId)
static Future<ApiResponse<CreatorProfile>> updateCreatorProfile(String creatorId, UpdateCreatorRequest request)
static Future<ApiResponse<String>> uploadCreatorBanner(String creatorId, File imageFile)
static Future<ApiResponse<CreatorProfile>> updateSubscriptionPrice(String creatorId, double newPrice)
static Future<ApiResponse<CreatorEarnings>> getCreatorEarnings(String creatorId)
```

### ImageUploadService
```dart
// Gestion des images
static Future<File?> pickImage()
static Future<ValidationResult> validateImage(File imageFile)
static Future<File> compressImage(File imageFile, {int maxWidth, int maxHeight, int quality})
static Future<String> uploadImage(File imageFile, String endpoint)
```

## 🎨 Validation

### Validation des champs
```dart
class ProfileValidation {
  static String? validateUsername(String? username)
  static String? validateDisplayName(String? displayName)
  static String? validateBio(String? bio)
  static String? validateSubscriptionPrice(double? price)
  static String? validateInstagram(String? url)
  static String? validateTwitter(String? url)
  static String? validateTiktok(String? url)
  static String? validateYoutube(String? url)
  static String? validateWebsite(String? url)
}
```

### Contraintes de validation
- **Username** : 3-30 caractères, lettres/chiffres/_
- **Bio** : 500 caractères maximum
- **Prix** : 4.99€ à 99.99€
- **URLs** : validation pattern spécifique par plateforme

## 🔄 Gestion d'état

### ProfileProvider
```dart
class ProfileProvider extends ChangeNotifier {
  // États
  ProfileLoadingState get loadingState;
  UserProfile? get userProfile;
  CreatorProfile? get creatorProfile;
  bool get hasUnsavedChanges;
  
  // Actions
  Future<void> loadUserProfile(String userId);
  Future<void> loadCreatorProfile(String creatorId);
  Future<void> pickAvatar();
  Future<void> pickBanner();
  Future<bool> saveProfile();
  void validateField(String fieldName, String value);
  Future<bool> checkUsernameAvailability(String username);
}
```

## 🎯 Utilisation

### Exemple d'utilisation basique
```dart
class ProfileEditExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Éditer le profil'),
            actions: [
              TextButton(
                onPressed: profileProvider.hasUnsavedChanges
                    ? () => profileProvider.saveProfile()
                    : null,
                child: const Text('Sauvegarder'),
              ),
            ],
          ),
          body: const ProfileEditPage(),
        );
      },
    );
  }
}
```

### Validation en temps réel
```dart
CustomTextField(
  controller: profileProvider.usernameController,
  label: 'Nom d\'utilisateur',
  onChanged: (value) {
    profileProvider.validateField('username', value);
  },
  errorText: profileProvider.validationErrors['username'],
)
```

## 🔗 Intégration API

### Endpoints requis
```
# Profil utilisateur
GET    /api/v1/users/{id}/profile
PUT    /api/v1/users/{id}/profile  
POST   /api/v1/users/{id}/avatar
PUT    /api/v1/users/{id}/social-links
GET    /api/v1/users/{id}/stats
GET    /api/v1/users/check-username?username={username}

# Profil créateur
GET    /api/v1/creators/{id}/profile
PUT    /api/v1/creators/{id}/profile
POST   /api/v1/creators/{id}/banner
PUT    /api/v1/creators/{id}/subscription-price
GET    /api/v1/creators/{id}/earnings
```

### Structure des requêtes
```json
{
  "username": "nouvel_username",
  "display_name": "Nouveau nom",
  "bio": "Nouvelle biographie...",
  "social_links": {
    "instagram": "https://instagram.com/username",
    "twitter": "https://twitter.com/username"
  }
}
```

## 🎨 Design System

### Couleurs OnlyFlick
```dart
static const Color primary = Color(0xFFCC0092);     // Rose fuchsia
static const Color secondary = Color(0xFFFFB2E9);   // Rose clair
static const Color backgroundPrimary = Colors.white;
static const Color textPrimary = Colors.black;
static const Color textSecondary = Color(0xFF666666);
```

### Typographie Luciole
```dart
static const String fontFamily = 'Luciole';
static const TextStyle heading1 = TextStyle(
  fontFamily: fontFamily,
  fontSize: 32,
  fontWeight: FontWeight.w700,
);
```

## 🔧 Configuration

### Permissions (Android)
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />
```

### Permissions (iOS)
```xml
<key>NSCameraUsageDescription</key>
<string>OnlyFlick a besoin d'accéder à l'appareil photo pour les photos de profil</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>OnlyFlick a besoin d'accéder à la galerie pour les photos de profil</string>
```

## 📈 Performance

### Optimisations
- **Compression automatique** : images redimensionnées selon l'usage
- **Validation debounced** : évite les appels API excessifs
- **Loading states** : feedback utilisateur pendant les opérations
- **Cache local** : stockage des données temporaires

### Tailles d'images
- **Avatar** : 500x500px, 85% qualité
- **Bannière** : 1200x400px, 90% qualité
- **Formats** : JPEG, PNG, WebP
- **Taille max** : 5MB par image

## 🧪 Tests

### Tests unitaires
```dart
// Test validation
testWidgets('Username validation', (tester) async {
  expect(ProfileValidation.validateUsername('test'), isNull);
  expect(ProfileValidation.validateUsername('ab'), isNotNull);
});

// Test provider
testWidgets('Profile provider state', (tester) async {
  final provider = ProfileProvider();
  expect(provider.isLoading, false);
  expect(provider.hasUnsavedChanges, false);
});
```

## 🚀 Déploiement

### Build production
```bash
# Android
flutter build apk --release

# iOS  
flutter build ios --release

# Web
flutter build web --release
```

## 📚 Documentation

### Fichiers de documentation
- `PROFILE_EDIT_README.md` : ce fichier
- `MESSAGING_README.md` : système de messagerie
- `API_DOCUMENTATION.md` : endpoints API
- `DESIGN_SYSTEM.md` : guide du design OnlyFlick

## 🤝 Contribution

1. **Style de code** : respecter les conventions Flutter/Dart
2. **Tests** : ajouter des tests pour les nouvelles fonctionnalités
3. **Documentation** : mettre à jour la documentation
4. **Accessibilité** : respecter les guidelines WCAG
5. **Performance** : optimiser les performances

## 📄 License

Ce système d'édition de profil fait partie de la plateforme OnlyFlick et suit les termes de licence du projet.

---

**Développé avec ❤️ pour OnlyFlick**
