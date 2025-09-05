import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/key_statistics_widget.dart';
import './widgets/news_section_widget.dart';
import './widgets/price_chart_widget.dart';
import './widgets/trading_buttons_widget.dart';

class InstrumentDetail extends StatefulWidget {
  const InstrumentDetail({Key? key}) : super(key: key);

  @override
  State<InstrumentDetail> createState() => _InstrumentDetailState();
}

class _InstrumentDetailState extends State<InstrumentDetail> {
  bool isInWatchlist = false;
  bool isLoading = false;
  Map<String, dynamic>? instrumentData;
  String? routeSymbol; // Store the route symbol

  @override
  void initState() {
    super.initState();
    // Don't load data in initState since context might not be ready
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (instrumentData == null) {
      _loadInstrumentData();
    }
  }

  Future<void> _loadInstrumentData() async {
    setState(() {
      isLoading = true;
    });

    // Get the symbol from route arguments - no hardcoding
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? symbol = arguments?['symbol'];

    // Store route symbol for refresh capability
    routeSymbol = symbol;

    // Fetch data based on the passed symbol, no defaults
    if (symbol != null && symbol.isNotEmpty) {
      instrumentData = _getInstrumentDataBySymbol(symbol);
    } else {
      // If no symbol provided, show error state
      setState(() {
        isLoading = false;
        instrumentData = null;
      });
      return;
    }

    // Simulate API call
    await Future.delayed(Duration(milliseconds: 800));

    setState(() {
      isLoading = false;
    });
  }

  Map<String, dynamic> _getInstrumentDataBySymbol(String symbol) {
    // Complete database for all symbols including UTTARAFUND
    final instrumentsDatabase = {
      'BATBC': {
        "id": 8,
        "symbol": "BATBC",
        "name": "British American Tobacco Bangladesh",
        "type": "Stock",
        "sector": "Consumer Goods",
        "currentPrice": 485.20,
        "dayChange": 15.80,
        "dayChangePercent": 3.37,
        "dayHigh": 490.00,
        "dayLow": 478.50,
        "yearHigh": 520.00,
        "yearLow": 420.00,
        "marketCap": "৳76,218 Cr",
        "peRatio": 22.1,
        "dividendYield": 3.8,
        "bidPrice": 484.90,
        "askPrice": 485.50,
        "volume": 950000,
        "avgVolume": 800000,
        "lastUpdated": DateTime.now().subtract(Duration(minutes: 8)),
      },
      'GP': {
        "id": 3,
        "symbol": "GP",
        "name": "GrameenPhone Ltd.",
        "type": "Stock",
        "sector": "Telecommunications",
        "currentPrice": 312.80,
        "dayChange": 8.90,
        "dayChangePercent": 2.93,
        "dayHigh": 318.50,
        "dayLow": 308.20,
        "yearHigh": 365.00,
        "yearLow": 280.00,
        "marketCap": "৳98,742 Cr",
        "peRatio": 15.2,
        "dividendYield": 4.1,
        "bidPrice": 312.50,
        "askPrice": 313.10,
        "volume": 1800000,
        "avgVolume": 1500000,
        "lastUpdated": DateTime.now().subtract(Duration(minutes: 3)),
      },
      'UTTARAFUND': {
        "id": 11,
        "symbol": "UTTARAFUND",
        "name": "Uttra Finance & Investments Limited",
        "type": "Mutual Fund",
        "sector": "Financial Services",
        "currentPrice": 18.75,
        "dayChange": 0.85,
        "dayChangePercent": 4.74,
        "dayHigh": 19.20,
        "dayLow": 18.10,
        "yearHigh": 22.50,
        "yearLow": 15.80,
        "marketCap": "৳2,850 Cr",
        "peRatio": 8.9,
        "dividendYield": 5.2,
        "bidPrice": 18.60,
        "askPrice": 18.90,
        "volume": 125000,
        "avgVolume": 95000,
        "lastUpdated": DateTime.now().subtract(Duration(minutes: 12)),
      },
      'SQRPHARMA': {
        "id": 1,
        "symbol": "SQRPHARMA",
        "name": "Square Pharmaceuticals Ltd.",
        "type": "Stock",
        "sector": "Pharmaceuticals",
        "currentPrice": 460.20,
        "dayChange": 12.50,
        "dayChangePercent": 2.79,
        "dayHigh": 465.00,
        "dayLow": 448.50,
        "yearHigh": 520.00,
        "yearLow": 380.00,
        "marketCap": "৳43,218 Cr",
        "peRatio": 18.5,
        "dividendYield": 3.2,
        "bidPrice": 459.50,
        "askPrice": 460.70,
        "volume": 2500000,
        "avgVolume": 1800000,
        "lastUpdated": DateTime.now().subtract(Duration(minutes: 5)),
      }
    };

    // Return exact symbol data, no fallback to hardcoded default
    return instrumentsDatabase[symbol] ??
        {
          "symbol": symbol,
          "name": "Unknown Instrument",
          "type": "Unknown",
          "currentPrice": 0.0,
          "dayChange": 0.0,
          "dayChangePercent": 0.0,
          "lastUpdated": DateTime.now(),
        };
  }

