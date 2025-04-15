import 'package:flutter/material.dart';
import 'package:trackie/core/di/dependency_injection.dart';
import 'package:trackie/core/services/first_run_service.dart';
import 'package:trackie/core/app_initialization.dart';
import 'package:trackie/presentation/widgets/gradient_background.dart';
import 'package:trackie/presentation/helpers/card_helper.dart';

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
  final int _pageCount = 3;

  @override
  void dispose() {
    _pageController.dispose();
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
    // Request battery optimization on the last page
    await widget.requestBatteryOptimization();

    // Complete onboarding
    await widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
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
                ],
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pageCount,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox(width: 80),
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      _currentPage < _pageCount - 1 ? 'Next' : 'Get Started',
                    ),
                  ),
                ],
              ),
            ),
          ],
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
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 100,
              color: color,
            ),
            const SizedBox(height: 28),
            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
