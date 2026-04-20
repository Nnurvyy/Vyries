import 'package:flutter/material.dart';
import '../auth/models/user_model.dart';
import '../food/models/food_model.dart';
import '../recommendation/models/recommendation_model.dart';
import '../../services/hive_service.dart';

class AdminController extends ChangeNotifier {
  List<UserModel> _users = [];
  List<FoodModel> _foods = [];
  List<RecommendationModel> _recommendations = [];

  List<UserModel> get users =>
      _users.where((u) => u.role == 'user').toList();
  List<FoodModel> get foods => _foods;
  List<RecommendationModel> get pendingSubmissions =>
      _recommendations.where((r) => r.status == 'pending').toList();
  List<RecommendationModel> get allSubmissions => _recommendations;

  int get totalUsers => _users.where((u) => u.role == 'user').length;
  int get pendingCount => pendingSubmissions.length;
  int get totalFoods => _foods.where((f) => f.isApproved).length;
  int get nutritionFilledCount =>
      _recommendations.where((r) => r.status == 'nutrition_filled').length;

  void loadAll() {
    _users = HiveService.users.values.cast<UserModel>().toList();
    _foods = HiveService.foods.values.cast<FoodModel>().toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    _recommendations = HiveService.recommendations.values.cast<RecommendationModel>().toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    notifyListeners();
  }

  Future<void> toggleUserBlock(String userId) async {
    final user = HiveService.users.get(userId);
    if (user == null) return;
    user.isBlocked = !user.isBlocked;
    await HiveService.users.put(userId, user);
    loadAll();
  }

  Future<void> deleteUser(String userId) async {
    await HiveService.users.delete(userId);
    loadAll();
  }

  Future<void> addFood(FoodModel food) async {
    await HiveService.foods.put(food.id, food);
    loadAll();
  }

  Future<void> updateFood(FoodModel food) async {
    await HiveService.foods.put(food.id, food);
    loadAll();
  }

  Future<void> deleteFood(String id) async {
    await HiveService.foods.delete(id);
    loadAll();
  }
}
