import 'package:hive/hive.dart';

class HistoryModel extends HiveObject {
  String id;
  String userId;
  String foodId;
  String foodName;
  double amount;        // gram (per portion)
  int quantity;         // number of portions
  double totalCalories;
  double totalProtein;
  double totalCarbs;
  double totalFat;
  DateTime date;
  String mealType;      // 'sarapan', 'makan siang', etc.

  HistoryModel({
    required this.id,
    required this.userId,
    required this.foodId,
    required this.foodName,
    required this.amount,
    this.quantity = 1,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.date,
    required this.mealType,
  });
}

class HistoryModelAdapter extends TypeAdapter<HistoryModel> {
  @override
  final int typeId = 2;

  @override
  HistoryModel read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{
      for (var i = 0; i < n; i++) reader.readByte(): reader.read(),
    };
    return HistoryModel(
      id: f[0] as String,
      userId: f[1] as String,
      foodId: f[2] as String,
      foodName: f[3] as String,
      amount: f[4] as double,
      totalCalories: f[5] as double,
      totalProtein: f[6] as double,
      totalCarbs: f[7] as double,
      totalFat: f[8] as double,
      date: f[9] as DateTime,
      mealType: f[10] as String,
      quantity: f[11] as int? ?? 1,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.userId)
      ..writeByte(2)..write(obj.foodId)
      ..writeByte(3)..write(obj.foodName)
      ..writeByte(4)..write(obj.amount)
      ..writeByte(5)..write(obj.totalCalories)
      ..writeByte(6)..write(obj.totalProtein)
      ..writeByte(7)..write(obj.totalCarbs)
      ..writeByte(8)..write(obj.totalFat)
      ..writeByte(9)..write(obj.date)
      ..writeByte(10)..write(obj.mealType)
      ..writeByte(11)..write(obj.quantity);
  }
}
