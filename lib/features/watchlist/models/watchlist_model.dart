import 'package:hive/hive.dart';

class WatchlistModel extends HiveObject {
  String id; // Usually userId
  List<String> foodIds;

  WatchlistModel({
    required this.id,
    required this.foodIds,
  });
}

class WatchlistModelAdapter extends TypeAdapter<WatchlistModel> {
  @override
  final int typeId = 4;

  @override
  WatchlistModel read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{
      for (var i = 0; i < n; i++) reader.readByte(): reader.read(),
    };
    return WatchlistModel(
      id: f[0] as String,
      foodIds: (f[1] as List?)?.cast<String>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, WatchlistModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.foodIds);
  }
}
