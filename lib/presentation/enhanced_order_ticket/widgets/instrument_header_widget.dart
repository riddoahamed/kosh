import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class InstrumentHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> instrumentData;

  const InstrumentHeaderWidget({
    Key? key,
    required this.instrumentData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dayChange = instrumentData['dayChange'] as double? ?? 0.0;
    final dayChangePercent =
        instrumentData['dayChangePercent'] as double? ?? 0.0;
    final isPositive = dayChange >= 0;
    final currentPrice = instrumentData['currentPrice'] as double? ?? 0.0;
    final lastUpdated =
        instrumentData['lastUpdated'] as DateTime? ?? DateTime.now();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.colorScheme.primaryContainer
                .withValues(alpha: 0.1),
            AppTheme.lightTheme.colorScheme.secondaryContainer
                .withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Symbol and name
          Row(
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
                    (instrumentData['symbol'] as String).substring(0, 2),
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
                      instrumentData['symbol'] as String,
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      instrumentData['name'] as String,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Price and change
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '৳${currentPrice.toStringAsFixed(2)}',
                style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
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
                      ? AppTheme.successColor.withValues(alpha: 0.1)
                      : AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: isPositive ? 'arrow_upward' : 'arrow_downward',
                      size: 16,
                      color: isPositive
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '৳${dayChange.abs().toStringAsFixed(2)} (${dayChangePercent.abs().toStringAsFixed(2)}%)',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
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

          // Last updated
          Text(
            'Last updated: ${lastUpdated.hour.toString().padLeft(2, '0')}:${lastUpdated.minute.toString().padLeft(2, '0')}',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),

          SizedBox(height: 2.h),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Day High',
                  '৳${(instrumentData['dayHigh'] as double? ?? 0.0).toStringAsFixed(2)}',
                ),
              ),
              Container(
                width: 1,
                height: 6.h,
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Day Low',
                  '৳${(instrumentData['dayLow'] as double? ?? 0.0).toStringAsFixed(2)}',
                ),
              ),
              Container(
                width: 1,
                height: 6.h,
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Volume',
                  '${((instrumentData['volume'] as int? ?? 0) / 1000).toStringAsFixed(0)}K',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
