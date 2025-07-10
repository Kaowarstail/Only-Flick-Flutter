import '../models/message.dart';

class MessageConstants {
  // Limites
  static const int maxContentLength = 5000;
  static const int maxConversationsPerPage = 50;
  static const int maxMessagesPerPage = 100;
  static const int maxMediaFileSizeMB = 50;

  // Types MIME autorisés
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/webp',
    'image/gif',
  ];

  static const List<String> allowedVideoTypes = [
    'video/mp4',
    'video/webm',
    'video/quicktime',
    'video/avi',
    'video/mov',
  ];

  static const List<String> allowedAudioTypes = [
    'audio/mp3',
    'audio/wav',
    'audio/ogg',
    'audio/mpeg',
    'audio/m4a',
  ];

  static List<String> get allAllowedTypes => [
    ...allowedImageTypes,
    ...allowedVideoTypes,
    ...allowedAudioTypes,
  ];

  // Tailles de fichier en bytes
  static int get maxFileSizeBytes => maxMediaFileSizeMB * 1024 * 1024;

  // Helper methods
  static bool isImageType(String mimeType) {
    return allowedImageTypes.contains(mimeType.toLowerCase());
  }

  static bool isVideoType(String mimeType) {
    return allowedVideoTypes.contains(mimeType.toLowerCase());
  }

  static bool isAudioType(String mimeType) {
    return allowedAudioTypes.contains(mimeType.toLowerCase());
  }

  static MessageType getMessageTypeFromMimeType(String mimeType) {
    if (isImageType(mimeType)) return MessageType.image;
    if (isVideoType(mimeType)) return MessageType.video;
    if (isAudioType(mimeType)) return MessageType.audio;
    return MessageType.text;
  }

  static bool isAllowedMimeType(String mimeType) {
    return allAllowedTypes.contains(mimeType.toLowerCase());
  }

  static String getFileExtensionFromMimeType(String mimeType) {
    switch (mimeType.toLowerCase()) {
      // Images
      case 'image/jpeg':
      case 'image/jpg':
        return '.jpg';
      case 'image/png':
        return '.png';
      case 'image/webp':
        return '.webp';
      case 'image/gif':
        return '.gif';
      
      // Vidéos
      case 'video/mp4':
        return '.mp4';
      case 'video/webm':
        return '.webm';
      case 'video/quicktime':
      case 'video/mov':
        return '.mov';
      case 'video/avi':
        return '.avi';
      
      // Audio
      case 'audio/mp3':
      case 'audio/mpeg':
        return '.mp3';
      case 'audio/wav':
        return '.wav';
      case 'audio/ogg':
        return '.ogg';
      case 'audio/m4a':
        return '.m4a';
      
      default:
        return '';
    }
  }

  static String getMimeTypeFromExtension(String extension) {
    switch (extension.toLowerCase()) {
      // Images
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.gif':
        return 'image/gif';
      
      // Vidéos
      case '.mp4':
        return 'video/mp4';
      case '.webm':
        return 'video/webm';
      case '.mov':
        return 'video/quicktime';
      case '.avi':
        return 'video/avi';
      
      // Audio
      case '.mp3':
        return 'audio/mp3';
      case '.wav':
        return 'audio/wav';
      case '.ogg':
        return 'audio/ogg';
      case '.m4a':
        return 'audio/m4a';
      
      default:
        return 'application/octet-stream';
    }
  }

  // Validation de taille de fichier
  static bool isValidFileSize(int fileSizeBytes) {
    return fileSizeBytes <= maxFileSizeBytes;
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
