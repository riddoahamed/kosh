import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';

class LearnHub extends StatefulWidget {
  const LearnHub({Key? key}) : super(key: key);

  @override
  State<LearnHub> createState() => _LearnHubState();
}

class _LearnHubState extends State<LearnHub> {
  int _selectedBottomIndex = 2; // Learn tab active

  // Simple FAQ data - linking to placeholder website URLs
  final List<Map<String, dynamic>> _faqData = [
    {
      'question': 'How do I open a BO account?',
      'answer':
          'Learn about opening a BO (Beneficiary Owner) account with our partner brokers.',
      'url': 'https://kosh.com.bd/help/bo-account',
      'icon': 'account_balance',
    },
    {
      'question': 'How to buy and sell shares?',
      'answer':
          'Step-by-step guide to placing buy and sell orders in the stock market.',
      'url': 'https://kosh.com.bd/help/trading-guide',
      'icon': 'swap_horiz',
    },
    {
      'question': 'Understanding your portfolio',
      'answer':
          'Learn how to track your investments and monitor portfolio performance.',
      'url': 'https://kosh.com.bd/help/portfolio-management',
      'icon': 'pie_chart',
    },
    {
      'question': 'Stock market basics',
      'answer':
          'Essential concepts every investor should know about the stock market.',
      'url': 'https://kosh.com.bd/help/market-basics',
      'icon': 'trending_up',
    },
    {
      'question': 'Investment risks and safety',
      'answer':
          'Important information about investment risks and how to invest safely.',
      'url': 'https://kosh.com.bd/help/investment-safety',
      'icon': 'security',
    },
  ];

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
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
                          'Quick help and investment basics',
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
                      Navigator.pushNamed(
                          context, AppRoutes.notificationsCenter);
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

            // FAQ Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Frequently Asked Questions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                    ),
                    SizedBox(height: 2.h),

                    // FAQ Cards
                    ...(_faqData.map((faq) => Container(
                          margin: EdgeInsets.only(bottom: 2.h),
                          child: InkWell(
                            onTap: () => _launchURL(faq['url']),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
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
                                  Container(
                                    padding: EdgeInsets.all(3.w),
                                    decoration: BoxDecoration(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: CustomIconWidget(
                                      iconName: faq['icon'],
                                      size: 24,
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          faq['question'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.lightTheme
                                                    .colorScheme.onSurface,
                                              ),
                                        ),
                                        SizedBox(height: 1.h),
                                        Text(
                                          faq['answer'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CustomIconWidget(
                                    iconName: 'open_in_new',
                                    size: 20,
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ))),

                    SizedBox(height: 4.h),

                    // Contact Support Card
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primaryContainer
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'help_outline',
                                size: 24,
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Need More Help?',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Contact our support team for personalized help with your investment questions.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                          ),
                          SizedBox(height: 2.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () =>
                                  _launchURL('https://kosh.com.bd/support'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppTheme.lightTheme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text('Contact Support'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10.h), // Bottom padding for navigation
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
              Navigator.pushNamed(context, AppRoutes.marketsBrowse);
              break;
            case 1:
              Navigator.pushNamed(context, AppRoutes.portfolioHoldings);
              break;
            case 2:
              // Already on Learn Hub
              break;
            case 3:
              Navigator.pushNamed(context, AppRoutes.notificationsCenter);
              break;
            case 4:
              Navigator.pushNamed(context, AppRoutes.userProfileSettings);
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'trending_up',
              size: 24,
              color: _selectedBottomIndex == 0
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            label: 'Markets',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'account_balance_wallet_outlined',
              size: 24,
              color: _selectedBottomIndex == 1
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
              iconName: 'notifications_outlined',
              size: 24,
              color: _selectedBottomIndex == 3
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'notifications',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            label: 'Updates',
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
