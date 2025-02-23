// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_adapter.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CountryVisitAdapter extends TypeAdapter<CountryVisit> {
  @override
  final int typeId = 1;

  @override
  CountryVisit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CountryVisit(
      countryCode: fields[0] as String,
      entryDate: fields[1] as DateTime,
      daysSpent: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CountryVisit obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.countryCode)
      ..writeByte(1)
      ..write(obj.entryDate)
      ..writeByte(2)
      ..write(obj.daysSpent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryVisitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
