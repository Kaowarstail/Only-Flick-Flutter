/// Profile validation utility for OnlyFlick profile editing
/// Provides client-side validation for immediate UX feedback

class ProfileValidation {
  // Bio validation
  static String? validateBio(String? bio) {
    if (bio == null || bio.isEmpty) return null;
    if (bio.length > 500) return "Bio trop longue (max 500 caractères)";
    if (bio.contains(RegExp(r'[<>{}]'))) return "Caractères non autorisés";
    
    // Check for excessive line breaks
    if (bio.split('\n').length > 10) return "Trop de sauts de ligne (max 10)";
    
    return null;
  }
  
  // Username validation
  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return "Nom d'utilisateur requis";
    }
    if (username.length < 3) {
      return "Nom d'utilisateur trop court (min 3 caractères)";
    }
    if (username.length > 30) {
      return "Nom d'utilisateur trop long (max 30 caractères)";
    }
    if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(username)) {
      return "Seuls lettres, chiffres, points et underscores autorisés";
    }
    if (username.startsWith('.') || username.endsWith('.')) {
      return "Ne peut pas commencer ou finir par un point";
    }
    if (username.contains('..')) {
      return "Points consécutifs non autorisés";
    }
    return null;
  }
  
  // Display name validation
  static String? validateDisplayName(String? displayName) {
    if (displayName == null || displayName.isEmpty) {
      return "Nom d'affichage requis";
    }
    if (displayName.length < 2) {
      return "Nom d'affichage trop court (min 2 caractères)";
    }
    if (displayName.length > 50) {
      return "Nom d'affichage trop long (max 50 caractères)";
    }
    if (displayName.contains(RegExp(r'[<>{}]'))) {
      return "Caractères non autorisés";
    }
    return null;
  }
  
  // Prix abonnement validation
  static String? validateSubscriptionPrice(String? price) {
    if (price == null || price.isEmpty) {
      return "Prix requis pour les créateurs";
    }
    
    double? amount = double.tryParse(price.replaceAll(',', '.'));
    if (amount == null) return "Prix invalide";
    if (amount < 4.99) return "Prix minimum: 4,99€";
    if (amount > 99.99) return "Prix maximum: 99,99€";
    
    // Check for reasonable decimal places
    String cleanPrice = price.replaceAll(',', '.');
    if (cleanPrice.contains('.')) {
      String decimal = cleanPrice.split('.').last;
      if (decimal.length > 2) {
        return "Maximum 2 décimales autorisées";
      }
    }
    
    return null;
  }
  
  // URL réseaux sociaux validation
  static String? validateSocialUrl(String? url, String platform) {
    if (url == null || url.isEmpty) return null;
    
    // Remove trailing slash for validation
    String cleanUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    
    Map<String, String> patterns = {
      'instagram': r'^https?://(www\.)?instagram\.com/[\w.]+$',
      'twitter': r'^https?://(www\.)?(twitter\.com|x\.com)/[\w]+$',
      'tiktok': r'^https?://(www\.)?tiktok\.com/@[\w.]+$',
      'youtube': r'^https?://(www\.)?youtube\.com/(c/|channel/|user/|@)?[\w-]+$',
    };
    
    if (!patterns.containsKey(platform.toLowerCase())) {
      return "Plateforme non supportée";
    }
    
    if (!RegExp(patterns[platform.toLowerCase()]!).hasMatch(cleanUrl)) {
      return "URL $platform invalide";
    }
    
    return null;
  }
  
  // Website URL validation
  static String? validateWebsiteUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    
    if (!RegExp(r'^https?://').hasMatch(url)) {
      return "L'URL doit commencer par http:// ou https://";
    }
    
    if (!RegExp(r'^https?://[\w\-.]+(\.[\w]{2,})+(/.*)?$').hasMatch(url)) {
      return "URL de site web invalide";
    }
    
    if (url.length > 200) {
      return "URL trop longue (max 200 caractères)";
    }
    
    return null;
  }
  
  // Category validation for creators
  static String? validateCategory(String? category) {
    if (category == null || category.isEmpty) return null;
    
    List<String> validCategories = [
      'fitness',
      'beauty',
      'lifestyle',
      'gaming',
      'music',
      'art',
      'cooking',
      'travel',
      'fashion',
      'education',
      'comedy',
      'photography',
      'other'
    ];
    
    if (!validCategories.contains(category.toLowerCase())) {
      return "Catégorie non valide";
    }
    
    return null;
  }
  
  // Comprehensive profile validation
  static List<String> validateFullProfile({
    String? bio,
    String? username,
    String? displayName,
    String? subscriptionPrice,
    String? instagram,
    String? twitter,
    String? tiktok,
    String? youtube,
    String? website,
    String? category,
    bool isCreator = false,
  }) {
    List<String> errors = [];
    
    // Basic info validation
    String? bioError = validateBio(bio);
    if (bioError != null) errors.add("Bio: $bioError");
    
    String? usernameError = validateUsername(username);
    if (usernameError != null) errors.add("Username: $usernameError");
    
    String? displayNameError = validateDisplayName(displayName);
    if (displayNameError != null) errors.add("Nom d'affichage: $displayNameError");
    
    // Creator-specific validation
    if (isCreator) {
      String? priceError = validateSubscriptionPrice(subscriptionPrice);
      if (priceError != null) errors.add("Prix: $priceError");
      
      String? categoryError = validateCategory(category);
      if (categoryError != null) errors.add("Catégorie: $categoryError");
    }
    
    // Social links validation
    String? instagramError = validateSocialUrl(instagram, 'instagram');
    if (instagramError != null) errors.add("Instagram: $instagramError");
    
    String? twitterError = validateSocialUrl(twitter, 'twitter');
    if (twitterError != null) errors.add("Twitter/X: $twitterError");
    
    String? tiktokError = validateSocialUrl(tiktok, 'tiktok');
    if (tiktokError != null) errors.add("TikTok: $tiktokError");
    
    String? youtubeError = validateSocialUrl(youtube, 'youtube');
    if (youtubeError != null) errors.add("YouTube: $youtubeError");
    
    String? websiteError = validateWebsiteUrl(website);
    if (websiteError != null) errors.add("Site web: $websiteError");
    
    return errors;
  }
  
  // Quick validation for real-time feedback
  static bool isValidBio(String? bio) => validateBio(bio) == null;
  static bool isValidUsername(String? username) => validateUsername(username) == null;
  static bool isValidDisplayName(String? displayName) => validateDisplayName(displayName) == null;
  static bool isValidSubscriptionPrice(String? price) => validateSubscriptionPrice(price) == null;
  static bool isValidSocialUrl(String? url, String platform) => validateSocialUrl(url, platform) == null;
  static bool isValidWebsiteUrl(String? url) => validateWebsiteUrl(url) == null;
  
  // Helper methods for UI
  static String getBioCharacterCount(String? bio) {
    int count = bio?.length ?? 0;
    return '$count/500';
  }
  
  static String getUsernameCharacterCount(String? username) {
    int count = username?.length ?? 0;
    return '$count/30';
  }
  
  static String getDisplayNameCharacterCount(String? displayName) {
    int count = displayName?.length ?? 0;
    return '$count/50';
  }
  
  // Format price for display
  static String formatPrice(double price) {
    return '${price.toStringAsFixed(2).replaceAll('.', ',')}€';
  }
  
  // Parse price from string
  static double? parsePrice(String? priceString) {
    if (priceString == null || priceString.isEmpty) return null;
    String cleanPrice = priceString.replaceAll('€', '').replaceAll(',', '.').trim();
    return double.tryParse(cleanPrice);
  }
  
  // Get suggested usernames if current is taken
  static List<String> getSuggestedUsernames(String baseUsername) {
    List<String> suggestions = [];
    String clean = baseUsername.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    
    suggestions.addAll([
      '${clean}_official',
      '${clean}2024',
      'the_$clean',
      '${clean}_',
      '${clean}xx',
    ]);
    
    return suggestions.take(3).toList();
  }
  
  // Platform-specific URL formatters
  static String formatInstagramUrl(String username) {
    String clean = username.replaceAll('@', '').trim();
    return 'https://instagram.com/$clean';
  }
  
  static String formatTwitterUrl(String username) {
    String clean = username.replaceAll('@', '').trim();
    return 'https://twitter.com/$clean';
  }
  
  static String formatTikTokUrl(String username) {
    String clean = username.replaceAll('@', '').trim();
    return 'https://tiktok.com/@$clean';
  }
  
  static String formatYouTubeUrl(String channelName) {
    String clean = channelName.trim();
    return 'https://youtube.com/@$clean';
  }
}
