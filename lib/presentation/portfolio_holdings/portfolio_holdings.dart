import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/supabase_service.dart';
import './widgets/performance_metrics_widget.dart';

class Position {
  Position({required this.symbol, required this.qty, required this.avgPrice, this.openToday});
  final String symbol;
  final double qty;
  final double avgPrice;
  final double? openToday;
}

class PortfolioHoldings extends StatefulWidget {
  const PortfolioHoldings({Key? key}) : super(key: key);

  @override
  State<PortfolioHoldings> createState() => _PortfolioHoldingsState();
}

class _PortfolioHoldingsState extends State<PortfolioHoldings>
    with TickerProviderStateMixin {
  bool _showPercentage = false;
  bool _isRefreshing = false;
  String _searchQuery = '';
  String _currentSortOption = 'Value';
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  // User fantasy cash state
  double _virtualCashAvailable = 50000.0;
  double _virtualCashReserved = 0.0;
  double _virtualStartingBalance = 50000.0;

  // Portfolio holdings data
  List<Map<String, dynamic>> _mockHoldings = [];
  List<Map<String, dynamic>> _filteredHoldings = [];

  // Real-time subscription streams
  StreamSubscription<List<Map<String, dynamic>>>? _positionsSubscription;
  StreamSubscription<Map<String, dynamic>?>? _userDataSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _instrumentsSubscription;

  // Missing fields required by _buildHoldingsTab
  List<Position> _positions = [];
  double _portfolioValue = 0;
  double _totalPL = 0;
  double _dayPL = 0;
  final Map<String, double> _lastPriceBySymbol = {};
  final Map<String, String> _nameBySymbol = {};

  // Helper methods required by _buildHoldingsTab
  String _fmtCurrency(num v) => '৳${v.toStringAsFixed(2)}';
  
  String _fmtSignedCurrency(num v) =>
      (v >= 0 ? '+৳' : '-৳') + v.abs().toStringAsFixed(2);
  
  String _fmtQty(num q) =>
      (q % 1 == 0) ? q.toStringAsFixed(0) : q.toStringAsFixed(4);

  void _openInstrument(String symbol) {
    Navigator.of(context).pushNamed('/instrument_detail', arguments: {'symbol': symbol});
  }

  Future<void> _refreshData() async {
    // TODO: reload from DB later
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _setupRealTimeSubscriptions();
    _loadPortfolioData();
  }

  void _setupRealTimeSubscriptions() {
    final userId = SupabaseService.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Subscribe to portfolio positions changes
      _positionsSubscription = SupabaseService.instance
          .subscribeToPortfolioUpdates(userId)
          .listen((data) {
        _updateHoldingsFromDatabase(data);
      });

      // Subscribe to user profile changes (cash updates)
      _userDataSubscription = SupabaseService.instance
          .subscribeToUserProfile(userId)
          .listen((data) {
        if (data != null) {
          _updateCashFromDatabase(data);
        }
      });

      // Subscribe to instrument price updates
      _instrumentsSubscription = SupabaseService.instance
          .subscribeToInstrumentUpdates()
          .listen((data) {
        _updatePricesFromDatabase(data);
      });
    } catch (e) {
      print('Error setting up subscriptions: $e');
    }
  }

  Future<void> _loadPortfolioData() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final userId = SupabaseService.instance.client.auth.currentUser?.id;
      if (userId == null) {
        _loadMockData();
        return;
      }

      // Load user profile data
      final userProfile = await SupabaseService.instance.getUserProfile(userId);
      if (userProfile != null) {
        setState(() {
          _virtualCashAvailable = (userProfile['virtual_cash_available'] ?? 50000.0).toDouble();
          _virtualCashReserved = (userProfile['virtual_cash_reserved'] ?? 0.0).toDouble();
          _virtualStartingBalance = (userProfile['virtual_starting_balance'] ?? 50000.0).toDouble();
        });
      }

      // Load portfolio positions
      final positions = await SupabaseService.instance.getUserPositions(userId);
      _updateHoldingsFromDatabase(positions.cast<Map<String, dynamic>>());

    } catch (e) {
      print('Error loading portfolio data: $e');
      _loadMockData();
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _updateHoldingsFromDatabase(List<Map<String, dynamic>> positionsData) {
    setState(() {
      _mockHoldings.clear();
      for (var position in positionsData) {
        final instrument = position['instruments'];
        if (instrument != null) {
          _mockHoldings.add({
            "id": position['id'],
            "name": instrument['name'] ?? 'Unknown',
            "symbol": instrument['symbol'] ?? 'N/A',
            "type": instrument['instrument_type'] ?? 'stock',
            "quantity": position['quantity'] ?? 0,
            "avgPrice": (position['avg_price'] ?? 0.0).toDouble(),
            "currentPrice": (instrument['last_price'] ?? position['avg_price'] ?? 0.0).toDouble(),
            "portfolioAllocation": _calculateAllocation(position),
            "chartUrl": "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=400&h=200&fit=crop",
            "lastUpdated": DateTime.now().toIso8601String()
          });
        }
      }
      _filteredHoldings = List.from(_mockHoldings);
    });
  }

  void _updateCashFromDatabase(Map<String, dynamic> userData) {
    setState(() {
      _virtualCashAvailable = (userData['virtual_cash_available'] ?? 50000.0).toDouble();
      _virtualCashReserved = (userData['virtual_cash_reserved'] ?? 0.0).toDouble();
    });
  }

  void _updatePricesFromDatabase(List<Map<String, dynamic>> instrumentsData) {
    setState(() {
      for (var holding in _mockHoldings) {
        final instrument = instrumentsData.firstWhere(
          (inst) => inst['symbol'] == holding['symbol'],
          orElse: () => <String, dynamic>{},
        );
        if (instrument.isNotEmpty) {
          holding['currentPrice'] = (instrument['last_price'] ?? holding['currentPrice']).toDouble();
        }
      }
      _filteredHoldings = List.from(_mockHoldings);
    });
  }

  double _calculateAllocation(Map<String, dynamic> position) {
    final quantity = (position['quantity'] as num).toDouble();
    final price = (position['instruments']?['last_price'] ?? position['avg_price'] ?? 0.0).toDouble();
    final value = quantity * price;
    return (_totalPortfolioValue > 0) ? (value / _totalPortfolioValue) * 100 : 0.0;
  }

  void _loadMockData() {
    setState(() {
      _mockHoldings = [
        {
          "id": 1,
          "name": "Square Pharmaceuticals Ltd",
          "symbol": "SQURPHARMA",
          "type": "stock",
          "quantity": 50,
          "avgPrice": 245.50,
          "currentPrice": 268.75,
          "portfolioAllocation": 35.2,
          "chartUrl": "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=400&h=200&fit=crop",
          "lastUpdated": "2025-09-04T14:30:00Z"
        },
        {
          "id": 2,
          "name": "BRAC Bank Limited",
          "symbol": "BRACBANK",
          "type": "stock",
          "quantity": 100,
          "avgPrice": 42.30,
          "currentPrice": 45.80,
          "portfolioAllocation": 28.7,
          "chartUrl": "https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?w=400&h=200&fit=crop",
          "lastUpdated": "2025-09-04T14:30:00Z"
        },
        {
          "id": 3,
          "name": "VANGUARD Balanced Fund",
          "symbol": "VGBLFX",
          "type": "mutual_fund",
          "quantity": 25,
          "avgPrice": 180.25,
          "currentPrice": 175.90,
          "portfolioAllocation": 22.1,
          "chartUrl": "https://images.unsplash.com/photo-1559526324-4b87b5e36e44?w=400&h=200&fit=crop",
          "lastUpdated": "2025-09-04T14:30:00Z"
        },
        {
          "id": 4,
          "name": "Gold ETF",
          "symbol": "GOLD",
          "type": "gold",
          "quantity": 10,
          "avgPrice": 520.00,
          "currentPrice": 535.25,
          "portfolioAllocation": 14.0,
          "chartUrl": "https://images.unsplash.com/photo-1610375461246-83df859d849d?w=200&h=100&fit=crop",
          "lastUpdated": "2025-09-04T14:30:00Z"
        }
      ];
      _filteredHoldings = List.from(_mockHoldings);
    });
  }

  double get _totalPortfolioValue {
    final holdingsValue = _mockHoldings.fold(0.0, (sum, holding) {
      final quantity = (holding['quantity'] as num).toDouble();
      final currentPrice = (holding['currentPrice'] as num).toDouble();
      return sum + (quantity * currentPrice);
    });
    return _virtualCashAvailable + holdingsValue;
  }

  double get _totalInvested {
    return _mockHoldings.fold(0.0, (sum, holding) {
      final quantity = (holding['quantity'] as num).toDouble();
      final avgPrice = (holding['avgPrice'] as num).toDouble();
      return sum + (quantity * avgPrice);
    });
  }

  double get _dayChange {
    return _totalPortfolioValue * 0.025; // 2.5% gain for demo
  }

  double get _totalPLValue {
    return _totalPortfolioValue - _virtualStartingBalance;
  }

  // Enhanced order execution with real database calls
  Future<bool> _executeBuyOrder(String symbol, int quantity, double execPrice) async {
    try {
      final userId = SupabaseService.instance.client.auth.currentUser?.id;
      if (userId == null) return false;

      final result = await SupabaseService.instance.executeTrade(
        userId: userId,
        symbol: symbol,
        orderType: 'buy',
        quantity: quantity,
        price: execPrice,
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Buy order executed successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        // Refresh data to show updated portfolio
        _loadPortfolioData();
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Order execution failed'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error executing buy order: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return false;
    }
  }

  Future<bool> _executeSellOrder(String symbol, int quantity, double execPrice) async {
    try {
      final userId = SupabaseService.instance.client.auth.currentUser?.id;
      if (userId == null) return false;

      final result = await SupabaseService.instance.executeTrade(
        userId: userId,
        symbol: symbol,
        orderType: 'sell',
        quantity: quantity,
        price: execPrice,
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Sell order executed successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        // Refresh data to show updated portfolio
        _loadPortfolioData();
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Order execution failed'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error executing sell order: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return false;
    }
  }

  @override
  void dispose() {
    _positionsSubscription?.cancel();
    _userDataSubscription?.cancel();
    _instrumentsSubscription?.cancel();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _filterHoldings() {
    setState(() {
      _filteredHoldings = _mockHoldings.where((holding) {
        final name = (holding['name'] as String).toLowerCase();
        final symbol = (holding['symbol'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || symbol.contains(query);
      }).toList();
      _sortHoldings();
    });
  }

  void _sortHoldings() {
    _filteredHoldings.sort((a, b) {
      switch (_currentSortOption) {
        case 'Value':
          final aValue = (a['quantity'] as num) * (a['currentPrice'] as num);
          final bValue = (b['quantity'] as num) * (b['currentPrice'] as num);
          return bValue.compareTo(aValue);
        case 'P/L':
          final aValue = (a['quantity'] as num) * (a['currentPrice'] as num);
          final aInvested = (a['quantity'] as num) * (a['avgPrice'] as num);
          final aPL = aValue - aInvested;

          final bValue = (b['quantity'] as num) * (b['currentPrice'] as num);
          final bInvested = (b['quantity'] as num) * (b['avgPrice'] as num);
          final bPL = bValue - bInvested;

          return bPL.compareTo(aPL);
        case 'Name':
          return (a['name'] as String).compareTo(b['name'] as String);
        default:
          return 0;
      }
    });
  }

  Future<void> _refreshPortfolio() async {
    await _loadPortfolioData();
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(4.w),
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
              SizedBox(height: 2.h),
              Text(
                'Sort Holdings',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 3.h),
              ...[
                'Value',
                'P/L',
                'Name',
              ].map((option) => ListTile(
                    title: Text(
                      option,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimaryLight,
                      ),
                    ),
                    trailing: _currentSortOption == option
                        ? CustomIconWidget(
                            iconName: 'check',
                            size: 20,
                            color: AppTheme.primaryLight,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _currentSortOption = option;
                      });
                      _filterHoldings();
                      Navigator.pop(context);
                    },
                  )),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  void _showHoldingDetails(Map<String, dynamic> holding) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        final quantity = (holding['quantity'] as num).toDouble();
        final avgPrice = (holding['avgPrice'] as num).toDouble();
        final currentPrice = (holding['currentPrice'] as num).toDouble();
        final currentValue = quantity * currentPrice;
        final unrealizedPL = currentValue - (quantity * avgPrice);
        final plPercentage =
            avgPrice > 0 ? (unrealizedPL / (quantity * avgPrice)) * 100 : 0.0;

        return Container(
          height: 70.h,
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
                margin: EdgeInsets.only(left: 38.w, bottom: 2.h),
              ),
              Text(
                holding['name'] as String,
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                holding['symbol'] as String,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
              SizedBox(height: 3.h),
              Container(
                width: double.infinity,
                height: 25.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.lightTheme.colorScheme.primaryContainer
                      .withValues(alpha: 0.1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomImageWidget(
                    imageUrl: holding['chartUrl'] as String,
                    width: double.infinity,
                    height: 25.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                        'Quantity', '${quantity.toStringAsFixed(0)} shares'),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                        'Avg Price', '৳${avgPrice.toStringAsFixed(2)}'),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                        'Current Price', '৳${currentPrice.toStringAsFixed(2)}'),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                        'Current Value', '৳${currentValue.toStringAsFixed(2)}'),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      'Unrealized P/L',
                      '৳${unrealizedPL.toStringAsFixed(2)}',
                      color: unrealizedPL >= 0
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      'P/L %',
                      '${plPercentage.toStringAsFixed(2)}%',
                      color: unrealizedPL >= 0
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _executeBuyOrder(holding['symbol'], 10, holding['currentPrice']);
                      },
                      child: Text('Buy More'),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _executeSellOrder(holding['symbol'], 5, holding['currentPrice']);
                      },
                      child: Text('Sell'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryLight,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: color ?? AppTheme.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'Portfolio',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 2.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Cash',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
                Text(
                  '৳${_virtualCashAvailable.toStringAsFixed(0)}',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/user-profile-settings');
            },
            icon: CustomIconWidget(
              iconName: 'account_circle',
              size: 24,
              color: AppTheme.textPrimaryLight,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Holdings'),
            Tab(text: 'Performance'),
            Tab(text: 'History'),
            Tab(text: 'Analysis'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildHoldingsTab(),
            _buildPerformanceTab(),
            _buildHistoryTab(),
            _buildAnalysisTab(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2, // Portfolio tab active
        selectedItemColor: AppTheme.primaryLight,
        unselectedItemColor: AppTheme.textSecondaryLight,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
                iconName: 'home', size: 24, color: AppTheme.textSecondaryLight),
            activeIcon: CustomIconWidget(
                iconName: 'home', size: 24, color: AppTheme.primaryLight),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
                iconName: 'trending_up',
                size: 24,
                color: AppTheme.textSecondaryLight),
            activeIcon: CustomIconWidget(
                iconName: 'trending_up',
                size: 24,
                color: AppTheme.primaryLight),
            label: 'Markets',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
                iconName: 'pie_chart',
                size: 24,
                color: AppTheme.textSecondaryLight),
            activeIcon: CustomIconWidget(
                iconName: 'pie_chart', size: 24, color: AppTheme.primaryLight),
            label: 'Portfolio',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
                iconName: 'school',
                size: 24,
                color: AppTheme.textSecondaryLight),
            activeIcon: CustomIconWidget(
                iconName: 'school', size: 24, color: AppTheme.primaryLight),
            label: 'Learn',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/dashboard-home');
              break;
            case 1:
              Navigator.pushNamed(context, '/markets-browse');
              break;
            case 2:
              // Already on portfolio
              break;
            case 3:
              Navigator.pushNamed(context, '/learn-hub');
              break;
          }
        },
      ),
    );
  }

  Widget _buildHoldingsTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: (_positions.isEmpty)
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: const Center(child: Text('No holdings yet')),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // ===== Portfolio summary card =====
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    boxShadow: const [BoxShadow(blurRadius: 4, offset: Offset(0, 1))],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BEGIN SUMMARY WIDGETS (keep your own widgets here)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Portfolio Value', style: TextStyle(fontWeight: FontWeight.w600)),
                              Text(_fmtCurrency(_portfolioValue)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Day P/L', style: TextStyle(fontWeight: FontWeight.w600)),
                              Text(
                                _fmtSignedCurrency(_dayPL),
                                style: TextStyle(color: _dayPL >= 0 ? Colors.green : Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Cash Available', style: TextStyle(fontWeight: FontWeight.w500)),
                              Text(_fmtCurrency(_virtualCashAvailable)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Total P/L', style: TextStyle(fontWeight: FontWeight.w500)),
                              Text(
                                _fmtSignedCurrency(_totalPLValue),
                                style: TextStyle(color: _totalPLValue >= 0 ? Colors.green : Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // END SUMMARY WIDGETS
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ===== Positions list =====
                ..._positions.map<Widget>((Position pos) {
                  final symbol = pos.symbol;
                  final qty = pos.qty;
                  final avg = pos.avgPrice;
                  final last = _lastPriceBySymbol[symbol] ?? avg;
                  final total = qty * last;
                  final totalPL = qty * (last - avg);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      onTap: () => _openInstrument(symbol),
                      title: Text('$symbol  •  ${_nameBySymbol[symbol] ?? ""}'),
                      subtitle: Text('Qty: ${_fmtQty(qty)}   Avg: ${_fmtCurrency(avg)}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_fmtCurrency(total)),
                          Text(
                            _fmtSignedCurrency(totalPL),
                            style: TextStyle(
                              color: totalPL >= 0 ? Colors.green : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
    );
  }

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          PerformanceMetricsWidget(
            totalInvested: _totalInvested,
            currentValue: _totalPortfolioValue,
            vwap: _totalInvested > 0
                ? _totalPortfolioValue / _totalInvested
                : 1.0,
            lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
          ),
          SizedBox(height: 2.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowLight,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Portfolio Allocation',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                ..._mockHoldings.map((holding) {
                  final allocation =
                      (holding['portfolioAllocation'] as num).toDouble();
                  return Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: Row(
                      children: [
                        Container(
                          width: 4.w,
                          height: 4.w,
                          decoration: BoxDecoration(
                            color: _getColorForIndex(
                                _mockHoldings.indexOf(holding)),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            holding['symbol'] as String,
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.textPrimaryLight,
                            ),
                          ),
                        ),
                        Text(
                          '${allocation.toStringAsFixed(1)}%',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.textPrimaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowLight,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Transactions',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Transaction history will appear here once you start trading.',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowLight,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Portfolio Analysis',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Detailed portfolio analysis and insights will be available here.',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      AppTheme.primaryLight,
      AppTheme.accentColor,
      AppTheme.warningColor,
      AppTheme.successColor,
    ];
    return colors[index % colors.length];
  }
}