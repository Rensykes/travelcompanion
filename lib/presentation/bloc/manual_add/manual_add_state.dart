import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class ManualAddState extends Equatable {
  const ManualAddState();

  @override
  List<Object?> get props => [];
}

class ManualAddInitial extends ManualAddState {}

class ManualAddLoading extends ManualAddState {}

class CountriesLoaded extends ManualAddState {
  final List<CountryItem> countries;
  final List<CountryItem> filteredCountries;
  final String? selectedCountryCode;
  final bool isSearching;

  const CountriesLoaded({
    required this.countries,
    required this.filteredCountries,
    this.selectedCountryCode,
    this.isSearching = false,
  });

  CountriesLoaded copyWith({
    List<CountryItem>? countries,
    List<CountryItem>? filteredCountries,
    String? selectedCountryCode,
    bool? isSearching,
  }) {
    return CountriesLoaded(
      countries: countries ?? this.countries,
      filteredCountries: filteredCountries ?? this.filteredCountries,
      selectedCountryCode: selectedCountryCode ?? this.selectedCountryCode,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props =>
      [countries, filteredCountries, selectedCountryCode, isSearching];
}

class SubmissionInProgress extends ManualAddState {}

class SubmissionSuccess extends ManualAddState {}

class SubmissionFailure extends ManualAddState {
  final String error;

  const SubmissionFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class CountryItem {
  final String name;
  final String alpha2Code;

  CountryItem({required this.name, required this.alpha2Code});
}
