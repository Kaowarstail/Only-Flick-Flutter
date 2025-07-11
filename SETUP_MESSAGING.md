# OnlyFlick - Configuration et Installation

## Installation de Flutter

Ce projet nécessite Flutter pour fonctionner. Si Flutter n'est pas installé sur votre système, suivez ces étapes :

### 1. Télécharger Flutter

Allez sur [https://flutter.dev/docs/get-started/install/windows](https://flutter.dev/docs/get-started/install/windows) et téléchargez Flutter.

### 2. Installation rapide avec Git

```bash
cd C:\
git clone https://github.com/flutter/flutter.git -b stable
```

### 3. Ajouter Flutter au PATH

Ajoutez `C:\flutter\bin` à votre variable d'environnement PATH.

### 4. Vérifier l'installation

```bash
flutter doctor
```

## Configuration du projet

### 1. Installation des dépendances

```bash
cd Only-Flick-Flutter
flutter pub get
```

### 2. Configuration de l'environnement

Copiez le fichier `.env.example` en `.env` et configurez vos variables :

```
API_URL=http://localhost:8080
```

### 3. Lancement du backend Go

```bash
cd ../Only-Flick-Go
go run cmd/api/main.go
```

### 4. Lancement de l'application Flutter

```bash
cd ../Only-Flick-Flutter
flutter run
```

## Fonctionnalités de Messagerie

### API REST Backend (Go)

- **GET** `/api/conversations` - Récupérer les conversations de l'utilisateur
- **POST** `/api/conversations` - Créer une nouvelle conversation
- **GET** `/api/conversations/{id}` - Récupérer une conversation spécifique
- **GET** `/api/conversations/{id}/messages` - Récupérer les messages d'une conversation
- **PUT** `/api/conversations/{id}/mark-read` - Marquer une conversation comme lue

### Frontend Flutter

#### Modèles créés :
- `Conversation` - Modèle pour les conversations
- `Message` - Modèle pour les messages
- `ConversationDTO` et `MessageDTO` - DTOs pour l'API

#### Services :
- `MessagingService` - Service pour les appels API REST
- `MessagingProvider` - Provider pour la gestion d'état

#### Pages :
- `ConversationsPage` - Liste des conversations
- `ChatPage` - Interface de chat pour une conversation
- `MessagingTestPage` - Page de test pour l'API

### Test de la messagerie

1. Lancez le backend Go
2. Lancez l'application Flutter
3. Naviguez vers la page de test de messagerie
4. Vérifiez que l'API répond correctement

### Intégration dans l'application

La messagerie est intégrée dans la navigation principale avec un onglet "Messages". Le provider est configuré dans `main.dart` et est disponible dans toute l'application.

## Debug et Résolution de problèmes

### Backend ne démarre pas
- Vérifiez que la base de données SQLite est accessible
- Vérifiez les logs Go pour les erreurs

### Erreurs Flutter
- Exécutez `flutter doctor` pour vérifier l'installation
- Exécutez `flutter clean && flutter pub get` pour nettoyer le cache

### Erreurs de compilation
- Vérifiez que toutes les dépendances sont installées
- Vérifiez que les imports sont corrects

### API non accessible
- Vérifiez que le backend Go est démarré
- Vérifiez l'URL dans le fichier `.env`
- Vérifiez les logs réseau dans l'application Flutter
