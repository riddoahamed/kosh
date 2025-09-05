import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/experience_selection_widget.dart';
import './widgets/interactive_demo_widget.dart';
import './widgets/onboarding_page_widget.dart';
import './widgets/progress_indicator_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _selectedExperience = '';
  bool _showExitDialog = false;

  final List<Map<String, dynamic>> _onboardingPages = [
    {
      'title': 'Welcome to KOSH',
      'description':
          'Your trusted companion for learning investing. Start with virtual money and grow your confidence before investing real funds.',
      'imageUrl':
          'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      'buttonText': 'Get Started',
    },
    {
      'title': 'Fantasy Trading Mode',
      'description':
          'Practice with ৳50,000 virtual money. Learn market dynamics, test strategies, and build confidence without any risk.',
      'imageUrl':
          'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      'buttonText': 'Learn More',
    },
    {
      'title': 'Real Market Data',
      'description':
          'Access live prices from Dhaka Stock Exchange. Track stocks, mutual funds, and gold with real-time updates twice daily.',
      'imageUrl':
          'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      'buttonText': 'Explore Markets',
    },
    {
      'title': 'Learn & Grow',
      'description':
          'Access educational content, tutorials, and tips from financial experts. Build your knowledge step by step.',
      'imageUrl':
          'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      'buttonText': 'Start Learning',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _getTotalPages() - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _showExitConfirmation();
  }

  void _completeOnboarding() {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    // Navigate to dashboard
    Navigator.pushReplacementNamed(context, '/dashboard-home');
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Skip Tutorial?',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'You can always access the tutorial later from Settings. Are you sure you want to skip?',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Continue Tutorial',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _completeOnboarding();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              ),
              child: Text(
                'Skip',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  int _getTotalPages() {
    return _onboardingPages.length +
        2; // +2 for experience selection and interactive demo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Progress indicator
          ProgressIndicatorWidget(
            currentPage: _currentPage,
            totalPages: _getTotalPages(),
          ),

          // Page content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                HapticFeedback.selectionClick();
              },
              itemCount: _getTotalPages(),
              itemBuilder: (context, index) {
                if (index < _onboardingPages.length) {
                  // Regular onboarding pages
                  final pageData = _onboardingPages[index];
                  return OnboardingPageWidget(
                    title: pageData['title'] as String,
                    description: pageData['description'] as String,
                    imageUrl: pageData['imageUrl'] as String,
                    buttonText: pageData['buttonText'] as String,
                    onSkip: _skipOnboarding,
                    onNext: _nextPage,
                  );
                } else if (index == _onboardingPages.length) {
                  // Experience selection page
                  return ExperienceSelectionWidget(
                    selectedLevel: _selectedExperience,
                    onLevelSelected: (level) {
                      setState(() {
                        _selectedExperience = level;
                      });
                      HapticFeedback.selectionClick();
                    },
                    onNext: _nextPage,
                  );
                } else if (index == _onboardingPages.length + 1) {
                  // Interactive demo page
                  return InteractiveDemoWidget(
                    onNext: () {
                      // Show completion screen
                      _showCompletionScreen();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionScreen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              SizedBox(height: 4.h),

              // Success icon
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'celebration',
                  color: AppTheme.accentColor,
                  size: 10.w,
                ),
              ),

              SizedBox(height: 3.h),

              // Title
              Text(
                'You\'re All Set!',
                style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 2.h),

              // Description
              Text(
                'Welcome to KOSH! You\'ll start with ৳50,000 virtual money in Fantasy Mode. Practice, learn, and build confidence.',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 4.h),

              // Trust signals
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'security',
                          color: AppTheme.accentColor,
                          size: 6.w,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            'BSEC Compliant & Secure',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'trending_up',
                          color: AppTheme.accentColor,
                          size: 6.w,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            'Real Market Data from DSE',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Start investing button
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _completeOnboarding();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Start Investing Journey',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
