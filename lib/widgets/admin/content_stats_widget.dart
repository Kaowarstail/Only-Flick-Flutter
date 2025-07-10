import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/admin_models.dart';

class ContentStatsWidget extends StatelessWidget {
  final ContentStats contentStats;

  const ContentStatsWidget({
    super.key,
    required this.contentStats,
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
                Icons.video_library,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Statistiques de contenu',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            'Total des contenus',
            contentStats.totalContents.toString(),
            Icons.all_inclusive,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            'Contenus gratuits',
            contentStats.freeContents.toString(),
            Icons.public,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            'Contenus premium',
            contentStats.premiumContents.toString(),
            Icons.star,
            Colors.amber,
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Activité récente',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            'Aujourd\'hui',
            contentStats.contentsToday.toString(),
            Icons.today,
            Colors.purple,
          ),
          const SizedBox(height: 8),
          _buildStatRow(
            'Cette semaine',
            contentStats.contentsWeek.toString(),
            Icons.date_range,
            Colors.indigo,
          ),
          const SizedBox(height: 8),
          _buildStatRow(
            'Ce mois',
            contentStats.contentsMonth.toString(),
            Icons.calendar_month,
            Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}
