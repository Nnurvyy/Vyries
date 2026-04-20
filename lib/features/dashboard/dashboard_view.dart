import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../helpers/app_colors.dart';
import '../auth/auth_controller.dart';
import '../auth/models/user_model.dart';
import '../history/history_controller.dart';
import '../history/models/history_model.dart';
import 'dashboard_controller.dart';
import 'widgets/calorie_ring_widget.dart';
import 'widgets/nutrient_card_widget.dart';
import 'widgets/date_selector_widget.dart';
import '../food/food_list_view.dart';
import '../scan/scan_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      final user = auth.currentUser;
      if (user != null) {
        context.read<DashboardController>().loadForDate(user.id, DateTime.now());
        context.read<HistoryController>().loadHistory(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final dash = context.watch<DashboardController>();
    final hist = context.watch<HistoryController>();
    final user = auth.currentUser!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final macros = user.macroTargets;
    final todayHistory = hist.forDate(dash.selectedDate);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // ─── SliverAppBar ───
          SliverAppBar(
            expandedHeight: 130,
            floating: false,
            pinned: true,
            backgroundColor:
                isDark ? AppColors.darkSurface : AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: isDark
                    ? BoxDecoration(color: AppColors.darkSurface)
                    : const BoxDecoration(gradient: AppColors.headerGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _greeting(),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                user.name.split(' ').first,
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                DateFormat('EEEE, d MMMM yyyy', 'id')
                                    .format(dash.selectedDate),
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              user.name[0].toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
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
            child: Column(
              children: [
                const SizedBox(height: 16),

                // ─── Date selector ───
                DateSelectorWidget(
                  selectedDate: dash.selectedDate,
                  onDateSelected: (d) =>
                      dash.loadForDate(user.id, d),
                ),
                const SizedBox(height: 24),

                // ─── Calorie ring ───
                CalorieRingWidget(
                  consumed: dash.totalCaloriesConsumed,
                  target: user.dailyCalorieNeed ?? 2000,
                ),
                const SizedBox(height: 24),

                // ─── Nutrient cards ───
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: NutrientCard(
                          label: 'Protein',
                          consumed: dash.totalProteinConsumed,
                          target: macros['protein'] ?? 150,
                          color: AppColors.proteinColor,
                          icon: Icons.fitness_center_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NutrientCard(
                          label: 'Karbo',
                          consumed: dash.totalCarbsConsumed,
                          target: macros['carbs'] ?? 250,
                          color: AppColors.carbsColor,
                          icon: Icons.grain_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NutrientCard(
                          label: 'Lemak',
                          consumed: dash.totalFatConsumed,
                          target: macros['fat'] ?? 65,
                          color: AppColors.fatColor,
                          icon: Icons.water_drop_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ─── Quick Actions ───
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _actionCard(
                          context,
                          icon: Icons.qr_code_scanner_rounded,
                          label: 'Scan\nMakanan',
                          color: AppColors.primary,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ScanFoodView())),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _actionCard(
                          context,
                          icon: Icons.restaurant_menu_rounded,
                          label: 'Cari\nMakanan',
                          color: AppColors.info,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const FoodListView())),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ─── Today meals ───
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text('Makanan Hari Ini',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          )),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: Text('Lihat Semua',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),

                if (todayHistory.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.restaurant_outlined,
                            size: 56,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightBorder),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada makanan hari ini',
                          style: GoogleFonts.poppins(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const FoodListView())),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Tambahkan makanan'),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: todayHistory.take(5).length,
                    itemBuilder: (_, i) =>
                        _mealTile(context, todayHistory[i], isDark),
                  ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_dashboard',
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const FoodListView())),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
                  )
                ],
          border: Border.all(
              color: isDark ? AppColors.darkBorder : color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mealTile(BuildContext context, HistoryModel h, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightDivider),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.calorieColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.restaurant_rounded,
                color: AppColors.calorieColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(h.foodName,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    )),
                Text(
                  '${h.amount.toStringAsFixed(0)}g · ${h.mealType}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${h.totalCalories.toStringAsFixed(0)} kkal',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLight,
                ),
              ),
              Text(
                DateFormat('HH:mm').format(h.date),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi 🌅';
    if (hour < 15) return 'Selamat Siang ☀️';
    if (hour < 18) return 'Selamat Sore 🌤️';
    return 'Selamat Malam 🌙';
  }
}
