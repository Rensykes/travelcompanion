// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocationLogAdapter extends TypeAdapter<LocationLog> {
  @override
  final int typeId = 1;

  @override
  LocationLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationLog(
      dateTime: fields[0] as DateTime,
      status: fields[1] as String,
      countryCode: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LocationLog obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.dateTime)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.countryCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
