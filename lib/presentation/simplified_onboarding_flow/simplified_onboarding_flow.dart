import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/experience_selection_widget.dart';
import './widgets/onboarding_slide_widget.dart';
import './widgets/progress_indicator_widget.dart';

class SimplifiedOnboardingFlow extends StatefulWidget {
  const SimplifiedOnboardingFlow({Key? key}) : super(key: key);

  @override
  State<SimplifiedOnboardingFlow> createState() =>
      _SimplifiedOnboardingFlowState();
}

class _SimplifiedOnboardingFlowState extends State<SimplifiedOnboardingFlow> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  String? _selectedExperience;

  final List<Map<String, dynamic>> _slides = [
    {
      "title": "What is KOSH?",
      "subtitle": "Your gateway to smart investing",
      "description":
          "Practice trading with virtual money, learn market dynamics without risk, and graduate to real-money investing when you're ready.",
      "imageUrl":
          "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "features": [
        "Start with virtual money for risk-free learning",
        "Access real market data and price movements",
        "Build confidence before investing real funds",
        "Track your portfolio performance in real-time"
      ]
    }
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onExperienceSelected(String experience) {
    setState(() {
      _selectedExperience = experience;
    });
  }

  Future<void> _completeOnboarding() async {
    if (_selectedExperience == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your experience level to continue'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Store onboarding completion and experience level
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasOnboarded', true);
      await prefs.setString('experienceLevel', _selectedExperience!);

      // TODO: Update user profile in Supabase with hasOnboarded=true and experienceLevel

      // Navigate to Markets
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.marketsBrowse);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error completing onboarding: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _skipOnboarding() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Skip Onboarding?'),
          content: const Text(
            'You can always access this tutorial later from Settings. Are you sure you want to skip?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
              ),
              child: const Text('Skip'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Mark onboarding as completed but without experience level
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasOnboarded', true);

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.marketsBrowse);
      }
    }
  }

  void _nextSlide() {
    if (_currentPage < _slides.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Skip button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Welcome to KOSH',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryLight,
                        ),
                  ),
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: AppTheme.textSecondaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Progress indicator
            ProgressIndicatorWidget(
              currentStep: _currentPage + 1,
              totalSteps: 2,
            ),

            // Content area
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: 2, // Fixed 2 slides
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // First slide: What is KOSH
                    return OnboardingSlideWidget(
                      slideData: _slides[0],
                      onNext: _nextSlide,
                    );
                  } else {
                    // Second slide: Experience selection
                    return ExperienceSelectionWidget(
                      selectedExperience: _selectedExperience,
                      onExperienceSelected: _onExperienceSelected,
                      onComplete: _completeOnboarding,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
