import 'dart:io';
import 'dart:developer';
import 'package:file_picker/file_picker.dart';

/// Service for handling file system operations throughout the application.
///
/// This service encapsulates all file-related operations, including:
/// - Picking directories for saving files
/// - Selecting files to open
/// - Reading from and writing to files
///
/// It uses the FilePicker package to provide platform-appropriate
/// file selection dialogs and abstracts the complexity of file I/O operations.
class FileService {
  /// Presents a directory selection dialog and returns the selected path.
  ///
  /// This method opens a platform-appropriate directory picker dialog
  /// that allows the user to select a folder where files will be saved.
  ///
  /// Parameters:
  /// - [dialogTitle]: Title to display in the directory selection dialog
  ///
  /// Returns:
  /// The path to the selected directory, or null if the user cancels the operation
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

  /// Presents a file selection dialog and returns the path of the selected file.
  ///
  /// This method opens a platform-appropriate file picker dialog that allows
  /// the user to select a file to open. The file types can be filtered by extension.
  ///
  /// Parameters:
  /// - [dialogTitle]: Title to display in the file selection dialog
  /// - [allowedExtensions]: List of file extensions to filter by (e.g., ['json', 'txt'])
  ///
  /// Returns:
  /// The path to the selected file, or null if the user cancels the operation
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

  /// Writes string data to a file at the specified path.
  ///
  /// This method creates a new file or overwrites an existing file
  /// with the provided string content.
  ///
  /// Parameters:
  /// - [filePath]: Full path to the file to write
  /// - [data]: String content to write to the file
  ///
  /// Throws an exception if the write operation fails.
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

  /// Reads and returns the contents of a file as a string.
  ///
  /// This method opens the file at the specified path and reads
  /// its entire contents into a string.
  ///
  /// Parameters:
  /// - [filePath]: Full path to the file to read
  ///
  /// Returns:
  /// The contents of the file as a string
  ///
  /// Throws an exception if the file cannot be read.
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
