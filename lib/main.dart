import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'features/auth/models/user_model.dart';
import 'features/food/models/food_model.dart';
import 'features/history/models/history_model.dart';
import 'features/recommendation/models/recommendation_model.dart';
import 'features/watchlist/models/watchlist_model.dart';

import 'services/hive_service.dart';
import 'services/theme_service.dart';
import 'helpers/app_theme.dart';
import 'helpers/seed_helper.dart';

import 'features/auth/auth_controller.dart';
import 'features/food/food_controller.dart';
import 'features/history/history_controller.dart';
import 'features/recommendation/recommendation_controller.dart';
import 'features/watchlist/watchlist_controller.dart';
import 'features/admin/admin_controller.dart';
import 'features/nutritionist/nutritionist_controller.dart';
import 'features/auth/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Locale for intl (Bahasa Indonesia)
  await initializeDateFormatting('id', null);

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters (manual, no build_runner needed)
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(FoodModelAdapter());
  Hive.registerAdapter(HistoryModelAdapter());
  Hive.registerAdapter(RecommendationModelAdapter());
  Hive.registerAdapter(WatchlistModelAdapter());

  // Open all boxes
  await HiveService.initBoxes();

  // Seed default data if empty
  await SeedHelper.seedIfEmpty();

  runApp(const NutriTrackApp());
}

class NutriTrackApp extends StatelessWidget {
  const NutriTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => FoodController()),
        ChangeNotifierProvider(create: (_) => HistoryController()),
        ChangeNotifierProvider(create: (_) => RecommendationController()),
        ChangeNotifierProxyProvider<AuthController, WatchlistController>(
          create: (_) => WatchlistController(),
          update: (_, auth, prev) => (prev ?? WatchlistController())..updateUser(auth.currentUser?.id),
        ),
        ChangeNotifierProvider(create: (_) => AdminController()),
        ChangeNotifierProvider(create: (_) => NutritionistController()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'NutriTrack',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            home: const SplashView(),
          );
        },
      ),
    );
  }
}
