import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../helpers/app_colors.dart';
import 'admin_controller.dart';
import '../food/models/food_model.dart';
import '../shared/widgets/nt_text_field.dart';
import '../shared/widgets/nt_button.dart';
import '../food/food_controller.dart';

class FoodManagementView extends StatefulWidget {
  const FoodManagementView({super.key});

  @override
  State<FoodManagementView> createState() => _FoodManagementViewState();
}

class _FoodManagementViewState extends State<FoodManagementView> {
  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Kelola Makanan'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            onPressed: () => _showFoodForm(context, admin, null),
          ),
        ],
      ),
      body: admin.foods.isEmpty
          ? Center(
              child: Text('Tidak ada data makanan',
                  style: GoogleFonts.poppins(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: admin.foods.length,
              itemBuilder: (_, i) =>
                  _foodCard(context, admin.foods[i], admin, isDark),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_food_mgmt',
        onPressed: () => _showFoodForm(context, admin, null),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _foodCard(
    BuildContext context,
    FoodModel food,
    AdminController admin,
    bool isDark,
  ) {
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(food.name[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLight,
                  )),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    )),
                Text('${food.category} · ${food.calories.toStringAsFixed(0)} kkal',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    )),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_rounded,
                    color: AppColors.info, size: 20),
                onPressed: () => _showFoodForm(context, admin, food),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error, size: 20),
                onPressed: () => _confirmDelete(context, food, admin),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showFoodForm(
    BuildContext context,
    AdminController admin,
    FoodModel? existing,
  ) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final calCtrl = TextEditingController(
        text: existing?.calories.toString() ?? '');
    final proteinCtrl = TextEditingController(
        text: existing?.protein.toString() ?? '');
    final carbsCtrl = TextEditingController(
        text: existing?.carbs.toString() ?? '');
    final fatCtrl = TextEditingController(
        text: existing?.fat.toString() ?? '');
    String selectedCat = existing?.category ?? 'Makanan Pokok';
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(existing == null ? 'Tambah Makanan' : 'Edit Makanan',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                  const SizedBox(height: 16),
                  NtTextField(
                    label: 'Nama Makanan',
                    hint: 'Nama makanan',
                    controller: nameCtrl,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  Text('Kategori',
                      style: GoogleFonts.poppins(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedCat,
                    items: FoodController.categories
                        .where((c) => c != 'Semua')
                        .map((c) => DropdownMenuItem(
                            value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setS(() => selectedCat = v!),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.lightBorder)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.lightBorder)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Nutrisi per 100g',
                      style: GoogleFonts.poppins(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: NtTextField(
                          label: 'Kalori (kkal)',
                          hint: '0',
                          controller: calCtrl,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Wajib' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: NtTextField(
                          label: 'Protein (g)',
                          hint: '0',
                          controller: proteinCtrl,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Wajib' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: NtTextField(
                          label: 'Karbo (g)',
                          hint: '0',
                          controller: carbsCtrl,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Wajib' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: NtTextField(
                          label: 'Lemak (g)',
                          hint: '0',
                          controller: fatCtrl,
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Wajib' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  NtButton(
                    label: existing == null ? 'Tambah' : 'Simpan',
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final food = FoodModel(
                        id: existing?.id ??
                            'food_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameCtrl.text.trim(),
                        category: selectedCat,
                        calories: double.tryParse(calCtrl.text) ?? 0,
                        protein: double.tryParse(proteinCtrl.text) ?? 0,
                        carbs: double.tryParse(carbsCtrl.text) ?? 0,
                        fat: double.tryParse(fatCtrl.text) ?? 0,
                        isApproved: true,
                        createdAt: existing?.createdAt ?? DateTime.now(),
                      );
                      if (existing == null) {
                        await admin.addFood(food);
                      } else {
                        await admin.updateFood(food);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    FoodModel food,
    AdminController admin,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Hapus Makanan?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Hapus "${food.name}" dari database?',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      admin.deleteFood(food.id);
    }
  }
}
