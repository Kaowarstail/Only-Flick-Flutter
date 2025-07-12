import 'dart:io';
import 'package:dio/dio.dart';
import '../models/models.dart';
import 'cloudinary_service.dart';

class MediaService {
  static final Dio _dio = Dio();

  // ========== Media Upload ==========

  /// Upload un fichier média avec suivi de progression
  static Future<MediaUploadResult> uploadMedia({
    required File file,
    required MediaType mediaType,
    bool compressImage = true,
    Function(double)? onProgress,
  }) async {
    try {
      // Valider le fichier
      final validation = validateMediaFile(file, mediaType);
      if (!validation.isValid) {
        return MediaUploadResult(
          success: false,
          error: validation.error,
        );
      }

      // Utiliser Cloudinary pour l'upload
      final result = await CloudinaryService.uploadFile(
        file: file,
        resourceType: _getCloudinaryResourceType(mediaType),
        folder: 'messages',
        onProgress: onProgress,
      );

      if (result['success'] == true) {
        return MediaUploadResult(
          success: true,
          mediaUrl: result['secure_url'],
          thumbnailUrl: result['thumbnail_url'],
          publicId: result['public_id'],
        );
      } else {
        return MediaUploadResult(
          success: false,
          error: result['error'] ?? 'Erreur d\'upload',
        );
      }
    } catch (e) {
      print('Error uploading media: $e');
      return MediaUploadResult(
        success: false,
        error: 'Erreur technique: $e',
      );
    }
  }

  /// Supprime un fichier média
  static Future<bool> deleteMedia(String publicId, MediaType mediaType) async {
    try {
      final result = await CloudinaryService.deleteFile(
        publicId: publicId,
        resourceType: _getCloudinaryResourceType(mediaType),
      );
      return result['success'] == true;
    } catch (e) {
      print('Error deleting media: $e');
      return false;
    }
  }

  // ========== Validation ==========

  /// Valide un fichier média
  static MediaValidationResult validateMediaFile(File file, MediaType mediaType) {
    try {
      // Vérifier existence
      if (!file.existsSync()) {
        return MediaValidationResult(false, 'Le fichier n\'existe pas');
      }

      // Vérifier taille
      final fileSize = file.lengthSync();
      final maxSize = _getMaxFileSize(mediaType);
      
      if (fileSize > maxSize) {
        final maxSizeMB = (maxSize / (1024 * 1024)).toStringAsFixed(1);
        return MediaValidationResult(false, 'Fichier trop volumineux (max ${maxSizeMB}MB)');
      }

      if (fileSize == 0) {
        return MediaValidationResult(false, 'Le fichier est vide');
      }

      // Vérifier extension
      final extension = file.path.toLowerCase().split('.').last;
      if (!_isValidExtension(extension, mediaType)) {
        return MediaValidationResult(false, 'Format de fichier non supporté');
      }

      return MediaValidationResult(true, null);
    } catch (e) {
      return MediaValidationResult(false, 'Erreur de validation: $e');
    }
  }

  /// Détecte le type de média depuis le chemin du fichier
  static MediaType? detectMediaTypeFromPath(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    
    if (MediaConstants.imageExtensions.contains(extension)) {
      return MediaType.image;
    } else if (MediaConstants.videoExtensions.contains(extension)) {
      return MediaType.video;
    } else if (MediaConstants.audioExtensions.contains(extension)) {
      return MediaType.audio;
    }
    
    return null;
  }

  /// Détecte le type de média depuis le MIME type
  static MediaType? detectMediaTypeFromMime(String mimeType) {
    if (mimeType.startsWith('image/')) {
      return MediaType.image;
    } else if (mimeType.startsWith('video/')) {
      return MediaType.video;
    } else if (mimeType.startsWith('audio/')) {
      return MediaType.audio;
    }
    
    return null;
  }

  /// Vérifie si un type de média est supporté
  static bool isSupportedMediaType(MediaType mediaType) {
    switch (mediaType) {
      case MediaType.image:
      case MediaType.video:
      case MediaType.audio:
        return true;
    }
  }

  // ========== Helper Methods ==========

  static String _getCloudinaryResourceType(MediaType mediaType) {
    switch (mediaType) {
      case MediaType.image:
        return 'image';
      case MediaType.video:
        return 'video';
      case MediaType.audio:
        return 'video'; // Cloudinary traite l'audio comme video
    }
  }

  static int _getMaxFileSize(MediaType mediaType) {
    switch (mediaType) {
      case MediaType.image:
        return MediaConstants.maxImageSize;
      case MediaType.video:
        return MediaConstants.maxVideoSize;
      case MediaType.audio:
        return MediaConstants.maxAudioSize;
    }
  }

  static bool _isValidExtension(String extension, MediaType mediaType) {
    switch (mediaType) {
      case MediaType.image:
        return MediaConstants.imageExtensions.contains(extension);
      case MediaType.video:
        return MediaConstants.videoExtensions.contains(extension);
      case MediaType.audio:
        return MediaConstants.audioExtensions.contains(extension);
    }
  }
}

/// Constantes pour les médias
class MediaConstants {
  // Tailles maximales (en bytes)
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int maxVideoSize = 100 * 1024 * 1024; // 100MB
  static const int maxAudioSize = 50 * 1024 * 1024; // 50MB

  // Extensions supportées
  static const List<String> imageExtensions = [
    'jpg', 'jpeg', 'png', 'webp', 'gif'
  ];
  
  static const List<String> videoExtensions = [
    'mp4', 'webm', 'mov'
  ];
  
  static const List<String> audioExtensions = [
    'mp3', 'wav', 'ogg'
  ];

  // Types MIME supportés
  static const List<String> supportedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/gif',
  ];
  
  static const List<String> supportedVideoTypes = [
    'video/mp4',
    'video/webm',
    'video/quicktime',
  ];
  
  static const List<String> supportedAudioTypes = [
    'audio/mpeg',
    'audio/wav',
    'audio/ogg',
  ];

  /// Vérifie si le type MIME est une image
  static bool isImageType(String mimeType) {
    return supportedImageTypes.contains(mimeType);
  }

  /// Vérifie si le type MIME est une vidéo
  static bool isVideoType(String mimeType) {
    return supportedVideoTypes.contains(mimeType);
  }

  /// Vérifie si le type MIME est un audio
  static bool isAudioType(String mimeType) {
    return supportedAudioTypes.contains(mimeType);
  }
}

/// Résultat d'upload de média
class MediaUploadResult {
  final bool success;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? publicId;
  final String? error;

  MediaUploadResult({
    required this.success,
    this.mediaUrl,
    this.thumbnailUrl,
    this.publicId,
    this.error,
  });
}

/// Résultat de validation de média
class MediaValidationResult {
  final bool isValid;
  final String? error;

  MediaValidationResult(this.isValid, this.error);
}
