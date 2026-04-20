import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../helpers/app_colors.dart';

class NutrientCard extends StatelessWidget {
  final String label;
  final double consumed;
  final double target;
  final Color color;
  final IconData icon;

  const NutrientCard({
    super.key,
    required this.label,
    required this.consumed,
    required this.target,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    final remaining = (target - consumed).clamp(0, target);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: color.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
        border: Border.all(
          color: isDark ? AppColors.darkBorder : color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 36,
            lineWidth: 5,
            percent: progress,
            backgroundColor:
                isDark ? AppColors.darkBackground : AppColors.lightDivider,
            progressColor: color,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            center: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            '${remaining.toStringAsFixed(1)}g',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          Text(
            'tersisa',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
