import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../helpers/app_colors.dart';
import '../auth/auth_controller.dart';
import '../auth/models/user_model.dart';
import '../food/food_controller.dart';
import '../food/food_list_view.dart';
import '../../services/theme_service.dart';
import '../shared/widgets/nt_button.dart';
import '../shared/widgets/nt_text_field.dart';
import '../auth/login_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final theme = context.watch<ThemeService>();
    final user = auth.currentUser!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.5), width: 2),
                        ),
                        child: Center(
                          child: Text(user.name[0].toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              )),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(user.name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )),
                      Text(user.email,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                          )),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _roleLabel(user.role),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ─── Stats ───
                  if (user.role == 'user') ...[
                    Row(
                      children: [
                        _statCard(
                          context,
                          icon: Icons.monitor_weight_outlined,
                          label: 'BB',
                          value: '${user.weight?.toStringAsFixed(0) ?? '-'} kg',
                          isDark: isDark,
                        ),
                        const SizedBox(width: 10),
                        _statCard(
                          context,
                          icon: Icons.height_rounded,
                          label: 'TB',
                          value: '${user.height?.toStringAsFixed(0) ?? '-'} cm',
                          isDark: isDark,
                        ),
                        const SizedBox(width: 10),
                        _statCard(
                          context,
                          icon: Icons.local_fire_department_rounded,
                          label: 'Target',
                          value:
                              '${user.dailyCalorieNeed?.toStringAsFixed(0) ?? '-'} kkal',
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ─── Menu items ───
                  _section(
                    context,
                    isDark: isDark,
                    title: 'Akun',
                    items: [
                      _menuItem(
                        context,
                        icon: Icons.person_outline_rounded,
                        label: 'Edit Profil',
                        isDark: isDark,
                        onTap: () => _showEditProfile(context, user),
                      ),
                      _menuItem(
                        context,
                        icon: Icons.bookmark_outline_rounded,
                        label: 'Watchlist Makanan',
                        isDark: isDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FoodListView()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _section(
                    context,
                    isDark: isDark,
                    title: 'Tampilan',
                    items: [
                      _menuItem(
                        context,
                        icon: isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        label:
                            isDark ? 'Mode Terang' : 'Mode Gelap',
                        isDark: isDark,
                        trailing: Switch(
                          value: isDark,
                          onChanged: (_) => theme.toggleTheme(),
                          activeColor: AppColors.primaryLight,
                        ),
                        onTap: () => theme.toggleTheme(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _section(
                    context,
                    isDark: isDark,
                    title: 'Lainnya',
                    items: [
                      _menuItem(
                        context,
                        icon: Icons.info_outline_rounded,
                        label: 'Tentang NutriTrack',
                        isDark: isDark,
                        onTap: () => _showAbout(context),
                      ),
                      _menuItem(
                        context,
                        icon: Icons.logout_rounded,
                        label: 'Keluar',
                        isDark: isDark,
                        color: AppColors.error,
                        onTap: () => _confirmLogout(context, auth),
                      ),
                    ],
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

  Widget _statCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightDivider),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                )),
            Text(label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                )),
          ],
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required bool isDark,
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryLight,
                letterSpacing: 0.5,
              )),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightDivider),
          ),
          child: Column(
            children: items
                .asMap()
                .entries
                .map((e) => Column(
                      children: [
                        e.value,
                        if (e.key < items.length - 1)
                          Divider(
                            height: 1,
                            indent: 52,
                            color: isDark
                                ? AppColors.darkDivider
                                : AppColors.lightDivider,
                          ),
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
    Color? color,
    Widget? trailing,
  }) {
    final c = color ??
        (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: (color ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color ?? AppColors.primary, size: 20),
      ),
      title: Text(label,
          style: GoogleFonts.poppins(fontSize: 14, color: c)),
      trailing: trailing ??
          Icon(Icons.chevron_right_rounded,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin': return '👑 Administrator';
      case 'nutritionist': return '🩺 Ahli Gizi';
      default: return '👤 Pengguna';
    }
  }

  Future<void> _showEditProfile(BuildContext context, UserModel user) async {
    final nameCtrl = TextEditingController(text: user.name);
    final weightCtrl = TextEditingController(
        text: user.weight?.toStringAsFixed(0) ?? '');
    final heightCtrl = TextEditingController(
        text: user.height?.toStringAsFixed(0) ?? '');
    final auth = context.read<AuthController>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit Profil',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
            const SizedBox(height: 20),
            NtTextField(label: 'Nama', hint: user.name, controller: nameCtrl,
                prefixIcon: Icons.person_outline_rounded),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: NtTextField(
                      label: 'BB (kg)', hint: 'kg', controller: weightCtrl,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.monitor_weight_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NtTextField(
                      label: 'TB (cm)', hint: 'cm', controller: heightCtrl,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.height_rounded),
                ),
              ],
            ),
            const SizedBox(height: 24),
            NtButton(
              label: 'Simpan',
              onPressed: () async {
                user.name = nameCtrl.text.trim();
                if (weightCtrl.text.isNotEmpty) {
                  user.weight = double.tryParse(weightCtrl.text);
                }
                if (heightCtrl.text.isNotEmpty) {
                  user.height = double.tryParse(heightCtrl.text);
                }
                await auth.updateProfile(user);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(
      BuildContext context, AuthController auth) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Keluar', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Yakin ingin keluar dari akun?',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Keluar',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true) {
      await auth.logout();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginView()),
          (_) => false,
        );
      }
    }
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.eco_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('NutriTrack', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'NutriTrack v1.0.0\n\nAplikasi pelacak nutrisi dan kalori harian berbasis Hive (offline-first).\n\nFitur:\n• Dashboard kalori harian\n• Scan makanan (YOLO)\n• Database makanan Indonesia\n• Manajemen multi-peran\n• Pengajuan makanan ke ahli gizi',
          style: GoogleFonts.poppins(fontSize: 13, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          )
        ],
      ),
    );
  }
}
