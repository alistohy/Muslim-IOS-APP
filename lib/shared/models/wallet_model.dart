import 'package:hive_flutter/hive_flutter.dart';


@HiveType(typeId: 1)
class Wallet extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late double balance;

  /// Currency code: EGP, USD, EUR
  @HiveField(3)
  late String currency;

  /// Hex color string, e.g. '#00E5FF'
  @HiveField(4)
  late String color;

  /// Icon name (matches a key in the app icon map)
  @HiveField(5)
  late String icon;

  Wallet({
    required this.id,
    required this.name,
    required this.balance,
    required this.currency,
    required this.color,
    required this.icon,
  });

  Wallet copyWith({
    String? id,
    String? name,
    double? balance,
    String? currency,
    String? color,
    String? icon,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  @override
  String toString() =>
      'Wallet(id: $id, name: $name, balance: $balance, '
      'currency: $currency, color: $color, icon: $icon)';
}

// ---------------------------------------------------------------------------
// Manual TypeAdapter (replaces build_runner generated file when not used)
// ---------------------------------------------------------------------------

class WalletAdapter extends TypeAdapter<Wallet> {
  @override
  final int typeId = 1;

  @override
  Wallet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Wallet(
      id: fields[0] as String,
      name: fields[1] as String,
      balance: fields[2] as double,
      currency: fields[3] as String,
      color: fields[4] as String,
      icon: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Wallet obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.balance)
      ..writeByte(3)
      ..write(obj.currency)
      ..writeByte(4)
      ..write(obj.color)
      ..writeByte(5)
      ..write(obj.icon);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
