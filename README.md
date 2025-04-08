# location_tracker

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Generate files

dart run build_runner build --delete-conflicting-outputs

# Using Entry Points 

flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor staging -t lib/main_staging.dart
flutter run --flavor prod -t lib/main_prod.dart

# Generate appbundle 

flutter build appbundle --flavor prod -t lib/main_prod.dart
flutter build apk --flavor dev -t lib/main_dev.dart


# Logging Emojis
The logs use emojis for better visibility and include:
🔍 For search operations
📝 For logging operations
✅ For successful operations
❌ For errors
🔄 For recalculation operations
�� For data retrieval
🗑️ For deletion operations
ℹ️ For informational messages