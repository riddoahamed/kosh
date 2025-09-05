import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class InteractiveDemoWidget extends StatefulWidget {
  final VoidCallback? onNext;

  const InteractiveDemoWidget({
    Key? key,
    this.onNext,
  }) : super(key: key);

  @override
  State<InteractiveDemoWidget> createState() => _InteractiveDemoWidgetState();
}

class _InteractiveDemoWidgetState extends State<InteractiveDemoWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  bool _hasSwipedMarkets = false;
  bool _hasTappedStock = false;
  bool _hasPulledPortfolio = false;
  int _currentStep = 0;

  final List<Map<String, dynamic>> mockStocks = [
    {
      'symbol': 'SQRPHARMA',
      'name': 'Square Pharmaceuticals',
      'price': '৳245.50',
      'change': '+2.5%',
      'isPositive': true,
    },
    {
      'symbol': 'BRACBANK',
      'name': 'BRAC Bank Limited',
      'price': '৳52.80',
      'change': '-1.2%',
      'isPositive': false,
    },
    {
      'symbol': 'WALTONHIL',
      'name': 'Walton Hi-Tech',
      'price': '৳1,245.00',
      'change': '+5.8%',
      'isPositive': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(-0.3, 0),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleSwipe() {
    if (!_hasSwipedMarkets) {
      setState(() {
        _hasSwipedMarkets = true;
        _currentStep = 1;
      });
      _slideController.forward();
    }
  }

  void _handleStockTap() {
    if (_hasSwipedMarkets && !_hasTappedStock) {
      setState(() {
        _hasTappedStock = true;
        _currentStep = 2;
      });
    }
  }

  void _handlePortfolioPull() {
    if (_hasTappedStock && !_hasPulledPortfolio) {
      setState(() {
        _hasPulledPortfolio = true;
        _currentStep = 3;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        child: Column(
          children: [
            // Header
            Text(
              'Try the core gestures',
              style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 1.h),

            Text(
              'Learn by doing - try these interactions',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 4.h),

            // Interactive demo area
            Expanded(
              child: Column(
                children: [
                  // Step 1: Swipe to browse markets
                  _buildDemoStep(
                    stepNumber: 1,
                    title: 'Swipe to browse markets',
                    isActive: _currentStep == 0,
                    isCompleted: _hasSwipedMarkets,
                    child: GestureDetector(
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity! < 0) {
                          _handleSwipe();
                        }
                      },
                      child: AnimatedBuilder(
                        animation: _slideAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: _slideAnimation.value * 100,
                            child: Container(
                              height: 12.h,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: mockStocks.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(width: 3.w),
                                itemBuilder: (context, index) {
                                  final stock = mockStocks[index];
                                  return _buildStockCard(stock, index == 0);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Step 2: Tap to buy
                  _buildDemoStep(
                    stepNumber: 2,
                    title: 'Tap to buy simulation',
                    isActive: _currentStep == 1,
                    isCompleted: _hasTappedStock,
                    child: GestureDetector(
                      onTap: _handleStockTap,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale:
                                _currentStep == 1 ? _pulseAnimation.value : 1.0,
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.accentColor.withValues(alpha: 0.1),
                                border: Border.all(
                                  color: AppTheme.accentColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'add_shopping_cart',
                                    color: AppTheme.accentColor,
                                    size: 6.w,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    'Buy SQRPHARMA',
                                    style: AppTheme
                                        .lightTheme.textTheme.titleMedium
                                        ?.copyWith(
                                      color: AppTheme.accentColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Step 3: Pull to refresh portfolio
                  _buildDemoStep(
                    stepNumber: 3,
                    title: 'Pull to refresh portfolio',
                    isActive: _currentStep == 2,
                    isCompleted: _hasPulledPortfolio,
                    child: RefreshIndicator(
                      onRefresh: () async {
                        _handlePortfolioPull();
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      child: Container(
                        height: 8.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'account_balance_wallet',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 6.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Portfolio: ৳50,000',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 2.h),

            // Progress indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 1.w),
                  width: 3.w,
                  height: 3.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index <= _currentStep
                        ? AppTheme.accentColor
                        : AppTheme.lightTheme.colorScheme.outline,
                  ),
                );
              }),
            ),

            SizedBox(height: 3.h),

            // Continue button
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: _hasPulledPortfolio ? widget.onNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasPulledPortfolio
                      ? AppTheme.accentColor
                      : AppTheme.lightTheme.colorScheme.outline,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _hasPulledPortfolio
                      ? 'Great! Continue'
                      : 'Complete all steps',
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
    );
  }

  Widget _buildDemoStep({
    required int stepNumber,
    required String title,
    required bool isActive,
    required bool isCompleted,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppTheme.accentColor
                    : isActive
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.outline,
              ),
              child: Center(
                child: isCompleted
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: Colors.white,
                        size: 4.w,
                      )
                    : Text(
                        stepNumber.toString(),
                        style:
                            AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isCompleted || isActive
                    ? AppTheme.lightTheme.colorScheme.onSurface
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        child,
      ],
    );
  }

  Widget _buildStockCard(Map<String, dynamic> stock, bool isPrimary) {
    return Container(
      width: 40.w,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isPrimary
            ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
            : AppTheme.lightTheme.colorScheme.surface,
        border: Border.all(
          color: isPrimary
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stock['symbol'] as String,
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 1.h),
          Text(
            stock['price'] as String,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            stock['change'] as String,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: (stock['isPositive'] as bool)
                  ? AppTheme.successColor
                  : AppTheme.errorColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
