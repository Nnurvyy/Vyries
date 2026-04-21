import 'package:flutter/material.dart';
import '../../services/hive_service.dart';
import 'models/watchlist_model.dart';

class WatchlistController extends ChangeNotifier {
  String? _userId;
  List<String> _foodIds = [];

  List<String> get foodIds => _foodIds;

  void updateUser(String? userId) {
    if (_userId != userId) {
      _userId = userId;
      _loadWatchlist();
    }
  }

  void _loadWatchlist() {
    if (_userId == null) {
      _foodIds = [];
    } else {
      final doc = HiveService.watchlists.get(_userId);
      _foodIds = doc?.foodIds ?? [];
    }
    notifyListeners();
  }

  Future<void> toggleWatchlist(String foodId) async {
    if (_userId == null) return;
    
    // Create new list to ensure reference changes
    final List<String> newList = List.from(_foodIds);
    if (newList.contains(foodId)) {
      newList.remove(foodId);
    } else {
      newList.add(foodId);
    }
    
    _foodIds = newList;
    
    final doc = WatchlistModel(id: _userId!, foodIds: _foodIds);
    await HiveService.watchlists.put(_userId!, doc);
    notifyListeners();
  }

  bool isInWatchlist(String foodId) {
    return _foodIds.contains(foodId);
  }
}
