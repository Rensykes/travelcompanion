# Card Conversion Guide

This document provides instructions for upgrading regular Flutter `Card` widgets to the new semi-transparent `GlassCard` throughout the application.

## Card Helper Overview

We have created a `CardHelper` class that provides standardized methods for creating different styled glass cards:

1. `CardHelper.standardCard()` - For general content sections
2. `CardHelper.highlightCard()` - For important sections or calls to action (higher opacity and thicker border)
3. `CardHelper.darkCard()` - Dark themed card for contrast
4. `CardHelper.listCard()` - Optimized for lists of items (zero padding)
5. `CardHelper.statCard()` - Optimized for statistical data display

## Conversion Steps

### 1. Import the Required Classes

```dart
import 'package:trackie/presentation/helpers/card_helper.dart';
```

### 2. Replace Cards Based on Their Usage

#### Basic Card

**From:**
```dart
Card(
  elevation: 4.0,
  child: Padding(
    padding: EdgeInsets.all(16.0),
    child: YourContent(),
  ),
)
```

**To:**
```dart
CardHelper.standardCard(
  child: YourContent(),
)
```

#### For Lists

**From:**
```dart
Card(
  elevation: 4.0,
  child: Column(
    children: [
      ListTile(...),
      ListTile(...),
    ],
  ),
)
```

**To:**
```dart
CardHelper.listCard(
  children: [
    ListTile(...),
    ListTile(...),
  ],
)
```

#### For Statistics

**From:**
```dart
Card(
  elevation: 4.0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16.0),
  ),
  child: Padding(
    padding: EdgeInsets.all(16.0),
    child: YourStatsContent(),
  ),
)
```

**To:**
```dart
CardHelper.statCard(
  child: YourStatsContent(),
)
```

#### For Important Items

**From:**
```dart
Card(
  elevation: 6.0,
  child: Padding(
    padding: EdgeInsets.all(16.0),
    child: YourImportantContent(),
  ),
)
```

**To:**
```dart
CardHelper.highlightCard(
  child: YourImportantContent(),
)
```

### 3. Handle Special Cases

#### For Cards with Margin

The `GlassCard` doesn't have a built-in margin parameter. Wrap it in a `Padding` widget:

**From:**
```dart
Card(
  margin: EdgeInsets.only(bottom: 16.0),
  child: YourContent(),
)
```

**To:**
```dart
Padding(
  padding: EdgeInsets.only(bottom: 16.0),
  child: CardHelper.standardCard(
    child: YourContent(),
  ),
)
```

#### For Custom-Styled Cards

For cards with unique styling needs, use the `GlassCard` directly:

```dart
GlassCard(
  elevation: 4.0,
  opacity: 0.15,
  borderRadius: 12.0,
  color: Colors.blue, // For a blue tinted card
  borderColor: Colors.white.withOpacity(0.3),
  borderWidth: 1.5,
  child: YourContent(),
)
```

## Files Still Using Regular Cards

The following files have instances of `Card` that should be converted:

1. `statistics_screen.dart` 
2. `calendar_view_screen.dart`
3. `advanced_settings_screen.dart`

## Modified Files

These files have already been updated to use the new cards:

1. `dashboard_screen.dart`
2. `export_import_screen.dart`
3. `first_run_handler.dart` 