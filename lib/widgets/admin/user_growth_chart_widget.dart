import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/admin_models.dart';

class UserGrowthChartWidget extends StatelessWidget {
  final List<UserGrowthStats> userGrowthData;

  const UserGrowthChartWidget({
    super.key,
    required this.userGrowthData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Icon(
                Icons.people_alt,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Croissance des utilisateurs (30 jours)',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: userGrowthData.isEmpty
                ? Center(
                    child: Text(
                      'Aucune donnée de croissance disponible',
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                : _buildGrowthChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthChart() {
    if (userGrowthData.isEmpty) return const SizedBox();

    final maxUsers = userGrowthData.map((e) => e.newUsers).reduce((a, b) => a > b ? a : b);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: userGrowthData.asMap().entries.map((entry) {
                final data = entry.value;
                final height = maxUsers > 0 ? (data.newUsers / maxUsers) * 150 + 20 : 50.0;
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Barre pour nouveaux utilisateurs
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.7),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                        // Petite barre pour nouveaux créateurs
                        if (data.newCreators > 0)
                          Container(
                            height: (data.newCreators / maxUsers) * 30 + 5,
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.7),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                color: Colors.blue.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                'Nouveaux utilisateurs',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                color: Colors.purple.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                'Nouveaux créateurs',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
