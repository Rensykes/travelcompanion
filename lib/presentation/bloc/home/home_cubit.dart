import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trackie/application/services/sim_info_service.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_cubit.dart';
import 'package:trackie/presentation/bloc/location_logs/location_logs_cubit.dart';
import 'package:trackie/presentation/bloc/home/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final LocationLogsRepository locationLogsRepository;
  final CountryVisitsRepository countryVisitsRepository;

  HomeCubit({
    required this.locationLogsRepository,
    required this.countryVisitsRepository,
  }) : super(const HomeState());

  Future<void> addCountry(
    Function(String, String, ContentType) showSnackBar,
  ) async {
    emit(state.copyWith(isFetchingLocation: true));

    try {
      final isoCode = await SimInfoService.getIsoCode();

      if (isoCode != null) {
        await countryVisitsRepository.saveCountryVisit(isoCode);
        await locationLogsRepository.logEntry(
          status: 'success',
          countryCode: isoCode,
        );

        // Refresh data
        await refresh();

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

  Future<void> refresh() async {
    // Refresh data in other cubits
    final locationLogsCubit = GetIt.instance.get<LocationLogsCubit>();
    final countryVisitsCubit = GetIt.instance.get<CountryVisitsCubit>();

    await locationLogsCubit.refresh();
    await countryVisitsCubit.refresh();
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
