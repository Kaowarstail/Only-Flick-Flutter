import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/admin_models.dart';
import '../services/admin_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/admin/dashboard_overview_card.dart';
import '../widgets/admin/revenue_chart_widget.dart';
import '../widgets/admin/user_growth_chart_widget.dart';
import '../widgets/admin/content_stats_widget.dart';
import '../widgets/admin/report_stats_widget.dart';
import '../widgets/admin/top_creators_widget.dart';
import '../widgets/admin/recent_reports_widget.dart';

class AdminDashboardWithSidebar extends StatefulWidget {
  const AdminDashboardWithSidebar({super.key});

  @override
  State<AdminDashboardWithSidebar> createState() => _AdminDashboardWithSidebarState();
}

class _AdminDashboardWithSidebarState extends State<AdminDashboardWithSidebar> {
  AdminDashboardData? _dashboardData;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedIndex = 0;

  // Sections de navigation
  final List<AdminSection> _sections = [
    AdminSection(
      title: 'Vue d\'ensemble',
      icon: Icons.dashboard,
      color: Colors.blue,
    ),
    AdminSection(
      title: 'Statistiques de croissance',
      icon: Icons.trending_up,
      color: Colors.green,
    ),
    AdminSection(
      title: 'Graphiques utilisateurs',
      icon: Icons.people_alt,
      color: Colors.purple,
    ),
    AdminSection(
      title: 'Graphiques contenus',
      icon: Icons.video_library,
      color: Colors.orange,
    ),
    AdminSection(
      title: 'Graphiques revenus',
      icon: Icons.monetization_on,
      color: Colors.teal,
    ),
    AdminSection(
      title: 'Modération',
      icon: Icons.flag,
      color: Colors.red,
    ),
  ];

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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              'Dashboard Administrateur',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadDashboardData,
            icon: Icon(Icons.refresh, color: AppTheme.primaryColor),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      drawer: isMobile ? _buildSidebar() : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(),
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Admin Panel',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _sections.length,
              itemBuilder: (context, index) {
                final section = _sections[index];
                final isSelected = _selectedIndex == index;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected ? section.color.withOpacity(0.1) : null,
                  ),
                  child: ListTile(
                    leading: Icon(
                      section.icon,
                      color: isSelected ? section.color : Colors.grey.shade600,
                      size: 20,
                    ),
                    title: Text(
                      section.title,
                      style: GoogleFonts.inter(
                        color: isSelected ? section.color : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                      // Fermer le drawer sur mobile
                      if (MediaQuery.of(context).size.width < 768) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Données mises à jour en temps réel',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.grey.shade600,
                ),
              ),
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
      );
    }

    if (_dashboardData == null) {
      return const Center(
        child: Text('Aucune donnée disponible'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildSectionContent(),
      ),
    );
  }

  Widget _buildSectionContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverviewSection();
      case 1:
        return _buildGrowthStatsSection();
      case 2:
        return _buildUserChartsSection();
      case 3:
        return _buildContentChartsSection();
      case 4:
        return _buildRevenueChartsSection();
      case 5:
        return _buildModerationSection();
      default:
        return _buildOverviewSection();
    }
  }

  Widget _buildOverviewSection() {
    final overview = _dashboardData!.overview;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Vue d\'ensemble', 
          Icons.dashboard, 
          Colors.blue,
          'Aperçu général des statistiques de la plateforme'
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            DashboardOverviewCard(
              title: '🔢 Utilisateurs totaux',
              value: overview.totalUsers.toString(),
              color: Colors.blue,
              icon: Icons.people,
              trend: '+${overview.newUsersWeek} cette semaine',
            ),
            DashboardOverviewCard(
              title: '🧑‍🎨 Créateurs',
              value: overview.totalCreators.toString(),
              color: Colors.purple,
              icon: Icons.brush,
              trend: 'Actifs',
            ),
            DashboardOverviewCard(
              title: '👥 Abonnés',
              value: overview.totalSubscribers.toString(),
              color: Colors.green,
              icon: Icons.card_membership,
              trend: 'Payants',
            ),
            DashboardOverviewCard(
              title: '💰 Revenus totaux',
              value: '${overview.totalRevenue.toStringAsFixed(2)}€',
              color: Colors.orange,
              icon: Icons.euro,
              trend: '+${overview.monthlyRevenue.toStringAsFixed(2)}€ ce mois',
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: TopCreatorsWidget(topCreators: _dashboardData!.topCreators),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: RecentReportsWidget(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGrowthStatsSection() {
    final overview = _dashboardData!.overview;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Statistiques de croissance', 
          Icons.trending_up, 
          Colors.green,
          'Analyse de la croissance de la plateforme'
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildGrowthCard(
                '📈 Nouvelles inscriptions (semaine)',
                overview.newUsersWeek.toString(),
                'utilisateurs',
                Colors.blue,
                Icons.person_add,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGrowthCard(
                '📊 Nouvelles inscriptions (mois)',
                overview.newUsersMonth.toString(),
                'utilisateurs',
                Colors.purple,
                Icons.group_add,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildGrowthCard(
                '📝 Contenus publiés',
                overview.totalContents.toString(),
                'contenus',
                Colors.orange,
                Icons.library_books,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGrowthCard(
                '💰 Revenus mensuels',
                '${overview.monthlyRevenue.toStringAsFixed(2)}€',
                'ce mois',
                Colors.teal,
                Icons.monetization_on,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Graphiques utilisateurs', 
          Icons.people_alt, 
          Colors.purple,
          'Évolution du nombre d\'utilisateurs dans le temps'
        ),
        const SizedBox(height: 20),
        UserGrowthChartWidget(userGrowthData: _dashboardData!.userGrowth),
      ],
    );
  }

  Widget _buildContentChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Graphiques contenus', 
          Icons.video_library, 
          Colors.orange,
          'Statistiques des contenus publiés sur la plateforme'
        ),
        const SizedBox(height: 20),
        ContentStatsWidget(contentStats: _dashboardData!.contentStats),
      ],
    );
  }

  Widget _buildRevenueChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Graphiques revenus', 
          Icons.monetization_on, 
          Colors.teal,
          'Évolution des revenus générés par les abonnements'
        ),
        const SizedBox(height: 20),
        RevenueChartWidget(revenueData: _dashboardData!.revenueChart),
        const SizedBox(height: 20),
        _buildRevenueBreakdown(),
      ],
    );
  }

  Widget _buildModerationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Modération', 
          Icons.flag, 
          Colors.red,
          'Gestion des signalements et modération du contenu'
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ReportStatsWidget(reportStats: _dashboardData!.reportStats),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: RecentReportsWidget(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueBreakdown() {
    final overview = _dashboardData!.overview;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Répartition des revenus',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildRevenueItem(
                  'Total',
                  '${overview.totalRevenue.toStringAsFixed(2)}€',
                  Colors.teal,
                  Icons.account_balance_wallet,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRevenueItem(
                  'Mensuel',
                  '${overview.monthlyRevenue.toStringAsFixed(2)}€',
                  Colors.green,
                  Icons.calendar_month,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRevenueItem(
                  'Hebdomadaire',
                  '${overview.weeklyRevenue.toStringAsFixed(2)}€',
                  Colors.blue,
                  Icons.date_range,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueItem(String title, String amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminSection {
  final String title;
  final IconData icon;
  final Color color;

  AdminSection({
    required this.title,
    required this.icon,
    required this.color,
  });
}
