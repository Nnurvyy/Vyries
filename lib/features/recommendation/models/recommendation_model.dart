import 'package:hive/hive.dart';

/// Status alur pengajuan makanan
/// pending → forwarded_to_nutritionist | rejected_by_admin
/// forwarded_to_nutritionist → nutrition_filled
/// nutrition_filled → approved | rejected_by_admin_final
class RecommendationModel extends HiveObject {
  String id;
  String userId;
  String userName;
  String? nutritionistId;
  String? foodName;      // Sekarang opsional
  String? foodCategory;
  String? imageUrl;     // Field foto makan
  DateTime submittedAt;

  /// 'pending' | 'forwarded' | 'rejected' | 'nutrition_filled' | 'approved'
  String status;

  String? adminNotes;
  String? nutritionistNotes;
  double? calories;
  double? protein;
  double? carbs;
  double? fat;
  DateTime? reviewedAt;
  DateTime? nutritionFilledAt;

  RecommendationModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.nutritionistId,
    this.foodName,
    this.foodCategory,
    this.imageUrl,
    required this.submittedAt,
    this.status = 'pending',
    this.adminNotes,
    this.nutritionistNotes,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.reviewedAt,
    this.nutritionFilledAt,
  });

  bool get isPending => status == 'pending';
  bool get isForwarded => status == 'forwarded';
  bool get isRejected => status == 'rejected';
  bool get isNutritionFilled => status == 'nutrition_filled';
  bool get isApproved => status == 'approved';
}

class RecommendationModelAdapter extends TypeAdapter<RecommendationModel> {
  @override
  final int typeId = 3;

  @override
  RecommendationModel read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{
      for (var i = 0; i < n; i++) reader.readByte(): reader.read(),
    };
    return RecommendationModel(
      id: f[0] as String,
      userId: f[1] as String,
      userName: f[2] as String,
      nutritionistId: f[3] as String?,
      foodName: f[4] as String?,
      foodCategory: f[5] as String?,
      submittedAt: f[6] as DateTime,
      status: f[7] as String? ?? 'pending',
      adminNotes: f[8] as String?,
      nutritionistNotes: f[9] as String?,
      calories: f[10] as double?,
      protein: f[11] as double?,
      carbs: f[12] as double?,
      fat: f[13] as double?,
      reviewedAt: f[14] as DateTime?,
      nutritionFilledAt: f[15] as DateTime?,
      imageUrl: f[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RecommendationModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.userId)
      ..writeByte(2)..write(obj.userName)
      ..writeByte(3)..write(obj.nutritionistId)
      ..writeByte(4)..write(obj.foodName)
      ..writeByte(5)..write(obj.foodCategory)
      ..writeByte(6)..write(obj.submittedAt)
      ..writeByte(7)..write(obj.status)
      ..writeByte(8)..write(obj.adminNotes)
      ..writeByte(9)..write(obj.nutritionistNotes)
      ..writeByte(10)..write(obj.calories)
      ..writeByte(11)..write(obj.protein)
      ..writeByte(12)..write(obj.carbs)
      ..writeByte(13)..write(obj.fat)
      ..writeByte(14)..write(obj.reviewedAt)
      ..writeByte(15)..write(obj.nutritionFilledAt)
      ..writeByte(16)..write(obj.imageUrl);
  }
}
