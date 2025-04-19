import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:trackie/core/di/dependency_injection.dart';
import 'package:trackie/core/services/first_run_service.dart';
import 'package:trackie/core/app_initialization.dart';
import 'package:trackie/core/utils/app_themes.dart';
import 'package:trackie/presentation/widgets/gradient_background.dart';
import 'package:trackie/presentation/helpers/card_helper.dart';
import 'package:country_flags/country_flags.dart';
import 'package:trackie/presentation/bloc/user_info/user_info_cubit.dart';
import 'package:trackie/presentation/bloc/manual_add/manual_add_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/presentation/bloc/manual_add/manual_add_cubit.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

/// Widget that handles showing onboarding screens and first-run tasks
///
/// This widget replaces the simple dialog approach with a more
/// comprehensive onboarding experience with multiple pages.
class FirstRunHandler extends StatefulWidget {
  final Widget child;
  final bool isDebugMode;

  const FirstRunHandler({
    super.key,
    required this.child,
    required this.isDebugMode,
  });

  @override
  State<FirstRunHandler> createState() => _FirstRunHandlerState();
}

class _FirstRunHandlerState extends State<FirstRunHandler> {
  final FirstRunService _firstRunService = getIt<FirstRunService>();
  bool _checkedFirstRun = false;
  bool _initializedBackgroundTasks = false;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    // Use a delay to ensure the Navigator is fully initialized
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _checkFirstRun();
      }
    });
  }

  /// Checks if this is the first run and shows onboarding if needed
  Future<void> _checkFirstRun() async {
    if (!_checkedFirstRun && mounted) {
      final isFirstRun = await _firstRunService.isFirstRun();

      setState(() {
        _checkedFirstRun = true;
        _showOnboarding = isFirstRun;
      });

      if (!isFirstRun) {
        // If not first run, initialize background tasks right away
        _initializeBackgroundTasks();
      }
      // If it is first run, the onboarding screen will handle the rest
    }
  }

  /// Initialize background tasks if not already done
  void _initializeBackgroundTasks() {
    if (!_initializedBackgroundTasks) {
      setState(() {
        _initializedBackgroundTasks = true;
      });

      // Initialize background tasks with the appropriate debug mode
      AppInitialization.initializeBackgroundTasks(
        isDebugMode: widget.isDebugMode,
      );

      log('Background tasks initialized with debug mode: ${widget.isDebugMode}');
    }
  }

  /// Completes the onboarding process
  Future<void> _completeOnboarding() async {
    // Mark first run as completed
    await _firstRunService.markFirstRunCompleted();

    // Initialize background tasks
    _initializeBackgroundTasks();

    // Hide onboarding
    if (mounted) {
      setState(() {
        _showOnboarding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return OnboardingScreen(
        onComplete: _completeOnboarding,
      );
    }

    return widget.child;
  }
}

/// The onboarding screen with multiple pages
class OnboardingScreen extends StatefulWidget {
  final Function() onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _pageCount = 4;
  // Add a navigator key as a class field
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // Add controllers for the new form fields
  final TextEditingController _nameController = TextEditingController();
  String? _selectedCountryCode;
  List<Country> _countryList = [];
  bool _batteryOptimizationEnabled = true;
  bool _isFormValid = false;

  // Animation controller for form fields
  late AnimationController _animationController;
  late Animation<double> _formOpacityAnimation;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    // Load the country list
    _loadCountries();

    // Add listener to validate the form
    _nameController.addListener(_validateForm);

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Slower animation
    );

    _formOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
  }

  // Load countries for the dropdown
  Future<void> _loadCountries() async {
    // This would typically come from a service or repository
    // For now, we'll use a simplified list of common countries
    setState(() {
      _countryList = [
        Country(name: 'United States', alpha2Code: 'US'),
        Country(name: 'United Kingdom', alpha2Code: 'GB'),
        Country(name: 'Canada', alpha2Code: 'CA'),
        Country(name: 'Australia', alpha2Code: 'AU'),
        Country(name: 'Germany', alpha2Code: 'DE'),
        Country(name: 'France', alpha2Code: 'FR'),
        Country(name: 'Japan', alpha2Code: 'JP'),
        Country(name: 'Brazil', alpha2Code: 'BR'),
        Country(name: 'India', alpha2Code: 'IN'),
        Country(name: 'China', alpha2Code: 'CN'),
        Country(name: 'Italy', alpha2Code: 'IT'),
        Country(name: 'Spain', alpha2Code: 'ES'),
        Country(name: 'Mexico', alpha2Code: 'MX'),
        Country(name: 'Russia', alpha2Code: 'RU'),
        Country(name: 'South Korea', alpha2Code: 'KR'),
        Country(name: 'Netherlands', alpha2Code: 'NL'),
        Country(name: 'Sweden', alpha2Code: 'SE'),
        Country(name: 'Switzerland', alpha2Code: 'CH'),
        Country(name: 'Norway', alpha2Code: 'NO'),
        Country(name: 'Denmark', alpha2Code: 'DK'),
        Country(name: 'Finland', alpha2Code: 'FI'),
        Country(name: 'Singapore', alpha2Code: 'SG'),
        Country(name: 'New Zealand', alpha2Code: 'NZ'),
        Country(name: 'Ireland', alpha2Code: 'IE'),
        Country(name: 'Portugal', alpha2Code: 'PT'),
        Country(name: 'Greece', alpha2Code: 'GR'),
        Country(name: 'Austria', alpha2Code: 'AT'),
        Country(name: 'Belgium', alpha2Code: 'BE'),
        Country(name: 'South Africa', alpha2Code: 'ZA'),
        Country(name: 'Argentina', alpha2Code: 'AR'),
      ];
    });
  }

  void _validateForm() {
    setState(() {
      _isFormValid =
          _nameController.text.isNotEmpty && _selectedCountryCode != null;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pageCount - 1) {
      // If moving to the user info page (which is the last page)
      if (_currentPage == _pageCount - 2) {
        // Reset form animation state
        setState(() {
          _showForm = false;
        });
        _animationController.reset();
      }

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    // Save user information first
    if (_nameController.text.isNotEmpty && _selectedCountryCode != null) {
      // Save user info using the UserInfoCubit
      final userInfoCubit = getIt<UserInfoCubit>();
      await userInfoCubit.saveUserInfo(
        name: _nameController.text,
        countryCode: _selectedCountryCode!,
      );

      log('User name: ${_nameController.text}');
      log('User country: $_selectedCountryCode');
    } else {
      // If fields are not filled, don't proceed
      return;
    }

    // Set battery optimization based on switch value without showing dialog
    // The switch in the UI controls this value directly
    log('Battery optimization enabled: $_batteryOptimizationEnabled');

    // Complete onboarding
    await widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      // Set navigatorKey to make sure we always have a valid navigator context
      navigatorKey: _navigatorKey,
      home: Scaffold(
        body: GradientScaffold(
          body: SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    // Content - PageView
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        children: [
                          // Welcome page
                          _buildOnboardingPage(
                            title: 'Welcome to Travel Companion',
                            description:
                                'Track your travels and keep a digital record of places you\'ve visited.',
                            icon: Icons.travel_explore,
                            color: Colors.blue,
                          ),

                          // Features page
                          _buildOnboardingPage(
                            title: 'Key Features',
                            description:
                                'Automatic location tracking, travel statistics, and trip history.',
                            icon: Icons.map,
                            color: Colors.green,
                          ),

                          // Permissions page
                          _buildOnboardingPage(
                            title: 'One Last Thing',
                            description:
                                'We need permission to track your location in the background for accurate travel logs.',
                            icon: Icons.location_on,
                            color: Colors.orange,
                          ),

                          // User info page
                          _buildUserInfoPage(),
                        ],
                      ),
                    ),

                    // Bottom section (non-scrollable)
                    Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Page indicator
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _pageCount,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentPage == index
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.primary
                                            .withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Navigation buttons
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (_currentPage > 0)
                                  TextButton(
                                    onPressed: () {
                                      _pageController.previousPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    child: const Text('Back'),
                                  )
                                else
                                  const SizedBox(width: 80),
                                ElevatedButton(
                                  onPressed: (_currentPage < _pageCount - 1 ||
                                          _isFormValid)
                                      ? _nextPage
                                      : null, // Disable on last page unless form is valid
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    _currentPage < _pageCount - 1
                                        ? 'Next'
                                        : 'Get Started',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: CardHelper.coloredCard(
        color: color,
        elevation: 4.0,
        padding: const EdgeInsets.all(24.0), // Slightly smaller padding
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: Icon(
                      icon,
                      size: 80,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title text
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24, // Slightly smaller font
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Description text
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // New method to build the user info page
  Widget _buildUserInfoPage() {
    return SafeArea(
      // Wrap in Scaffold to provide ScaffoldMessenger
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated heading text - slower speed
                  Center(
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Let me know you better',
                          textStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppThemes.lightGreen,
                          ),
                          speed:
                              const Duration(milliseconds: 150), // Slower speed
                        ),
                      ],
                      totalRepeatCount: 1,
                      onFinished: () {
                        setState(() {
                          _showForm = true;
                        });
                        _animationController.forward();
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form fields with fade-in animation
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _showForm ? _formOpacityAnimation.value : 0.0,
                        child: child,
                      );
                    },
                    child: Column(
                      children: [
                        // Name text field
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: "What's your name?*",
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(Icons.person),
                            helperText: "Required",
                          ),
                          onChanged: (_) => _validateForm(),
                        ),
                        const SizedBox(height: 20),

                        // Country selection field
                        _buildCountrySelectionField(),
                        const SizedBox(height: 20),

                        // Battery optimization heading
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                          child: Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        // Battery optimization switch
                        SwitchListTile(
                          title: const Text(
                            'Allow background location tracking',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: const Text(
                            'Enabling this will improve accuracy but may use more battery',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          value: _batteryOptimizationEnabled,
                          onChanged: (value) {
                            setState(() {
                              _batteryOptimizationEnabled = value;
                            });
                            // Use _navigatorKey.currentContext to show SnackBar
                            if (_navigatorKey.currentContext != null) {
                              ScaffoldMessenger.of(
                                      _navigatorKey.currentContext!)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    value
                                        ? 'Background tracking enabled'
                                        : 'Background tracking disabled',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                              );
                            }
                          },
                          tileColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          dense: true,
                        ),

                        if (!_isFormValid)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              'Please fill in all required fields',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build the country selection field
  Widget _buildCountrySelectionField() {
    return FormField<String>(
      validator: (value) {
        if (_selectedCountryCode == null) {
          return 'Please select a country';
        }
        return null;
      },
      builder: (FormFieldState<String> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                // Explicitly unfocus before showing modal
                FocusScope.of(context).unfocus();

                // Show country picker immediately using the navigator key context
                _showCountryPicker(context);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Where are you located?*',
                  hintText: 'Select a country',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.flag),
                  errorText: field.errorText,
                  filled: true,
                  fillColor: Colors.white,
                  helperText: "Required",
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _selectedCountryCode != null
                          ? _buildCountryDisplay(_selectedCountryCode!)
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

  // Display selected country with flag
  Widget _buildCountryDisplay(String countryCode) {
    String countryName = countryCode;
    for (var country in _countryList) {
      if (country.alpha2Code == countryCode) {
        countryName = country.name;
        break;
      }
    }

    return Row(
      children: [
        // Use a simple container with a flag emoji instead of CountryFlag widget
        Container(
          width: 30,
          height: 24,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(
            countryEmoji(countryCode),
            style: const TextStyle(fontSize: 16),
          ),
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

  // Show a country picker dialog
  void _showCountryPicker(BuildContext context) {
    // Get ManualAddCubit from dependency injection
    final ManualAddCubit cubit = getIt<ManualAddCubit>();
    cubit.setSearching(true);

    // Get the context from the navigator key to ensure we have a valid navigation context
    final navigatorContext = _navigatorKey.currentContext;

    if (navigatorContext == null) {
      // If navigator context is null, we can't show the modal - should not happen
      log('Error: Navigator context is null');
      return;
    }

    showModalBottomSheet(
      context:
          navigatorContext, // Use navigator context instead of the passed context
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext modalContext) {
        // Calculate a higher position to avoid keyboard
        final keyboardHeight = MediaQuery.of(modalContext).viewInsets.bottom;
        final screenHeight = MediaQuery.of(modalContext).size.height;
        // Reduce height to 60% instead of 70%
        final modalHeight = screenHeight * 0.6;

        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<ManualAddCubit, ManualAddState>(
            builder: (modalContext, state) {
              if (state is CountriesLoaded) {
                // Create a custom modal without using go_router's context.pop()
                return Padding(
                  // Apply padding to move the modal up when keyboard is visible
                  padding: EdgeInsets.only(
                    bottom: keyboardHeight > 0 ? keyboardHeight * 0.7 : 0,
                    // Add additional top padding to push content up
                    top: 8,
                  ),
                  child: Container(
                    height: modalHeight,
                    padding:
                        const EdgeInsets.only(top: 16, left: 16, right: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title row with close button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Select Country',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(modalContext).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Search field
                        TextField(
                          controller: cubit.searchController,
                          autofocus: false,
                          decoration: InputDecoration(
                            hintText: 'Search countries...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: cubit.searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      cubit.searchController.clear();
                                      cubit.filterCountries();
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) => cubit.filterCountries(),
                        ),
                        const SizedBox(height: 16),
                        // Country list
                        Expanded(
                          child: state.filteredCountries.isNotEmpty
                              ? ListView.builder(
                                  itemCount: state.filteredCountries.length,
                                  // Ensure scrolling works well
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  // Make each item smaller to fit more countries
                                  itemExtent: 60,
                                  itemBuilder: (context, index) {
                                    final country =
                                        state.filteredCountries[index];
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
                                        // 1. Get the country code
                                        final String selectedCode =
                                            country.alpha2Code;

                                        // 2. Set autofocus to false on the text field first
                                        cubit.searchController.text = '';

                                        // 3. Clear focus
                                        FocusScope.of(modalContext).unfocus();

                                        // 4. Dismiss with the correct Navigator context
                                        Navigator.of(modalContext).pop();

                                        // 5. Update the state after modal is closed
                                        Future.microtask(() {
                                          if (mounted) {
                                            setState(() {
                                              _selectedCountryCode =
                                                  selectedCode;
                                            });
                                            _validateForm();

                                            // 6. Ensure the parent screen doesn't focus on any field
                                            FocusScope.of(context).unfocus();
                                          }
                                        });
                                      },
                                    );
                                  },
                                )
                              : const Center(
                                  child: Text(
                                    'No countries found',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        );
      },
    ).then((_) {
      if (mounted) {
        cubit.setSearching(false);

        // Ensure no field has focus after modal is dismissed
        FocusScope.of(context).unfocus();

        // Add small delay to prevent focus
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            FocusScope.of(context).unfocus();
          }
        });
      }
    });
  }

  // Helper function to convert country code to emoji flag
  String countryEmoji(String countryCode) {
    // Convert country code to emoji flag
    final flagOffset = 0x1F1E6;
    final asciiOffset = 0x41;

    final firstChar = countryCode.codeUnitAt(0) - asciiOffset + flagOffset;
    final secondChar = countryCode.codeUnitAt(1) - asciiOffset + flagOffset;

    return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
  }
}

// Simple Country class for the dropdown
class Country {
  final String name;
  final String alpha2Code;

  Country({required this.name, required this.alpha2Code});
}
