import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/application/services/sim_info_service.dart';
import 'package:trackie/core/utils/db_util.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/presentation/bloc/app_shell/app_shell_state.dart';
import 'package:trackie/core/constants/route_constants.dart';

class AppShellCubit extends Cubit<AppShellState> {
  final LocationLogsRepository locationLogsRepository;
  final CountryVisitsRepository countryVisitsRepository;

  AppShellCubit({
    required this.locationLogsRepository,
    required this.countryVisitsRepository,
  }) : super(const AppShellState());

  Future<void> addCountry(
    Function(String, String, ContentType) showSnackBar,
  ) async {
    emit(state.copyWith(isFetchingLocation: true));

    try {
      final isoCode = await SimInfoService.getIsoCode();

      if (isoCode != null) {
        await countryVisitsRepository.createCountryVisit(
          countryCode: isoCode,
          entryDate: DateTime.now(),
          daysSpent: 0,
        );
        await locationLogsRepository.createLocationLog(
          logDateTime: DateTime.now(),
          status: DBUtils.manualEntry,
          countryCode: isoCode,
        );

        // Let the UI layer handle the refresh
        showSnackBar(
          'Location Retrieved!',
          'You are currently in: $isoCode 👌',
          ContentType.success,
        );
      } else {
        _handleLocationError(showSnackBar);
      }
    } catch (e) {
      _handleLocationError(showSnackBar);
    } finally {
      emit(state.copyWith(isFetchingLocation: false));
    }
  }

  bool shouldShowFloatingActionButton(String currentPath) {
    // Check screen paths by name
    final bool isCalendarScreen =
        currentPath.startsWith(RouteConstants.calendar);
    final bool isSettingsScreen =
        currentPath.startsWith(RouteConstants.settings);
    final bool isAddScreen = currentPath.startsWith(RouteConstants.add);

    // Hide FAB on calendar and settings screens
    return !isCalendarScreen && !isSettingsScreen && !isAddScreen;
  }

  void _handleLocationError(
      Function(String, String, ContentType) showSnackBar) {
    showSnackBar(
      'Error',
      'Could not retrieve location. Please try again later.',
      ContentType.failure,
    );
  }
}
