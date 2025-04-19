import 'package:flutter/material.dart';
import 'package:trackie/core/di/dependency_injection.dart';
import 'package:trackie/core/services/first_run_service.dart';
import 'package:trackie/core/app_initialization.dart';
import 'package:trackie/presentation/widgets/gradient_background.dart';
import 'package:trackie/presentation/helpers/card_helper.dart';
import 'package:country_flags/country_flags.dart';
import 'package:trackie/presentation/bloc/user_info/user_info_cubit.dart';

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

      debugPrint(
          'Background tasks initialized with debug mode: ${widget.isDebugMode}');
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
        requestBatteryOptimization: () async {
          if (mounted) {
            return await _firstRunService
                .showBatteryOptimizationDialog(context);
          }
          return false;
        },
      );
    }

    return widget.child;
  }
}

/// The onboarding screen with multiple pages
class OnboardingScreen extends StatefulWidget {
  final Function() onComplete;
  final Future<bool> Function() requestBatteryOptimization;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
    required this.requestBatteryOptimization,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
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

  @override
  void initState() {
    super.initState();
    // Load the country list
    _loadCountries();

    // Add listener to validate the form
    _nameController.addListener(_validateForm);
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
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pageCount - 1) {
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

      debugPrint('User name: ${_nameController.text}');
      debugPrint('User country: $_selectedCountryCode');
    } else {
      // If fields are not filled, don't proceed
      return;
    }

    // Request battery optimization if enabled
    if (_batteryOptimizationEnabled) {
      await widget.requestBatteryOptimization();
    }

    // Complete onboarding
    await widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => Scaffold(
            body: GradientScaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    // Content - PageView
                    Expanded(
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
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: CardHelper.coloredCard(
        color: Colors.purple,
        elevation: 4.0,
        padding: const EdgeInsets.all(24.0), // Reduced padding
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Let me know you better',
                  style: TextStyle(
                    fontSize: 22, // Reduced size
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

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
                  'Allow battery optimization',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                subtitle: const Text(
                  'Enable for accurate background location tracking',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                value: _batteryOptimizationEnabled,
                onChanged: (value) {
                  setState(() {
                    _batteryOptimizationEnabled = value;
                  });
                },
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
      ),
    );
  }

  // Build the country selection field
  Widget _buildCountrySelectionField() {
    // Use a Builder to get the correct context
    return Builder(builder: (BuildContext builderContext) {
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
                onTap: () => _showCountryPicker(builderContext),
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
    });
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Select Your Country',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _countryList.length,
                    itemBuilder: (context, index) {
                      final country = _countryList[index];
                      return ListTile(
                        leading: Container(
                          width: 30,
                          height: 24,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            countryEmoji(country.alpha2Code),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        title: Text(country.name),
                        onTap: () {
                          setState(() {
                            _selectedCountryCode = country.alpha2Code;
                          });
                          _validateForm();
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
