import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OrderSummaryWidget extends StatelessWidget {
  final double totalAmount;
  final double availableBalance;
  final double remainingBalance;
  final int? quantity;
  final double unitPrice;

  const OrderSummaryWidget({
    Key? key,
    required this.totalAmount,
    required this.availableBalance,
    required this.remainingBalance,
    this.quantity,
    required this.unitPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
            "Order Summary",
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          _buildSummaryRow("Order Type", "Market Order"),
          SizedBox(height: 1.h),
          if (quantity != null) ...[
            _buildSummaryRow("Quantity", "$quantity shares"),
            SizedBox(height: 1.h),
            _buildSummaryRow("Unit Price", "৳${unitPrice.toStringAsFixed(2)}"),
            SizedBox(height: 1.h),
          ],
          _buildSummaryRow(
            "Total Amount",
            "৳${totalAmount.toStringAsFixed(2)}",
            isHighlighted: true,
          ),
          SizedBox(height: 2.h),
          Divider(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          SizedBox(height: 2.h),
          _buildSummaryRow(
              "Available Balance", "৳${availableBalance.toStringAsFixed(2)}"),
          SizedBox(height: 1.h),
          _buildSummaryRow(
            "Remaining Balance",
            "৳${remainingBalance.toStringAsFixed(2)}",
            textColor: remainingBalance < 0
                ? AppTheme.errorColor
                : AppTheme.successColor,
          ),
          if (remainingBalance < 0) ...[
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'warning',
                    color: AppTheme.errorColor,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      "Insufficient balance for this order",
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    "Market orders execute at current market price. Final price may vary slightly.",
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isHighlighted = false,
    Color? textColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
            color: textColor ?? AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
