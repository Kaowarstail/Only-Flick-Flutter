import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

import '../models/user.dart';
import '../models/profile_models.dart';
import '../services/user_service.dart';
import '../services/creator_service.dart';
import '../services/image_upload_service.dart';
import '../utils/profile_validation.dart';
import '../services/api_service.dart';

enum ProfileLoadingState {
  idle,
  loading,
  uploading,
  saving,
  success,
  error
}

class ProfileProvider extends ChangeNotifier {
  // État de chargement
  ProfileLoadingState _loadingState = ProfileLoadingState.idle;
  String? _errorMessage;
  
  // Données du profil
  UserProfile? _userProfile;
  CreatorProfile? _creatorProfile;
  UserStats? _userStats;
  CreatorEarnings? _creatorEarnings;
  
  // Données temporaires pour l'édition
  final Map<String, dynamic> _tempChanges = {};
  File? _tempAvatarFile;
  File? _tempBannerFile;
  
  // Contrôleurs de texte
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController subscriptionPriceController = TextEditingController();
  
  // Contrôleurs des liens sociaux
  final TextEditingController twitterController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController tiktokController = TextEditingController();
  final TextEditingController youtubeController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  
  // Validation
  final Map<String, String?> _validationErrors = {};
  bool _isFormValid = false;
  
  // Getters
  ProfileLoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  UserProfile? get userProfile => _userProfile;
  CreatorProfile? get creatorProfile => _creatorProfile;
  UserStats? get userStats => _userStats;
  CreatorEarnings? get creatorEarnings => _creatorEarnings;
  File? get tempAvatarFile => _tempAvatarFile;
  File? get tempBannerFile => _tempBannerFile;
  Map<String, String?> get validationErrors => _validationErrors;
  bool get isFormValid => _isFormValid;
  bool get hasUnsavedChanges => _tempChanges.isNotEmpty || _tempAvatarFile != null || _tempBannerFile != null;
  
  // Getters pour les états de chargement
  bool get isLoading => _loadingState == ProfileLoadingState.loading;
  bool get isUploading => _loadingState == ProfileLoadingState.uploading;
  bool get isSaving => _loadingState == ProfileLoadingState.saving;
  bool get isWorking => isLoading || isUploading || isSaving;
  
  @override
  void dispose() {
    usernameController.dispose();
    displayNameController.dispose();
    bioController.dispose();
    subscriptionPriceController.dispose();
    twitterController.dispose();
    instagramController.dispose();
    tiktokController.dispose();
    youtubeController.dispose();
    websiteController.dispose();
    super.dispose();
  }
  
  // Méthodes de chargement des données
  Future<void> loadUserProfile(String userId) async {
    try {
      _setLoadingState(ProfileLoadingState.loading);
      _clearError();
      
      // Charger le profil utilisateur
      _userProfile = await UserService.getUserProfile(userId);
      
      // Charger les statistiques
      final statsResponse = await UserService.getUserStats(userId);
      _userStats = statsResponse.data;
      
      // Initialiser les contrôleurs
      _initializeControllers();
      
      _setLoadingState(ProfileLoadingState.success);
    } catch (e) {
      _setError('Erreur lors du chargement du profil: ${e.toString()}');
      _setLoadingState(ProfileLoadingState.error);
    }
  }
  
  Future<void> loadCreatorProfile(String creatorId) async {
    try {
      _setLoadingState(ProfileLoadingState.loading);
      _clearError();
      
      // Charger le profil créateur
      _creatorProfile = await CreatorService.getCreatorProfile(creatorId);
      
      // Charger les gains
      final earningsResponse = await CreatorService.getCreatorEarnings(creatorId);
      _creatorEarnings = earningsResponse.data;
      
      // Initialiser les contrôleurs
      _initializeControllers();
      
      _setLoadingState(ProfileLoadingState.success);
    } catch (e) {
      _setError('Erreur lors du chargement du profil créateur: ${e.toString()}');
      _setLoadingState(ProfileLoadingState.error);
    }
  }
  
