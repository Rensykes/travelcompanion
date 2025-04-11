import 'dart:io';
import 'dart:developer';
import 'package:file_picker/file_picker.dart';

class FileService {
  /// Pick a directory to save files
  Future<String?> pickDirectory({required String dialogTitle}) async {
    final outputDir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: dialogTitle,
    );

    if (outputDir == null) {
      log(
        "⚠️ Directory pick cancelled by user",
        name: 'FileService',
        level: 2, // WARN
        time: DateTime.now(),
      );
      return null;
    }

    return outputDir;
  }

  /// Pick a file to open
  Future<String?> pickFile({
    required String dialogTitle,
    required List<String> allowedExtensions,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      dialogTitle: dialogTitle,
    );

    if (result == null || result.files.single.path == null) {
      log(
        "⚠️ File pick cancelled by user",
        name: 'FileService',
        level: 2, // WARN
        time: DateTime.now(),
      );
      return null;
    }

    return result.files.single.path;
  }

  /// Write data to a file
  Future<void> writeToFile(String filePath, String data) async {
    final file = File(filePath);
    await file.writeAsString(data);
    log(
      "✅ Data successfully written to: $filePath",
      name: 'FileService',
      level: 1, // SUCCESS
      time: DateTime.now(),
    );
  }

  /// Read data from a file
  Future<String> readFromFile(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    log(
      "📖 Successfully read data from: $filePath",
      name: 'FileService',
      level: 1, // SUCCESS
      time: DateTime.now(),
    );
    return content;
  }
}
