import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import '../models/models.dart';
import '../constants/constants.dart';
import 'api_service.dart';

class MediaService {
  // ========== Upload Management ==========

  /// Upload un fichier média avec optimisation
  static Future<MediaUploadResult> uploadMedia({
    required File file,
    required MediaType mediaType,
    Function(double)? onProgress,
    bool compressImage = true,
  }) async {
    try {
      // Validation initiale
      final validation = await _validateFile(file, mediaType);
      if (!validation.isValid) {
        return MediaUploadResult.error(validation.error!);
      }

      File fileToUpload = file;
      
      // Compression image si nécessaire
      if (mediaType == MediaType.image && compressImage) {
        final compressedFile = await _compressImage(file);
        if (compressedFile != null) {
          fileToUpload = compressedFile;
        }
      }

      // Déterminer MIME type
      final mimeType = _getMimeType(fileToUpload, mediaType);
      
      // Upload
      final response = await ApiService.uploadFile(
        '/upload/chat-media',
        file: fileToUpload,
        fieldName: 'media',
        mimeType: mimeType,
        onProgress: onProgress,
        requiresAuth: true,
      );

      final mediaUrl = response['media_url'] as String?;
      final thumbnailUrl = response['thumbnail_url'] as String?;
      
      if (mediaUrl != null) {
        return MediaUploadResult.success(
          mediaUrl: mediaUrl,
          thumbnailUrl: thumbnailUrl,
          mimeType: mimeType,
          fileSize: await fileToUpload.length(),
        );
      }
      
      return MediaUploadResult.error('Échec de l\'upload');
    } catch (e) {
      print('Error uploading media: $e');
      if (e is ApiException) {
        return MediaUploadResult.error(e.message);
      }
      return MediaUploadResult.error('Erreur d\'upload: $e');
    }
  }

  /// Supprime un fichier média
  static Future<bool> deleteMedia(String mediaUrl) async {
    try {
      await ApiService.delete(
        '/media',
        body: {'media_url': mediaUrl},
        requiresAuth: true,
      );
      return true;
    } catch (e) {
      print('Error deleting media: $e');
      return false;
    }
  }

  // ========== Image Processing ==========

  /// Compresse une image (version simplifiée sans package externe)
  static Future<File?> _compressImage(File imageFile) async {
    try {
      // Pour l'instant, retourner le fichier original
      // TODO: Implémenter compression réelle avec package image
      final fileSize = await imageFile.length();
      const maxSizeBytes = 2 * 1024 * 1024; // 2MB
      
      if (fileSize <= maxSizeBytes) {
        return imageFile; // Pas besoin de compression
      }
      
      // TODO: Implémenter compression avec package image
      return imageFile;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  /// Génère une miniature pour vidéo
  static Future<String?> generateVideoThumbnail(String videoPath) async {
    try {
      // TODO: Implémenter génération thumbnail vidéo
      // Peut utiliser video_thumbnail package
      return null;
    } catch (e) {
      print('Error generating video thumbnail: $e');
      return null;
    }
  }

  // ========== Validation ==========

  static Future<MediaValidationResult> _validateFile(File file, MediaType mediaType) async {
    // Existence
    if (!await file.exists()) {
      return MediaValidationResult(false, 'Le fichier n\'existe pas');
    }

    // Taille
    final fileSize = await file.length();
    final maxSize = MessageConstants.maxMediaFileSizeMB * 1024 * 1024;
    if (fileSize > maxSize) {
      return MediaValidationResult(
        false, 
        'Fichier trop volumineux (max ${MessageConstants.maxMediaFileSizeMB}MB)'
      );
    }

    // Type MIME
    final mimeType = _getMimeType(file, mediaType);
    if (!MessageConstants.isAllowedMimeType(mimeType)) {
      return MediaValidationResult(false, 'Type de fichier non supporté');
    }

    return MediaValidationResult(true, null);
  }

  static String _getMimeType(File file, MediaType mediaType) {
    final extension = path.extension(file.path).toLowerCase();
    
    switch (mediaType) {
      case MediaType.image:
        switch (extension) {
          case '.jpg':
          case '.jpeg':
            return 'image/jpeg';
          case '.png':
            return 'image/png';
          case '.webp':
            return 'image/webp';
          case '.gif':
            return 'image/gif';
          default:
            return 'image/jpeg';
        }
      
      case MediaType.video:
        switch (extension) {
          case '.mp4':
            return 'video/mp4';
          case '.webm':
            return 'video/webm';
          case '.mov':
            return 'video/quicktime';
          default:
            return 'video/mp4';
        }
      
      case MediaType.audio:
        switch (extension) {
          case '.mp3':
            return 'audio/mpeg';
          case '.wav':
            return 'audio/wav';
          case '.ogg':
            return 'audio/ogg';
          default:
            return 'audio/mpeg';
        }
    }
  }

  // ========== Utility Methods ==========

  /// Obtient les informations d'un fichier média
  static Future<MediaInfo> getMediaInfo(File file) async {
    final fileSize = await file.length();
    final extension = path.extension(file.path);
    final name = path.basenameWithoutExtension(file.path);
    
    return MediaInfo(
      name: name,
      extension: extension,
      sizeBytes: fileSize,
      sizeMB: fileSize / (1024 * 1024),
      path: file.path,
    );
  }

  /// Vérifie si un fichier peut être uploadé
  static Future<bool> canUploadFile(File file, MediaType mediaType) async {
    final validation = await _validateFile(file, mediaType);
    return validation.isValid;
  }
}

// ========== Result Classes ==========

enum MediaType { image, video, audio }

class MediaUploadResult {
  final bool success;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? mimeType;
  final int? fileSize;
  final String? error;

  MediaUploadResult._({
    required this.success,
    this.mediaUrl,
    this.thumbnailUrl,
    this.mimeType,
    this.fileSize,
    this.error,
  });

  factory MediaUploadResult.success({
    required String mediaUrl,
    String? thumbnailUrl,
    String? mimeType,
    int? fileSize,
  }) {
    return MediaUploadResult._(
      success: true,
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      mimeType: mimeType,
      fileSize: fileSize,
    );
  }

  factory MediaUploadResult.error(String error) {
    return MediaUploadResult._(
      success: false,
      error: error,
    );
  }
}

class MediaValidationResult {
  final bool isValid;
  final String? error;

  MediaValidationResult(this.isValid, this.error);
}

class MediaInfo {
  final String name;
  final String extension;
  final int sizeBytes;
  final double sizeMB;
  final String path;

  MediaInfo({
    required this.name,
    required this.extension,
    required this.sizeBytes,
    required this.sizeMB,
    required this.path,
  });

  String get formattedSize {
    if (sizeMB >= 1) {
      return '${sizeMB.toStringAsFixed(1)} MB';
    } else {
      return '${(sizeBytes / 1024).toStringAsFixed(0)} KB';
    }
  }
}
