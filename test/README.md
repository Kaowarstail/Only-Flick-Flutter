# OnlyFlick Messaging System Tests

## 🧪 Vue d'ensemble

Cette suite de tests valide complètement l'intégration des services de messagerie OnlyFlick avec votre backend Go. Elle teste tous les aspects du système de messagerie : API, services, modèles, et intégration end-to-end.

## 📁 Structure des Tests

```
test/
├── test_config.dart                           # Configuration centrale des tests
├── services/                                  # Tests unitaires des services
│   ├── api_service_integration_test.dart     # Tests ApiService
│   ├── message_service_test.dart             # Tests MessageService
│   ├── conversation_service_test.dart        # Tests ConversationService
│   ├── notification_service_test.dart        # Tests NotificationService
│   └── media_service_test.dart               # Tests MediaService
└── integration/
    └── messaging_integration_test.dart       # Tests d'intégration complets
```

## 🚀 Lancement des Tests

### Option 1: Scripts automatisés (Recommandé)

#### Windows (PowerShell)
```powershell
# Tous les tests
.\run_messaging_tests.ps1

# Tests unitaires seulement
.\run_messaging_tests.ps1 -Unit

# Tests d'intégration seulement
.\run_messaging_tests.ps1 -Integration

# Mode verbose
.\run_messaging_tests.ps1 -Verbose
```

#### Linux/Mac (Bash)
```bash
# Rendre le script exécutable
chmod +x run_messaging_tests.sh

# Tous les tests
./run_messaging_tests.sh

# Tests unitaires seulement
./run_messaging_tests.sh --unit

# Tests d'intégration seulement
./run_messaging_tests.sh --integration

# Mode verbose
./run_messaging_tests.sh --verbose
```

### Option 2: Commandes Flutter directes

```bash
# Tests unitaires individuels
flutter test test/services/api_service_integration_test.dart
flutter test test/services/message_service_test.dart
flutter test test/services/conversation_service_test.dart
flutter test test/services/notification_service_test.dart
flutter test test/services/media_service_test.dart

# Test d'intégration complet
flutter test test/integration/messaging_integration_test.dart

# Tous les tests avec verbose
flutter test --verbose

# Tests en mode watch (re-run automatique)
flutter test --watch
```

## ⚙️ Prérequis et Configuration

### 1. Backend en cours d'exécution
```bash
# Assurez-vous que votre serveur Go fonctionne
cd ../Only-Flick-Go
go run main.go
# ou
make run
```

### 2. Configuration .env
Vérifiez que votre fichier `.env` contient :
```env
API_URL=http://localhost:8080
```

### 3. Base de données
- Assurez-vous que votre base de données contient des données de test
- Au moins un utilisateur pour l'authentification
- Quelques conversations et messages pour les tests

### 4. Authentification
- Connectez-vous via votre application pour obtenir un token JWT valide
- Les tests utilisent ce token pour les endpoints authentifiés

## 📊 Types de Tests

### Tests ApiService
- ✅ Connexion au backend
- ✅ Authentification JWT
- ✅ Gestion des erreurs HTTP
- ✅ Timeouts et résilience
- ✅ Structure des réponses API

### Tests MessageService
- ✅ Validation des messages
- ✅ Envoi de messages texte
- ✅ Récupération des messages
- ✅ Pagination des messages
- ✅ Gestion des erreurs métier

### Tests ConversationService
- ✅ Récupération des conversations
- ✅ Création/récupération de conversations
- ✅ Marquage comme lu
- ✅ Statistiques des conversations
- ✅ Recherche de conversations
- ✅ Pagination

### Tests NotificationService
- ✅ Démarrage/arrêt du polling
- ✅ Émission des mises à jour
- ✅ Adaptation fréquence (actif/arrière-plan)
- ✅ Vérification manuelle
- ✅ Gestion des subscriptions

### Tests MediaService
- ✅ Validation MIME types
- ✅ Validation extensions fichiers
- ✅ Validation tailles fichiers
- ✅ Détection types de média
- ✅ Gestion erreurs upload

