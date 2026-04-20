import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../helpers/app_colors.dart';
import '../recommendation/recommendation_controller.dart';
import '../recommendation/models/recommendation_model.dart';
import '../shared/widgets/status_badge.dart';

class SubmissionManagementView extends StatefulWidget {
  const SubmissionManagementView({super.key});

  @override
  State<SubmissionManagementView> createState() =>
      _SubmissionManagementViewState();
}

class _SubmissionManagementViewState
    extends State<SubmissionManagementView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendationController>().loadAll();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rec = context.watch<RecommendationController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Kelola Pengajuan'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: GoogleFonts.poppins(
              fontSize: 12, fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: 'Pending (${rec.pending.length})'),
            Tab(text: 'Terisi (${rec.nutritionFilled.length})'),
            Tab(text: 'Semua (${rec.all.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildList(context, rec.pending, 'pending', isDark),
          _buildList(context, rec.nutritionFilled, 'filled', isDark),
          _buildList(context, rec.all, 'all', isDark),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<RecommendationModel> items,
    String mode,
    bool isDark,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Text('Tidak ada data',
            style: GoogleFonts.poppins(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) => _recCard(context, items[i], mode, isDark),
    );
  }

  Widget _recCard(
    BuildContext context,
    RecommendationModel rec,
    String mode,
    bool isDark,
  ) {
    final recCtrl = context.read<RecommendationController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(rec.foodName ?? 'Tanpa Nama (Foto)',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    )),
              ),
              StatusBadge(status: rec.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Diajukan oleh: ${rec.userName}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          if (rec.foodCategory != null)
            Text('Kategori: ${rec.foodCategory}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                )),
          Text(
            '📅 ${DateFormat('d MMM yyyy, HH:mm', 'id').format(rec.submittedAt)}',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),

          // Nutrition filled data
          if (rec.isNutritionFilled || rec.isApproved) ...[
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _nutriStat('Kalori', '${rec.calories?.toStringAsFixed(0)} kkal',
                    AppColors.calorieColor),
                _nutriStat('Protein', '${rec.protein?.toStringAsFixed(1)}g',
                    AppColors.proteinColor),
                _nutriStat('Karbo', '${rec.carbs?.toStringAsFixed(1)}g',
                    AppColors.carbsColor),
                _nutriStat('Lemak', '${rec.fat?.toStringAsFixed(1)}g',
                    AppColors.fatColor),
              ],
            ),
          ],

          // Action buttons
          if (rec.isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectDialog(context, rec, recCtrl),
                    icon: const Icon(Icons.cancel_outlined, size: 16),
                    label: const Text('Tolak'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      textStyle: GoogleFonts.poppins(fontSize: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveDialog(context, rec, recCtrl),
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Teruskan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      textStyle: GoogleFonts.poppins(fontSize: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (rec.isNutritionFilled) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    _finalApprove(context, rec, recCtrl),
                icon: const Icon(Icons.check_circle_rounded, size: 16),
                label: const Text('Setujui & Publikasi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  textStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _nutriStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Future<void> _approveDialog(BuildContext context,
      RecommendationModel rec, RecommendationController recCtrl) async {
    final notesCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Teruskan ke Ahli Gizi?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pengajuan "${rec.foodName ?? 'Tanpa Nama'}" akan diteruskan ke ahli gizi untuk diisi nutrisinya.',
                style: GoogleFonts.poppins(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: InputDecoration(
                hintText: 'Catatan (opsional)',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Teruskan',
                  style: TextStyle(color: AppColors.primary))),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await recCtrl.approveByAdmin(rec.id, notes: notesCtrl.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengajuan diteruskan ke ahli gizi'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _rejectDialog(BuildContext context,
      RecommendationModel rec, RecommendationController recCtrl) async {
    final reasonCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Tolak Pengajuan?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pengajuan "${rec.foodName ?? 'Tanpa Nama'}" akan ditolak.',
                style: GoogleFonts.poppins(fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: InputDecoration(
                hintText: 'Alasan penolakan (wajib)',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Tolak',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await recCtrl.rejectByAdmin(rec.id, reason: reasonCtrl.text.trim());
    }
  }

  Future<void> _finalApprove(BuildContext context,
      RecommendationModel rec, RecommendationController recCtrl) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Setujui Makanan?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          '${rec.foodName ?? 'Makanan ini'} akan ditambahkan ke database makanan dan dapat digunakan semua pengguna.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Setujui',
                  style: TextStyle(color: AppColors.primary))),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await recCtrl.finalApproveByAdmin(rec.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${rec.foodName ?? 'Makanan'} berhasil dipublikasikan!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
