import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HoldingsCard extends StatelessWidget {
  final Map<String, dynamic> holding;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const HoldingsCard({
    Key? key,
    required this.holding,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentValue = (holding['currentValue'] as double?) ?? 0.0;
    final dayChange = (holding['dayChange'] as double?) ?? 0.0;
    final dayChangePercentage =
        (holding['dayChangePercentage'] as double?) ?? 0.0;
    final isPositive = dayChange >= 0;
    final changeColor =
        isPositive ? AppTheme.successColor : AppTheme.errorColor;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 70.w,
        margin: EdgeInsets.only(right: 3.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.borderLight,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: _getInstrumentColor(
                        holding['type'] as String? ?? 'stock'),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      _getInstrumentIcon(holding['type'] as String? ?? 'stock'),
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        holding['symbol'] as String? ?? '',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        holding['name'] as String? ?? '',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              '${holding['quantity']} shares',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              '৳${currentValue.toStringAsFixed(2)}',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: isPositive ? 'arrow_upward' : 'arrow_downward',
                  color: changeColor,
                  size: 12,
                ),
                SizedBox(width: 1.w),
                Text(
                  '${isPositive ? '+' : ''}${dayChangePercentage.toStringAsFixed(2)}%',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: changeColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getInstrumentColor(String type) {
    switch (type.toLowerCase()) {
      case 'stock':
        return AppTheme.primaryLight;
      case 'mutual_fund':
        return AppTheme.accentColor;
      case 'gold':
        return AppTheme.warningColor;
      default:
        return AppTheme.primaryLight;
    }
  }

  String _getInstrumentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'stock':
        return 'S';
      case 'mutual_fund':
        return 'M';
      case 'gold':
        return 'G';
      default:
        return 'S';
    }
  }
}
