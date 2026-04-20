import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../helpers/app_colors.dart';

class CalorieRingWidget extends StatelessWidget {
  final double consumed;
  final double target;

  const CalorieRingWidget({
    super.key,
    required this.consumed,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    final remaining = (target - consumed).clamp(0, target);
    final isOver = consumed > target;

    return CircularPercentIndicator(
      radius: 100.0,
      lineWidth: 14.0,
      percent: progress,
      backgroundColor:
          isDark ? AppColors.darkCard : AppColors.lightDivider,
      linearGradient: LinearGradient(
        colors: isOver
            ? [AppColors.warning, AppColors.error]
            : [AppColors.primaryLight, AppColors.primaryDark],
      ),
      circularStrokeCap: CircularStrokeCap.round,
      animation: true,
      animationDuration: 800,
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOver ? Icons.warning_amber_rounded : Icons.local_fire_department_rounded,
            color: isOver ? AppColors.warning : AppColors.primaryLight,
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            remaining.toStringAsFixed(0),
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          Text(
            isOver ? 'Kkal Lebih' : 'Kkal Tersisa',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          Text(
            '${consumed.toStringAsFixed(0)} / ${target.toStringAsFixed(0)}',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.primaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
