import '../models/content_models.dart';
import '../models/user_models.dart';
import 'api_service.dart';

class ContentService {
  // Mock data that matches our enhanced GORM seed data
  static List<User> getMockUsers() {
    return [
      User(
        id: "user-1",
        username: "alice_photographer",
        email: "alice@example.com",
        firstName: "Alice",
        lastName: "Johnson",
        role: UserRole.creator,
        biography: "Professional photographer and visual artist. Capturing life's beautiful moments 📸✨",
        profilePicture: "https://i.pravatar.cc/300?img=1",
        isActive: true,
        isEmailVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
      ),
      User(
        id: "user-2",
        username: "bob_fitness",
        email: "bob@example.com",
        firstName: "Bob",
        lastName: "Wilson",
        role: UserRole.creator,
        biography: "Fitness coach & nutrition expert. Transform your body and mind 💪🏋️‍♂️",
        profilePicture: "https://i.pravatar.cc/300?img=11",
        isActive: true,
        isEmailVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
        updatedAt: DateTime.now(),
      ),
      User(
        id: "user-3",
        username: "carol_chef",
        email: "carol@example.com",
        firstName: "Carol",
        lastName: "Martinez",
        role: UserRole.creator,
        biography: "Chef & food stylist. Bringing delicious recipes to your kitchen 👩‍🍳🍽️",
        profilePicture: "https://i.pravatar.cc/300?img=5",
        isActive: true,
        isEmailVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 250)),
        updatedAt: DateTime.now(),
      ),
      User(
        id: "user-4",
        username: "david_traveler",
        email: "david@example.com",
        firstName: "David",
        lastName: "Chen",
        role: UserRole.creator,
        biography: "World traveler & adventure seeker. Join me on epic journeys ✈️🌍",
        profilePicture: "https://i.pravatar.cc/300?img=33",
        isActive: true,
        isEmailVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        updatedAt: DateTime.now(),
      ),
      User(
        id: "user-5",
        username: "emma_artist",
        email: "emma@example.com",
        firstName: "Emma",
        lastName: "Davis",
        role: UserRole.creator,
        biography: "Digital artist & illustrator. Creating magic through pixels 🎨✨",
        profilePicture: "https://i.pravatar.cc/300?img=9",
        isActive: true,
        isEmailVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        updatedAt: DateTime.now(),
      ),
      User(
        id: "user-6",
        username: "frank_musician",
        email: "frank@example.com",
        firstName: "Frank",
        lastName: "Thompson",
        role: UserRole.creator,
        biography: "Musician & producer. Sharing the rhythm of life 🎵🎹",
        profilePicture: "https://i.pravatar.cc/300?img=12",
        isActive: true,
        isEmailVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
        updatedAt: DateTime.now(),
      ),
      User(
        id: "user-7",
        username: "grace_stylist",
        email: "grace@example.com",
        firstName: "Grace",
        lastName: "Kim",
        role: UserRole.creator,
        biography: "Fashion stylist & trend setter. Style is a way to say who you are 👗💄",
        profilePicture: "https://i.pravatar.cc/300?img=20",
        isActive: true,
        isEmailVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  static List<Content> getMockFeedContent() {
    final users = getMockUsers();
    final userMap = {for (var user in users) user.id: user};

    return [
      Content(
        id: 1,
        creatorId: "user-1",
        title: "Golden Hour Portrait Session",
        description: "Behind the scenes of a magical golden hour photoshoot in the city park. Learn about lighting techniques and camera settings.",
        type: "image",
        mediaUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800&h=600&fit=crop",
        thumbnailUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&h=300&fit=crop",
        isPremium: false,
        viewCount: 1250,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        creator: userMap["user-1"],
        likeCount: 5,
        commentCount: 4,
        isLikedByCurrentUser: false,
      ),
      Content(
        id: 4,
        creatorId: "user-2",
        title: "30-Minute Full Body Workout",
        description: "High-intensity workout that targets all muscle groups. No equipment needed!",
        type: "video",
        mediaUrl: "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4",
        thumbnailUrl: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=300&fit=crop",
        isPremium: false,
        viewCount: 3200,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
        creator: userMap["user-2"],
        likeCount: 6,
        commentCount: 4,
        isLikedByCurrentUser: true,
      ),
      Content(
        id: 7,
        creatorId: "user-3",
        title: "Homemade Pasta from Scratch",
        description: "Learn to make authentic Italian pasta at home. Recipe and technique included!",
        type: "video",
        mediaUrl: "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4",
        thumbnailUrl: "https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=300&h=300&fit=crop",
        isPremium: false,
        viewCount: 4100,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        creator: userMap["user-3"],
        likeCount: 7,
        commentCount: 4,
        isLikedByCurrentUser: false,
      ),
      Content(
        id: 10,
        creatorId: "user-4",
        title: "Hidden Gems of Tokyo",
        description: "Discover the secret spots in Tokyo that most tourists never see. Complete with maps and insider tips!",
        type: "image",
        mediaUrl: "https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800&h=600&fit=crop",
        thumbnailUrl: "https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=300&h=300&fit=crop",
        isPremium: false,
        viewCount: 3800,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
        creator: userMap["user-4"],
        likeCount: 6,
        commentCount: 4,
        isLikedByCurrentUser: true,
      ),
      Content(
        id: 12,
        creatorId: "user-5",
        title: "Digital Portrait Speedpaint",
        description: "Watch me create a digital portrait from start to finish in real-time. Includes brush settings!",
        type: "video",
        mediaUrl: "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4",
        thumbnailUrl: "https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=300&h=300&fit=crop",
        isPremium: false,
        viewCount: 1950,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
        creator: userMap["user-5"],
        likeCount: 4,
        commentCount: 3,
        isLikedByCurrentUser: false,
      ),
      Content(
        id: 14,
        creatorId: "user-6",
        title: "Acoustic Sessions at Home",
        description: "Intimate acoustic performances of my latest songs, recorded in my home studio.",
        type: "video",
        mediaUrl: "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4",
        thumbnailUrl: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop",
        isPremium: false,
        viewCount: 2800,
        createdAt: DateTime.now().subtract(const Duration(hours: 18)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 18)),
        creator: userMap["user-6"],
        likeCount: 5,
        commentCount: 4,
        isLikedByCurrentUser: true,
      ),
      Content(
        id: 16,
        creatorId: "user-7",
        title: "Fall Fashion Lookbook 2024",
        description: "15 stunning fall outfits styled by me. Perfect for any occasion and budget!",
        type: "image",
        mediaUrl: "https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=600&fit=crop",
        thumbnailUrl: "https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=300&h=300&fit=crop",
        isPremium: false,
        viewCount: 3500,
        createdAt: DateTime.now().subtract(const Duration(hours: 24)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 24)),
        creator: userMap["user-7"],
        likeCount: 6,
        commentCount: 3,
        isLikedByCurrentUser: false,
      ),
    ];
  }

  static List<User> getStoriesUsers() {
    return getMockUsers().take(8).toList();
  }

  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${difference.inDays} jours';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'maintenant';
    }
  }

  static String formatViewCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  static String formatLikeCount(int count) {
    if (count == 1) {
      return '1 j\'aime';
    } else {
      return '$count j\'aime';
    }
  }

  static String formatCommentCount(int count) {
    if (count == 0) {
      return 'Aucun commentaire';
    } else if (count == 1) {
      return 'Voir le commentaire';
    } else {
      return 'Voir les $count commentaires';
    }
  }

  // Obtenir les contenus d'un créateur organisés par statut premium
  static Future<Map<String, dynamic>> getCreatorContents(String creatorId, {
    int page = 1,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };
      
      final query = Uri(queryParameters: queryParams).query;
      final responseData = await ApiService.get('/creators/$creatorId/contents?$query');
      
      return {
        'creator': responseData['creator'],
        'free_content': {
          'contents': (responseData['free_content']['contents'] as List)
              .map((contentData) => Content.fromJson(contentData))
              .toList(),
          'pagination': responseData['free_content']['pagination'],
        },
        'premium_content': {
          'contents': (responseData['premium_content']['contents'] as List)
              .map((contentData) => Content.fromJson(contentData))
              .toList(),
          'pagination': responseData['premium_content']['pagination'],
        },
      };
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur lors de la récupération des contenus du créateur.');
    }
  }
}
