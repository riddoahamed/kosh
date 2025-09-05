import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HoldingCardWidget extends StatelessWidget {
  final Map<String, dynamic> holding;
  final bool showPercentage;
  final VoidCallback onTap;
  final VoidCallback onBuyMore;
  final VoidCallback onSell;

  const HoldingCardWidget({
    Key? key,
    required this.holding,
    required this.showPercentage,
    required this.onTap,
    required this.onBuyMore,
    required this.onSell,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String name = holding['name'] as String;
    final String symbol = holding['symbol'] as String;
    final double quantity = (holding['quantity'] as num).toDouble();
    final double avgPrice = (holding['avgPrice'] as num).toDouble();
    final double currentPrice = (holding['currentPrice'] as num).toDouble();
    final double currentValue = quantity * currentPrice;
    final double unrealizedPL = currentValue - (quantity * avgPrice);
    final double plPercentage =
        avgPrice > 0 ? (unrealizedPL / (quantity * avgPrice)) * 100 : 0.0;
    final double portfolioAllocation =
        (holding['portfolioAllocation'] as num).toDouble();
    final String chartUrl = holding['chartUrl'] as String;

    final isPositive = unrealizedPL >= 0;
    final plColor = isPositive ? AppTheme.successColor : AppTheme.errorColor;

    return Slidable(
      key: ValueKey(symbol),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onBuyMore(),
            backgroundColor: AppTheme.successColor,
            foregroundColor: Colors.white,
            icon: Icons.add_shopping_cart,
            label: 'Buy More',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onSell(),
            backgroundColor: AppTheme.errorColor,
            foregroundColor: Colors.white,
            icon: Icons.sell,
            label: 'Sell',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
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
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.textPrimaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          symbol,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryLight,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          '${quantity.toStringAsFixed(0)} shares',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 8.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppTheme.lightTheme.colorScheme.primaryContainer
                            .withValues(alpha: 0.1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CustomImageWidget(
                          imageUrl: chartUrl,
                          width: double.infinity,
                          height: 8.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Value',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '৳${currentValue.toStringAsFixed(2)}',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'P/L',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName:
                                isPositive ? 'trending_up' : 'trending_down',
                            size: 16,
                            color: plColor,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            showPercentage
                                ? '${plPercentage.toStringAsFixed(2)}%'
                                : '৳${unrealizedPL.toStringAsFixed(2)}',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: plColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Avg: ৳${avgPrice.toStringAsFixed(2)}',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                  Text(
                    '${portfolioAllocation.toStringAsFixed(1)}% of portfolio',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
