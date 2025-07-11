<<<<<<< HEAD
// Models principaux pour la messagerie
export 'conversation.dart';
export 'message.dart';

// DTOs pour la messagerie
export 'dto/conversation_dto.dart';
export 'dto/message_dto.dart';

// Models existants
export 'user.dart';
export 'creator.dart';
export 'content_models.dart';
export 'admin_models.dart';
export 'admin_navigation.dart';

// Export user_models en cachant User pour éviter le conflit
export 'user_models.dart' hide User, AuthResponse;
=======
// Models principaux (messagerie compatible)
export 'user.dart';
export 'message.dart';
export 'conversation.dart';
export 'creator.dart';

// DTOs
export 'dto/message_dto.dart';
export 'dto/conversation_dto.dart';

// Models existants (éviter conflits)
export 'user_models.dart' hide User, AuthResponse;
export 'content_models.dart';
export 'admin_models.dart';
export 'admin_navigation.dart';
>>>>>>> 9e6ce054e4dab9a259c45349328c263edf321aab
