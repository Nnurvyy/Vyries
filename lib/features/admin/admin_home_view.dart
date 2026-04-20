import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../helpers/app_colors.dart';
import 'admin_controller.dart';
import '../auth/auth_controller.dart';

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    final auth = context.watch<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor:
                isDark ? AppColors.darkSurface : AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: isDark
                    ? BoxDecoration(color: AppColors.darkSurface)
                    : const BoxDecoration(gradient: AppColors.headerGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Admin Panel',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                        Text(
                          'Selamat datang, ${auth.currentUser?.name ?? "-"}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Stats Grid ───
                  Text('Ringkasan',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      )),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _statCard(
                        isDark: isDark,
                        icon: Icons.group_rounded,
                        label: 'Total Pengguna',
                        value: admin.totalUsers.toString(),
                        color: AppColors.info,
                      ),
                      _statCard(
                        isDark: isDark,
                        icon: Icons.restaurant_menu_rounded,
                        label: 'Total Makanan',
                        value: admin.totalFoods.toString(),
                        color: AppColors.primary,
                      ),
                      _statCard(
                        isDark: isDark,
                        icon: Icons.hourglass_empty_rounded,
                        label: 'Pengajuan Pending',
                        value: admin.pendingCount.toString(),
                        color: AppColors.warning,
                      ),
                      _statCard(
                        isDark: isDark,
                        icon: Icons.science_rounded,
                        label: 'Menunggu Konfirmasi',
                        value: admin.nutritionFilledCount.toString(),
                        color: AppColors.statusFilled,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ─── Recent submissions ───
                  Text('Pengajuan Terbaru',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      )),
                  const SizedBox(height: 12),

                  if (admin.allSubmissions.isEmpty)
                    Center(
                      child: Text('Tidak ada pengajuan',
                          style: GoogleFonts.poppins(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary)),
                    )
                  else
                    ...admin.allSubmissions.take(5).map(
                      (rec) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightDivider),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.fastfood_rounded,
                                  color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(rec.foodName ?? 'Tanpa Nama (Foto)',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                      )),
                                  Text('oleh ${rec.userName}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                      )),
                                ],
                              ),
                            ),
                            _statusChip(rec.status),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required bool isDark,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : color.withOpacity(0.2)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: color.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(value,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              )),
          Text(label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              )),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'pending': color = AppColors.statusPending; label = 'Pending'; break;
      case 'forwarded': color = AppColors.statusForwarded; label = 'Diteruskan'; break;
      case 'rejected': color = AppColors.statusRejected; label = 'Ditolak'; break;
      case 'nutrition_filled': color = AppColors.statusFilled; label = 'Terisi'; break;
      case 'approved': color = AppColors.statusApproved; label = 'Disetujui'; break;
      default: color = Colors.grey; label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: GoogleFonts.poppins(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
