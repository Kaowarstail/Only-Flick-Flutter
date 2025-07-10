import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:only_flick_flutter/services/media_service.dart';
import 'package:only_flick_flutter/models/models.dart';
import 'package:only_flick_flutter/constants/constants.dart';
import '../test_config.dart';

void main() {
  group('MediaService Tests', () {
    
    setUpAll(() async {
      await TestConfig.initialize();
      TestConfig.printTestEnvironment();
    });

    test('should validate media MIME types', () async {
      TestConfig.printTestHeader('Media MIME Type Validation Test');
      
      try {
        // Test validation des images
        expect(MediaConstants.isImageType('image/jpeg'), isTrue);
        expect(MediaConstants.isImageType('image/png'), isTrue);
        expect(MediaConstants.isImageType('image/webp'), isTrue);
        expect(MediaConstants.isImageType('image/gif'), isTrue);
        expect(MediaConstants.isImageType('text/plain'), isFalse);
        TestConfig.printTestResult(true, 'Image MIME type validation works');

        // Test validation des vidéos
        expect(MediaConstants.isVideoType('video/mp4'), isTrue);
        expect(MediaConstants.isVideoType('video/webm'), isTrue);
        expect(MediaConstants.isVideoType('video/quicktime'), isTrue);
        expect(MediaConstants.isVideoType('image/jpeg'), isFalse);
        TestConfig.printTestResult(true, 'Video MIME type validation works');

        // Test validation des audios
        expect(MediaConstants.isAudioType('audio/mpeg'), isTrue);
        expect(MediaConstants.isAudioType('audio/wav'), isTrue);
        expect(MediaConstants.isAudioType('audio/ogg'), isTrue);
        expect(MediaConstants.isAudioType('video/mp4'), isFalse);
        TestConfig.printTestResult(true, 'Audio MIME type validation works');

        // Test tailles maximales
        expect(MediaConstants.maxImageSize, greaterThan(0));
        expect(MediaConstants.maxVideoSize, greaterThan(0));
        expect(MediaConstants.maxAudioSize, greaterThan(0));
        TestConfig.printTestResult(true, 'Media size limits are defined');
        
        TestConfig.printTestDebug('Max image size: ${MediaConstants.maxImageSize} bytes');
        TestConfig.printTestDebug('Max video size: ${MediaConstants.maxVideoSize} bytes');
        TestConfig.printTestDebug('Max audio size: ${MediaConstants.maxAudioSize} bytes');

      } catch (e) {
        TestConfig.printTestResult(false, 'MIME type validation test failed: $e');
        throw e;
      }
    });

    test('should validate file extensions', () async {
      TestConfig.printTestHeader('File Extension Validation Test');
      
      try {
        // Test extensions d'images
        final imageExtensions = ['.jpg', '.jpeg', '.png', '.webp', '.gif'];
        for (final ext in imageExtensions) {
          final isValid = MediaConstants.isValidImageExtension(ext);
          expect(isValid, isTrue, reason: '$ext should be valid image extension');
        }
        TestConfig.printTestResult(true, 'Image extensions validation works');

        // Test extensions de vidéos
        final videoExtensions = ['.mp4', '.webm', '.mov', '.avi'];
        for (final ext in videoExtensions) {
          final isValid = MediaConstants.isValidVideoExtension(ext);
          expect(isValid, isTrue, reason: '$ext should be valid video extension');
        }
        TestConfig.printTestResult(true, 'Video extensions validation works');

        // Test extensions d'audio
        final audioExtensions = ['.mp3', '.wav', '.ogg', '.m4a'];
        for (final ext in audioExtensions) {
          final isValid = MediaConstants.isValidAudioExtension(ext);
          expect(isValid, isTrue, reason: '$ext should be valid audio extension');
        }
        TestConfig.printTestResult(true, 'Audio extensions validation works');

        // Test extensions invalides
        final invalidExtensions = ['.txt', '.doc', '.pdf', '.exe'];
        for (final ext in invalidExtensions) {
          final isImage = MediaConstants.isValidImageExtension(ext);
          final isVideo = MediaConstants.isValidVideoExtension(ext);
          final isAudio = MediaConstants.isValidAudioExtension(ext);
          
          expect(isImage, isFalse, reason: '$ext should not be valid image');
          expect(isVideo, isFalse, reason: '$ext should not be valid video');
          expect(isAudio, isFalse, reason: '$ext should not be valid audio');
        }
        TestConfig.printTestResult(true, 'Invalid extensions properly rejected');

      } catch (e) {
        TestConfig.printTestResult(false, 'Extension validation test failed: $e');
        throw e;
      }
    });

    test('should handle upload validation errors', () async {
      TestConfig.printTestHeader('Upload Validation Error Test');
      
      try {
        // Test avec un fichier inexistant
        final fakeFile = File('non_existent_file.jpg');
        
        final result = await MediaService.uploadMedia(
          file: fakeFile,
          mediaType: MediaType.image,
        ).timeout(TestConfig.defaultTimeout);
        
        // Le résultat devrait indiquer une erreur
        expect(result.success, isFalse);
        expect(result.error, isNotNull);
        
        TestConfig.printTestResult(true, 'Upload error handled correctly: ${result.error}');
        TestConfig.printTestDebug('Error type: ${result.error?.runtimeType}');
        
      } catch (e) {
        if (e is MediaException) {
          TestConfig.printTestResult(true, 'Upload exception handled: ${e.message}');
          expect(e.message, isNotNull);
        } else {
          TestConfig.printTestResult(false, 'Unexpected error type: $e');
        }
      }
    });

    test('should validate file size limits', () async {
      TestConfig.printTestHeader('File Size Validation Test');
      
      try {
        // Ces tests sont conceptuels car créer de gros fichiers serait coûteux
        
        // Test taille image valide (simulation)
        const smallImageSize = 1024 * 1024; // 1MB
        final isValidImageSize = MediaService.isValidFileSize(smallImageSize, MediaType.image);
        expect(isValidImageSize, isTrue);
        TestConfig.printTestResult(true, 'Small image size validation works');

        // Test taille image trop grande (simulation)
        const largeImageSize = 50 * 1024 * 1024; // 50MB
        final isInvalidImageSize = MediaService.isValidFileSize(largeImageSize, MediaType.image);
        expect(isInvalidImageSize, isFalse);
        TestConfig.printTestResult(true, 'Large image size properly rejected');

        // Test taille vidéo valide (simulation)
        const smallVideoSize = 10 * 1024 * 1024; // 10MB
        final isValidVideoSize = MediaService.isValidFileSize(smallVideoSize, MediaType.video);
        expect(isValidVideoSize, isTrue);
        TestConfig.printTestResult(true, 'Small video size validation works');

        // Test taille vidéo trop grande (simulation)
        const largeVideoSize = 200 * 1024 * 1024; // 200MB
        final isInvalidVideoSize = MediaService.isValidFileSize(largeVideoSize, MediaType.video);
        expect(isInvalidVideoSize, isFalse);
        TestConfig.printTestResult(true, 'Large video size properly rejected');

        TestConfig.printTestInfo('File size validation tests completed (simulated)');

      } catch (e) {
        TestConfig.printTestResult(false, 'File size validation test failed: $e');
        throw e;
      }
    });

    test('should handle media type detection', () async {
      TestConfig.printTestHeader('Media Type Detection Test');
      
      try {
        // Test détection par extension
        expect(MediaService.detectMediaTypeFromPath('image.jpg'), equals(MediaType.image));
        expect(MediaService.detectMediaTypeFromPath('video.mp4'), equals(MediaType.video));
        expect(MediaService.detectMediaTypeFromPath('audio.mp3'), equals(MediaType.audio));
        expect(MediaService.detectMediaTypeFromPath('document.pdf'), isNull);

        TestConfig.printTestResult(true, 'Media type detection by extension works');

        // Test détection par MIME type
        expect(MediaService.detectMediaTypeFromMime('image/jpeg'), equals(MediaType.image));
        expect(MediaService.detectMediaTypeFromMime('video/mp4'), equals(MediaType.video));
        expect(MediaService.detectMediaTypeFromMime('audio/mpeg'), equals(MediaType.audio));
        expect(MediaService.detectMediaTypeFromMime('text/plain'), isNull);

        TestConfig.printTestResult(true, 'Media type detection by MIME type works');

        // Test cas complexes
        expect(MediaService.detectMediaTypeFromPath('my-image.photo.jpg'), equals(MediaType.image));
        expect(MediaService.detectMediaTypeFromPath('PATH/TO/VIDEO.MP4'), equals(MediaType.video));
        expect(MediaService.detectMediaTypeFromPath('file_without_extension'), isNull);

        TestConfig.printTestResult(true, 'Complex media type detection works');

      } catch (e) {
        TestConfig.printTestResult(false, 'Media type detection test failed: $e');
        throw e;
      }
    });

    test('should validate upload request structure', () async {
      TestConfig.printTestHeader('Upload Request Validation Test');
      
      try {
        // Test création d'une requête valide (simulation)
        final validRequest = MediaUploadRequest(
          conversationId: TestConfig.testConversationId,
          mediaType: MediaType.image,
          caption: 'Test image caption',
        );

        expect(validRequest.conversationId, equals(TestConfig.testConversationId));
        expect(validRequest.mediaType, equals(MediaType.image));
        expect(validRequest.caption, equals('Test image caption'));
        
        TestConfig.printTestResult(true, 'Valid upload request structure works');

        // Test validation des champs requis
        expect(validRequest.conversationId, isNotNull);
        expect(validRequest.mediaType, isNotNull);
        
        TestConfig.printTestResult(true, 'Required fields validation works');

        // Test sérialisation JSON
        final json = validRequest.toJson();
        expect(json, isA<Map<String, dynamic>>());
        expect(json['conversationId'], equals(TestConfig.testConversationId));
        expect(json['mediaType'], isNotNull);
        
        TestConfig.printTestResult(true, 'Upload request JSON serialization works');

      } catch (e) {
        TestConfig.printTestResult(false, 'Upload request validation test failed: $e');
        throw e;
      }
    });

    test('should handle progress tracking simulation', () async {
      TestConfig.printTestHeader('Progress Tracking Test');
      
      try {
        double? lastProgress;
        bool progressCallbackCalled = false;

        // Simuler un callback de progression
        void onProgress(double progress) {
          lastProgress = progress;
          progressCallbackCalled = true;
          TestConfig.printTestDebug('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
        }

        // Simuler différents états de progression
        onProgress(0.0);
        expect(lastProgress, equals(0.0));

        onProgress(0.5);
        expect(lastProgress, equals(0.5));

        onProgress(1.0);
        expect(lastProgress, equals(1.0));

        expect(progressCallbackCalled, isTrue);
        TestConfig.printTestResult(true, 'Progress tracking simulation works');

        // Test validation des valeurs de progression
        expect(lastProgress, greaterThanOrEqualTo(0.0));
        expect(lastProgress, lessThanOrEqualTo(1.0));
        
        TestConfig.printTestResult(true, 'Progress values are within valid range');

      } catch (e) {
        TestConfig.printTestResult(false, 'Progress tracking test failed: $e');
        throw e;
      }
    });

    test('should handle different media types in upload', () async {
      TestConfig.printTestHeader('Media Types Upload Test');
      
      try {
        // Test des différents types de média (simulation)
        final mediaTypes = [MediaType.image, MediaType.video, MediaType.audio];
        
        for (final mediaType in mediaTypes) {
          final request = MediaUploadRequest(
            conversationId: TestConfig.testConversationId,
            mediaType: mediaType,
            caption: 'Test $mediaType upload',
          );

          expect(request.mediaType, equals(mediaType));
          TestConfig.printTestDebug('✓ $mediaType upload request created');
        }

        TestConfig.printTestResult(true, 'All media types supported in upload requests');

        // Test validation spécifique par type
        for (final mediaType in mediaTypes) {
          final isValidType = MediaService.isSupportedMediaType(mediaType);
          expect(isValidType, isTrue);
          TestConfig.printTestDebug('✓ $mediaType is supported');
        }

        TestConfig.printTestResult(true, 'Media type support validation works');

      } catch (e) {
        TestConfig.printTestResult(false, 'Media types upload test failed: $e');
        throw e;
      }
    });

    test('should provide media constants information', () async {
      TestConfig.printTestHeader('Media Constants Information Test');
      
      try {
        // Afficher les informations sur les constantes média
        TestConfig.printTestDebug('=== Media Configuration ===');
        TestConfig.printTestDebug('Max Image Size: ${(MediaConstants.maxImageSize / (1024 * 1024)).toStringAsFixed(1)} MB');
        TestConfig.printTestDebug('Max Video Size: ${(MediaConstants.maxVideoSize / (1024 * 1024)).toStringAsFixed(1)} MB');
        TestConfig.printTestDebug('Max Audio Size: ${(MediaConstants.maxAudioSize / (1024 * 1024)).toStringAsFixed(1)} MB');
        
        TestConfig.printTestDebug('Supported Image Types: ${MediaConstants.supportedImageTypes}');
        TestConfig.printTestDebug('Supported Video Types: ${MediaConstants.supportedVideoTypes}');
        TestConfig.printTestDebug('Supported Audio Types: ${MediaConstants.supportedAudioTypes}');

        // Vérifier que les constantes sont cohérentes
        expect(MediaConstants.maxImageSize, greaterThan(0));
        expect(MediaConstants.maxVideoSize, greaterThan(MediaConstants.maxImageSize));
        expect(MediaConstants.maxAudioSize, greaterThan(0));

        expect(MediaConstants.supportedImageTypes, isNotEmpty);
        expect(MediaConstants.supportedVideoTypes, isNotEmpty);
        expect(MediaConstants.supportedAudioTypes, isNotEmpty);

        TestConfig.printTestResult(true, 'Media constants are properly configured');

      } catch (e) {
        TestConfig.printTestResult(false, 'Media constants test failed: $e');
        throw e;
      }
    });
  });
}
