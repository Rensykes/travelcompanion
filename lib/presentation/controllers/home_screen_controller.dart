import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:trackie/application/services/sim_info_service.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trackie/presentation/providers/country_visits_provider.dart';
import 'package:trackie/presentation/providers/location_logs_provider.dart';

part 'home_screen_controller.g.dart';

@riverpod
class HomeScreenController extends _$HomeScreenController {
  late final CountryVisitsRepository _countryVisitsRepository;
  late final LocationLogsRepository _locationLogsRepository;

  @override
  HomeScreenStateData build() {
    _countryVisitsRepository = ref.read(countryVisitsRepositoryProvider);
    _locationLogsRepository = ref.read(locationLogsRepositoryProvider);

    // Set up app state change listener
    ref.onDispose(() {
      // Clean up any listeners if needed
    });

    return const HomeScreenStateData();
  }

  Future<void> addCountry(
    Function(String, String, ContentType) showSnackBar,
  ) async {
    state = state.copyWith(isFetchingLocation: true);
    try {
      final isoCode = await SimInfoService.getIsoCode();
      if (isoCode != null) {
        await _countryVisitsRepository.saveCountryVisit(isoCode);
        await _locationLogsRepository.logEntry(
          status: 'success',
          countryCode: isoCode,
        );
        ref.invalidate(countryVisitsProvider);
        ref.invalidate(locationLogsProvider);
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
      state = state.copyWith(isFetchingLocation: false);
    }
  }

  void changeTab(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }

  void _handleLocationError(
    Function(String, String, ContentType) showSnackBar,
  ) {
    _locationLogsRepository.logEntry(status: 'error');
    showSnackBar(
      'Oops!',
      'Cannot retrieve your location 😢',
      ContentType.failure,
    );
  }

  // Method to refresh all data
  Future<void> refreshAllData() async {
    await ref.read(countryVisitsProvider.notifier).refresh();
    await ref.read(locationLogsProvider.notifier).refresh();
  }
}

class HomeScreenStateData {
  final bool isLoading;
  final bool isFetchingLocation;
  final int selectedTabIndex;

  const HomeScreenStateData({
    this.isLoading = false,
    this.isFetchingLocation = false,
    this.selectedTabIndex = 0,
  });

  HomeScreenStateData copyWith({
    bool? isLoading,
    bool? isFetchingLocation,
    int? selectedTabIndex,
  }) {
    return HomeScreenStateData(
      isLoading: isLoading ?? this.isLoading,
      isFetchingLocation: isFetchingLocation ?? this.isFetchingLocation,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }
}