  void _initializeControllers() {
    if (_userProfile != null) {
      usernameController.text = _userProfile!.username;
      displayNameController.text = _userProfile!.displayName ?? '';
      bioController.text = _userProfile!.bio ?? '';
      
      // Liens sociaux
      if (_userProfile!.socialLinks != null) {
        twitterController.text = _userProfile!.socialLinks!.twitter ?? '';
        instagramController.text = _userProfile!.socialLinks!.instagram ?? '';
        tiktokController.text = _userProfile!.socialLinks!.tiktok ?? '';
        youtubeController.text = _userProfile!.socialLinks!.youtube ?? '';
        websiteController.text = _userProfile!.socialLinks!.website ?? '';
      }
    }
    
    if (_creatorProfile != null) {
      subscriptionPriceController.text = _creatorProfile!.subscriptionPrice.toString();
    }
  }
  
  // Méthodes de validation
  void validateField(String fieldName, String value) {
    String? error;
    
    switch (fieldName) {
      case 'username':
        error = ProfileValidation.validateUsername(value);
        break;
      case 'displayName':
        error = ProfileValidation.validateDisplayName(value);
        break;
      case 'bio':
        error = ProfileValidation.validateBio(value);
        break;
      case 'subscriptionPrice':
        final price = double.tryParse(value);
        error = ProfileValidation.validateSubscriptionPrice(price);
        break;
      case 'twitter':
        error = ProfileValidation.validateTwitter(value);
        break;
      case 'instagram':
        error = ProfileValidation.validateInstagram(value);
        break;
      case 'tiktok':
        error = ProfileValidation.validateTiktok(value);
        break;
      case 'youtube':
        error = ProfileValidation.validateYoutube(value);
        break;
      case 'website':
        error = ProfileValidation.validateWebsite(value);
        break;
    }
    
    if (error != null) {
      _validationErrors[fieldName] = error;
    } else {
      _validationErrors.remove(fieldName);
    }
    
    _updateFormValidity();
    notifyListeners();
  }
  
  void _updateFormValidity() {
    _isFormValid = _validationErrors.isEmpty && 
                   usernameController.text.isNotEmpty &&
                   displayNameController.text.isNotEmpty;
  }
  
  // Méthodes de gestion des changements temporaires
  void updateTempValue(String key, dynamic value) {
    if (value == null || value == '') {
      _tempChanges.remove(key);
    } else {
      _tempChanges[key] = value;
    }
    notifyListeners();
  }
  
  void clearTempChanges() {
    _tempChanges.clear();
    _tempAvatarFile = null;
    _tempBannerFile = null;
    notifyListeners();
  }
  
  // Méthodes de gestion des images
  Future<void> pickAvatar() async {
    try {
      _setLoadingState(ProfileLoadingState.uploading);
      _clearError();
      
      final imageFile = await ImageUploadService.pickImage();
      if (imageFile != null) {
        // Valider l'image
        final validation = await ImageUploadService.validateImage(imageFile);
        if (!validation.isValid) {
          _setError(validation.errorMessage!);
          _setLoadingState(ProfileLoadingState.error);
          return;
        }
        
        // Compresser l'image
        final compressedFile = await ImageUploadService.compressImage(
          imageFile,
          maxWidth: 500,
          maxHeight: 500,
          quality: 85
        );
        
        _tempAvatarFile = compressedFile;
        _setLoadingState(ProfileLoadingState.success);
      } else {
        _setLoadingState(ProfileLoadingState.idle);
      }
    } catch (e) {
      _setError('Erreur lors de la sélection de l\'image: ${e.toString()}');
      _setLoadingState(ProfileLoadingState.error);
    }
  }
  
  Future<void> pickBanner() async {
    try {
      _setLoadingState(ProfileLoadingState.uploading);
      _clearError();
      
      final imageFile = await ImageUploadService.pickImage();
      if (imageFile != null) {
        // Valider l'image
        final validation = await ImageUploadService.validateImage(imageFile);
        if (!validation.isValid) {
          _setError(validation.errorMessage!);
          _setLoadingState(ProfileLoadingState.error);
          return;
        }
        
        // Compresser l'image
        final compressedFile = await ImageUploadService.compressImage(
          imageFile,
          maxWidth: 1200,
          maxHeight: 400,
          quality: 90
        );
        
        _tempBannerFile = compressedFile;
        _setLoadingState(ProfileLoadingState.success);
      } else {
        _setLoadingState(ProfileLoadingState.idle);
      }
    } catch (e) {
      _setError('Erreur lors de la sélection de la bannière: ${e.toString()}');
      _setLoadingState(ProfileLoadingState.error);
    }
  }
  
