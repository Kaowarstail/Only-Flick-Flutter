import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/admin_models.dart';

class RevenueChartWidget extends StatelessWidget {
  final List<RevenueStats> revenueData;

  const RevenueChartWidget({
    super.key,
    required this.revenueData,
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
                Icons.trending_up,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Revenus des 30 derniers jours',
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
            child: revenueData.isEmpty
                ? Center(
                    child: Text(
                      'Aucune donnée de revenus disponible',
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                : _buildSimpleChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleChart() {
    if (revenueData.isEmpty) return const SizedBox();

    final maxAmount = revenueData.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    final minAmount = revenueData.map((e) => e.amount).reduce((a, b) => a < b ? a : b);
    final range = maxAmount - minAmount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: revenueData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final height = range > 0 ? ((data.amount - minAmount) / range) * 150 + 20 : 50.0;
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.7),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                      child: Center(
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Text(
                            '€${data.amount.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: revenueData.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              final shouldShowDate = index % 5 == 0 || index == revenueData.length - 1;
              
              return Expanded(
                child: Text(
                  shouldShowDate ? data.date.split('-').reversed.take(2).join('/') : '',
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
