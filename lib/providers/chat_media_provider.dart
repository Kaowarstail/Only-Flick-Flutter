import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/media_service.dart';

/// Provider pour la gestion des médias de chat
class ChatMediaProvider extends ChangeNotifier {
  // État des uploads en cours
  final Map<String, MediaUploadProgress> _uploadProgress = {};
  
  // Historique des médias uploadés
  final List<UploadedMedia> _uploadedMedia = [];
  
  // Cache des validations
  final Map<String, MediaValidationResult> _validationCache = {};

  // ========== Getters ==========

  /// Uploads en cours
  Map<String, MediaUploadProgress> get uploadProgress => 
      Map.unmodifiable(_uploadProgress);

  /// Historique des médias uploadés
  List<UploadedMedia> get uploadedMedia => List.unmodifiable(_uploadedMedia);

  /// Indique s'il y a des uploads en cours
  bool get hasActiveUploads => _uploadProgress.isNotEmpty;

  /// Nombre total d'uploads en cours
  int get activeUploadsCount => _uploadProgress.length;

  /// Progression globale (moyenne des uploads en cours)
  double get overallProgress {
    if (_uploadProgress.isEmpty) return 0.0;
    
    final totalProgress = _uploadProgress.values
        .map((progress) => progress.progress)
        .reduce((a, b) => a + b);
    
    return totalProgress / _uploadProgress.length;
  }

  // ========== Méthodes publiques ==========

  /// Upload un fichier média
  Future<String?> uploadMedia({
    required File file,
    required MediaType mediaType,
    bool compressImage = true,
    String? uploadId,
  }) async {
    final id = uploadId ?? _generateUploadId();
    
    try {
      // Valider le fichier d'abord
      final validation = await validateMediaFile(file, mediaType);
      if (!validation.isValid) {
        _setUploadError(id, validation.error!);
        return null;
      }

      // Initialiser le suivi de progression
      _startUpload(id, file.path, mediaType);

      // Lancer l'upload avec suivi de progression
      final result = await MediaService.uploadMedia(
        file: file,
        mediaType: mediaType,
        compressImage: compressImage,
        onProgress: (progress) {
          _updateUploadProgress(id, progress);
        },
      );

      if (result.success && result.mediaUrl != null) {
        // Upload réussi
        _completeUpload(id, result);
        
        // Ajouter à l'historique
        _addToHistory(UploadedMedia(
          id: id,
          originalPath: file.path,
          mediaUrl: result.mediaUrl!,
          thumbnailUrl: result.thumbnailUrl,
          publicId: result.publicId,
          mediaType: mediaType,
          uploadedAt: DateTime.now(),
        ));
        
        return result.mediaUrl;
      } else {
        // Upload échoué
        _setUploadError(id, result.error ?? 'Erreur d\'upload inconnue');
        return null;
      }
    } catch (e) {
      _setUploadError(id, 'Erreur technique: $e');
      return null;
    }
  }

  /// Upload multiple files
  Future<List<String>> uploadMultipleMedia(List<File> files) async {
    final List<String> uploadedUrls = [];
    
    for (final file in files) {
      final mediaType = MediaService.detectMediaTypeFromPath(file.path);
      if (mediaType != null) {
        final url = await uploadMedia(
          file: file,
          mediaType: mediaType,
        );
        if (url != null) {
          uploadedUrls.add(url);
        }
      }
    }
    
    return uploadedUrls;
  }

  /// Annule un upload
  void cancelUpload(String uploadId) {
    if (_uploadProgress.containsKey(uploadId)) {
      _uploadProgress.remove(uploadId);
      notifyListeners();
    }
  }

  /// Valide un fichier média
  Future<MediaValidationResult> validateMediaFile(File file, MediaType mediaType) async {
    final cacheKey = '${file.path}_$mediaType';
    
    // Vérifier le cache
    if (_validationCache.containsKey(cacheKey)) {
      return _validationCache[cacheKey]!;
    }
    
    // Valider
    final result = MediaService.validateMediaFile(file, mediaType);
    
    // Mettre en cache
    _validationCache[cacheKey] = result;
    
    return result;
  }

