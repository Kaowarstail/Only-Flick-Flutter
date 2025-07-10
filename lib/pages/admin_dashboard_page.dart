import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/admin_models.dart';
import '../models/admin_navigation.dart';
import '../services/admin_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/admin/admin_sidebar.dart';
import '../widgets/admin/simple_overview_card.dart';
import '../widgets/admin/growth_stats_widget.dart';
import '../widgets/admin/user_management_widget.dart';
import '../widgets/admin/content_management_widget.dart';
import '../widgets/admin/reports_overview_widget.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  AdminDashboardData? _dashboardData;
  bool _isLoading = true;
  String? _errorMessage;
  String _currentSection = 'overview';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await AdminApiService.getDashboardStats();
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getSectionTitle() {
    final section = AdminSection.sections.firstWhere(
      (s) => s.id == _currentSection,
      orElse: () => AdminSection.sections.first,
    );
    return section.title;
  }

  String _getSectionSubtitle() {
    final section = AdminSection.sections.firstWhere(
      (s) => s.id == _currentSection,
      orElse: () => AdminSection.sections.first,
    );
    return section.description;
  }

  Widget _buildSectionContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    switch (_currentSection) {
      case 'overview':
        return _buildOverviewSection();
      case 'growth':
        return GrowthStatsWidget(isLoading: _isLoading);
      case 'users':
        return _buildUsersSection();
      case 'content':
        return _buildContentSection();
      case 'reports':
        return _buildReportsSection();
      case 'revenue':
        return _buildRevenueSection();
      default:
        return _buildOverviewSection();
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Une erreur inattendue s\'est produite',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Statistiques principales
          if (_dashboardData != null) ...[
            // Vue d'ensemble
            Row(
              children: [
                Expanded(
                  child: SimpleOverviewCard(
                    title: 'Utilisateurs totaux',
                    value: _dashboardData!.overview.totalUsers.toString(),
                    emoji: '👥',
                    color: Colors.blue,
                    change: '+12.5%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SimpleOverviewCard(
                    title: 'Créateurs',
                    value: _dashboardData!.overview.totalCreators.toString(),
                    emoji: '🧑‍🎨',
                    color: Colors.purple,
                    change: '+8.3%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SimpleOverviewCard(
                    title: 'Abonnés',
                    value: _dashboardData!.overview.totalSubscribers.toString(),
                    emoji: '💎',
                    color: Colors.green,
                    change: '+15.2%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: SimpleOverviewCard(
                    title: 'Revenus totaux',
                    value: '€${_dashboardData!.overview.totalRevenue.toStringAsFixed(2)}',
                    emoji: '💰',
                    color: Colors.amber,
                    change: '+22.1%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SimpleOverviewCard(
                    title: 'Contenus publiés',
                    value: _dashboardData!.overview.totalContents.toString(),
                    emoji: '📦',
                    color: Colors.orange,
                    change: '+9.7%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SimpleOverviewCard(
                    title: 'Signalements',
                    value: _dashboardData!.overview.pendingReports.toString(),
                    emoji: '⚠️',
                    color: Colors.red,
                    change: '-5.3%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Nouvelles inscriptions
            Row(
              children: [
                Expanded(
                  child: SimpleOverviewCard(
                    title: 'Nouvelles inscriptions (semaine)',
                    value: _dashboardData!.overview.newUsersWeek.toString(),
                    emoji: '🆕',
                    color: Colors.indigo,
                    change: '+18.2%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SimpleOverviewCard(
                    title: 'Nouvelles inscriptions (mois)',
                    value: _dashboardData!.overview.newUsersMonth.toString(),
                    emoji: '📅',
                    color: Colors.teal,
                    change: '+25.7%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SimpleOverviewCard(
                    title: 'Revenus mensuels',
                    value: '€${_dashboardData!.overview.monthlyRevenue.toStringAsFixed(2)}',
                    emoji: '💳',
                    color: Colors.cyan,
                    change: '+14.8%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Top créateurs
            if (_dashboardData!.topCreators.isNotEmpty) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '🏆',
                            style: TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Top Créateurs',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(
                        _dashboardData!.topCreators.take(5).length,
                        (index) {
                          final creator = _dashboardData!.topCreators[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.purple.shade100,
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple.shade700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        creator.username,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${creator.subscriberCount} abonnés',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '€${creator.monthlyRevenue.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ] else ...[
            _buildEmptyState(),
          ],
        ],
      ),
    );
  }

  Widget _buildUsersSection() {
    return const UserManagementWidget();
  }

  Widget _buildContentSection() {
    return const ContentManagementWidget();
  }

  Widget _buildReportsSection() {
    return ReportsOverviewWidget(
      reportStats: _dashboardData?.reportStats,
    );
  }

  Widget _buildRevenueSection() {
    return const Center(
      child: Text('Section Revenus - À implémenter'),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Chargement du dashboard...',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _onSectionChanged(String sectionId) {
    setState(() {
      _currentSection = sectionId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          // Sidebar
          AdminSidebar(
            currentSection: _currentSection,
            onSectionChanged: _onSectionChanged,
          ),
          // Contenu principal
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getSectionTitle(),
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getSectionSubtitle(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _loadDashboardData,
                        icon: Icon(Icons.refresh, color: AppTheme.primaryColor),
                        tooltip: 'Actualiser',
                      ),
                    ],
                  ),
                ),
                // Contenu
                Expanded(
                  child: _buildSectionContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
