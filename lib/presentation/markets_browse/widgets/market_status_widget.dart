import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class MarketStatusWidget extends StatelessWidget {
  final bool isMarketOpen;
  final String nextSessionTime;

  const MarketStatusWidget({
    Key? key,
    required this.isMarketOpen,
    required this.nextSessionTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isMarketOpen
            ? AppTheme.successColor.withValues(alpha: 0.1)
            : AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isMarketOpen
              ? AppTheme.successColor.withValues(alpha: 0.3)
              : AppTheme.errorColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 2.w,
            height: 2.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isMarketOpen ? AppTheme.successColor : AppTheme.errorColor,
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            isMarketOpen ? 'Market Open' : 'Market Closed',
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: isMarketOpen ? AppTheme.successColor : AppTheme.errorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!isMarketOpen) ...[
            SizedBox(width: 2.w),
            Text(
              '• Opens $nextSessionTime',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
