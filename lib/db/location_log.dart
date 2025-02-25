import 'package:hive/hive.dart';

part 'location_log.g.dart'; // This is required for code generation

@HiveType(typeId: 2)
class LocationLog extends HiveObject {
  @HiveField(0)
  final DateTime dateTime;

  @HiveField(1)
  final String status; // "success" or "error"

  @HiveField(2)
  final String? countryCode; // Null if status is "error"

  LocationLog({
    required this.dateTime,
    required this.status,
    this.countryCode,
  });
}