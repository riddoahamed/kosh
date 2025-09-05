import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PerformanceMetricsWidget extends StatelessWidget {
  final double totalInvested;
  final double currentValue;
  final double vwap;
  final DateTime lastUpdated;

  const PerformanceMetricsWidget({
    Key? key,
    required this.totalInvested,
    required this.currentValue,
    required this.vwap,
    required this.lastUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalReturn = currentValue - totalInvested;
    final totalReturnPercent =
        totalInvested > 0 ? (totalReturn / totalInvested) * 100 : 0.0;
    final isPositive = totalReturn >= 0;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'analytics',
                size: 20,
                color: AppTheme.primaryLight,
              ),
              SizedBox(width: 2.w),
              Text(
                'Performance Metrics',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Total Invested',
                  '৳${totalInvested.toStringAsFixed(2)}',
                  AppTheme.textPrimaryLight,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Current Value',
                  '৳${currentValue.toStringAsFixed(2)}',
                  AppTheme.textPrimaryLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Total Return',
                  '৳${totalReturn.toStringAsFixed(2)}',
                  isPositive ? AppTheme.successColor : AppTheme.errorColor,
                  showIcon: true,
                  isPositive: isPositive,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Return %',
                  '${totalReturnPercent.toStringAsFixed(2)}%',
                  isPositive ? AppTheme.successColor : AppTheme.errorColor,
                  showIcon: true,
                  isPositive: isPositive,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'VWAP',
                  '৳${vwap.toStringAsFixed(2)}',
                  AppTheme.textPrimaryLight,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Updated',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'access_time',
                          size: 14,
                          color: AppTheme.textSecondaryLight,
                        ),
                        SizedBox(width: 1.w),
                        Flexible(
                          child: Text(
                            _formatLastUpdated(lastUpdated),
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.textSecondaryLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    Color valueColor, {
    bool showIcon = false,
    bool isPositive = true,
  }) {
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
            if (showIcon) ...[
              CustomIconWidget(
                iconName: isPositive ? 'trending_up' : 'trending_down',
                size: 16,
                color: valueColor,
              ),
              SizedBox(width: 1.w),
            ],
            Flexible(
              child: Text(
                value,
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: valueColor,
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

  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
