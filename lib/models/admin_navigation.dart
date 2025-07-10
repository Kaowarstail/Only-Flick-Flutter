class AdminSection {
  final String id;
  final String title;
  final String icon;
  final String description;

  const AdminSection({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
  });

  static const List<AdminSection> sections = [
    AdminSection(
      id: 'overview',
      title: 'Vue d\'ensemble',
      icon: '📊',
      description: 'Aperçu général des statistiques',
    ),
    AdminSection(
      id: 'growth',
      title: 'Statistiques de croissance',
      icon: '📈',
      description: 'Graphiques de croissance et tendances',
    ),
    AdminSection(
      id: 'users',
      title: 'Gestion des utilisateurs',
      icon: '👥',
      description: 'Utilisateurs et créateurs',
    ),
    AdminSection(
      id: 'content',
      title: 'Gestion du contenu',
      icon: '📦',
      description: 'Contenus publiés et modération',
    ),
    AdminSection(
      id: 'reports',
      title: 'Signalements',
      icon: '⚠️',
      description: 'Modération et signalements',
    ),
    AdminSection(
      id: 'revenue',
      title: 'Revenus',
      icon: '💰',
      description: 'Statistiques financières',
    ),
  ];
}

// Modèles pour les statistiques de croissance
class GrowthStats {
  final List<DataPoint> newUsers;
  final List<DataPoint> contentPublished;
  final List<DataPoint> revenue;

  const GrowthStats({
    required this.newUsers,
    required this.contentPublished,
    required this.revenue,
  });

  factory GrowthStats.fromJson(Map<String, dynamic> json) {
    return GrowthStats(
      newUsers: (json['new_users'] as List<dynamic>)
          .map((item) => DataPoint.fromJson(item))
          .toList(),
      contentPublished: (json['content_published'] as List<dynamic>)
          .map((item) => DataPoint.fromJson(item))
          .toList(),
      revenue: (json['revenue'] as List<dynamic>)
          .map((item) => DataPoint.fromJson(item))
          .toList(),
    );
  }
}

class DataPoint {
  final String date;
  final double value;
  final String? label;

  const DataPoint({
    required this.date,
    required this.value,
    this.label,
  });

  factory DataPoint.fromJson(Map<String, dynamic> json) {
    return DataPoint(
      date: json['date'] as String,
      value: (json['value'] as num).toDouble(),
      label: json['label'] as String?,
    );
  }
}