  void _toggleWatchlist() {
    setState(() {
      isInWatchlist = !isInWatchlist;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isInWatchlist ? 'Added to watchlist' : 'Removed from watchlist',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareInstrument() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share functionality will be implemented'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showPriceAlert() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Set Price Alert',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Get notified when ${instrumentData?['symbol']} reaches your target price',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 3.h),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Target Price (৳)',
                hintText: 'Enter target price',
                prefixText: '৳ ',
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Price alert set successfully'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Text('Set Alert'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Handle case where no valid instrument data exists
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.primaryColor,
          ),
        ),
      );
    }

    if (instrumentData == null || routeSymbol == null) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('Instrument Details'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.lightTheme.colorScheme.error,
              ),
              SizedBox(height: 16),
              Text(
                'No instrument data available',
                style: AppTheme.lightTheme.textTheme.headlineSmall,
              ),
              SizedBox(height: 8),
              Text(
                'Please select an instrument from the Markets screen',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final dayChange = instrumentData!['dayChange'] as double;
    final dayChangePercent = instrumentData!['dayChangePercent'] as double;
    final isPositive = dayChange >= 0;
    final lastUpdated = instrumentData!['lastUpdated'] as DateTime;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              instrumentData!['symbol'] as String,
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              instrumentData!['name'] as String,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showPriceAlert,
            icon: CustomIconWidget(
              iconName: 'notifications',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          IconButton(
            onPressed: _toggleWatchlist,
            icon: CustomIconWidget(
              iconName: isInWatchlist ? 'favorite' : 'favorite_border',
              size: 24,
              color: isInWatchlist
                  ? AppTheme.errorColor
                  : AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          IconButton(
            onPressed: _shareInstrument,
            icon: CustomIconWidget(
              iconName: 'share',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.lightTheme.primaryColor,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price header
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '৳${(instrumentData!['currentPrice'] as double).toStringAsFixed(2)}',
                                    style: AppTheme
                                        .lightTheme.textTheme.headlineMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.w,
                                      vertical: 0.5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isPositive
                                          ? AppTheme.successColor
                                              .withValues(alpha: 0.1)
                                          : AppTheme.errorColor
                                              .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CustomIconWidget(
                                          iconName: isPositive
                                              ? 'arrow_upward'
                                              : 'arrow_downward',
                                          size: 16,
                                          color: isPositive
                                              ? AppTheme.successColor
                                              : AppTheme.errorColor,
                                        ),
                                        SizedBox(width: 1.w),
                                        Text(
                                          '৳${dayChange.abs().toStringAsFixed(2)} (${dayChangePercent.abs().toStringAsFixed(2)}%)',
                                          style: AppTheme
                                              .lightTheme.textTheme.labelMedium
                                              ?.copyWith(
                                            color: isPositive
                                                ? AppTheme.successColor
                                                : AppTheme.errorColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Last updated: ${lastUpdated.hour.toString().padLeft(2, '0')}:${lastUpdated.minute.toString().padLeft(2, '0')}',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Price chart
                        PriceChartWidget(instrumentData: instrumentData!),

                        // Key statistics
                        KeyStatisticsWidget(instrumentData: instrumentData!),

                        // News section
                        NewsSectionWidget(
                            instrumentName: instrumentData!['name'] as String),

                        // Bottom padding for trading buttons
                        SizedBox(height: 15.h),
                      ],
                    ),
                  ),
                ),

                // Trading buttons (sticky bottom)
                TradingButtonsWidget(instrumentData: instrumentData!),
              ],
            ),
    );
  }
}
