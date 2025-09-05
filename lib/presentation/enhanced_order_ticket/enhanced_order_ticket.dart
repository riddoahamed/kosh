import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/instrument_header_widget.dart';

class EnhancedOrderTicket extends StatefulWidget {
  const EnhancedOrderTicket({Key? key}) : super(key: key);

  @override
  State<EnhancedOrderTicket> createState() => _EnhancedOrderTicketState();
}

class _EnhancedOrderTicketState extends State<EnhancedOrderTicket>
    with TickerProviderStateMixin {
  // Core data
  Map<String, dynamic>? instrumentData;
  String orderType = 'buy'; // 'buy' or 'sell'

  // Input mode and controllers
  String inputMode = 'amount'; // 'amount' or 'quantity'
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  // Order calculations
  double currentPrice = 0.0;
  double totalAmount = 0.0;
  double totalQuantity = 0.0;
  double brokerageFee = 0.0;
  double totalCost = 0.0;
  double availableBalance = 50000.0;
  double holdingQuantity = 0.0; // For sell orders

  // UI state
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadInstrumentData();
    _amountController.addListener(_onAmountChanged);
    _quantityController.addListener(_onQuantityChanged);
    _animationController.forward();
  }

  void _loadInstrumentData() {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      setState(() {
        instrumentData = arguments['instrument'] as Map<String, dynamic>?;
        orderType = arguments['orderType'] as String? ?? 'buy';

        if (instrumentData != null) {
          currentPrice = instrumentData!['currentPrice'] as double? ??
              instrumentData!['askPrice'] as double? ??
              0.0;

          // For sell orders, check available quantity
          if (orderType == 'sell') {
            holdingQuantity =
                _getHoldingQuantity(instrumentData!['symbol'] as String);
          }
        }
      });

      // Set default amount based on order type
      if (orderType == 'buy') {
        _amountController.text = '10000';
        _calculateFromAmount();
      } else {
        // For sell orders, start with quantity mode
        inputMode = 'quantity';
        if (holdingQuantity > 0) {
          _quantityController.text = holdingQuantity.toString();
          _calculateFromQuantity();
        }
      }
    }
  }

  double _getHoldingQuantity(String symbol) {
    // Mock holding data - in real app, get from portfolio
    final mockHoldings = {
      'SQRPHARMA': 100.0,
      'BATBC': 50.0,
      'GP': 75.0,
      'BEXIMCO': 200.0,
      'CITYBANK': 300.0,
    };
    return mockHoldings[symbol] ?? 0.0;
  }

  void _onAmountChanged() {
    if (inputMode == 'amount' && _amountController.text.isNotEmpty) {
      _calculateFromAmount();
    }
  }

  void _onQuantityChanged() {
    if (inputMode == 'quantity' && _quantityController.text.isNotEmpty) {
      _calculateFromQuantity();
    }
  }

  void _calculateFromAmount() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount > 0 && currentPrice > 0) {
      setState(() {
        totalAmount = amount;
        totalQuantity = (amount / currentPrice).floor().toDouble();
        brokerageFee = amount * 0.005; // 0.5% brokerage

        if (orderType == 'buy') {
          totalCost = amount + brokerageFee;
        } else {
          // For sell orders, user receives amount minus brokerage
          totalCost = amount - brokerageFee;
        }
      });

      // Update quantity field without triggering listener
      _quantityController.removeListener(_onQuantityChanged);
      _quantityController.text = totalQuantity.toStringAsFixed(0);
      _quantityController.addListener(_onQuantityChanged);
    }
  }

  void _calculateFromQuantity() {
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    if (quantity > 0 && currentPrice > 0) {
      setState(() {
        totalQuantity = quantity;
        totalAmount = quantity * currentPrice;
        brokerageFee = totalAmount * 0.005; // 0.5% brokerage

        if (orderType == 'buy') {
          totalCost = totalAmount + brokerageFee;
        } else {
          // For sell orders, user receives amount minus brokerage
          totalCost = totalAmount - brokerageFee;
        }
      });

      // Update amount field without triggering listener
      _amountController.removeListener(_onAmountChanged);
      _amountController.text = totalAmount.toStringAsFixed(2);
      _amountController.addListener(_onAmountChanged);
    }
  }

  void _switchInputMode(String mode) {
    setState(() {
      inputMode = mode;
    });

    if (mode == 'amount') {
      _calculateFromAmount();
    } else {
      _calculateFromQuantity();
    }
  }

  void _previewOrder() {
    if (totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid ${inputMode}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (orderType == 'buy' && totalCost > availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient balance for this order'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (orderType == 'sell' && totalQuantity > holdingQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Insufficient quantity. You hold ${holdingQuantity.toStringAsFixed(0)} shares'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (orderType == 'sell' && holdingQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'You don\'t hold any shares of ${instrumentData!['symbol']}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    _showOrderPreview();
  }

  void _showOrderPreview() {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOrderPreviewSheet(),
    );
  }

  Widget _buildOrderPreviewSheet() {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Review ${orderType.toUpperCase()} Order',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    size: 6.w,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instrument info
                  _buildInstrumentPreview(),
                  SizedBox(height: 3.h),

                  // Order details
                  _buildOrderDetails(),
                  SizedBox(height: 3.h),

                  // Cost breakdown
                  _buildCostBreakdown(),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Confirm button
          Container(
            padding: EdgeInsets.all(4.w),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 12.w,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _confirmOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orderType == 'buy'
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 6.w,
                          height: 6.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: orderType == 'buy'
                                  ? 'trending_up'
                                  : 'trending_down',
                              size: 20,
                              color: Colors.white,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Confirm ${orderType.toUpperCase()} Order',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color: Colors.white,
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
    );
  }

  Widget _buildInstrumentPreview() {
    if (instrumentData == null) return SizedBox.shrink();

    final dayChange = instrumentData!['dayChange'] as double? ?? 0.0;
    final isPositive = dayChange >= 0;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                (instrumentData!['symbol'] as String).substring(0, 2),
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instrumentData!['symbol'] as String,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  instrumentData!['name'] as String,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '৳${currentPrice.toStringAsFixed(2)}',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AppTheme.successColor.withValues(alpha: 0.1)
                      : AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${isPositive ? '+' : ''}${dayChange.toStringAsFixed(2)}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: isPositive
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Details',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        _buildDetailRow('Order Type', orderType.toUpperCase(),
            color: orderType == 'buy'
                ? AppTheme.successColor
                : AppTheme.errorColor),
        _buildDetailRow(
            'Quantity', '${totalQuantity.toStringAsFixed(0)} shares'),
        _buildDetailRow(
            'Price per Share', '৳${currentPrice.toStringAsFixed(2)}'),
        _buildDetailRow('Total Amount', '৳${totalAmount.toStringAsFixed(2)}'),
        if (orderType == 'sell')
          _buildDetailRow(
              'Available Qty', '${holdingQuantity.toStringAsFixed(0)} shares'),
      ],
    );
  }

  Widget _buildCostBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          orderType == 'buy' ? 'Cost Breakdown' : 'Proceeds Breakdown',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        _buildDetailRow('Order Value', '৳${totalAmount.toStringAsFixed(2)}'),
        _buildDetailRow(
            'Brokerage (0.5%)',
            orderType == 'buy'
                ? '+৳${brokerageFee.toStringAsFixed(2)}'
                : '-৳${brokerageFee.toStringAsFixed(2)}'),
        Divider(height: 3.h),
        _buildDetailRow(orderType == 'buy' ? 'Total Cost' : 'Net Proceeds',
            '৳${totalCost.toStringAsFixed(2)}',
            isTotal: true),
        if (orderType == 'buy') ...[
          SizedBox(height: 1.h),
          _buildDetailRow('Remaining Balance',
              '৳${(availableBalance - totalCost).toStringAsFixed(2)}',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
        ] else ...[
          SizedBox(height: 1.h),
          _buildDetailRow('Remaining Qty',
              '${(holdingQuantity - totalQuantity).toStringAsFixed(0)} shares',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
        ],
      ],
    );
  }

  Widget _buildDetailRow(String label, String value,
      {Color? color, bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: color ?? AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: color ?? AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmOrder() async {
    setState(() {
      isLoading = true;
    });

    // Simulate order processing
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });

    Navigator.pop(context); // Close preview
    _showOrderSuccess();
  }

  void _showOrderSuccess() {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.successColor,
                size: 40,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              "Order Placed Successfully!",
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              "Your ${orderType} order for ${totalQuantity.toStringAsFixed(0)} shares of ${instrumentData!['symbol']} has been placed.",
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Order ID:",
                          style: AppTheme.lightTheme.textTheme.bodySmall),
                      Text(
                          "ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
                          style: AppTheme.lightTheme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Amount:",
                          style: AppTheme.lightTheme.textTheme.bodySmall),
                      Text("৳${totalCost.toStringAsFixed(2)}",
                          style: AppTheme.lightTheme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/portfolio-holdings');
                    },
                    child: Text("View Portfolio"),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text("Done"),
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
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (instrumentData == null) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.primaryColor,
          ),
        ),
      );
    }

    // Check if sell order is possible
    bool canSell = orderType == 'sell' ? holdingQuantity > 0 : true;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('${orderType.toUpperCase()} Order'),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Sell order warning if no holdings
            if (orderType == 'sell' && !canSell)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                margin: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.errorColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'warning',
                      size: 6.w,
                      color: AppTheme.errorColor,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'You don\'t hold any shares of ${instrumentData!['symbol']}. You cannot place a sell order.',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Instrument header
                    InstrumentHeaderWidget(instrumentData: instrumentData!),

                    SizedBox(height: 4.h),

                    // Holdings info for sell orders
                    if (orderType == 'sell')
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppTheme
                              .lightTheme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Holdings',
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${holdingQuantity.toStringAsFixed(0)} shares',
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (orderType == 'sell') SizedBox(height: 3.h),

                    // Input mode toggle
                    if (canSell) _buildInputToggle(),

                    if (canSell) SizedBox(height: 3.h),

                    // Input field
                    if (canSell)
                      inputMode == 'amount'
                          ? _buildAmountInput()
                          : _buildQuantityInput(),

                    if (canSell) SizedBox(height: 4.h),

                    // Order summary
                    if (canSell) _buildOrderSummary(),

                    SizedBox(height: 6.h),
                  ],
                ),
              ),
            ),

            // Preview button
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed:
                      (totalAmount > 0 && canSell) ? _previewOrder : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orderType == 'buy'
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: orderType == 'buy'
                            ? 'trending_up'
                            : 'trending_down',
                        size: 20,
                        color: Colors.white,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        canSell
                            ? 'Preview ${orderType.toUpperCase()} Order'
                            : 'Cannot ${orderType.toUpperCase()}',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _switchInputMode('amount'),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color: inputMode == 'amount'
                      ? AppTheme.lightTheme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Amount',
                  textAlign: TextAlign.center,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: inputMode == 'amount'
                        ? Colors.white
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _switchInputMode('quantity'),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color: inputMode == 'quantity'
                      ? AppTheme.lightTheme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Quantity',
                  textAlign: TextAlign.center,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: inputMode == 'quantity'
                        ? Colors.white
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Amount',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            prefixText: '৳ ',
            prefixStyle: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            hintText: '0.00',
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
            contentPadding: EdgeInsets.all(4.w),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Quantity',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            // Decrease button
            Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: IconButton(
                onPressed: () {
                  final current = int.tryParse(_quantityController.text) ?? 0;
                  if (current > 0) {
                    _quantityController.text = (current - 1).toString();
                  }
                },
                icon: CustomIconWidget(
                  iconName: 'remove',
                  size: 20,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            // Quantity input
            Expanded(
              child: TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textAlign: TextAlign.center,
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  suffix: Text(
                    'shares',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
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
                  contentPadding: EdgeInsets.all(4.w),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            // Increase button
            Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: IconButton(
                onPressed: () {
                  final current = int.tryParse(_quantityController.text) ?? 0;
                  _quantityController.text = (current + 1).toString();
                },
                icon: CustomIconWidget(
                  iconName: 'add',
                  size: 20,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          _buildSummaryRow(
              'Quantity', '${totalQuantity.toStringAsFixed(0)} shares'),
          _buildSummaryRow(
              'Price per Share', '৳${currentPrice.toStringAsFixed(2)}'),
          _buildSummaryRow('Order Value', '৳${totalAmount.toStringAsFixed(2)}'),
          _buildSummaryRow(
              'Brokerage (0.5%)', '৳${brokerageFee.toStringAsFixed(2)}'),
          Divider(height: 3.h),
          _buildSummaryRow('Total Cost', '৳${totalCost.toStringAsFixed(2)}',
              isTotal: true),
          if (orderType == 'buy') ...[
            SizedBox(height: 1.h),
            _buildSummaryRow('Available Balance',
                '৳${(availableBalance - totalCost).toStringAsFixed(2)}',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isTotal = false, Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: color ?? AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: color ?? AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
