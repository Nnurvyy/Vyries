class CalorieHelper {
  /// Hitung BMR dengan Mifflin-St Jeor Equation
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
  }) {
    if (gender.toLowerCase() == 'laki-laki') {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
  }

  /// Faktor aktivitas berdasarkan profesi
  static double getActivityMultiplier(String profession) {
    switch (profession.toLowerCase()) {
      case 'mahasiswa':
      case 'pegawai kantor':
      case 'wirausaha':
        return 1.2;
      case 'guru':
      case 'dokter':
      case 'perawat':
        return 1.375;
      case 'karyawan':
      case 'petani':
      case 'nelayan':
        return 1.55;
      case 'atlet':
      case 'buruh':
      case 'tentara':
        return 1.725;
      default:
        return 1.375;
    }
  }

  /// Hitung TDEE
  static double calculateTDEE({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required String profession,
  }) {
    final bmr = calculateBMR(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
    );
    return bmr * getActivityMultiplier(profession);
  }

  /// Hitung kebutuhan kalori harian dengan target kenaikan BB
  static double calculateDailyCalorieNeed({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required String profession,
    double targetWeightGainPerMonth = 0,
  }) {
    final tdee = calculateTDEE(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
      profession: profession,
    );
    // 7700 kcal ≈ 1 kg lemak tubuh
    final dailyAdjustment = (targetWeightGainPerMonth * 7700) / 30;
    return tdee + dailyAdjustment;
  }

  /// Hitung target makro (protein, karbo, lemak) dalam gram
  static Map<String, double> calculateMacros(double dailyCalories) {
    return {
      'protein': (dailyCalories * 0.30) / 4, // 4 kcal/g
      'carbs': (dailyCalories * 0.50) / 4,   // 4 kcal/g
      'fat': (dailyCalories * 0.20) / 9,     // 9 kcal/g
    };
  }

  /// Format angka kalori
  static String formatCalorie(double cal) => cal.toStringAsFixed(0);
  static String formatNutrient(double g) => '${g.toStringAsFixed(1)}g';
}
