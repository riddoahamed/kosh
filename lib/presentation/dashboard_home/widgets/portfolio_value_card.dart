import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PortfolioValueCard extends StatefulWidget {
  final double totalBalance;
  final double dayChange;
  final double dayChangePercentage;
  final bool isFantasyMode;
  final VoidCallback onToggleVisibility;
  final bool isBalanceVisible;

  const PortfolioValueCard({
    Key? key,
    required this.totalBalance,
    required this.dayChange,
    required this.dayChangePercentage,
    required this.isFantasyMode,
    required this.onToggleVisibility,
    required this.isBalanceVisible,
  }) : super(key: key);

  @override
  State<PortfolioValueCard> createState() => _PortfolioValueCardState();
}

class _PortfolioValueCardState extends State<PortfolioValueCard> {
  @override
  Widget build(BuildContext context) {
    final isPositive = widget.dayChange >= 0;
    final changeColor =
        isPositive ? AppTheme.successColor : AppTheme.errorColor;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Portfolio Value',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Text(
                        widget.isBalanceVisible
                            ? '৳${widget.totalBalance.toStringAsFixed(2)}'
                            : '৳ ••••••',
                        style: AppTheme.lightTheme.textTheme.headlineMedium
                            ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimaryLight,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: widget.isFantasyMode
                              ? AppTheme.warningColor.withValues(alpha: 0.1)
                              : AppTheme.accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.isFantasyMode ? 'Fantasy' : 'Real Tester',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: widget.isFantasyMode
                                ? AppTheme.warningColor
                                : AppTheme.accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: widget.onToggleVisibility,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: widget.isBalanceVisible
                        ? 'visibility'
                        : 'visibility_off',
                    color: AppTheme.primaryLight,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          widget.isBalanceVisible
              ? Row(
                  children: [
                    CustomIconWidget(
                      iconName: isPositive ? 'trending_up' : 'trending_down',
                      color: changeColor,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '৳${widget.dayChange.abs().toStringAsFixed(2)}',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: changeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '(${isPositive ? '+' : '-'}${widget.dayChangePercentage.abs().toStringAsFixed(2)}%)',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: changeColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'today',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }
}