### Tests d'Intégration
- ✅ Flow complet end-to-end
- ✅ Dépendances entre services
- ✅ Gestion globale des erreurs
- ✅ Performance et timeouts

## 🔍 Interprétation des Résultats

### ✅ Succès Complet (100%)
Votre système de messagerie fonctionne parfaitement ! Vous pouvez :
- Implémenter les composants UI
- Ajouter des fonctionnalités temps réel
- Optimiser les performances

### 👍 Succès Partiel (80-99%)
La plupart des fonctionnalités marchent. Vérifiez :
- Les tests qui échouent
- Les logs détaillés avec `--verbose`
- L'état de votre backend

### ⚠️ Problèmes Modérés (50-79%)
Votre système a besoin d'attention :
- Vérifiez la connectivité backend
- Validez l'authentification
- Contrôlez les données de test

### ❌ Problèmes Majeurs (<50%)
Action urgente requise :
- Backend non démarré ou inaccessible
- Configuration incorrecte
- Problèmes de base de données

## 🛠️ Dépannage

### Erreurs de Connexion
```
❌ Connection refused / Cannot connect to backend
```
**Solutions :**
- Démarrez votre serveur Go : `cd ../Only-Flick-Go && go run main.go`
- Vérifiez l'URL dans `.env` : `API_URL=http://localhost:8080`
- Contrôlez le firewall et les ports

### Erreurs d'Authentification
```
❌ JWT token missing or expired (401)
```
**Solutions :**
- Connectez-vous via votre application
- Vérifiez que le token est sauvé dans SharedPreferences
- Contrôlez les endpoints d'authentification

### Erreurs de Timeout
```
❌ TimeoutException
```
**Solutions :**
- Vérifiez les performances du backend
- Contrôlez la connexion réseau
- Augmentez les timeouts si nécessaire

### Erreurs de Données
```
❌ Conversation not found / User not found
```
**Solutions :**
- Ajoutez des données de test à votre base
- Vérifiez les IDs utilisés dans `test_config.dart`
- Contrôlez la cohérence des données

## 📝 Personnalisation des Tests

### Modifier les IDs de Test
Éditez `test/test_config.dart` :
```dart
class TestConfig {
  // Adaptez ces IDs selon vos données de test
  static const String testUserId1 = 'your-user-id-1';
  static const String testUserId2 = 'your-user-id-2';
  static const String testConversationId = 'your-conversation-id';
}
```

### Ajouter de Nouveaux Tests
1. Créez un nouveau fichier dans `test/services/`
2. Importez les dépendances nécessaires
3. Suivez la structure des tests existants
4. Ajoutez le test aux scripts de lancement

### Configurer les Timeouts
Modifiez dans `test_config.dart` :
```dart
static const Duration defaultTimeout = Duration(seconds: 10);
static const Duration longTimeout = Duration(seconds: 30);
```

## 🎯 Prochaines Étapes

Après que tous les tests passent :

1. **Interface Utilisateur**
   - Implémentez les écrans de messagerie
   - Intégrez les services testés
   - Ajoutez la gestion d'état (Provider/Bloc)

2. **Fonctionnalités Avancées**
   - WebSocket pour temps réel
   - Notifications push
   - Recherche avancée
   - Filtres et tri

3. **Optimisations**
   - Cache local des messages
   - Pagination infinie
   - Compression des images
   - Retry automatique

4. **Tests UI**
   - Tests de widgets
   - Tests d'intégration UI
   - Tests de performance

## 📞 Support

Si vous rencontrez des problèmes :

1. **Vérifiez les logs** avec `--verbose`
2. **Consultez la documentation** de l'API Go
3. **Testez manuellement** les endpoints avec Postman
4. **Vérifiez la cohérence** entre Flutter et Go

---

**Note :** Ces tests sont conçus pour valider l'intégration complète de votre système de messagerie. Ils simulent un usage réel et détectent les problèmes avant la mise en production.
