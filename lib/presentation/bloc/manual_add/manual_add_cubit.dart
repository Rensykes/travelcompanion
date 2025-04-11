import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/presentation/bloc/calendar/calendar_cubit.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_cubit.dart';
import 'package:trackie/presentation/bloc/location_logs/location_logs_cubit.dart';
import 'package:trackie/presentation/bloc/manual_add/manual_add_state.dart';
import 'package:trackie/core/utils/data_refresh_util.dart';

class ManualAddCubit extends Cubit<ManualAddState> {
  final LocationLogsRepository _locationLogsRepository;
  final CountryVisitsRepository _countryVisitsRepository;
  final LocationLogsCubit _locationLogsCubit;
  final CountryVisitsCubit _countryVisitsCubit;
  final CalendarCubit _calendarCubit;

  DateTime selectedDate = DateTime.now();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  ManualAddCubit({
    required LocationLogsRepository locationLogsRepository,
    required CountryVisitsRepository countryVisitsRepository,
    required LocationLogsCubit locationLogsCubit,
    required CountryVisitsCubit countryVisitsCubit,
    required CalendarCubit calendarCubit,
  })  : _locationLogsRepository = locationLogsRepository,
        _countryVisitsRepository = countryVisitsRepository,
        _locationLogsCubit = locationLogsCubit,
        _countryVisitsCubit = countryVisitsCubit,
        _calendarCubit = calendarCubit,
        super(ManualAddInitial()) {
    // Initialize date controller
    dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);

    // Setup search controller listener
    searchController.addListener(filterCountries);

