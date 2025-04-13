import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:trackie/presentation/helpers/snackbar_helper.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:get_it/get_it.dart';
import 'package:trackie/core/utils/data_refresh_util.dart';
import 'package:trackie/presentation/bloc/manual_add/manual_add_cubit.dart';
import 'package:trackie/presentation/bloc/manual_add/manual_add_state.dart';
import 'package:trackie/presentation/widgets/manual_add/country_selection_field.dart';
import 'package:trackie/presentation/widgets/manual_add/country_search_modal.dart';
import 'package:trackie/presentation/widgets/manual_add/date_selection_field.dart';
import 'package:trackie/presentation/widgets/manual_add/submit_button.dart';
import 'package:go_router/go_router.dart';
import 'package:trackie/core/constants/route_constants.dart';

class ManualAddScreen extends StatelessWidget {
  const ManualAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide ManualAddCubit to this screen
    return BlocProvider(
      create: (_) => GetIt.instance.get<ManualAddCubit>(),
      child: const _ManualAddScreenContent(),
    );
  }
}

class _ManualAddScreenContent extends StatefulWidget {
  const _ManualAddScreenContent();

  @override
  State<_ManualAddScreenContent> createState() =>
      _ManualAddScreenContentState();
}

class _ManualAddScreenContentState extends State<_ManualAddScreenContent> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManualAddCubit, ManualAddState>(
      listenWhen: (previous, current) =>
          current is SubmissionSuccess || current is SubmissionFailure,
      listener: (context, state) {
        if (!mounted) return;

        if (state is SubmissionSuccess) {
          // Refresh all data using context
          DataRefreshUtil.refreshAllData(context: context);

          SnackBarHelper.showSnackBar(
            context,
            'Location Added',
            'Successfully added visit',
            ContentType.success,
          );

          // Always navigate to home after successful submission
          context.go(RouteConstants.dashboardFullPath);
        } else if (state is SubmissionFailure) {
          SnackBarHelper.showSnackBar(
            context,
            'Error',
            'Failed to add location: ${state.error}',
            ContentType.failure,
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<ManualAddCubit>();
        final isLoading = state is SubmissionInProgress;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Manual Location Entry'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Enter Country Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Country Selection Field
                    if (state is CountriesLoaded)
                      CountrySelectionField(
                        selectedCountryCode: state.selectedCountryCode,
                        countryList: state.countries,
                        onTap: () =>
                            _showCountrySearchModal(context, cubit, state),
                      ),

                    const SizedBox(height: 24),

                    // Date Selection Field
                    DateSelectionField(
                      dateController: cubit.dateController,
                      onTap: () => _showDateTimePicker(context, cubit),
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SubmitButton(
                      isLoading: isLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          cubit.submitForm();
                        }
                      },
                    ),

                    // Add extra padding at the bottom for better scrolling
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCountrySearchModal(
    BuildContext context,
    ManualAddCubit cubit,
    CountriesLoaded state,
  ) {
    cubit.setSearching(true);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        // Provide the existing cubit to the modal context
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<ManualAddCubit, ManualAddState>(
            builder: (context, currentState) {
              if (currentState is CountriesLoaded) {
                return CountrySearchModal(
                  filteredCountries: currentState.filteredCountries,
                  searchController: cubit.searchController,
                  onCountrySelected: (countryCode) {
                    cubit.selectCountry(countryCode);
                  },
                  onSearchClear: () {
                    cubit.searchController.clear();
                    cubit.filterCountries(); // Call filtering explicitly
                  },
                  onSearchChanged: (query) {
                    // Don't need setState anymore because we're using BlocBuilder
                    cubit.filterCountries(); // Call filtering explicitly
                  },
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        );
      },
    ).then((_) {
      // Check if mounted before updating search state
      if (mounted) {
        cubit.setSearching(false);
      }
    });
  }

  Future<void> _showDateTimePicker(
    BuildContext context,
    ManualAddCubit cubit,
  ) async {
    final dateTime = await showOmniDateTimePicker(
      context: context,
      initialDate: cubit.selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      is24HourMode: true,
      isShowSeconds: false,
      minutesInterval: 1,
      secondsInterval: 1,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(
        maxWidth: 350,
        maxHeight: 650,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1.drive(
            Tween(
              begin: 0,
              end: 1,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      selectableDayPredicate: (dateTime) {
        // Disallow dates in the future
        return dateTime.isBefore(DateTime.now().add(const Duration(days: 1)));
      },
    );

    if (dateTime != null && mounted) {
      cubit.updateSelectedDate(dateTime);
    }
  }
}
