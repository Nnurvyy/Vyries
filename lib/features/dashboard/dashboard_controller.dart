import 'package:flutter/material.dart';
import '../history/models/history_model.dart';
import '../../services/hive_service.dart';

class DashboardController extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  List<HistoryModel> _todayHistory = [];

  DateTime get selectedDate => _selectedDate;
  List<HistoryModel> get todayHistory => _todayHistory;

  void loadForDate(String userId, DateTime date) {
    _selectedDate = date;
    _todayHistory = HiveService.histories.values
        .where((h) =>
            h.userId == userId &&
            h.date.year == date.year &&
            h.date.month == date.month &&
            h.date.day == date.day)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  double get totalCaloriesConsumed =>
      _todayHistory.fold(0, (sum, h) => sum + h.totalCalories);
  double get totalProteinConsumed =>
      _todayHistory.fold(0, (sum, h) => sum + h.totalProtein);
  double get totalCarbsConsumed =>
      _todayHistory.fold(0, (sum, h) => sum + h.totalCarbs);
  double get totalFatConsumed =>
      _todayHistory.fold(0, (sum, h) => sum + h.totalFat);

  double caloriesLeft(double dailyTarget) =>
      (dailyTarget - totalCaloriesConsumed).clamp(0, dailyTarget);
  double proteinLeft(double target) =>
      (target - totalProteinConsumed).clamp(0, target);
  double carbsLeft(double target) =>
      (target - totalCarbsConsumed).clamp(0, target);
  double fatLeft(double target) =>
      (target - totalFatConsumed).clamp(0, target);

  double calorieProgress(double dailyTarget) =>
      dailyTarget > 0 ? (totalCaloriesConsumed / dailyTarget).clamp(0, 1) : 0;
}
