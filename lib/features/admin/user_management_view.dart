import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../helpers/app_colors.dart';
import 'admin_controller.dart';
import '../auth/models/user_model.dart';

class UserManagementView extends StatelessWidget {
  const UserManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Kelola Pengguna'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${admin.users.length} user',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body:
          admin.users.isEmpty
              ? Center(
                child: Text(
                  'Tidak ada pengguna',
                  style: GoogleFonts.poppins(
                    color:
                        isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                  ),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: admin.users.length,
                itemBuilder:
                    (_, i) => _userCard(context, admin.users[i], admin, isDark),
              ),
    );
  }

  Widget _userCard(
    BuildContext context,
    UserModel user,
    AdminController admin,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              user.isBlocked
                  ? AppColors.error.withOpacity(0.3)
                  : isDark
                  ? AppColors.darkBorder
                  : AppColors.lightDivider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color:
                      user.isBlocked
                          ? AppColors.error.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:
                          user.isBlocked ? AppColors.error : AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.name,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                          ),
                        ),
                        if (user.isBlocked) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'DIBLOKIR',
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      user.email,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color:
                            isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoBadge(
                '${user.weight ?? '-'} kg',
                Icons.monitor_weight_outlined,
                isDark,
              ),
              const SizedBox(width: 8),
              _infoBadge(
                '${user.height ?? '-'} cm',
                Icons.height_rounded,
                isDark,
              ),
              const SizedBox(width: 8),
              _infoBadge('${user.age ?? '-'} thn', Icons.cake_outlined, isDark),
            ],
          ),
          if (user.dailyCalorieNeed != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                _infoBadge(
                  '${user.dailyCalorieNeed!.toStringAsFixed(0)} kkal/hari',
                  Icons.local_fire_department_rounded,
                  isDark,
                ),
              ],
            ),
          ],
          if (user.medicalHistory != null &&
              user.medicalHistory!.isNotEmpty &&
              user.medicalHistory != 'Tidak ada') ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.medical_information_outlined,
                    size: 14,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      user.medicalHistory!,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmBlock(context, user, admin),
                  icon: Icon(
                    user.isBlocked
                        ? Icons.lock_open_rounded
                        : Icons.block_rounded,
                    size: 16,
                  ),
                  label: Text(user.isBlocked ? 'Buka Blokir' : 'Blokir'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        user.isBlocked ? AppColors.primary : AppColors.error,
                    side: BorderSide(
                      color:
                          user.isBlocked ? AppColors.primary : AppColors.error,
                    ),
                    textStyle: GoogleFonts.poppins(fontSize: 12),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context, user, admin),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: const Text('Hapus'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    textStyle: GoogleFonts.poppins(fontSize: 12),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBadge(String text, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightDivider,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primaryLight),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmBlock(
    BuildContext context,
    UserModel user,
    AdminController admin,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              user.isBlocked ? 'Buka Blokir Pengguna?' : 'Blokir Pengguna?',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              '${user.isBlocked ? "Buka blokir" : "Blokir"} akun ${user.name}?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  user.isBlocked ? 'Buka Blokir' : 'Blokir',
                  style: TextStyle(
                    color: user.isBlocked ? AppColors.primary : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
    );
    if (ok == true && context.mounted) {
      admin.toggleUserBlock(user.id);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    UserModel user,
    AdminController admin,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              'Hapus Pengguna?',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Hapus akun ${user.name} secara permanen?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
    if (ok == true && context.mounted) {
      admin.deleteUser(user.id);
    }
  }
}
