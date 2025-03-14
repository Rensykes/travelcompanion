import 'package:hive/hive.dart';

part 'country_adapter.g.dart';

@HiveType(typeId: 1)
class CountryVisit {
  @HiveField(0)
  String countryCode;

  @HiveField(1)
  DateTime entryDate;

  @HiveField(2)
  int daysSpent;

  CountryVisit({
    required this.countryCode,
    required this.entryDate,
    required this.daysSpent,
  });

  @override
  String toString() {
    return 'CountryVisit(entryDate: $entryDate, countryCode: $countryCode)';
  }
}

