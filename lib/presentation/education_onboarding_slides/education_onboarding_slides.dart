import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/onboarding_slide_widget.dart';
import './widgets/progress_dots_widget.dart';
import './widgets/skip_button_widget.dart';

class EducationOnboardingSlides extends StatefulWidget {
  const EducationOnboardingSlides({Key? key}) : super(key: key);

  @override
  State<EducationOnboardingSlides> createState() =>
      _EducationOnboardingSlidesState();
}

class _EducationOnboardingSlidesState extends State<EducationOnboardingSlides>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;
  bool _isLastPage = false;

  final List<Map<String, dynamic>> _slides = [
    {
      "title": "What is KOSH?",
      "description":
          "Easy investing: start with play money or join our real-money beta.",
      "content": [
        "Practice with virtual money before investing real funds",
        "Learn market dynamics without financial risk",
        "Graduate to real-money beta when you're ready",
        "Build confidence through hands-on experience"
      ],
      "imageUrl":
          "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "backgroundColor": const Color(0xFFF8F9FA),
      "accentColor": AppTheme.primaryLight,
    },
    {
      "title": "What is a BO Account?",
      "description": "Like a bank account for your shares in Bangladesh.",
      "content": [
        "Beneficiary Owner Account holds your securities",
        "Required for all stock trading in Bangladesh",
        "Your shares are registered in your name",
        "Secure digital record of your investments"
      ],
      "imageUrl":
          "https://images.unsplash.com/photo-1554224155-6726b3ff858f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "backgroundColor": const Color(0xFFE8F5E8),
      "accentColor": AppTheme.accentColor,
    },
    {
      "title": "How to Invest",
      "description": "Search → choose amount or shares → Buy/Sell.",
      "content": [
        "Search for stocks using company names or symbols",
        "Choose to invest by amount (BDT) or share quantity",
        "Review order details before confirmation",
        "Orders execute at current market prices"
      ],
      "imageUrl":
          "https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "backgroundColor": const Color(0xFFFFF8E1),
      "accentColor": AppTheme.warningColor,
    },
    {
      "title": "Track Portfolio",
      "description": "See profit/loss anytime. Learning by doing.",
      "content": [
        "Real-time portfolio value updates",
        "Track individual stock performance",
        "View profit/loss with clear indicators",
        "Learn from market movements and decisions"
      ],
      "imageUrl":
          "https://images.unsplash.com/photo-1460925895917-afdab827c52f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "backgroundColor": const Color(0xFFF3E5F5),
      "accentColor": const Color(0xFF9C27B0),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _isLastPage = page == _slides.length - 1;
    });
  }

  Future<void> _markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('education_onboarding_completed', true);
    await prefs.setBool('FEATURE_EDU_TOOLTIPS', true);
  }

  Future<void> _handleSkip() async {
    final confirmed = await _showSkipConfirmation();
    if (confirmed == true) {
      await _markOnboardingComplete();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboardHome);
      }
    }
  }

  Future<void> _handleNext() async {
    if (_isLastPage) {
      await _markOnboardingComplete();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboardHome);
      }
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<bool?> _showSkipConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Skip Tutorial?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
          ),
          content: Text(
            'You can always access this tutorial later from Settings. Are you sure you want to skip?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondaryLight),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                foregroundColor: Colors.white,
              ),
              child: const Text('Skip'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header with Skip Button
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
                    SkipButtonWidget(
                      onTap: _handleSkip,
                    ),
                  ],
                ),
              ),

              // Progress Dots
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: ProgressDotsWidget(
                  controller: _pageController,
                  count: _slides.length,
                  currentPage: _currentPage,
                ),
              ),

              // Page Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    return OnboardingSlideWidget(
                      slideData: _slides[index],
                      isActive: index == _currentPage,
                    );
                  },
                ),
              ),

              // Bottom Button
              Padding(
                padding: EdgeInsets.all(4.w),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _slides[_currentPage]['accentColor'] as Color,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 4.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      _isLastPage ? 'Get Started' : 'Next',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
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
