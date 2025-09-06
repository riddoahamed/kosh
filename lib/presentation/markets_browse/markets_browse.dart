import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';

class MarketsBrowse extends StatefulWidget {
  const MarketsBrowse({Key? key}) : super(key: key);

  @override
  State<MarketsBrowse> createState() => _MarketsBrowseState();
}

class _MarketsBrowseState extends State<MarketsBrowse>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _allInstruments = [];
  List<Map<String, dynamic>> _filteredInstruments = [];
  List<String> _activeFilters = [];
  String _selectedCategory = 'All'; // 'All', 'Stocks', 'Mutual Funds', 'Gold'
  List<String> _selectedCategories = [];
  RangeValues _priceRange = const RangeValues(0, 10000);

  bool _isLoading = false;
  bool _isMarketOpen = true;
  String _nextSessionTime = "9:30 AM";
  String _lastUpdated = "2 minutes ago";
  String _dataProvider = "CSV"; // Get from appFlags.DATA_PROVIDER_STOCKS
  String _globalLastUpdated = "14:32"; // Get from appFlags.GLOBAL_LAST_UPDATED

  late TabController _tabController;
  int _currentTabIndex = 1; // Markets tab active

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 1);
    _loadMockData();
    _setupScrollListener();
    _loadAppFlags();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadAppFlags() {
    // Simulate reading from appFlags
    // In real implementation, read from appFlags.DATA_PROVIDER_STOCKS and appFlags.GLOBAL_LAST_UPDATED
    setState(() {
      _dataProvider =
          "CSV"; // Default value, change to "Unofficial (beta)" for testing
      _globalLastUpdated = DateTime.now().hour.toString().padLeft(2, '0') +
          ":" +
          DateTime.now().minute.toString().padLeft(2, '0');
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreData();
      }
    });
  }

  void _loadMockData() {
    setState(() {
      _isLoading = true;
    });

    // Mock data for instruments with status = active
    _allInstruments = [
      {
        "id": 1,
        "symbol": "SQRPHARMA",
        "name": "Square Pharmaceuticals Ltd.",
        "category": "Stocks",
        "currentPrice": 245.50,
        "dayChange": 12.30,
        "dayChangePercent": 5.27,
        "lastUpdated": DateTime.now().subtract(Duration(minutes: 5)),
        "status": "active",
        "chartThumbnail":
            "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=200&h=100&fit=crop",
      },
      {
        "id": 2,
        "symbol": "BEXIMCO",
        "name": "Beximco Pharmaceuticals Ltd.",
        "category": "Stocks",
        "currentPrice": 89.75,
        "dayChange": -2.15,
        "dayChangePercent": -2.34,
        "lastUpdated": DateTime.now().subtract(Duration(minutes: 8)),
        "status": "active",
        "chartThumbnail":
            "https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?w=200&h=100&fit=crop",
      },
      {
        "id": 3,
        "symbol": "GP",
        "name": "GrameenPhone Ltd.",
        "category": "Stocks",
        "currentPrice": 312.80,
        "dayChange": 8.90,
        "dayChangePercent": 2.93,
        "lastUpdated": DateTime.now().subtract(Duration(minutes: 3)),
        "status": "active",
        "chartThumbnail":
            "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=200&h=100&fit=crop",
      },
      {
        "id": 4,
        "symbol": "AIBL1STMF",
        "name": "AIBL 1st Mutual Fund",
        "category": "Mutual Funds",
        "currentPrice": 12.45,
        "dayChange": 0.35,
        "dayChangePercent": 2.89,
        "lastUpdated": DateTime.now().subtract(Duration(minutes: 12)),
        "status": "active",
        "chartThumbnail":
            "https://images.unsplash.com/photo-1559526324-4b87b5e36e44?w=200&h=100&fit=crop",
      },
      {
        "id": 5,
        "symbol": "ICBAMCL2ND",
        "name": "ICB AMCL Second Mutual Fund",
        "category": "Mutual Funds",
        "currentPrice": 8.92,
        "dayChange": -0.18,
        "dayChangePercent": -1.98,
        "lastUpdated": DateTime.now().subtract(Duration(minutes: 15)),
        "status": "active",
        "chartThumbnail":
            "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=200&h=100&fit=crop",
      },
      {
        "id": 6,
        "symbol": "GOLD22K",
        "name": "Gold 22 Karat",
        "category": "Gold",
        "currentPrice": 6850.00,
        "dayChange": 125.00,
        "dayChangePercent": 1.86,
        "lastUpdated": DateTime.now().subtract(Duration(minutes: 7)),
        "status": "active",
        "chartThumbnail":
            "https://images.unsplash.com/photo-1610375461246-83df859d849d?w=200&h=100&fit=crop",
      },
      {
        "id": 7,
        "symbol": "GOLD18K",
        "name": "Gold 18 Karat",
        "category": "Gold",
        "currentPrice": 5680.00,
        "dayChange": -45.00,
        "dayChangePercent": -0.79,
        "lastUpdated": DateTime.now().subtract(Duration(minutes: 10)),
        "status": "active",
        "chartThumbnail":
            "https://images.unsplash.com/photo-1605792657660-596af9009e82?w=200&h=100&fit=crop",
      },
      {
        "id": 8,
        "symbol": "BATBC",
        "name": "British American Tobacco Bangladesh",
        "category": "Stocks",
        "currentPrice": 485.20,
        "dayChange": 15.80,
        "dayChangePercent": 3.37,
        "lastUpdated": DateTime.now().subtract(Duration(minutes: 6)),
        "status": "active",
        "chartThumbnail":
            "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=200&h=100&fit=crop",
      },
      {
        "id": 9,
        "symbol": "CITYBANK",
        "name": "City Bank Ltd.",
        "category": "Stocks",
        "currentPrice": 28.45,
        "dayChange": -1.25,
        "dayChangePercent": -4.21,
        "lastUpdated": DateTime.now().subtract(Duration(minutes: 4)),
        "status": "active",
        "chartThumbnail":
            "https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?w=200&h=100&fit=crop",
      },
      {
        "id": 10,
        "symbol": "EBLNRBMF",
        "name": "EBL NRB Mutual Fund",
        "category": "Mutual Funds",
        "currentPrice": 11.78,
        "dayChange": 0.42,
        "dayChangePercent": 3.70,
        "lastUpdated": DateTime.now().subtract(Duration(minutes: 9)),
        "status": "active",
        "chartThumbnail":
            "https://images.unsplash.com/photo-1559526324-4b87b5e36e44?w=200&h=100&fit=crop",
      },
    ];

    // Filter only active instruments
    _allInstruments = _allInstruments
        .where((instrument) => instrument['status'] == 'active')
        .toList();

    _filteredInstruments = List.from(_allInstruments);
    _applyFilters();

    setState(() {
      _isLoading = false;
    });
  }

  void _loadMoreData() {
    // Simulate loading more data
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _applyFilters();
    });
  }

  void _applyFilters() {
    var filtered = List<Map<String, dynamic>>.from(_allInstruments);

    // Apply search filter (case insensitive)
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((instrument) {
        final symbol = (instrument['symbol'] as String).toLowerCase();
        final name = (instrument['name'] as String).toLowerCase();
        return symbol.contains(searchQuery) || name.contains(searchQuery);
      }).toList();
    }

    // Apply category filter from horizontal chips
    if (_selectedCategory != 'All') {
      filtered = filtered.where((instrument) {
        return instrument['category'] == _selectedCategory;
      }).toList();
    }

    _filteredInstruments = filtered;
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _applyFilters();
    });
  }

  void _onFilterTap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        selectedCategories: _selectedCategories,
        priceRange: _priceRange,
        onApplyFilters: (categories, priceRange) {
          setState(() {
            _selectedCategories = categories;
            _priceRange = priceRange;
            _updateActiveFilters();
            _filteredInstruments = _allInstruments;
            _applyFilters();
          });
        },
      ),
    );
  }

  void _updateActiveFilters() {
    _activeFilters.clear();

    if (_selectedCategories.isNotEmpty) {
      _activeFilters.addAll(_selectedCategories);
    }

    if (_priceRange.start > 0 || _priceRange.end < 10000) {
      _activeFilters
          .add('৳${_priceRange.start.round()}-৳${_priceRange.end.round()}');
    }
  }

  void _onFilterRemove(String filter) {
    setState(() {
      if (_selectedCategories.contains(filter)) {
        _selectedCategories.remove(filter);
      } else if (filter.contains('৳')) {
        _priceRange = const RangeValues(0, 10000);
      }
      _updateActiveFilters();
      _filteredInstruments = _allInstruments;
      _applyFilters();
    });
  }

  void _onInstrumentTap(Map<String, dynamic> instrument) {
    // Fixed: Pass the correct symbol for proper navigation
    Navigator.pushNamed(
      context,
      AppRoutes.instrumentDetail,
      arguments: {'symbol': instrument['symbol']},
    );
  }

  void _onQuickBuy(Map<String, dynamic> instrument) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      AppRoutes.buyOrderTicket,
      arguments: {
        'instrument': instrument,
        'orderType': 'buy',
      },
    );
  }

  void _onAddToWatchlist(Map<String, dynamic> instrument) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${instrument['symbol']} added to watchlist'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onRefresh() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _globalLastUpdated = DateTime.now().hour.toString().padLeft(2, '0') +
          ":" +
          DateTime.now().minute.toString().padLeft(2, '0');
    });
    await Future.delayed(const Duration(seconds: 1));
    _loadMockData();
  }

  List<Map<String, dynamic>> _getInstrumentsByCategory() {
    return _filteredInstruments;
  }

  @override
  Widget build(BuildContext context) {
    final instruments = _getInstrumentsByCategory();
    final hasResults = instruments.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Provider and Last Updated Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Provider: $_dataProvider',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _dataProvider.contains('Unofficial')
                              ? AppTheme.lightTheme.colorScheme.secondary
                              : AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                      if (_dataProvider.contains('Unofficial'))
                        Text(
                          'Beta version',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Last updated',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        _globalLastUpdated.isEmpty
                            ? '--:--'
                            : _globalLastUpdated,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Header
            Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search by symbol or name',
                      prefixIcon: CustomIconWidget(
                        iconName: 'search',
                        size: 5.w,
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                              icon: CustomIconWidget(
                                iconName: 'clear',
                                size: 5.w,
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.lightTheme.colorScheme.outline,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Category Filter Chips
                  SizedBox(
                    height: 10.w,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: ['All', 'Stocks', 'Mutual Funds', 'Gold']
                          .map((category) {
                        final isSelected = _selectedCategory == category;
                        return Container(
                          margin: EdgeInsets.only(right: 2.w),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) =>
                                _onCategorySelected(category),
                            selectedColor: AppTheme
                                .lightTheme.colorScheme.primary
                                .withValues(alpha: 0.2),
                            checkmarkColor:
                                AppTheme.lightTheme.colorScheme.primary,
                            labelStyle: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: isSelected
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : AppTheme.lightTheme.colorScheme.outline,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppTheme.lightTheme.colorScheme.primary,
                child: hasResults
                    ? ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: instruments.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == instruments.length) {
                            return Container(
                              padding: EdgeInsets.all(4.w),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final instrument = instruments[index];
                          final dayChange = instrument['dayChange'] as double;
                          final dayChangePercent =
                              instrument['dayChangePercent'] as double;
                          final isPositive = dayChange >= 0;
                          final lastUpdated =
                              instrument['lastUpdated'] as DateTime;

                          return Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 1.h),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () => _onInstrumentTap(instrument),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: EdgeInsets.all(4.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  instrument['symbol']
                                                      as String,
                                                  style: AppTheme.lightTheme
                                                      .textTheme.titleMedium
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(height: 0.5.h),
                                                Text(
                                                  instrument['name'] as String,
                                                  style: AppTheme.lightTheme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: AppTheme
                                                        .lightTheme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '৳${(instrument['currentPrice'] as double).toStringAsFixed(2)}',
                                                style: AppTheme.lightTheme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              SizedBox(height: 0.5.h),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 2.w,
                                                    vertical: 0.5.h),
                                                decoration: BoxDecoration(
                                                  color: isPositive
                                                      ? AppTheme.successColor
                                                          .withValues(
                                                              alpha: 0.1)
                                                      : AppTheme.errorColor
                                                          .withValues(
                                                              alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    CustomIconWidget(
                                                      iconName: isPositive
                                                          ? 'arrow_upward'
                                                          : 'arrow_downward',
                                                      size: 12,
                                                      color: isPositive
                                                          ? AppTheme
                                                              .successColor
                                                          : AppTheme.errorColor,
                                                    ),
                                                    SizedBox(width: 1.w),
                                                    Text(
                                                      '${dayChange.abs().toStringAsFixed(2)} (${dayChangePercent.abs().toStringAsFixed(2)}%)',
                                                      style: AppTheme.lightTheme
                                                          .textTheme.bodySmall
                                                          ?.copyWith(
                                                        color: isPositive
                                                            ? AppTheme
                                                                .successColor
                                                            : AppTheme
                                                                .errorColor,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 1.h),
                                      Text(
                                        'Last updated: ${lastUpdated.hour.toString().padLeft(2, '0')}:${lastUpdated.minute.toString().padLeft(2, '0')}',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: AppTheme.lightTheme.colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: 50.h,
                          child: EmptyStateWidget(
                            title: _searchController.text.isNotEmpty
                                ? 'No results found'
                                : 'No instruments available',
                            subtitle: _searchController.text.isNotEmpty
                                ? 'Try adjusting your search or filters'
                                : 'Check back later for available instruments',
                            suggestedInstruments:
                                _searchController.text.isNotEmpty
                                    ? _allInstruments.take(6).toList()
                                    : null,
                            onSuggestedTap: _onInstrumentTap,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          labelColor: AppTheme.lightTheme.colorScheme.primary,
          unselectedLabelColor:
              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          indicatorColor: Colors.transparent,
          onTap: (index) {
            setState(() {
              _currentTabIndex = index;
            });

            // Navigate to respective screens
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(
                    context, AppRoutes.marketsBrowse);
                break;
              case 1:
                // Already on Markets Browse
                break;
              case 2:
                Navigator.pushReplacementNamed(
                    context, AppRoutes.portfolioHoldings);
                break;
              case 3:
                Navigator.pushReplacementNamed(context, AppRoutes.learnHub);
                break;
              case 4:
                Navigator.pushReplacementNamed(
                    context, AppRoutes.userProfileSettings);
                break;
            }
          },
          tabs: [
            Tab(
              icon: CustomIconWidget(
                iconName: 'home',
                color: _currentTabIndex == 0
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 6.w,
              ),
              text: 'Home',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'trending_up',
                color: _currentTabIndex == 1
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 6.w,
              ),
              text: 'Markets',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'account_balance_wallet',
                color: _currentTabIndex == 2
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 6.w,
              ),
              text: 'Portfolio',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'school',
                color: _currentTabIndex == 3
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 6.w,
              ),
              text: 'Learn',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'person',
                color: _currentTabIndex == 4
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 6.w,
              ),
              text: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}