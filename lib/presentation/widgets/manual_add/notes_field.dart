import 'package:flutter/material.dart';

class NotesField extends StatelessWidget {
  final TextEditingController notesController;

  const NotesField({
    super.key,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: notesController,
      decoration: const InputDecoration(
        labelText: 'Notes (Optional)',
        hintText: 'Add any additional information',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.note),
      ),
      maxLines: 3,
    );
  }
}
