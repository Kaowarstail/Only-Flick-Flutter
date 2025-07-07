/// Image upload service for OnlyFlick profile editing
/// Handles image picking, processing, and upload for profile pictures

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class ImageUploadService {
  static final ImagePicker _picker = ImagePicker();
  static final ApiService _apiService = ApiService();
  
  // Image size constants (selon les specs OnlyFlick)
  static const int minProfileSize = 150;
  static const int recommendedProfileSize = 320;
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const double aspectRatio = 1.0; // Carré obligatoire
  
  // Formats supportés
  static const List<String> supportedFormats = ['jpg', 'jpeg', 'png', 'webp'];
  
  /// Pick image from gallery
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1080,
        maxHeight: 1080,
      );
      
      if (image != null) {
        File imageFile = File(image.path);
        
        // Validate file
        if (await validateImageFile(imageFile)) {
          return imageFile;
        } else {
          throw Exception('Image non valide');
        }
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la sélection: ${e.toString()}');
    }
  }
  
  /// Take photo with camera
  static Future<File?> takePhotoWithCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 1080,
        maxHeight: 1080,
      );
      
      if (image != null) {
        File imageFile = File(image.path);
        
        // Validate file
        if (await validateImageFile(imageFile)) {
          return imageFile;
        } else {
          throw Exception('Image non valide');
        }
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la prise de photo: ${e.toString()}');
    }
  }
  
  /// Validate image file
  static Future<bool> validateImageFile(File imageFile) async {
    try {
      // Check file existence
      if (!await imageFile.exists()) {
        throw Exception('Fichier inexistant');
      }
      
      // Check file size
      int fileSize = await imageFile.length();
      if (fileSize > maxFileSize) {
        throw Exception('Fichier trop volumineux (max 5MB)');
      }
      
      if (fileSize == 0) {
        throw Exception('Fichier vide');
      }
      
      // Check file extension
      String extension = imageFile.path.split('.').last.toLowerCase();
      if (!supportedFormats.contains(extension)) {
        throw Exception('Format non supporté. Utilisez: ${supportedFormats.join(', ')}');
      }
      
      return true;
    } catch (e) {
      debugPrint('Image validation error: ${e.toString()}');
      return false;
    }
  }
  
  /// Get image dimensions
  static Future<Size?> getImageDimensions(File imageFile) async {
    try {
      // For now, return a placeholder. In a real app, you'd use image package
      // to get actual dimensions
      return const Size(320, 320);
    } catch (e) {
      debugPrint('Error getting image dimensions: ${e.toString()}');
      return null;
    }
  }
  
  /// Compress image to target size
  static Future<File> compressImage(File imageFile, int targetSizeKB) async {
    try {
      // In a real implementation, you'd use image compression library
      // For now, return the original file
      return imageFile;
    } catch (e) {
      throw Exception('Erreur lors de la compression: ${e.toString()}');
    }
  }
  
  /// Upload profile picture to server
  static Future<ApiResponse<String>> uploadProfilePicture(File imageFile) async {
    try {
      // Validate before upload
      if (!await validateImageFile(imageFile)) {
        return ApiResponse<String>(
          success: false,
          message: 'Image non valide',
        );
      }
      
      // Upload using multipart request
      final response = await _apiService.uploadFile(
        '/api/v1/upload/avatar',
        imageFile,
        fieldName: 'avatar',
      );
      
      if (response.success && response.data != null) {
        // Extract URL from response
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        String imageUrl = data['url'] ?? data['avatar_url'] ?? '';
        
        return ApiResponse<String>(
          success: true,
          data: imageUrl,
          message: 'Image uploadée avec succès',
        );
      } else {
        return ApiResponse<String>(
          success: false,
          message: response.message ?? 'Erreur lors de l\'upload',
        );
      }
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        message: 'Erreur lors de l\'upload: ${e.toString()}',
      );
    }
  }
  
  /// Upload banner image
  static Future<ApiResponse<String>> uploadBannerImage(File imageFile) async {
    try {
      if (!await validateImageFile(imageFile)) {
        return ApiResponse<String>(
          success: false,
          message: 'Image non valide',
        );
      }
      
      final response = await _apiService.uploadFile(
        '/api/v1/upload/banner',
        imageFile,
        fieldName: 'banner',
      );
      
      if (response.success && response.data != null) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        String imageUrl = data['url'] ?? data['banner_url'] ?? '';
        
        return ApiResponse<String>(
          success: true,
          data: imageUrl,
          message: 'Bannière uploadée avec succès',
        );
      } else {
        return ApiResponse<String>(
          success: false,
          message: response.message ?? 'Erreur lors de l\'upload',
        );
      }
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        message: 'Erreur lors de l\'upload: ${e.toString()}',
      );
    }
  }
  
  /// Delete old image from server
  static Future<ApiResponse<void>> deleteImage(String imageUrl) async {
    try {
      // Extract media ID from URL if needed
      String mediaId = _extractMediaIdFromUrl(imageUrl);
      
      final response = await _apiService.delete('/api/v1/media/$mediaId');
      
      return ApiResponse<void>(
        success: response.success,
        message: response.message ?? 'Image supprimée',
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Erreur lors de la suppression: ${e.toString()}',
      );
    }
  }
  
  /// Extract media ID from URL
  static String _extractMediaIdFromUrl(String url) {
    // Extract ID from URL pattern like: /media/12345.jpg
    try {
      Uri uri = Uri.parse(url);
      String path = uri.path;
      String fileName = path.split('/').last;
      String id = fileName.split('.').first;
      return id;
    } catch (e) {
      return url; // Fallback to full URL
    }
  }
  
  /// Get image file size in MB
  static Future<double> getFileSizeMB(File file) async {
    try {
      int bytes = await file.length();
      return bytes / (1024 * 1024);
    } catch (e) {
      return 0.0;
    }
  }
  
  /// Generate thumbnail for image
  static Future<File?> generateThumbnail(File imageFile, int size) async {
    try {
      // In a real implementation, you'd resize the image
      // For now, return the original
      return imageFile;
    } catch (e) {
      debugPrint('Error generating thumbnail: ${e.toString()}');
      return null;
    }
  }
  
  /// Check if image needs compression
  static Future<bool> needsCompression(File imageFile) async {
    try {
      double sizeMB = await getFileSizeMB(imageFile);
      return sizeMB > 2.0; // Compress if larger than 2MB
    } catch (e) {
      return false;
    }
  }
  
  /// Get optimized image for upload
  static Future<File> getOptimizedImage(File originalFile) async {
    try {
      // Check if compression is needed
      if (await needsCompression(originalFile)) {
        return await compressImage(originalFile, 2048); // Target 2MB
      }
      return originalFile;
    } catch (e) {
      return originalFile;
    }
  }
  
  /// Show image picker dialog
  static Future<File?> showImagePicker(BuildContext context) async {
    return await showModalBottomSheet<File?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Choisir une photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  context,
                  icon: Icons.photo_library,
                  label: 'Galerie',
                  onTap: () async {
                    final file = await pickImageFromGallery();
                    if (context.mounted) Navigator.pop(context, file);
                  },
                ),
                _buildPickerOption(
                  context,
                  icon: Icons.camera_alt,
                  label: 'Appareil photo',
                  onTap: () async {
                    final file = await takePhotoWithCamera();
                    if (context.mounted) Navigator.pop(context, file);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  static Widget _buildPickerOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFCC0092).withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              size: 30,
              color: const Color(0xFFCC0092),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