  /// Supprime un média uploadé
  Future<bool> deleteUploadedMedia(String uploadId) async {
    try {
      final media = _uploadedMedia.firstWhere((m) => m.id == uploadId);
      
      if (media.publicId != null) {
        final success = await MediaService.deleteMedia(media.publicId!, media.mediaType);
        
        if (success) {
          _uploadedMedia.removeWhere((m) => m.id == uploadId);
          notifyListeners();
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Error deleting media: $e');
      return false;
    }
  }

  /// Récupère un média uploadé par ID
  UploadedMedia? getUploadedMedia(String uploadId) {
    try {
      return _uploadedMedia.firstWhere((m) => m.id == uploadId);
    } catch (e) {
      return null;
    }
  }

  /// Récupère les médias par type
  List<UploadedMedia> getMediaByType(MediaType mediaType) {
    return _uploadedMedia.where((m) => m.mediaType == mediaType).toList();
  }

  /// Récupère les médias récents
  List<UploadedMedia> getRecentMedia({int limit = 20}) {
    final sortedMedia = [..._uploadedMedia];
    sortedMedia.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    return sortedMedia.take(limit).toList();
  }

  /// Efface l'historique des médias
  void clearMediaHistory() {
    _uploadedMedia.clear();
    notifyListeners();
  }

  /// Efface le cache de validation
  void clearValidationCache() {
    _validationCache.clear();
  }

  /// Réessaie un upload échoué
  Future<String?> retryUpload(String uploadId) async {
    final progress = _uploadProgress[uploadId];
    if (progress == null || progress.status != UploadStatus.error) {
      return null;
    }

    final file = File(progress.filePath);
    return uploadMedia(
      file: file,
      mediaType: progress.mediaType,
      uploadId: uploadId,
    );
  }

  // ========== Méthodes de validation utilitaires ==========

  /// Vérifie si un fichier est une image
  static bool isImageFile(String filePath) {
    return MediaService.detectMediaTypeFromPath(filePath) == MediaType.image;
  }

  /// Vérifie si un fichier est une vidéo
  static bool isVideoFile(String filePath) {
    return MediaService.detectMediaTypeFromPath(filePath) == MediaType.video;
  }

  /// Vérifie si un fichier est un audio
  static bool isAudioFile(String filePath) {
    return MediaService.detectMediaTypeFromPath(filePath) == MediaType.audio;
  }

  /// Obtient la taille maximale autorisée pour un type de média
  static int getMaxFileSizeForType(MediaType mediaType) {
    switch (mediaType) {
      case MediaType.image:
        return MediaConstants.maxImageSize;
      case MediaType.video:
        return MediaConstants.maxVideoSize;
      case MediaType.audio:
        return MediaConstants.maxAudioSize;
    }
  }

  /// Formate la taille d'un fichier pour l'affichage
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // ========== Méthodes privées ==========

  String _generateUploadId() {
    return 'upload_${DateTime.now().millisecondsSinceEpoch}_${_uploadProgress.length}';
  }

  void _startUpload(String uploadId, String filePath, MediaType mediaType) {
    _uploadProgress[uploadId] = MediaUploadProgress(
      id: uploadId,
      filePath: filePath,
      mediaType: mediaType,
      progress: 0.0,
      status: UploadStatus.uploading,
      startedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void _updateUploadProgress(String uploadId, double progress) {
    final currentProgress = _uploadProgress[uploadId];
    if (currentProgress != null) {
      _uploadProgress[uploadId] = currentProgress.copyWith(
        progress: progress,
        lastUpdated: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void _completeUpload(String uploadId, MediaUploadResult result) {
    final currentProgress = _uploadProgress[uploadId];
    if (currentProgress != null) {
      _uploadProgress[uploadId] = currentProgress.copyWith(
        progress: 1.0,
        status: UploadStatus.completed,
        resultUrl: result.mediaUrl,
        completedAt: DateTime.now(),
      );
      
      // Supprimer de la liste après un délai
      Future.delayed(const Duration(seconds: 2), () {
        _uploadProgress.remove(uploadId);
        notifyListeners();
      });
      
      notifyListeners();
    }
  }

  void _setUploadError(String uploadId, String error) {
    final currentProgress = _uploadProgress[uploadId];
    if (currentProgress != null) {
      _uploadProgress[uploadId] = currentProgress.copyWith(
        status: UploadStatus.error,
        error: error,
        completedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void _addToHistory(UploadedMedia media) {
    _uploadedMedia.insert(0, media); // Ajouter au début
    
    // Limiter l'historique à 100 éléments
    if (_uploadedMedia.length > 100) {
      _uploadedMedia.removeRange(100, _uploadedMedia.length);
    }
  }

  @override
  void dispose() {
    // Nettoyer les uploads en cours si nécessaire
    super.dispose();
  }
}

/// État d'un upload
enum UploadStatus {
  uploading,
  completed,
  error,
}

/// Progression d'un upload
class MediaUploadProgress {
  final String id;
  final String filePath;
  final MediaType mediaType;
  final double progress;
  final UploadStatus status;
  final DateTime startedAt;
  final DateTime? lastUpdated;
  final DateTime? completedAt;
  final String? resultUrl;
  final String? error;

  MediaUploadProgress({
    required this.id,
    required this.filePath,
    required this.mediaType,
    required this.progress,
    required this.status,
    required this.startedAt,
    this.lastUpdated,
    this.completedAt,
    this.resultUrl,
    this.error,
  });

  MediaUploadProgress copyWith({
    double? progress,
    UploadStatus? status,
    DateTime? lastUpdated,
    DateTime? completedAt,
    String? resultUrl,
    String? error,
  }) {
    return MediaUploadProgress(
      id: id,
      filePath: filePath,
      mediaType: mediaType,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      startedAt: startedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      completedAt: completedAt ?? this.completedAt,
      resultUrl: resultUrl ?? this.resultUrl,
      error: error ?? this.error,
    );
  }
}

/// Média uploadé
class UploadedMedia {
  final String id;
  final String originalPath;
  final String mediaUrl;
  final String? thumbnailUrl;
  final String? publicId;
  final MediaType mediaType;
  final DateTime uploadedAt;

  UploadedMedia({
    required this.id,
    required this.originalPath,
    required this.mediaUrl,
    this.thumbnailUrl,
    this.publicId,
    required this.mediaType,
    required this.uploadedAt,
  });
}
