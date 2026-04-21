import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../helpers/app_colors.dart';
import 'nutritionist_controller.dart';
import '../auth/auth_controller.dart';
import '../recommendation/models/recommendation_model.dart';
import '../shared/widgets/status_badge.dart';
import '../shared/widgets/nt_button.dart';
import '../shared/widgets/nt_text_field.dart';

class NutritionistTasksView extends StatefulWidget {
  const NutritionistTasksView({super.key});

  @override
  State<NutritionistTasksView> createState() => _NutritionistTasksViewState();
}

class _NutritionistTasksViewState extends State<NutritionistTasksView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthController>().currentUser?.id ?? '';
      context.read<NutritionistController>().loadTasks(userId);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<NutritionistController>();
    final auth = context.watch<AuthController>();
    final user = auth.currentUser!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Daftar Tugas Ahli Gizi'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: GoogleFonts.poppins(
              fontSize: 12, fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: 'Tugas (${ctrl.pendingCount})'),
            Tab(text: 'Selesai (${ctrl.completedTasks.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildTaskList(context, ctrl.pendingTasks, user.id, isDark),
          _buildTaskList(context, ctrl.completedTasks, user.id, isDark,
              readOnly: true),
        ],
      ),
    );
  }

  Widget _buildTaskList(
    BuildContext context,
    List<RecommendationModel> items,
    String userId,
    bool isDark, {
    bool readOnly = false,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              readOnly
                  ? Icons.check_circle_outline_rounded
                  : Icons.inbox_outlined,
              size: 64,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            const SizedBox(height: 12),
            Text(
              readOnly ? 'Belum ada yang selesai' : 'Tidak ada tugas',
              style: GoogleFonts.poppins(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) => _taskCard(
        context, items[i], userId, isDark,
        readOnly: readOnly,
      ),
    );
  }

  Widget _taskCard(
    BuildContext context,
    RecommendationModel rec,
    String userId,
    bool isDark, {
    bool readOnly = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: readOnly
              ? AppColors.primary.withOpacity(0.3)
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (readOnly ? AppColors.primaryLight : AppColors.info)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  readOnly
                      ? Icons.check_circle_rounded
                      : Icons.science_rounded,
                  color: readOnly ? AppColors.primaryLight : AppColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rec.foodName ?? 'Tanpa Nama (Foto)',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        )),
                    Text('Diajukan oleh: ${rec.userName}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        )),
                  ],
                ),
              ),
              StatusBadge(status: rec.status),
            ],
          ),
          if (rec.foodCategory != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Kategori: ${rec.foodCategory}',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.info)),
            ),
          ],

          if (readOnly && rec.calories != null) ...[
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _nutriResult('Kalori', '${rec.calories!.toStringAsFixed(0)}kkal',
                    AppColors.calorieColor),
                _nutriResult('Protein', '${rec.protein!.toStringAsFixed(1)}g',
                    AppColors.proteinColor),
                _nutriResult('Karbo', '${rec.carbs!.toStringAsFixed(1)}g',
                    AppColors.carbsColor),
                _nutriResult('Lemak', '${rec.fat!.toStringAsFixed(1)}g',
                    AppColors.fatColor),
              ],
            ),
          ],

          if (!readOnly) ...[
            const SizedBox(height: 14),
            NtButton(
              label: 'Isi Data Nutrisi',
              icon: const Icon(Icons.edit_note_rounded,
                  color: Colors.white, size: 20),
              onPressed: () =>
                  _showFillNutritionForm(context, rec, userId),
            ),
          ],
        ],
      ),
    );
  }

  Widget _nutriResult(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Future<void> _showFillNutritionForm(
    BuildContext context,
    RecommendationModel rec,
    String userId,
  ) async {
    final calCtrl = TextEditingController();
    final proteinCtrl = TextEditingController();
    final carbsCtrl = TextEditingController();
    final fatCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final ctrl = context.read<NutritionistController>();

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
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Isi Kandungan Nutrisi',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
                Text('"${rec.foodName ?? 'Tanpa Nama'}" · per 100g',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 20),
                NtTextField(
                  label: 'Kalori (kkal/100g)',
                  hint: 'misal: 130',
                  controller: calCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.local_fire_department_rounded,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: NtTextField(
                        label: 'Protein (g)',
                        hint: '0.0',
                        controller: proteinCtrl,
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: NtTextField(
                        label: 'Karbohidrat (g)',
                        hint: '0.0',
                        controller: carbsCtrl,
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                NtTextField(
                  label: 'Lemak (g)',
                  hint: '0.0',
                  controller: fatCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.water_drop_outlined,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                NtTextField(
                  label: 'Catatan ahli gizi (opsional)',
                  hint: 'Informasi tambahan...',
                  controller: notesCtrl,
                  maxLines: 2,
                  prefixIcon: Icons.note_outlined,
                ),
                const SizedBox(height: 24),
                NtButton(
                  label: 'Kirim ke Admin',
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final ok = await ctrl.submitNutrition(
                      recId: rec.id,
                      nutritionistId: userId,
                      calories: double.tryParse(calCtrl.text) ?? 0,
                      protein: double.tryParse(proteinCtrl.text) ?? 0,
                      carbs: double.tryParse(carbsCtrl.text) ?? 0,
                      fat: double.tryParse(fatCtrl.text) ?? 0,
                      notes: notesCtrl.text.isEmpty ? null : notesCtrl.text,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data nutrisi berhasil dikirim ke admin!'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
