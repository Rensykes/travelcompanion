import 'package:flutter/material.dart';

class DateSelectionField extends StatelessWidget {
  final TextEditingController dateController;
  final Function() onTap;

  const DateSelectionField({
    super.key,
    required this.dateController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: dateController,
      decoration: InputDecoration(
        labelText: 'Visit Date',
        hintText: 'Select date of visit',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.calendar_today),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: onTap,
        ),
      ),
      readOnly: true,
      onTap: onTap,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a date';
        }
        return null;
      },
    );
  }
}
