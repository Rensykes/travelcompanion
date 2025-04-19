import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/core/di/dependency_injection.dart';
import 'package:trackie/presentation/bloc/user_info/user_info_cubit.dart';
import 'package:trackie/presentation/bloc/user_info/user_info_state.dart';
import 'package:country_flags/country_flags.dart';

/// A widget that displays user information
class UserInfoDisplay extends StatelessWidget {
  const UserInfoDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserInfoCubit>.value(
      value: getIt<UserInfoCubit>(),
      child: BlocBuilder<UserInfoCubit, UserInfoState>(
        builder: (context, state) {
          if (state is UserInfoLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is UserInfoLoaded) {
            return _buildUserInfoCard(context, state);
          } else if (state is UserInfoNotFound) {
            return const Center(
              child: Text('User information not found'),
            );
          } else if (state is UserInfoError) {
            return Center(
              child: Text('Error: ${state.message}'),
            );
          } else {
            // Initial state or other states
            // Trigger loading user info
            context.read<UserInfoCubit>().loadUserInfo();
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, UserInfoLoaded state) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'User Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              icon: Icons.person,
              label: 'Name',
              value: state.name,
              onEdit: () => _showNameEditDialog(context, state.name),
            ),
            const SizedBox(height: 16),
            _buildCountryRow(
              context,
              countryCode: state.countryCode,
              onEdit: () => _showCountryEditDialog(context, state.countryCode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, size: 18),
          onPressed: onEdit,
        ),
      ],
    );
  }

  Widget _buildCountryRow(
    BuildContext context, {
    required String countryCode,
    required VoidCallback onEdit,
  }) {
    return Row(
      children: [
        Icon(Icons.flag, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        _buildCountryFlag(countryCode),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Country',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                _getCountryName(countryCode),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, size: 18),
          onPressed: onEdit,
        ),
      ],
    );
  }

  Widget _buildCountryFlag(String countryCode) {
    try {
      return CountryFlag.fromCountryCode(
        countryCode,
        height: 24,
        width: 30,
      );
    } catch (e) {
      // In case there's an issue with the country flag package
      return Container(
        width: 30,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        child: Text(
          _countryEmoji(countryCode),
          style: const TextStyle(fontSize: 16),
        ),
      );
    }
  }

  void _showNameEditDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Your Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('SAVE'),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context
                    .read<UserInfoCubit>()
                    .updateUserName(controller.text.trim());
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showCountryEditDialog(BuildContext context, String currentCountryCode) {
    // This would typically show a country picker
    // For simplicity, we'll just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Country editing not implemented in this example'),
      ),
    );
  }

  // Helper method to convert country code to emoji flag
  String _countryEmoji(String countryCode) {
    final flagOffset = 0x1F1E6;
    final asciiOffset = 0x41;

    final firstChar = countryCode.codeUnitAt(0) - asciiOffset + flagOffset;
    final secondChar = countryCode.codeUnitAt(1) - asciiOffset + flagOffset;

    return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
  }

  // Helper method to get country name from code
  // In a real app, you would use a proper mapping of country codes to names
  String _getCountryName(String countryCode) {
    final Map<String, String> countryCodes = {
      'US': 'United States',
      'GB': 'United Kingdom',
      'CA': 'Canada',
      'AU': 'Australia',
      'DE': 'Germany',
      'FR': 'France',
      'JP': 'Japan',
      'BR': 'Brazil',
      'IN': 'India',
      'CN': 'China',
      'IT': 'Italy',
      'ES': 'Spain',
      'MX': 'Mexico',
      'RU': 'Russia',
      'KR': 'South Korea',
      'NL': 'Netherlands',
      'SE': 'Sweden',
      'CH': 'Switzerland',
      'NO': 'Norway',
      'DK': 'Denmark',
      'FI': 'Finland',
      'SG': 'Singapore',
      'NZ': 'New Zealand',
      'IE': 'Ireland',
      'PT': 'Portugal',
      'GR': 'Greece',
      'AT': 'Austria',
      'BE': 'Belgium',
      'ZA': 'South Africa',
      'AR': 'Argentina',
    };

    return countryCodes[countryCode] ?? countryCode;
  }
}
