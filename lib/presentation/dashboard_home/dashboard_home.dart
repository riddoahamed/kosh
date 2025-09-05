import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/portfolio_service.dart';
import '../../services/trading_service.dart';
import '../../services/supabase_service.dart';
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

  // Real data from Supabase
  String? _userId;
  Map<String, dynamic>? _portfolioData;
  List<Map<String, dynamic>> _marketHighlights = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    try {
      // Get current user
      final user = SupabaseService.instance.client.auth.currentUser;
      if (user != null) {
        _userId = user.id;

        // Fetch real portfolio data
        await _loadPortfolioData();
        await _loadMarketHighlights();
      }
    } catch (e) {
      debugPrint('Error initializing data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPortfolioData() async {
    if (_userId == null) return;

    try {
      final portfolioData =
          await PortfolioService.instance.getPortfolioData(_userId!);
      setState(() {
        _portfolioData = portfolioData;
      });
    } catch (e) {
      debugPrint('Error loading portfolio data: $e');
    }
  }

  Future<void> _loadMarketHighlights() async {
    try {
      final instruments =
          await TradingService.instance.getActiveInstruments(limit: 10);
      // Sort by day change percentage to show top movers
      instruments.sort((a, b) => ((b['day_change_percent'] as num?) ?? 0.0)
          .compareTo((a['day_change_percent'] as num?) ?? 0.0));
      setState(() {
        _marketHighlights = instruments.take(5).toList();
      });
    } catch (e) {
      debugPrint('Error loading market highlights: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);

    try {
      await _loadPortfolioData();
      await _loadMarketHighlights();

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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh data'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() => _isRefreshing = false);
    }
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.primaryLight,
                strokeWidth: 3.0,
              ),
              SizedBox(height: 2.h),
              Text(
                'Loading your portfolio...',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final portfolioSummary = _portfolioData?['summary'] ?? {};
    final positions = (_portfolioData?['positions'] as List?) ?? [];
    final recentTrades = (_portfolioData?['recent_trades'] as List?) ?? [];
    final metrics = _portfolioData?['metrics'] ?? {};

    final hasHoldings = positions.isNotEmpty;
    final totalValue = (metrics['current_value'] as num?)?.toDouble() ?? 0.0;
    final dayChange = (metrics['day_change'] as num?)?.toDouble() ?? 0.0;
    final dayChangePercentage =
        (metrics['day_change_percent'] as num?)?.toDouble() ?? 0.0;
    final availableBalance =
        (portfolioSummary['cash_available'] as num?)?.toDouble() ?? 50000.0;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppTheme.primaryLight,
          child: CustomScrollView(
            slivers: [
              // Enhanced App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
                elevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good ${_getGreeting()}',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                    Text(
                      'Investor', // Can be fetched from user profile
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Container(
                    margin: EdgeInsets.only(right: 4.w),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'fiber_manual_record',
                                color: AppTheme.successColor,
                                size: 8,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Live',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.w600,
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

              // Enhanced Portfolio Value Card with real data
              SliverToBoxAdapter(
                child: PortfolioValueCard(
                  totalBalance: totalValue + availableBalance,
                  dayChange: dayChange,
                  dayChangePercentage: dayChangePercentage,
                  isFantasyMode: _isFantasyMode,
                  onToggleVisibility: _toggleBalanceVisibility,
                  isBalanceVisible: _isBalanceVisible,
                ),
              ),

              // Main Content with real data
              hasHoldings
                  ? SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Real Holdings Section
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 2.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Your Holdings',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                      context, '/portfolio-holdings'),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 3.w, vertical: 1.h),
                                    decoration: BoxDecoration(
                                      color:
                                          AppTheme.primaryLight.withAlpha(26),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'View All',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: AppTheme.primaryLight,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(width: 1.w),
                                        CustomIconWidget(
                                          iconName: 'arrow_forward_ios',
                                          color: AppTheme.primaryLight,
                                          size: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 22.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              itemCount: positions.length,
                              itemBuilder: (context, index) {
                                final position = positions[index];
                                final instrument = position['instruments'];

                                return Container(
                                  width: 70.w,
                                  margin: EdgeInsets.only(right: 4.w),
                                  child: HoldingsCard(
                                    holding: {
                                      'symbol': instrument['symbol'],
                                      'name': instrument['name'],
                                      'quantity': position['quantity'],
                                      'currentValue': position['market_value'],
                                      'dayChange': position['unrealized_pnl'],
                                      'dayChangePercentage':
                                          position['unrealized_pnl_percent'],
                                      'sector': instrument['sector'],
                                    },
                                    onTap: () => _onHoldingTap(position),
                                    onLongPress: () =>
                                        _onHoldingLongPress(position),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Real Recent Transactions Section
                          if (recentTrades.isNotEmpty) ...[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4.w, vertical: 2.h),
                              child: Text(
                                'Recent Transactions',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              itemCount: recentTrades.length > 3
                                  ? 3
                                  : recentTrades.length,
                              itemBuilder: (context, index) {
                                final trade = recentTrades[index];
                                return TransactionItem(
                                  transaction: {
                                    'id': trade['id'],
                                    'type': trade['order_side'],
                                    'symbol': trade['instruments']['symbol'],
                                    'quantity': trade['quantity'],
                                    'price': trade['price'],
                                    'amount': trade['total_amount'],
                                    'status': 'completed',
                                    'timestamp':
                                        DateTime.parse(trade['created_at']),
                                  },
                                  onTap: () => _onTransactionTap(trade),
                                );
                              },
                            ),
                          ],

                          // Enhanced Market Highlights with real data
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
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                      context, '/markets-browse'),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 3.w, vertical: 1.h),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentColor.withAlpha(26),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Explore',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: AppTheme.accentColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(width: 1.w),
                                        CustomIconWidget(
                                          iconName: 'trending_up',
                                          color: AppTheme.accentColor,
                                          size: 14,
                                        ),
                                      ],
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
                              itemCount: _marketHighlights.length,
                              itemBuilder: (context, index) {
                                final instrument = _marketHighlights[index];
                                return Container(
                                  width: 65.w,
                                  margin: EdgeInsets.only(right: 4.w),
                                  child: MarketHighlightCard(
                                    instrument: {
                                      'symbol': instrument['symbol'],
                                      'name': instrument['name'],
                                      'currentPrice': instrument['last_price'],
                                      'dayChange': instrument['day_change'],
                                      'dayChangePercentage':
                                          instrument['day_change_percent'],
                                      'sector': instrument['sector'],
                                    },
                                    onTap: () =>
                                        _onMarketHighlightTap(instrument),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 12.h),
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
        elevation: 12.0,
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
      floatingActionButton: Container(
        height: 14.w,
        width: 14.w,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryLight.withAlpha(51),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showQuickActionBottomSheet,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: CustomIconWidget(
            iconName: 'add',
            color: Colors.white,
            size: 28,
          ),
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