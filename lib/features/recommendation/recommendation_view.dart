import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../helpers/app_colors.dart';
import '../auth/auth_controller.dart';
import 'recommendation_controller.dart';
import 'models/recommendation_model.dart';
import '../shared/widgets/status_badge.dart';
import '../shared/widgets/nt_button.dart';
import '../shared/widgets/nt_text_field.dart';

class RecommendationView extends StatefulWidget {
  const RecommendationView({super.key});

  @override
  State<RecommendationView> createState() => _RecommendationViewState();
}

class _RecommendationViewState extends State<RecommendationView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendationController>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rec = context.watch<RecommendationController>();
    final auth = context.watch<AuthController>();
    final user = auth.currentUser!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final myRecs = rec.forUser(user.id);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Pengajuan Makanan'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            onPressed: () => _showSubmitDialog(context, user.id, user.name),
          ),
        ],
      ),
      body: myRecs.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64,
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder),
                  const SizedBox(height: 12),
                  Text('Belum ada pengajuan',
                      style: GoogleFonts.poppins(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary)),
                  const SizedBox(height: 20),
                  NtButton(
                    label: '+ Ajukan Makanan',
                    width: 200,
                    onPressed: () =>
                        _showSubmitDialog(context, user.id, user.name),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: myRecs.length,
              itemBuilder: (_, i) => _recCard(myRecs[i], isDark),
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_recommendation', // Unique tag to avoid crash
        onPressed: () => _showSubmitDialog(context, user.id, user.name),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Ajukan Makanan',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _recCard(RecommendationModel rec, bool isDark) {
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
              if (rec.imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(rec.imageUrl!),
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
              ],
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
          const SizedBox(height: 8),
          Text(
            '📅 ${DateFormat('d MMM yyyy', 'id').format(rec.submittedAt)}',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          if (rec.adminNotes != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (rec.isRejected ? AppColors.error : AppColors.info)
                    .withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    rec.isRejected ? Icons.info_outline : Icons.message_outlined,
                    size: 14,
                    color: rec.isRejected ? AppColors.error : AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(rec.adminNotes!,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: rec.isRejected ? AppColors.error : AppColors.info,
                        )),
                  ),
                ],
              ),
            ),
          ],
          if (rec.isApproved && rec.calories != null) ...[
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _resultNutri('Kalori', '${rec.calories!.toStringAsFixed(0)} kkal',
                    AppColors.calorieColor),
                _resultNutri('Protein', '${rec.protein!.toStringAsFixed(1)}g',
                    AppColors.proteinColor),
                _resultNutri('Karbo', '${rec.carbs!.toStringAsFixed(1)}g',
                    AppColors.carbsColor),
                _resultNutri('Lemak', '${rec.fat!.toStringAsFixed(1)}g',
                    AppColors.fatColor),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _resultNutri(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color)),
        Text(label,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Future<void> _showSubmitDialog(
      BuildContext context, String userId, String userName) async {
    final nameCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final recCtrl = context.read<RecommendationController>();
    File? selectedImage;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
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
                const SizedBox(height: 20),
                Text('Ajukan Makanan Baru',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
                const SizedBox(height: 4),
                Text(
                  'Upload foto makanan agar ahli gizi dapat mengidentifikasi\ndan mengisi nutrisinya.',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey, height: 1.5),
                ),
                const SizedBox(height: 24),
                
                // ─── Image Picker ───
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      setModalState(() => selectedImage = File(picked.path));
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
                    ),
                    child: selectedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo_rounded, size: 32, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text('Upload Foto Makanan', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(selectedImage!, fit: BoxFit.cover),
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),
                NtTextField(
                  label: 'Nama Makanan (Opsional)',
                  hint: 'Masukkan nama jika tahu',
                  controller: nameCtrl,
                  prefixIcon: Icons.fastfood_rounded,
                ),
                const SizedBox(height: 32),
                NtButton(
                  label: 'Kirim Pengajuan',
                  onPressed: () async {
                    if (selectedImage == null && nameCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Upload foto atau isi nama makanan')),
                      );
                      return;
                    }
                    
                    await recCtrl.submitRecommendation(
                      userId: userId,
                      userName: userName,
                      foodName: nameCtrl.text.trim().isEmpty ? null : nameCtrl.text.trim(),
                      imageUrl: selectedImage?.path,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pengajuan berhasil dikirim!'),
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
