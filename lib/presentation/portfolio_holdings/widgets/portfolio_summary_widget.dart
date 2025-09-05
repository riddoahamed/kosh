import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PortfolioSummaryWidget extends StatelessWidget {
  final double totalValue;
  final double dayChange;
  final double totalPL;
  final bool showPercentage;
  final VoidCallback onToggleDisplay;

  const PortfolioSummaryWidget({
    Key? key,
    required this.totalValue,
    required this.dayChange,
    required this.totalPL,
    required this.showPercentage,
    required this.onToggleDisplay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dayChangePercent =
        totalValue > 0 ? (dayChange / totalValue) * 100 : 0.0;
    final totalPLPercent = totalValue > 0 ? (totalPL / totalValue) * 100 : 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Portfolio Value',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
              GestureDetector(
                onTap: onToggleDisplay,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        showPercentage ? '%' : '৳',
                        style:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      CustomIconWidget(
                        iconName: 'swap_horiz',
                        size: 16,
                        color: AppTheme.primaryLight,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            '৳${totalValue.toStringAsFixed(2)}',
            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
              color: AppTheme.textPrimaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildChangeIndicator(
                  'Today',
                  dayChange,
                  dayChangePercent,
                  showPercentage,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildChangeIndicator(
                  'Total P/L',
                  totalPL,
                  totalPLPercent,
                  showPercentage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChangeIndicator(
      String label, double value, double percentage, bool showPercentage) {
    final isPositive = value >= 0;
    final color = isPositive ? AppTheme.successColor : AppTheme.errorColor;
    final displayValue = showPercentage
        ? '${percentage.toStringAsFixed(2)}%'
        : '৳${value.toStringAsFixed(2)}';

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
        Row(
          children: [
            CustomIconWidget(
              iconName: isPositive ? 'trending_up' : 'trending_down',
              size: 16,
              color: color,
            ),
            SizedBox(width: 1.w),
            Flexible(
              child: Text(
                displayValue,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
