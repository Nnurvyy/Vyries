import 'package:flutter/material.dart';
import 'models/recommendation_model.dart';
import '../../services/hive_service.dart';
import '../food/models/food_model.dart';

class RecommendationController extends ChangeNotifier {
  List<RecommendationModel> _all = [];

  List<RecommendationModel> get all => _all;
  List<RecommendationModel> get pending =>
      _all.where((r) => r.status == 'pending').toList();
  List<RecommendationModel> get forwarded =>
      _all.where((r) => r.status == 'forwarded').toList();
  List<RecommendationModel> get nutritionFilled =>
      _all.where((r) => r.status == 'nutrition_filled').toList();

  void loadAll() {
    _all = HiveService.recommendations.values
        .cast<RecommendationModel>()
        .toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    notifyListeners();
  }

  List<RecommendationModel> forUser(String userId) =>
      _all.where((r) => r.userId == userId).toList();

  Future<void> submitRecommendation({
    required String userId,
    required String userName,
    String? foodName,
    String? foodCategory,
    String? imageUrl,
  }) async {
    final id = 'rec_${DateTime.now().millisecondsSinceEpoch}';
    final rec = RecommendationModel(
      id: id,
      userId: userId,
      userName: userName,
      foodName: foodName,
      foodCategory: foodCategory,
      imageUrl: imageUrl,
      submittedAt: DateTime.now(),
      status: 'pending',
    );
    await HiveService.recommendations.put(id, rec);
    loadAll();
  }

  Future<void> approveByAdmin(String id, {String? notes}) async {
    final rec = HiveService.recommendations.get(id) as RecommendationModel?;
    if (rec == null) return;
    rec.status = 'forwarded';
    rec.adminNotes = notes;
    rec.reviewedAt = DateTime.now();
    await HiveService.recommendations.put(id, rec);
    loadAll();
  }

  Future<void> rejectByAdmin(String id, {String? reason}) async {
    final rec = HiveService.recommendations.get(id) as RecommendationModel?;
    if (rec == null) return;
    rec.status = 'rejected';
    rec.adminNotes = reason;
    rec.reviewedAt = DateTime.now();
    await HiveService.recommendations.put(id, rec);
    loadAll();
  }

  Future<void> finalApproveByAdmin(String id) async {
    final rec = HiveService.recommendations.get(id) as RecommendationModel?;
    if (rec == null || rec.status != 'nutrition_filled') return;
    rec.status = 'approved';
    rec.reviewedAt = DateTime.now();
    await HiveService.recommendations.put(id, rec);

    if (rec.calories != null) {
      final foodId = 'food_${DateTime.now().millisecondsSinceEpoch}';
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
      );
      await HiveService.foods.put(foodId, food);
    }
    loadAll();
  }

  Future<void> fillNutrition({
    required String recId,
    required String nutritionistId,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    String? notes,
  }) async {
    final rec = HiveService.recommendations.get(recId) as RecommendationModel?;
    if (rec == null) return;
    rec.status = 'nutrition_filled';
    rec.nutritionistId = nutritionistId;
    rec.calories = calories;
    rec.protein = protein;
    rec.carbs = carbs;
    rec.fat = fat;
    rec.nutritionistNotes = notes;
    rec.nutritionFilledAt = DateTime.now();
    await HiveService.recommendations.put(recId, rec);
    loadAll();
  }
}