    // Load countries
    _loadCountries();
  }

  // Load all countries
  Future<void> _loadCountries() async {
    emit(ManualAddLoading());
    try {
      final countryList = _getCountriesList();

      // Sort alphabetically by name
      countryList.sort((a, b) => a.name.compareTo(b.name));

      emit(CountriesLoaded(
        countries: countryList,
        filteredCountries: List.from(countryList),
      ));

      log('Loaded ${countryList.length} countries');
    } catch (e) {
      log('Error loading countries: $e');

      // Fallback with a few example countries if there's an error
      final fallbackList = [
        CountryItem(name: "United States", alpha2Code: "US"),
        CountryItem(name: "United Kingdom", alpha2Code: "GB"),
        CountryItem(name: "Germany", alpha2Code: "DE"),
        CountryItem(name: "France", alpha2Code: "FR"),
        CountryItem(name: "Spain", alpha2Code: "ES"),
      ];

      emit(CountriesLoaded(
        countries: fallbackList,
        filteredCountries: List.from(fallbackList),
      ));
    }
  }

  // Filter countries based on search query
  void filterCountries() {
    if (state is CountriesLoaded) {
      final currentState = state as CountriesLoaded;
      final query = searchController.text.toLowerCase();

      List<CountryItem> filtered;
      if (query.isEmpty) {
        filtered = List.from(currentState.countries);
      } else {
        filtered = currentState.countries.where((country) {
          return country.alpha2Code.toLowerCase().contains(query) ||
              country.name.toLowerCase().contains(query);
        }).toList();
      }

      // Only emit if the filtered list has actually changed
      if (!_areListsEqual(filtered, currentState.filteredCountries)) {
        log('Filtering countries with query: "$query", found ${filtered.length} results');
        emit(currentState.copyWith(
          filteredCountries: filtered,
        ));
      }
    }
  }

  // Helper method to check if two lists have the same items
  bool _areListsEqual(List<CountryItem> list1, List<CountryItem> list2) {
    if (list1.length != list2.length) return false;

    for (int i = 0; i < list1.length; i++) {
      if (list1[i].alpha2Code != list2[i].alpha2Code) return false;
    }

    return true;
  }

  // Set the search mode
  void setSearching(bool isSearching) {
    if (state is CountriesLoaded) {
      final currentState = state as CountriesLoaded;
      if (isSearching) {
        searchController.clear();
        filterCountries();
      }
      emit(currentState.copyWith(isSearching: isSearching));
    }
  }

  // Select a country
  void selectCountry(String countryCode) {
    if (state is CountriesLoaded) {
      final currentState = state as CountriesLoaded;
      emit(currentState.copyWith(
        selectedCountryCode: countryCode,
        isSearching: false,
      ));
    }
  }

  // Update selected date
  void updateSelectedDate(DateTime date) {
    selectedDate = date;
    dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
  }

  // Submit the form
  Future<void> submitForm() async {
    if (state is CountriesLoaded) {
      final currentState = state as CountriesLoaded;

      if (currentState.selectedCountryCode == null) {
        return;
      }

      emit(SubmissionInProgress());

      try {
        final countryCode = currentState.selectedCountryCode!;
        final notes = notesController.text;

        // Save country visit with selected date
        await _countryVisitsRepository.saveCountryVisitWithDate(
          countryCode,
          selectedDate,
        );

        // Log the entry with notes if available
        await _locationLogsRepository.logEntry(
          status: 'manual_entry',
          countryCode: countryCode,
          notes: notes.isNotEmpty ? notes : 'Manual entry',
          logDateTime: selectedDate,
        );

        // Refresh data
        _refreshAllData();

        emit(SubmissionSuccess());
      } catch (e) {
        emit(SubmissionFailure(e.toString()));
      }
    }
  }

  // Refresh all data
  void _refreshAllData() {
    DataRefreshUtil.refreshAllData(
      locationLogsCubit: _locationLogsCubit,
      countryVisitsCubit: _countryVisitsCubit,
      calendarCubit: _calendarCubit,
      enableLogging: true,
    );
  }

  // Clean up resources
  @override
  Future<void> close() {
    searchController.removeListener(filterCountries);
    searchController.dispose();
    dateController.dispose();
    notesController.dispose();
    return super.close();
  }

  // Get countries list
  List<CountryItem> _getCountriesList() {
    return <CountryItem>[
      CountryItem(name: "Afghanistan", alpha2Code: "AF"),
      CountryItem(name: "Albania", alpha2Code: "AL"),
      CountryItem(name: "Algeria", alpha2Code: "DZ"),
      CountryItem(name: "American Samoa", alpha2Code: "AS"),
      CountryItem(name: "Andorra", alpha2Code: "AD"),
      CountryItem(name: "Angola", alpha2Code: "AO"),
      CountryItem(name: "Anguilla", alpha2Code: "AI"),
      CountryItem(name: "Antarctica", alpha2Code: "AQ"),
      CountryItem(name: "Antigua and Barbuda", alpha2Code: "AG"),
      CountryItem(name: "Argentina", alpha2Code: "AR"),
      CountryItem(name: "Armenia", alpha2Code: "AM"),
      CountryItem(name: "Aruba", alpha2Code: "AW"),
      CountryItem(name: "Australia", alpha2Code: "AU"),
      CountryItem(name: "Austria", alpha2Code: "AT"),
      CountryItem(name: "Azerbaijan", alpha2Code: "AZ"),
      CountryItem(name: "Bahamas", alpha2Code: "BS"),
      CountryItem(name: "Bahrain", alpha2Code: "BH"),
      CountryItem(name: "Bangladesh", alpha2Code: "BD"),
      CountryItem(name: "Barbados", alpha2Code: "BB"),
      CountryItem(name: "Belarus", alpha2Code: "BY"),
      CountryItem(name: "Belgium", alpha2Code: "BE"),
      CountryItem(name: "Belize", alpha2Code: "BZ"),
      CountryItem(name: "Benin", alpha2Code: "BJ"),
      CountryItem(name: "Bermuda", alpha2Code: "BM"),
      CountryItem(name: "Bhutan", alpha2Code: "BT"),
      CountryItem(name: "Bolivia", alpha2Code: "BO"),
      CountryItem(name: "Bosnia and Herzegovina", alpha2Code: "BA"),
      CountryItem(name: "Botswana", alpha2Code: "BW"),
      CountryItem(name: "Brazil", alpha2Code: "BR"),
      CountryItem(name: "British Indian Ocean Territory", alpha2Code: "IO"),
      CountryItem(name: "Brunei Darussalam", alpha2Code: "BN"),
      CountryItem(name: "Bulgaria", alpha2Code: "BG"),
      CountryItem(name: "Burkina Faso", alpha2Code: "BF"),
      CountryItem(name: "Burundi", alpha2Code: "BI"),
      CountryItem(name: "Cambodia", alpha2Code: "KH"),
      CountryItem(name: "Cameroon", alpha2Code: "CM"),
      CountryItem(name: "Canada", alpha2Code: "CA"),
      CountryItem(name: "Cape Verde", alpha2Code: "CV"),
      CountryItem(name: "Cayman Islands", alpha2Code: "KY"),
      CountryItem(name: "Central African Republic", alpha2Code: "CF"),
      CountryItem(name: "Chad", alpha2Code: "TD"),
      CountryItem(name: "Chile", alpha2Code: "CL"),
      CountryItem(name: "China", alpha2Code: "CN"),
      CountryItem(name: "Colombia", alpha2Code: "CO"),
      CountryItem(name: "Comoros", alpha2Code: "KM"),
      CountryItem(name: "Congo", alpha2Code: "CG"),
      CountryItem(name: "Democratic Republic of the Congo", alpha2Code: "CD"),
      CountryItem(name: "Cook Islands", alpha2Code: "CK"),
      CountryItem(name: "Costa Rica", alpha2Code: "CR"),
      CountryItem(name: "Croatia", alpha2Code: "HR"),
      CountryItem(name: "Cuba", alpha2Code: "CU"),
      CountryItem(name: "Cyprus", alpha2Code: "CY"),
      CountryItem(name: "Czech Republic", alpha2Code: "CZ"),
      CountryItem(name: "Denmark", alpha2Code: "DK"),
      CountryItem(name: "Djibouti", alpha2Code: "DJ"),
      CountryItem(name: "Dominica", alpha2Code: "DM"),
      CountryItem(name: "Dominican Republic", alpha2Code: "DO"),
      CountryItem(name: "Ecuador", alpha2Code: "EC"),
      CountryItem(name: "Egypt", alpha2Code: "EG"),
      CountryItem(name: "El Salvador", alpha2Code: "SV"),
      CountryItem(name: "Equatorial Guinea", alpha2Code: "GQ"),
      CountryItem(name: "Eritrea", alpha2Code: "ER"),
      CountryItem(name: "Estonia", alpha2Code: "EE"),
      CountryItem(name: "Ethiopia", alpha2Code: "ET"),
      CountryItem(name: "Falkland Islands", alpha2Code: "FK"),
      CountryItem(name: "Faroe Islands", alpha2Code: "FO"),
      CountryItem(name: "Fiji", alpha2Code: "FJ"),
      CountryItem(name: "Finland", alpha2Code: "FI"),
      CountryItem(name: "France", alpha2Code: "FR"),
      CountryItem(name: "French Guiana", alpha2Code: "GF"),
      CountryItem(name: "French Polynesia", alpha2Code: "PF"),
      CountryItem(name: "Gabon", alpha2Code: "GA"),
      CountryItem(name: "Gambia", alpha2Code: "GM"),
      CountryItem(name: "Georgia", alpha2Code: "GE"),
      CountryItem(name: "Germany", alpha2Code: "DE"),
      CountryItem(name: "Ghana", alpha2Code: "GH"),
      CountryItem(name: "Gibraltar", alpha2Code: "GI"),
      CountryItem(name: "Greece", alpha2Code: "GR"),
      CountryItem(name: "Greenland", alpha2Code: "GL"),
      CountryItem(name: "Grenada", alpha2Code: "GD"),
      CountryItem(name: "Guadeloupe", alpha2Code: "GP"),
      CountryItem(name: "Guam", alpha2Code: "GU"),
      CountryItem(name: "Guatemala", alpha2Code: "GT"),
      CountryItem(name: "Guinea", alpha2Code: "GN"),
      CountryItem(name: "Guinea-Bissau", alpha2Code: "GW"),
      CountryItem(name: "Guyana", alpha2Code: "GY"),
      CountryItem(name: "Haiti", alpha2Code: "HT"),
      CountryItem(name: "Honduras", alpha2Code: "HN"),
      CountryItem(name: "Hong Kong", alpha2Code: "HK"),
      CountryItem(name: "Hungary", alpha2Code: "HU"),
      CountryItem(name: "Iceland", alpha2Code: "IS"),
      CountryItem(name: "India", alpha2Code: "IN"),
      CountryItem(name: "Indonesia", alpha2Code: "ID"),
      CountryItem(name: "Iran", alpha2Code: "IR"),
      CountryItem(name: "Iraq", alpha2Code: "IQ"),
      CountryItem(name: "Ireland", alpha2Code: "IE"),
      CountryItem(name: "Israel", alpha2Code: "IL"),
      CountryItem(name: "Italy", alpha2Code: "IT"),
      CountryItem(name: "Jamaica", alpha2Code: "JM"),
      CountryItem(name: "Japan", alpha2Code: "JP"),
      CountryItem(name: "Jordan", alpha2Code: "JO"),
      CountryItem(name: "Kazakhstan", alpha2Code: "KZ"),
      CountryItem(name: "Kenya", alpha2Code: "KE"),
      CountryItem(name: "Kiribati", alpha2Code: "KI"),
      CountryItem(name: "Kuwait", alpha2Code: "KW"),
      CountryItem(name: "Kyrgyzstan", alpha2Code: "KG"),
      CountryItem(name: "Latvia", alpha2Code: "LV"),
      CountryItem(name: "Lebanon", alpha2Code: "LB"),
      CountryItem(name: "Lesotho", alpha2Code: "LS"),
      CountryItem(name: "Liberia", alpha2Code: "LR"),
      CountryItem(name: "Libya", alpha2Code: "LY"),
      CountryItem(name: "Liechtenstein", alpha2Code: "LI"),
      CountryItem(name: "Lithuania", alpha2Code: "LT"),
      CountryItem(name: "Luxembourg", alpha2Code: "LU"),
      CountryItem(name: "Macao", alpha2Code: "MO"),
      CountryItem(name: "Macedonia", alpha2Code: "MK"),
      CountryItem(name: "Madagascar", alpha2Code: "MG"),
      CountryItem(name: "Malawi", alpha2Code: "MW"),
      CountryItem(name: "Malaysia", alpha2Code: "MY"),
      CountryItem(name: "Maldives", alpha2Code: "MV"),
      CountryItem(name: "Mali", alpha2Code: "ML"),
      CountryItem(name: "Malta", alpha2Code: "MT"),
      CountryItem(name: "Marshall Islands", alpha2Code: "MH"),
      CountryItem(name: "Martinique", alpha2Code: "MQ"),
      CountryItem(name: "Mauritania", alpha2Code: "MR"),
      CountryItem(name: "Mauritius", alpha2Code: "MU"),
      CountryItem(name: "Mexico", alpha2Code: "MX"),
      CountryItem(name: "Micronesia", alpha2Code: "FM"),
      CountryItem(name: "Moldova", alpha2Code: "MD"),
      CountryItem(name: "Monaco", alpha2Code: "MC"),
      CountryItem(name: "Mongolia", alpha2Code: "MN"),
      CountryItem(name: "Montenegro", alpha2Code: "ME"),
      CountryItem(name: "Montserrat", alpha2Code: "MS"),
      CountryItem(name: "Morocco", alpha2Code: "MA"),
      CountryItem(name: "Mozambique", alpha2Code: "MZ"),
      CountryItem(name: "Myanmar", alpha2Code: "MM"),
      CountryItem(name: "Namibia", alpha2Code: "NA"),
      CountryItem(name: "Nauru", alpha2Code: "NR"),
      CountryItem(name: "Nepal", alpha2Code: "NP"),
      CountryItem(name: "Netherlands", alpha2Code: "NL"),
      CountryItem(name: "New Caledonia", alpha2Code: "NC"),
      CountryItem(name: "New Zealand", alpha2Code: "NZ"),
      CountryItem(name: "Nicaragua", alpha2Code: "NI"),
      CountryItem(name: "Niger", alpha2Code: "NE"),
      CountryItem(name: "Nigeria", alpha2Code: "NG"),
      CountryItem(name: "Niue", alpha2Code: "NU"),
      CountryItem(name: "Norfolk Island", alpha2Code: "NF"),
      CountryItem(name: "Northern Mariana Islands", alpha2Code: "MP"),
      CountryItem(name: "Norway", alpha2Code: "NO"),
      CountryItem(name: "Oman", alpha2Code: "OM"),
      CountryItem(name: "Pakistan", alpha2Code: "PK"),
      CountryItem(name: "Palau", alpha2Code: "PW"),
      CountryItem(name: "Palestinian Territory", alpha2Code: "PS"),
      CountryItem(name: "Panama", alpha2Code: "PA"),
      CountryItem(name: "Papua New Guinea", alpha2Code: "PG"),
      CountryItem(name: "Paraguay", alpha2Code: "PY"),
      CountryItem(name: "Peru", alpha2Code: "PE"),
      CountryItem(name: "Philippines", alpha2Code: "PH"),
      CountryItem(name: "Poland", alpha2Code: "PL"),
      CountryItem(name: "Portugal", alpha2Code: "PT"),
      CountryItem(name: "Puerto Rico", alpha2Code: "PR"),
      CountryItem(name: "Qatar", alpha2Code: "QA"),
      CountryItem(name: "Romania", alpha2Code: "RO"),
      CountryItem(name: "Russian Federation", alpha2Code: "RU"),
      CountryItem(name: "Rwanda", alpha2Code: "RW"),
      CountryItem(name: "Saint Kitts and Nevis", alpha2Code: "KN"),
      CountryItem(name: "Saint Lucia", alpha2Code: "LC"),
      CountryItem(name: "Saint Vincent and the Grenadines", alpha2Code: "VC"),
      CountryItem(name: "Samoa", alpha2Code: "WS"),
      CountryItem(name: "San Marino", alpha2Code: "SM"),
      CountryItem(name: "Sao Tome and Principe", alpha2Code: "ST"),
      CountryItem(name: "Saudi Arabia", alpha2Code: "SA"),
      CountryItem(name: "Senegal", alpha2Code: "SN"),
      CountryItem(name: "Serbia", alpha2Code: "RS"),
      CountryItem(name: "Seychelles", alpha2Code: "SC"),
      CountryItem(name: "Sierra Leone", alpha2Code: "SL"),
      CountryItem(name: "Singapore", alpha2Code: "SG"),
      CountryItem(name: "Slovakia", alpha2Code: "SK"),
      CountryItem(name: "Slovenia", alpha2Code: "SI"),
      CountryItem(name: "Solomon Islands", alpha2Code: "SB"),
      CountryItem(name: "Somalia", alpha2Code: "SO"),
      CountryItem(name: "South Africa", alpha2Code: "ZA"),
      CountryItem(name: "South Korea", alpha2Code: "KR"),
      CountryItem(name: "Spain", alpha2Code: "ES"),
      CountryItem(name: "Sri Lanka", alpha2Code: "LK"),
      CountryItem(name: "Sudan", alpha2Code: "SD"),
      CountryItem(name: "Suriname", alpha2Code: "SR"),
      CountryItem(name: "Swaziland", alpha2Code: "SZ"),
      CountryItem(name: "Sweden", alpha2Code: "SE"),
      CountryItem(name: "Switzerland", alpha2Code: "CH"),
      CountryItem(name: "Syrian Arab Republic", alpha2Code: "SY"),
      CountryItem(name: "Taiwan", alpha2Code: "TW"),
      CountryItem(name: "Tajikistan", alpha2Code: "TJ"),
      CountryItem(name: "Tanzania", alpha2Code: "TZ"),
      CountryItem(name: "Thailand", alpha2Code: "TH"),
      CountryItem(name: "Timor-Leste", alpha2Code: "TL"),
      CountryItem(name: "Togo", alpha2Code: "TG"),
      CountryItem(name: "Tokelau", alpha2Code: "TK"),
      CountryItem(name: "Tonga", alpha2Code: "TO"),
      CountryItem(name: "Trinidad and Tobago", alpha2Code: "TT"),
      CountryItem(name: "Tunisia", alpha2Code: "TN"),
      CountryItem(name: "Turkey", alpha2Code: "TR"),
      CountryItem(name: "Turkmenistan", alpha2Code: "TM"),
      CountryItem(name: "Turks and Caicos Islands", alpha2Code: "TC"),
      CountryItem(name: "Tuvalu", alpha2Code: "TV"),
      CountryItem(name: "Uganda", alpha2Code: "UG"),
      CountryItem(name: "Ukraine", alpha2Code: "UA"),
      CountryItem(name: "United Arab Emirates", alpha2Code: "AE"),
      CountryItem(name: "United Kingdom", alpha2Code: "GB"),
      CountryItem(name: "United States", alpha2Code: "US"),
      CountryItem(name: "Uruguay", alpha2Code: "UY"),
      CountryItem(name: "Uzbekistan", alpha2Code: "UZ"),
      CountryItem(name: "Vanuatu", alpha2Code: "VU"),
      CountryItem(name: "Venezuela", alpha2Code: "VE"),
      CountryItem(name: "Vietnam", alpha2Code: "VN"),
      CountryItem(name: "Virgin Islands, British", alpha2Code: "VG"),
      CountryItem(name: "Virgin Islands, U.S.", alpha2Code: "VI"),
      CountryItem(name: "Yemen", alpha2Code: "YE"),
      CountryItem(name: "Zambia", alpha2Code: "ZM"),
      CountryItem(name: "Zimbabwe", alpha2Code: "ZW"),
    ];
  }
}
