import 'package:flutter/material.dart';
import '../recommendation/models/recommendation_model.dart';
import '../../services/hive_service.dart';
import '../food/models/food_model.dart';

class NutritionistController extends ChangeNotifier {
  List<RecommendationModel> _tasks = [];

  /// Pengajuan yang sudah diteruskan admin (siap diisi nutrisi)
  List<RecommendationModel> get pendingTasks =>
      _tasks.where((r) => r.status == 'forwarded').toList();

  List<RecommendationModel> get completedTasks =>
      _tasks.where((r) => r.status == 'nutrition_filled' ||
                           r.status == 'approved').toList();

  int get pendingCount => pendingTasks.length;

  void loadTasks(String nutritionistId) {
    _tasks = HiveService.recommendations.values
        .cast<RecommendationModel>()
        .toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    notifyListeners();
  }

  Future<bool> submitNutrition({
    required String recId,
    required String nutritionistId,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    String? notes,
  }) async {
    final rec = HiveService.recommendations.get(recId);
    if (rec == null) return false;

    rec.status = 'nutrition_filled';
    rec.nutritionistId = nutritionistId;
    rec.calories = calories;
    rec.protein = protein;
    rec.carbs = carbs;
    rec.fat = fat;
    rec.nutritionistNotes = notes;
    rec.nutritionFilledAt = DateTime.now();
    await HiveService.recommendations.put(recId, rec);

    loadTasks(nutritionistId);
    return true;
  }

  Future<void> adminFinalApprove(String recId) async {
    final rec = HiveService.recommendations.get(recId);
    if (rec == null || rec.status != 'nutrition_filled') return;

    rec.status = 'approved';
    rec.reviewedAt = DateTime.now();
    await HiveService.recommendations.put(recId, rec);

    // Masukkan ke database makanan
    if (rec.calories != null) {
      final foodId = 'food_rec_${DateTime.now().millisecondsSinceEpoch}';
      final food = FoodModel(
        id: foodId,
        name: rec.foodName ?? 'Makanan Teridentifikasi',
        category: rec.foodCategory ?? 'Lainnya',
        calories: rec.calories!,
        protein: rec.protein ?? 0,
        carbs: rec.carbs ?? 0,
        fat: rec.fat ?? 0,
        isApproved: true,
        createdAt: DateTime.now(),
        imageUrl: rec.imageUrl,
        description: rec.nutritionistNotes,
      );
      await HiveService.foods.put(foodId, food);
    }

    loadTasks('');
    notifyListeners();
  }
}
