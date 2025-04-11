import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:country_flags/country_flags.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_cubit.dart';
import 'package:trackie/presentation/bloc/location_logs/location_logs_cubit.dart';
import 'package:trackie/presentation/bloc/calendar/calendar_cubit.dart';
import 'package:trackie/presentation/helpers/snackbar_helper.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:get_it/get_it.dart';

class ManualAddScreen extends StatefulWidget {
  const ManualAddScreen({super.key});

  @override
  State<ManualAddScreen> createState() => _ManualAddScreenState();
}

class _ManualAddScreenState extends State<ManualAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _countryCodeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  @override
  void dispose() {
    _countryCodeController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void refreshAllData() {
    if (context.mounted) {
      context.read<LocationLogsCubit>().refresh();
      context.read<CountryVisitsCubit>().refresh();
      context.read<CalendarCubit>().refresh();
    }
  }

  Future<void> _showDateTimePicker() async {
    final dateTime = await showOmniDateTimePicker(
      context: context,
      initialDate: _selectedDate,
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

    if (dateTime != null) {
      setState(() {
        _selectedDate = dateTime;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final countryCode = _countryCodeController.text.toUpperCase();
        final notes = _notesController.text;

        // Save country visit with selected date
        final countryVisitsRepository =
            GetIt.instance.get<CountryVisitsRepository>();
        await countryVisitsRepository.saveCountryVisitWithDate(
          countryCode,
          _selectedDate,
        );

        // Log the entry with notes if available
        final locationLogsRepository =
            GetIt.instance.get<LocationLogsRepository>();
        await locationLogsRepository.logEntry(
          status: 'manual_entry',
          countryCode: countryCode,
          notes: notes.isNotEmpty ? notes : 'Manual entry',
        );

        if (context.mounted) {
          SnackBarHelper.showSnackBar(
            context,
            'Location Added',
            'Successfully added visit to $countryCode',
            ContentType.success,
          );

          // Refresh data and navigate back
          refreshAllData();
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          SnackBarHelper.showSnackBar(
            context,
            'Error',
            'Failed to add location: ${e.toString()}',
            ContentType.failure,
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

                // Country Code Input
                TextFormField(
                  controller: _countryCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Country Code (ISO)',
                    hintText: 'Enter 2-letter ISO code (e.g., US, DE)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a country code';
                    }
                    if (value.length != 2) {
                      return 'Country code must be 2 letters';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 2,
                ),
                const SizedBox(height: 8),

                // Show country flag preview if valid code
                if (_countryCodeController.text.length == 2)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const Text(
                          'Preview: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        CountryFlag.fromCountryCode(
                          _countryCodeController.text,
                          height: 30,
                          width: 40,
                          borderRadius: 4,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Date Input with Picker
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Visit Date',
                    hintText: 'Select date of visit',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: _showDateTimePicker,
                    ),
                  ),
                  readOnly: true,
                  onTap: _showDateTimePicker,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Notes Input
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Add any additional information',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitForm,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Save Location'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                // Add extra padding at the bottom for better scrolling
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