  void removeTempAvatar() {
    _tempAvatarFile = null;
    notifyListeners();
  }
  
  void removeTempBanner() {
    _tempBannerFile = null;
    notifyListeners();
  }
  
  // Méthodes de sauvegarde
  Future<bool> saveProfile() async {
    if (!_isFormValid) return false;
    
    try {
      _setLoadingState(ProfileLoadingState.saving);
      _clearError();
      
      // Sauvegarder le profil utilisateur
      if (_userProfile != null) {
        await _saveUserProfile();
      }
      
      // Sauvegarder le profil créateur
      if (_creatorProfile != null) {
        await _saveCreatorProfile();
      }
      
      // Uploader les images
      if (_tempAvatarFile != null) {
        await _uploadAvatar();
      }
      
      if (_tempBannerFile != null) {
        await _uploadBanner();
      }
      
      // Nettoyer les changements temporaires
      clearTempChanges();
      
      _setLoadingState(ProfileLoadingState.success);
      return true;
    } catch (e) {
      _setError('Erreur lors de la sauvegarde: ${e.toString()}');
      _setLoadingState(ProfileLoadingState.error);
      return false;
    }
  }
  
  Future<void> _saveUserProfile() async {
    if (_userProfile == null) return;
    
    final request = UpdateProfileRequest(
      username: usernameController.text,
      displayName: displayNameController.text.isEmpty ? null : displayNameController.text,
      bio: bioController.text.isEmpty ? null : bioController.text,
      socialLinks: SocialLinksRequest(
        twitter: twitterController.text.isEmpty ? null : twitterController.text,
        instagram: instagramController.text.isEmpty ? null : instagramController.text,
        tiktok: tiktokController.text.isEmpty ? null : tiktokController.text,
        youtube: youtubeController.text.isEmpty ? null : youtubeController.text,
        website: websiteController.text.isEmpty ? null : websiteController.text,
      ),
    );
    
    final response = await UserService.updateUserProfile(_userProfile!.id, request);
    _userProfile = response.data;
  }
  
  Future<void> _saveCreatorProfile() async {
    if (_creatorProfile == null) return;
    
    final subscriptionPrice = double.tryParse(subscriptionPriceController.text);
    if (subscriptionPrice != null) {
      final request = UpdateCreatorRequest(
        subscriptionPrice: subscriptionPrice,
        bio: bioController.text.isEmpty ? null : bioController.text,
      );
      
      final response = await CreatorService.updateCreatorProfile(_creatorProfile!.id, request);
      _creatorProfile = response.data;
    }
  }
  
  Future<void> _uploadAvatar() async {
    if (_tempAvatarFile == null || _userProfile == null) return;
    
    final response = await UserService.uploadProfileAvatar(_userProfile!.id, _tempAvatarFile!);
    // Mettre à jour l'URL de l'avatar
    _userProfile = _userProfile!.copyWith(avatarUrl: response.data);
  }
  
  Future<void> _uploadBanner() async {
    if (_tempBannerFile == null || _creatorProfile == null) return;
    
    final response = await CreatorService.uploadCreatorBanner(_creatorProfile!.id, _tempBannerFile!);
    // Mettre à jour l'URL de la bannière
    _creatorProfile = _creatorProfile!.copyWith(bannerUrl: response.data);
  }
  
  // Méthodes de vérification
  Future<bool> checkUsernameAvailability(String username) async {
    try {
      final response = await UserService.checkUsernameAvailability(username);
      return response.data ?? false;
    } catch (e) {
      return false;
    }
  }
  
  // Méthodes utilitaires
  void _setLoadingState(ProfileLoadingState state) {
    _loadingState = state;
    notifyListeners();
  }
  
  void _setError(String message) {
    _errorMessage = message;
  }
  
  void _clearError() {
    _errorMessage = null;
  }
  
  void clearError() {
    _clearError();
    notifyListeners();
  }
  
  // Méthode pour recharger les données
  Future<void> refresh() async {
    if (_userProfile != null) {
      await loadUserProfile(_userProfile!.id);
    }
    if (_creatorProfile != null) {
      await loadCreatorProfile(_creatorProfile!.id);
    }
  }
}
