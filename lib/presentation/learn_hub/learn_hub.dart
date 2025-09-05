import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import './widgets/simple_learn_card_widget.dart';

class LearnHub extends StatefulWidget {
  const LearnHub({Key? key}) : super(key: key);

  @override
  State<LearnHub> createState() => _LearnHubState();
}

class _LearnHubState extends State<LearnHub> {
  int _selectedBottomIndex = 2; // Learn tab active

  // Configurable learning URLs
  final String _baseLearnUrl = const String.fromEnvironment(
      'LEARN_HUB_BASE_URL',
      defaultValue: 'https://kosh.app/learn/placeholder');

  // Simple learning topics for MVP
  late final List<Map<String, dynamic>> _learningTopics;

  @override
  void initState() {
    super.initState();
    _learningTopics = [
      {
        'id': 'stocks',
        'title': 'What is a stock?',
        'description': 'Basic intro to stock investing and market fundamentals',
        'icon': 'trending_up',
        'url': '$_baseLearnUrl/stocks'
      },
      {
        'id': 'mutual_funds',
        'title': 'What is a mutual fund?',
        'description':
            'Understanding mutual funds and SIP investment strategies',
        'icon': 'pie_chart',
        'url': '$_baseLearnUrl/mutual-funds'
      },
      {
        'id': 'profit_loss',
        'title': 'What is P/L?',
        'description': 'Learn about profit and loss in trading and investing',
        'icon': 'analytics',
        'url': '$_baseLearnUrl/profit-loss'
      },
      {
        'id': 'bo_account',
        'title': 'What is a BO account?',
        'description':
            'Everything about Beneficiary Owner accounts in Bangladesh',
        'icon': 'account_balance',
        'url': '$_baseLearnUrl/bo-account'
      },
      {
        'id': 'trading_basics',
        'title': 'How to buy and sell?',
        'description': 'Step-by-step guide to placing your first trade',
        'icon': 'swap_horiz',
        'url': '$_baseLearnUrl/trading-basics'
      },
    ];
  }

  Future<void> _openLearnMore(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Open in external browser
        );
      } else {
        _showError('Could not open learning content. Please try again later.');
      }
    } catch (e) {
      _showError('Could not open learning content. Please try again later.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Learn',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                        ),
                        Text(
                          'Build your investing knowledge',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/user-profile-settings');
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      child: CustomIconWidget(
                        iconName: 'notifications_outlined',
                        size: 24,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),

                    // Section title
                    Text(
                      'Essential Topics',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                    ),

                    SizedBox(height: 1.h),

                    Text(
                      'Master the basics with our curated learning materials',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                    ),

                    SizedBox(height: 3.h),

                    // Learning cards
                    ...List.generate(_learningTopics.length, (index) {
                      final topic = _learningTopics[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: SimpleLearnCardWidget(
                          title: topic['title'] as String,
                          description: topic['description'] as String,
                          iconName: topic['icon'] as String,
                          onLearnMore: () =>
                              _openLearnMore(topic['url'] as String),
                        ),
                      );
                    }),

                    SizedBox(height: 4.h),

                    // Trust indicators
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
                                  'BSEC Compliant & Trusted',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
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
                                iconName: 'school',
                                color: AppTheme.accentColor,
                                size: 6.w,
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Text(
                                  'Expert-curated learning content',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
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

                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomIndex,
        onTap: (index) {
          setState(() {
            _selectedBottomIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/dashboard-home');
              break;
            case 1:
              Navigator.pushNamed(context, '/markets-browse');
              break;
            case 2:
              // Already on Learn Hub
              break;
            case 3:
              Navigator.pushNamed(context, '/portfolio-holdings');
              break;
            case 4:
              Navigator.pushNamed(context, '/user-profile-settings');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home_outlined',
              size: 24,
              color: _selectedBottomIndex == 0
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'home',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'trending_up',
              size: 24,
              color: _selectedBottomIndex == 1
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            label: 'Markets',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'school_outlined',
              size: 24,
              color: _selectedBottomIndex == 2
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'school',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'account_balance_wallet_outlined',
              size: 24,
              color: _selectedBottomIndex == 3
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'account_balance_wallet',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            label: 'Portfolio',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person_outlined',
              size: 24,
              color: _selectedBottomIndex == 4
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'person',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
