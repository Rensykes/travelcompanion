import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import 'package:trackie/presentation/bloc/manual_add/manual_add_state.dart';
import 'package:go_router/go_router.dart';

class CountrySearchModal extends StatelessWidget {
  final List<CountryItem> filteredCountries;
  final TextEditingController searchController;
  final Function(String) onCountrySelected;
  final Function() onSearchClear;
  final Function(String) onSearchChanged;

  const CountrySearchModal({
    super.key,
    required this.filteredCountries,
    required this.searchController,
    required this.onCountrySelected,
    required this.onSearchClear,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Column(
        children: [
          const Text(
            'Select Country',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search countries...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: onSearchClear,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredCountries.isNotEmpty
                ? _buildCountryList()
                : const Center(
                    child: Text(
                      'No countries found',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryList() {
    return ListView.builder(
      itemCount: filteredCountries.length,
      itemBuilder: (context, index) {
        final country = filteredCountries[index];
        return ListTile(
          leading: SizedBox(
            width: 40,
            child: CountryFlag.fromCountryCode(
              country.alpha2Code,
              height: 30,
              width: 40,
              shape: const RoundedRectangle(4),
            ),
          ),
          title: Text(
            '${country.alpha2Code} - ${country.name}',
            style: const TextStyle(fontSize: 16),
          ),
          onTap: () {
            onCountrySelected(country.alpha2Code);
            context.pop();
          },
        );
      },
    );
  }
}
