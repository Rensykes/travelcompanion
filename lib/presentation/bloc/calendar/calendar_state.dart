import 'package:equatable/equatable.dart';
import 'package:trackie/data/models/calendar_day_data.dart';

class CalendarState extends Equatable {
  final Map<DateTime, CalendarDayData> dayData;
  final DateTime? selectedDay;
  final bool isLoading;
  final String? error;

  const CalendarState({
    this.dayData = const {},
    this.selectedDay,
    this.isLoading = false,
    this.error,
  });

  CalendarState copyWith({
    Map<DateTime, CalendarDayData>? dayData,
    DateTime? selectedDay,
    bool? isLoading,
    String? error,
  }) {
    return CalendarState(
      dayData: dayData ?? this.dayData,
      selectedDay: selectedDay ?? this.selectedDay,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [dayData, selectedDay, isLoading, error];
}
