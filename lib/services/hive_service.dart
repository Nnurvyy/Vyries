import 'package:hive_flutter/hive_flutter.dart';
import '../features/auth/models/user_model.dart';
import '../features/food/models/food_model.dart';
import '../features/history/models/history_model.dart';
import '../features/recommendation/models/recommendation_model.dart';

class HiveService {
  static const String userBox = 'users';
  static const String foodBox = 'foods';
  static const String historyBox = 'histories';
  static const String recommendationBox = 'recommendations';
  static const String settingsBox = 'settings';

  static Future<void> initBoxes() async {
    await Hive.openBox<UserModel>(userBox);
    await Hive.openBox<FoodModel>(foodBox);
    await Hive.openBox<HistoryModel>(historyBox);
    await Hive.openBox<RecommendationModel>(recommendationBox);
    await Hive.openBox(settingsBox);
  }

  static Box<UserModel> get users => Hive.box<UserModel>(userBox);
  static Box<FoodModel> get foods => Hive.box<FoodModel>(foodBox);
  static Box<HistoryModel> get histories => Hive.box<HistoryModel>(historyBox);
  static Box<RecommendationModel> get recommendations =>
      Hive.box<RecommendationModel>(recommendationBox);
  static Box get settings => Hive.box(settingsBox);
}
