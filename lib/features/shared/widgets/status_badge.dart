import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../helpers/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  static String label(String status) {
    switch (status) {
      case 'pending': return 'Menunggu';
      case 'forwarded': return 'Diteruskan';
      case 'rejected': return 'Ditolak';
      case 'nutrition_filled': return 'Nutrisi Terisi';
      case 'approved': return 'Disetujui';
      default: return status;
    }
  }

  static Color color(String status) {
    switch (status) {
      case 'pending': return AppColors.statusPending;
      case 'forwarded': return AppColors.statusForwarded;
      case 'rejected': return AppColors.statusRejected;
      case 'nutrition_filled': return AppColors.statusFilled;
      case 'approved': return AppColors.statusApproved;
      default: return Colors.grey;
    }
  }

  static IconData icon(String status) {
    switch (status) {
      case 'pending': return Icons.hourglass_empty_rounded;
      case 'forwarded': return Icons.send_rounded;
      case 'rejected': return Icons.cancel_rounded;
      case 'nutrition_filled': return Icons.science_rounded;
      case 'approved': return Icons.check_circle_rounded;
      default: return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon(status), size: 12, color: c),
          const SizedBox(width: 4),
          Text(
            label(status),
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}
