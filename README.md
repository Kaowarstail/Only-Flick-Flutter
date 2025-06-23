# OnlyFlick Flutter

Une application Flutter pour la plateforme OnlyFlick, permettant de découvrir et partager du contenu créé par des créateurs.

## 🚀 Fonctionnalités

### Authentification
- ✅ Connexion avec email/mot de passe
- ✅ Inscription avec validation
- ✅ Mot de passe oublié
- ✅ Réinitialisation de mot de passe avec token
- ✅ Rafraîchissement automatique des tokens
- ✅ Déconnexion sécurisée

### Gestion des utilisateurs
- ✅ Profil utilisateur
- ✅ Modification du profil
- ✅ Gestion des rôles (utilisateur, créateur, admin)
- 🔄 Upload de photo de profil (en cours)
- 🔄 Blocage d'utilisateurs (en cours)

### Créateurs
- 🔄 Demande de statut créateur
- 🔄 Profil créateur avec bannière
- 🔄 Statistiques détaillées
- 🔄 Gestion des abonnés

## 🏗️ Architecture

### Structure du projet

```
lib/
├── main.dart                 # Point d'entrée de l'application
├── models/                   # Modèles de données
│   ├── user.dart            # Modèle utilisateur
│   └── creator.dart         # Modèle créateur
├── pages/                   # Pages de l'application
│   ├── auth/                # Pages d'authentification
│   │   ├── login_page.dart
│   │   ├── register_page.dart
│   │   ├── forgot_password_page.dart
│   │   └── reset_password_page.dart
│   ├── home_page.dart       # Page d'accueil
│   └── profile_page.dart    # Page de profil
├── providers/               # Gestion d'état avec Provider
│   └── auth_provider.dart   # Provider d'authentification
├── services/                # Services pour les appels API
│   ├── api_service.dart     # Service HTTP centralisé
│   ├── auth_service.dart    # Service d'authentification
│   ├── user_service.dart    # Service utilisateurs
│   └── creator_service.dart # Service créateurs
├── widgets/                 # Widgets réutilisables
│   └── auth_widgets.dart    # Widgets pour l'authentification
├── theme/                   # Thème de l'application
│   └── app_theme.dart
└── routes/                  # Gestion des routes
    └── app_routes.dart
```

### Services

#### ApiService
Service HTTP centralisé qui gère :
- Headers d'authentification automatiques
- Format de réponse standardisé du backend Golang
- Gestion d'erreurs uniforme
- Support pour GET, POST, PUT, DELETE

#### AuthService
Service d'authentification compatible avec les endpoints :
- `POST /auth/login`
- `POST /auth/register`
- `POST /auth/logout`
- `POST /auth/refresh-token`
- `POST /auth/reset-password`
- `PUT /auth/reset-password/:token`
- `GET /auth/me`

#### UserService
Service de gestion des utilisateurs pour :
- Récupération et mise à jour des profils
- Gestion des utilisateurs bloqués
- Upload de photos de profil

#### CreatorService
Service pour les créateurs avec support pour :
- Demande de statut créateur
- Gestion des profils créateurs
- Statistiques et abonnés

## 🔧 Configuration

### Variables d'environnement

Créez un fichier `.env` à la racine du projet :

```env
API_URL=http://localhost:8080
```

Pour la production, remplacez par l'URL de votre serveur backend.

### Backend

Cette application Flutter est conçue pour fonctionner avec un backend Golang qui implémente les endpoints documentés dans `api_endpoints.md`.

Le backend doit retourner les réponses au format standardisé :

```json
{
  "success": true,
  "data": { /* données de la réponse */ },
  "message": "Description optionnelle",
  "meta": { /* métadonnées comme pagination */ }
}
```

En cas d'erreur :

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Description de l'erreur"
  }
}
```

## 📦 Dépendances

### Principales
- `flutter`: Framework de développement
- `provider`: Gestion d'état
- `http`: Appels HTTP
- `shared_preferences`: Stockage local
- `google_fonts`: Polices Google

### Configuration
- `flutter_dotenv`: Variables d'environnement
- `go_router`: Navigation avancée (optionnel)

## 🚀 Installation et exécution

1. Clonez le repository
2. Installez les dépendances :
   ```bash
   flutter pub get
   ```
3. Créez le fichier `.env` avec l'URL de votre backend
4. Lancez l'application :
   ```bash
   flutter run
   ```

## 🔐 Authentification

L'application utilise un système d'authentification basé sur des tokens JWT :

1. L'utilisateur se connecte avec email/mot de passe
2. Le backend retourne un token JWT
3. Le token est stocké localement avec `shared_preferences`
4. Le token est automatiquement ajouté aux headers des requêtes API
5. Le token peut être rafraîchi automatiquement

## 🎨 Interface utilisateur

L'application utilise un design moderne avec :
- Couleurs cohérentes définies dans `AppTheme`
- Polices Google Fonts (Inter)
- Composants Material Design personnalisés
- Interface responsive

## 🔄 État de développement

### ✅ Complété
- Architecture de base
- Authentification complète
- Services API
- Pages d'authentification
- Gestion des erreurs

### 🔄 En cours
- Upload de fichiers (images)
- Gestion du contenu
- Abonnements
- Notifications

### 📋 À faire
- Tests unitaires
- Tests d'intégration
- Documentation API
- Optimisations de performance

## 🤝 Contribution

Les contributions sont les bienvenues ! Veuillez consulter les guidelines de contribution avant de soumettre une pull request.

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.
