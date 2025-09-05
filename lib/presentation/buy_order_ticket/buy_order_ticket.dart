import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/amount_input_widget.dart';
import './widgets/confirmation_bottom_sheet.dart';
import './widgets/input_toggle_widget.dart';
import './widgets/instrument_header_widget.dart';
import './widgets/order_summary_widget.dart';
import './widgets/quantity_input_widget.dart';

class BuyOrderTicket extends StatefulWidget {
  const BuyOrderTicket({Key? key}) : super(key: key);

  @override
  State<BuyOrderTicket> createState() => _BuyOrderTicketState();
}

class _BuyOrderTicketState extends State<BuyOrderTicket> {
  bool _isQuantityMode = true;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  double _totalAmount = 0.0;
  int? _quantity;
  String? _quantityError;
  String? _amountError;
  bool _isOrderProcessing = false;

  // Mock data for the instrument
  final Map<String, dynamic> _instrument = {
    "id": 1,
    "name": "Grameenphone Ltd.",
    "symbol": "GP",
    "type": "Stock",
    "currentPrice": 285.50,
    "changePercent": 2.15,
    "marketCap": "৳1,22,345 Cr",
    "sector": "Telecommunications",
    "lastUpdated": DateTime.now(),
  };

  // Mock user balance
  final double _availableBalance = 50000.0;

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_onQuantityChanged);
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onQuantityChanged() {
    if (_isQuantityMode) {
      final quantityText = _quantityController.text;
      if (quantityText.isEmpty) {
        setState(() {
          _quantity = null;
          _totalAmount = 0.0;
          _quantityError = null;
        });
        return;
      }

      final quantity = int.tryParse(quantityText);
      if (quantity == null || quantity <= 0) {
        setState(() {
          _quantityError = "Please enter a valid quantity";
          _totalAmount = 0.0;
          _quantity = null;
        });
        return;
      }

      final total = quantity * (_instrument["currentPrice"] as double);
      setState(() {
        _quantity = quantity;
        _totalAmount = total;
        _quantityError =
            total > _availableBalance ? "Insufficient balance" : null;
      });
    }
  }

  void _onAmountChanged() {
    if (!_isQuantityMode) {
      final amountText = _amountController.text;
      if (amountText.isEmpty) {
        setState(() {
          _totalAmount = 0.0;
          _quantity = null;
          _amountError = null;
        });
        return;
      }

      final amount = double.tryParse(amountText);
      if (amount == null || amount <= 0) {
        setState(() {
          _amountError = "Please enter a valid amount";
          _totalAmount = 0.0;
          _quantity = null;
        });
        return;
      }

      final unitPrice = _instrument["currentPrice"] as double;
      final calculatedQuantity = (amount / unitPrice).floor();

      setState(() {
        _totalAmount = amount;
        _quantity = calculatedQuantity;
        _amountError =
            amount > _availableBalance ? "Insufficient balance" : null;
      });
    }
  }

  void _toggleInputMode() {
    setState(() {
      _isQuantityMode = !_isQuantityMode;
      _quantityController.clear();
      _amountController.clear();
      _totalAmount = 0.0;
      _quantity = null;
      _quantityError = null;
      _amountError = null;
    });
  }

  void _incrementQuantity() {
    final currentQuantity = int.tryParse(_quantityController.text) ?? 0;
    _quantityController.text = (currentQuantity + 1).toString();
  }

  void _decrementQuantity() {
    final currentQuantity = int.tryParse(_quantityController.text) ?? 0;
    if (currentQuantity > 0) {
      _quantityController.text = (currentQuantity - 1).toString();
    }
  }

  void _showConfirmationBottomSheet() {
    if (_totalAmount <= 0 || _totalAmount > _availableBalance) return;

    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConfirmationBottomSheet(
        instrument: _instrument,
        totalAmount: _totalAmount,
        quantity: _quantity,
        unitPrice: _instrument["currentPrice"] as double,
        onConfirm: _handleOrderConfirmation,
      ),
    );
  }

  void _handleOrderConfirmation() {
    setState(() {
      _isOrderProcessing = true;
    });

    // Simulate order processing and show success
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        HapticFeedback.heavyImpact();
        _showOrderSuccessDialog();
      }
    });
  }

  void _showOrderSuccessDialog() {
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
              "Your order for ${_quantity ?? 0} shares of ${_instrument["name"]} has been placed successfully.",
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
                      Text("Transaction ID:",
                          style: AppTheme.lightTheme.textTheme.bodySmall),
                      Text(
                          "TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
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
                      Text("৳${_totalAmount.toStringAsFixed(2)}",
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
  Widget build(BuildContext context) {
    final remainingBalance = _availableBalance - _totalAmount;
    final canPlaceOrder = _totalAmount > 0 &&
        _totalAmount <= _availableBalance &&
        _quantityError == null &&
        _amountError == null;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            InstrumentHeaderWidget(
              instrument: _instrument,
              onClose: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),
                    InputToggleWidget(
                      isQuantityMode: _isQuantityMode,
                      onToggle: _toggleInputMode,
                    ),
                    SizedBox(height: 3.h),
                    _isQuantityMode
                        ? QuantityInputWidget(
                            controller: _quantityController,
                            onIncrement: _incrementQuantity,
                            onDecrement: _decrementQuantity,
                            onChanged: (_) => _onQuantityChanged(),
                            errorText: _quantityError,
                          )
                        : AmountInputWidget(
                            controller: _amountController,
                            onChanged: (_) => _onAmountChanged(),
                            errorText: _amountError,
                          ),
                    SizedBox(height: 3.h),
                    OrderSummaryWidget(
                      totalAmount: _totalAmount,
                      availableBalance: _availableBalance,
                      remainingBalance: remainingBalance,
                      quantity: _quantity,
                      unitPrice: _instrument["currentPrice"] as double,
                    ),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: canPlaceOrder && !_isOrderProcessing
                          ? _showConfirmationBottomSheet
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canPlaceOrder
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isOrderProcessing
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              "Review Order",
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    "By placing this order, you agree to our terms and conditions",
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
