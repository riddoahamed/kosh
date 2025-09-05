import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/holdings_card.dart';
import './widgets/market_highlight_card.dart';
import './widgets/portfolio_value_card.dart';
import './widgets/quick_action_bottom_sheet.dart';
import './widgets/transaction_item.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({Key? key}) : super(key: key);

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome>
    with TickerProviderStateMixin {
  bool _isBalanceVisible = true;
  bool _isFantasyMode = true;
  bool _isRefreshing = false;
  int _selectedTabIndex = 0;
  late TabController _tabController;

  // Mock user data
  final String _userName = "Ahmed Rahman";
  final double _totalBalance = 125750.50;
  final double _dayChange = 2450.75;
  final double _dayChangePercentage = 1.98;

  // Mock holdings data
  final List<Map<String, dynamic>> _holdings = [
    {
      "id": 1,
      "symbol": "SQRPHARMA",
      "name": "Square Pharmaceuticals Ltd.",
      "type": "stock",
      "quantity": 50,
      "currentValue": 12500.00,
      "dayChange": 250.00,
      "dayChangePercentage": 2.04,
      "logo":
          "https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=100&h=100&fit=crop&crop=center"
    },
    {
      "id": 2,
      "symbol": "BRACBANK",
      "name": "BRAC Bank Limited",
      "type": "stock",
      "quantity": 100,
      "currentValue": 8750.00,
      "dayChange": -125.00,
      "dayChangePercentage": -1.41,
      "logo":
          "https://images.unsplash.com/photo-1541354329998-f4d9a9f9297f?w=100&h=100&fit=crop&crop=center"
    },
    {
      "id": 3,
      "symbol": "GOLDMF",
      "name": "Gold Mutual Fund",
      "type": "mutual_fund",
      "quantity": 25,
      "currentValue": 15200.00,
      "dayChange": 180.00,
      "dayChangePercentage": 1.20,
      "logo":
          "https://images.unsplash.com/photo-1610375461246-83df859d849d?w=100&h=100&fit=crop&crop=center"
    },
  ];

  // Mock transactions data
  final List<Map<String, dynamic>> _recentTransactions = [
    {
      "id": 1,
      "type": "buy",
      "symbol": "SQRPHARMA",
      "quantity": 25,
      "price": 250.00,
      "amount": 6250.00,
      "status": "completed",
      "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      "id": 2,
      "type": "sell",
      "symbol": "BRACBANK",
      "quantity": 50,
      "price": 87.50,
      "amount": 4375.00,
      "status": "completed",
      "timestamp": DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      "id": 3,
      "type": "buy",
      "symbol": "GOLDMF",
      "quantity": 10,
      "price": 608.00,
      "amount": 6080.00,
      "status": "pending",
      "timestamp": DateTime.now().subtract(const Duration(days: 2)),
    },
  ];

  // Mock market highlights data
  final List<Map<String, dynamic>> _marketHighlights = [
    {
      "id": 1,
      "symbol": "GRAMEENPHONE",
      "name": "Grameenphone Ltd.",
      "currentPrice": 285.50,
      "dayChange": 8.25,
      "dayChangePercentage": 2.98,
      "logo":
          "https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=100&h=100&fit=crop&crop=center"
    },
    {
      "id": 2,
      "symbol": "WALTONHIL",
      "name": "Walton Hi-Tech Industries Ltd.",
      "currentPrice": 1245.00,
      "dayChange": -15.50,
      "dayChangePercentage": -1.23,
      "logo":
          "https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=100&h=100&fit=crop&crop=center"
    },
    {
      "id": 3,
      "symbol": "CITYBANK",
      "name": "City Bank Limited",
      "currentPrice": 32.75,
      "dayChange": 1.25,
      "dayChangePercentage": 3.97,
      "logo":
          "https://images.unsplash.com/photo-1541354329998-f4d9a9f9297f?w=100&h=100&fit=crop&crop=center"
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isRefreshing = false);

    // Show success feedback
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.successColor,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text('Portfolio updated successfully'),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _toggleBalanceVisibility() {
    HapticFeedback.lightImpact();
    setState(() => _isBalanceVisible = !_isBalanceVisible);
  }

  void _showQuickActionBottomSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickActionBottomSheet(
        onBuyTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/buy-order-ticket');
        },
        onSellTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/portfolio-holdings');
        },
        onViewMarkets: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/markets-browse');
        },
      ),
    );
  }

  void _onHoldingTap(Map<String, dynamic> holding) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/instrument-detail');
  }

  void _onHoldingLongPress(Map<String, dynamic> holding) {
    HapticFeedback.heavyImpact();
    _showHoldingActions(holding);
  }

  void _showHoldingActions(Map<String, dynamic> holding) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              holding['symbol'] as String,
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            _buildActionTile(
              icon: 'visibility',
              title: 'View Details',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/instrument-detail');
              },
            ),
            _buildActionTile(
              icon: 'add_shopping_cart',
              title: 'Buy More',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/buy-order-ticket');
              },
            ),
            _buildActionTile(
              icon: 'sell',
              title: 'Sell',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/buy-order-ticket');
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: AppTheme.primaryLight,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.titleMedium,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void _onTransactionTap(Map<String, dynamic> transaction) {
    HapticFeedback.lightImpact();
    // Show transaction details
  }

  void _onMarketHighlightTap(Map<String, dynamic> instrument) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/instrument-detail');
  }

  void _onGetStarted() {
    Navigator.pushNamed(context, '/markets-browse');
  }

  @override
  Widget build(BuildContext context) {
    final bool hasHoldings = _holdings.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppTheme.primaryLight,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
                elevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good ${_getGreeting()},',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                    Text(
                      _userName,
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Container(
                    margin: EdgeInsets.only(right: 4.w),
                    child: Row(
                      children: [
                        Text(
                          'Last updated: ${_getLastUpdatedTime()}',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryLight,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        CustomIconWidget(
                          iconName: 'access_time',
                          color: AppTheme.textSecondaryLight,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Portfolio Value Card
              SliverToBoxAdapter(
                child: PortfolioValueCard(
                  totalBalance: _totalBalance,
                  dayChange: _dayChange,
                  dayChangePercentage: _dayChangePercentage,
                  isFantasyMode: _isFantasyMode,
                  onToggleVisibility: _toggleBalanceVisibility,
                  isBalanceVisible: _isBalanceVisible,
                ),
              ),

              // Main Content
              hasHoldings
                  ? SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Holdings Section
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 2.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Top Holdings',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                      context, '/portfolio-holdings'),
                                  child: Text(
                                    'View All',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: AppTheme.primaryLight,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              itemCount: _holdings.length,
                              itemBuilder: (context, index) {
                                return HoldingsCard(
                                  holding: _holdings[index],
                                  onTap: () => _onHoldingTap(_holdings[index]),
                                  onLongPress: () =>
                                      _onHoldingLongPress(_holdings[index]),
                                );
                              },
                            ),
                          ),

                          // Recent Transactions Section
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 2.h),
                            child: Text(
                              'Recent Transactions',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            itemCount: _recentTransactions.length > 3
                                ? 3
                                : _recentTransactions.length,
                            itemBuilder: (context, index) {
                              return TransactionItem(
                                transaction: _recentTransactions[index],
                                onTap: () => _onTransactionTap(
                                    _recentTransactions[index]),
                              );
                            },
                          ),

                          // Market Highlights Section
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 2.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Market Highlights',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                      context, '/markets-browse'),
                                  child: Text(
                                    'View All',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: AppTheme.primaryLight,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 18.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              itemCount: _marketHighlights.length,
                              itemBuilder: (context, index) {
                                return MarketHighlightCard(
                                  instrument: _marketHighlights[index],
                                  onTap: () => _onMarketHighlightTap(
                                      _marketHighlights[index]),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 10.h),
                        ],
                      ),
                    )
                  : SliverFillRemaining(
                      child: EmptyStateWidget(
                        onGetStarted: _onGetStarted,
                      ),
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          HapticFeedback.lightImpact();
          setState(() => _selectedTabIndex = index);
          _navigateToTab(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        selectedItemColor: AppTheme.primaryLight,
        unselectedItemColor: AppTheme.textSecondaryLight,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home',
              color: _selectedTabIndex == 0
                  ? AppTheme.primaryLight
                  : AppTheme.textSecondaryLight,
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'trending_up',
              color: _selectedTabIndex == 1
                  ? AppTheme.primaryLight
                  : AppTheme.textSecondaryLight,
              size: 24,
            ),
            label: 'Markets',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'account_balance_wallet',
              color: _selectedTabIndex == 2
                  ? AppTheme.primaryLight
                  : AppTheme.textSecondaryLight,
              size: 24,
            ),
            label: 'Portfolio',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'school',
              color: _selectedTabIndex == 3
                  ? AppTheme.primaryLight
                  : AppTheme.textSecondaryLight,
              size: 24,
            ),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              color: _selectedTabIndex == 4
                  ? AppTheme.primaryLight
                  : AppTheme.textSecondaryLight,
              size: 24,
            ),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickActionBottomSheet,
        backgroundColor: AppTheme.primaryLight,
        child: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  String _getLastUpdatedTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _navigateToTab(int index) {
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, '/markets-browse');
        break;
      case 2:
        Navigator.pushNamed(context, '/portfolio-holdings');
        break;
      case 3:
        Navigator.pushNamed(context, '/learn-hub');
        break;
      case 4:
        Navigator.pushNamed(context, '/user-profile-settings');
        break;
    }
  }
}
