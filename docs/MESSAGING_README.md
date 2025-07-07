# OnlyFlick Messaging System

## Overview

A modern, Instagram-style messaging system built with Flutter for the OnlyFlick platform. Features include 1-on-1 conversations, paid messages, media sharing, and real-time updates.

## Features

### 🔥 Core Features
- **Instagram-style UI**: Modern, clean messaging interface
- **Paid Messages**: Monetizable content with blur overlay and unlock mechanism
- **Media Sharing**: Images and videos with preview support
- **Real-time Updates**: HTTP polling for live message updates
- **Message Status**: Sent, delivered, read indicators
- **Typing Indicators**: Real-time typing status
- **Reply System**: Reply to specific messages
- **Search**: Search conversations and users

### 🎨 Design
- **OnlyFlick Branding**: Custom colors (#CC0092, #FFB2E9)
- **Accessible Typography**: OpenSans font for readability
- **Smooth Animations**: Micro-interactions and transitions
- **Responsive Layout**: Works on all screen sizes
- **Dark Mode Ready**: Theme system prepared for dark mode

### 🔐 Security
- **JWT Authentication**: Secure user authentication
- **Input Validation**: Client-side validation for all inputs
- **Media Validation**: File type and size validation
- **Rate Limiting**: Built-in rate limiting considerations

## Architecture

### State Management
- **Provider Pattern**: Used for state management
- **Separation of Concerns**: Clean separation between UI, business logic, and data

### File Structure
```
lib/
├── models/
│   ├── message_models.dart      # Message, Conversation, Request models
│   └── user.dart                # User model
├── services/
│   ├── api_service.dart         # HTTP client wrapper
│   ├── message_service.dart     # Message API calls
│   ├── conversation_service.dart # Conversation API calls
│   └── notification_service.dart # Polling and notifications
├── providers/
│   ├── auth_provider.dart       # Authentication state
│   └── message_provider.dart    # Messaging state
├── pages/
│   └── messaging/
│       ├── conversations_list_page.dart  # Conversations list
│       └── chat_page.dart               # 1-on-1 chat
├── widgets/
│   ├── conversation_card.dart           # Conversation list item
│   ├── message_bubble.dart              # Message bubble
│   ├── paid_message_overlay.dart        # Paid message overlay
│   └── paid_message_composer.dart       # Paid message composer
└── theme/
    └── app_theme.dart                   # OnlyFlick theme
```

## Usage

### 1. Initialize Providers
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => AuthProvider()),
    ChangeNotifierProvider(create: (context) => MessageProvider()),
  ],
  child: YourApp(),
)
```

### 2. Navigate to Messaging
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ConversationsListPage(),
  ),
);
```

### 3. Open Specific Chat
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChatPage(
      conversationId: 'conversation-id',
      otherUser: user,
    ),
  ),
);
```

## API Integration

### Required Backend Endpoints

#### Conversations
- `GET /api/conversations` - Get user's conversations
- `POST /api/conversations` - Create new conversation
- `DELETE /api/conversations/:id` - Delete conversation
- `PUT /api/conversations/:id/read` - Mark as read

#### Messages
- `GET /api/conversations/:id/messages` - Get messages
- `POST /api/conversations/:id/messages` - Send message
- `POST /api/conversations/:id/messages/paid` - Send paid message
- `PUT /api/messages/:id/unlock` - Unlock paid message
- `POST /api/messages/media` - Upload media

#### Users
- `GET /api/users/search` - Search users
- `GET /api/users/:id` - Get user profile

### HTTP Polling
The system uses HTTP polling for real-time updates:
- Polls every 2 seconds when app is active
- Polls every 10 seconds when app is in background
- Stops polling when app is closed

## Paid Message System

### How It Works
1. User composes a paid message with custom price
2. Message is sent with blur overlay for recipient
3. Recipient can preview and choose to unlock
4. Payment is processed (external payment system)
5. Message is unlocked and fully visible

### Commission System
- Platform takes 20% commission on paid messages
- Real-time commission calculation in composer
- Transparent pricing for users

## Customization

### Colors
Update `lib/theme/app_theme.dart` to customize colors:
```dart
static const Color primaryColor = Color(0xFFCC0092);
static const Color secondaryColor = Color(0xFFFFB2E9);
```

### Typography
The system uses OpenSans for accessibility. To use Luciole font:
1. Add Luciole font files to `assets/fonts/`
2. Update `pubspec.yaml`
3. Update `app_theme.dart`

### Animations
All animations are customizable in individual widgets:
- Message bubble animations
- Typing indicators
- Send button animations
- Page transitions

## Dependencies

### Required Packages
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  http: ^1.2.1
  image_picker: ^1.1.2
  shared_preferences: ^2.2.3
  google_fonts: ^6.2.1
```

### Optional Packages
```yaml
# For enhanced features
flutter_local_notifications: ^17.0.0  # Local notifications
permission_handler: ^11.3.1           # Permissions
cached_network_image: ^3.3.1          # Image caching
video_player: ^2.8.6                  # Video playback
```

## Testing

### Unit Tests
- Test message provider logic
- Test API service calls
- Test model serialization

### Widget Tests
- Test message bubble rendering
- Test conversation list
- Test paid message overlay

### Integration Tests
- Test full messaging flow
- Test paid message workflow
- Test media sharing

## Performance

### Optimizations
- **Lazy Loading**: Messages loaded on demand
- **Pagination**: 50 messages per page
- **Image Caching**: Cached network images
- **Memory Management**: Proper disposal of resources

### Best Practices
- Use const constructors where possible
- Implement proper error handling
- Add loading states for better UX
- Use debouncing for search

## Security Considerations

### Client-Side
- Validate all user inputs
- Sanitize media uploads
- Implement rate limiting
- Use secure storage for tokens

### Server-Side
- Implement proper authentication
- Validate all API requests
- Use HTTPS only
- Implement proper access control

## Deployment

### Build Configuration
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### Environment Variables
Create `.env` file:
```
API_BASE_URL=https://your-api.com
API_VERSION=v1
ENABLE_LOGGING=true
```

## Contributing

1. Follow Flutter/Dart style guidelines
2. Add tests for new features
3. Update documentation
4. Test on multiple devices
5. Ensure accessibility compliance

## License

This messaging system is part of the OnlyFlick platform and follows the project's licensing terms.
