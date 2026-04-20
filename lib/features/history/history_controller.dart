import 'package:flutter/material.dart';
import 'models/history_model.dart';
import '../food/models/food_model.dart';
import '../../services/hive_service.dart';

class HistoryController extends ChangeNotifier {
  List<HistoryModel> _userHistory = [];

  List<HistoryModel> get userHistory => _userHistory;

  void loadHistory(String userId) {
    _userHistory = HiveService.histories.values
        .cast<HistoryModel>()
        .where((h) => h.userId == userId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  List<HistoryModel> forDate(DateTime date) {
    return _userHistory
        .where((h) =>
            h.date.year == date.year &&
            h.date.month == date.month &&
            h.date.day == date.day)
        .toList();
  }

  Future<void> addEntry({
    required String userId,
    required FoodModel food,
    required double amount,
    int quantity = 1,
    required String mealType,
  }) async {
    final nutrients = food.nutritionForAmount(amount);
    final id = 'hist_${DateTime.now().millisecondsSinceEpoch}';

    final entry = HistoryModel(
      id: id,
      userId: userId,
      foodId: food.id,
      foodName: food.name,
      amount: amount,
      quantity: quantity,
      totalCalories: nutrients['calories']! * quantity,
      totalProtein: nutrients['protein']! * quantity,
      totalCarbs: nutrients['carbs']! * quantity,
      totalFat: nutrients['fat']! * quantity,
      date: DateTime.now(),
      mealType: mealType,
    );

    await HiveService.histories.put(id, entry);
    loadHistory(userId);
  }

  Future<void> deleteEntry(String id, String userId) async {
    await HiveService.histories.delete(id);
    loadHistory(userId);
  }

  Map<String, double> weeklyCalories(String userId) {
    final now = DateTime.now();
    final result = <String, double>{};
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = '${day.day}/${day.month}';
      final total = HiveService.histories.values
          .cast<HistoryModel>()
          .where((h) =>
              h.userId == userId &&
              h.date.year == day.year &&
              h.date.month == day.month &&
              h.date.day == day.day)
          .fold<double>(0, (sum, h) => sum + h.totalCalories);
      result[key] = total;
    }
    return result;
  }
}
