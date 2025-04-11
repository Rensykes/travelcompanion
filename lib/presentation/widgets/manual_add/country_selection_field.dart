import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import 'package:trackie/presentation/bloc/manual_add/manual_add_state.dart';

class CountrySelectionField extends StatelessWidget {
  final String? selectedCountryCode;
  final List<CountryItem> countryList;
  final Function() onTap;

  const CountrySelectionField({
    super.key,
    required this.selectedCountryCode,
    required this.countryList,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (value) {
        if (selectedCountryCode == null) {
          return 'Please select a country';
        }
        return null;
      },
      builder: (FormFieldState<String> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onTap,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Country',
                  hintText: 'Select a country',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.flag),
                  errorText: field.errorText,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: selectedCountryCode != null
                          ? _buildCountryDisplay(selectedCountryCode!)
                          : const Text(
                              'Select a country',
                              style: TextStyle(color: Colors.grey),
                            ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCountryDisplay(String countryCode) {
    String countryName = countryCode;
    for (var country in countryList) {
      if (country.alpha2Code == countryCode) {
        countryName = country.name;
        break;
      }
    }

    return Row(
      children: [
        CountryFlag.fromCountryCode(
          countryCode,
          height: 24,
          width: 30,
          borderRadius: 4,
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            countryName,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
