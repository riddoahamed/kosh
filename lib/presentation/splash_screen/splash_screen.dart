import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/loading_indicator_widget.dart';
import './widgets/retry_button_widget.dart';
import './widgets/trust_badge_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = true;
  bool _showRetry = false;
  String _loadingText = 'Initializing...';
  bool _isAuthenticated = false;
  bool _hasCompletedOnboarding = false;
  bool _networkTimeout = false;

  final List<String> _loadingSteps = [
    'Initializing...',
    'Checking authentication...',
    'Loading user preferences...',
    'Fetching market data...',
    'Preparing dashboard...',
  ];

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _isLoading = true;
        _showRetry = false;
        _networkTimeout = false;
        _currentStep = 0;
      });

      // Check network connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        _handleNetworkError();
        return;
      }

      // Step 1: Initialize core services
      await _updateLoadingStep(0);
      await _initializeCoreServices();

      // Step 2: Check authentication status
      await _updateLoadingStep(1);
      await _checkAuthenticationStatus();

      // Step 3: Load user preferences
      await _updateLoadingStep(2);
      await _loadUserPreferences();

      // Step 4: Fetch market data cache
      await _updateLoadingStep(3);
      await _fetchMarketDataCache();

      // Step 5: Prepare dashboard
      await _updateLoadingStep(4);
      await _prepareDashboard();

      // Complete initialization
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateToNextScreen();
    } catch (e) {
      _handleInitializationError();
    }
  }

  Future<void> _updateLoadingStep(int step) async {
    if (step < _loadingSteps.length) {
      setState(() {
        _currentStep = step;
        _loadingText = _loadingSteps[step];
      });
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }

  Future<void> _initializeCoreServices() async {
    // Initialize core app services
    await Future.delayed(const Duration(milliseconds: 500));

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppTheme.lightTheme.primaryColor,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.lightTheme.colorScheme.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');
      final userId = prefs.getString('user_id');

      _isAuthenticated =
          authToken != null &&
          authToken.isNotEmpty &&
          userId != null &&
          userId.isNotEmpty;

      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      _isAuthenticated = false;
    }
  }

  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Load other user preferences
      final theme = prefs.getString('theme_mode') ?? 'light';
      final language = prefs.getString('language') ?? 'en';

      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      // Handle gracefully - onboarding no longer required
    }
  }

  Future<void> _fetchMarketDataCache() async {
    try {
      // Simulate fetching market data cache
      await Future.delayed(const Duration(milliseconds: 800));

      // Check if cache needs update
      final prefs = await SharedPreferences.getInstance();
      final lastUpdate = prefs.getString('last_market_update');
      final now = DateTime.now().toIso8601String();

      if (lastUpdate == null) {
        await prefs.setString('last_market_update', now);
      }
    } catch (e) {
      // Handle cache error gracefully
    }
  }

  Future<void> _prepareDashboard() async {
    try {
      // Prepare dashboard data and UI
      await Future.delayed(const Duration(milliseconds: 600));

      // Initialize user mode (fantasy/real)
      final prefs = await SharedPreferences.getInstance();
      final userMode = prefs.getString('user_mode') ?? 'fantasy';

      // Set last active timestamp
      await prefs.setString('last_active', DateTime.now().toIso8601String());
    } catch (e) {
      // Handle preparation error gracefully
    }
  }

  void _handleNetworkError() {
    setState(() {
      _isLoading = false;
      _showRetry = true;
      _networkTimeout = true;
    });
  }

  void _handleInitializationError() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showRetry = true;
          _networkTimeout = true;
        });
      }
    });
  }

  void _navigateToNextScreen() {
    _fadeController.forward().then((_) {
      if (!mounted) return;

      String nextRoute;

      // Removed onboarding flow completely - go directly to login or markets
      if (!_isAuthenticated) {
        nextRoute = '/login-screen';
      } else {
        nextRoute =
            '/markets-browse'; // Navigate to Markets Browse instead of dashboard
      }

      Navigator.pushReplacementNamed(context, nextRoute);
    });
  }

  void _retryInitialization() {
    _initializeApp();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.lightTheme.colorScheme.surface,
                  AppTheme.lightTheme.colorScheme.surface.withValues(
                    alpha: 0.95,
                  ),
                ],
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Logo
                      const AnimatedLogoWidget(),

                      SizedBox(height: 8.h),

                      // Loading or Retry Content
                      _showRetry
                          ? RetryButtonWidget(
                            onRetry: _retryInitialization,
                            message:
                                _networkTimeout
                                    ? 'Connection timeout. Please check your internet connection.'
                                    : 'Something went wrong. Please try again.',
                          )
                          : LoadingIndicatorWidget(loadingText: _loadingText),
                    ],
                  ),
                ),

                // Bottom Trust Elements
                Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Column(
                    children: [
                      const TrustBadgeWidget(),
                      SizedBox(height: 2.h),
                      Text(
                        'Secure • Trusted • BSEC Compliant',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                          color: AppTheme
                              .lightTheme
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Last updated: ${DateTime.now().toString().substring(0, 16)}',
                        style: GoogleFonts.inter(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w300,
                          color: AppTheme
                              .lightTheme
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.5),
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
    );
  }
}
