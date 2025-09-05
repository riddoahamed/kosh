import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class KeyStatisticsWidget extends StatelessWidget {
  final Map<String, dynamic> instrumentData;

  const KeyStatisticsWidget({
    Key? key,
    required this.instrumentData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> statisticsData = [
      {
        "label": "Day Range",
        "value":
            "৳${(instrumentData['dayLow'] as double).toStringAsFixed(2)} - ৳${(instrumentData['dayHigh'] as double).toStringAsFixed(2)}",
        "icon": "trending_up",
      },
      {
        "label": "52W High",
        "value":
            "৳${(instrumentData['yearHigh'] as double).toStringAsFixed(2)}",
        "icon": "arrow_upward",
      },
      {
        "label": "52W Low",
        "value": "৳${(instrumentData['yearLow'] as double).toStringAsFixed(2)}",
        "icon": "arrow_downward",
      },
      {
        "label": "Market Cap",
        "value": instrumentData['marketCap'] as String,
        "icon": "account_balance",
      },
      {
        "label": "P/E Ratio",
        "value": (instrumentData['peRatio'] as double).toStringAsFixed(2),
        "icon": "analytics",
      },
      {
        "label": "Dividend Yield",
        "value":
            "${(instrumentData['dividendYield'] as double).toStringAsFixed(2)}%",
        "icon": "payments",
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Statistics',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 2.5,
            ),
            itemCount: statisticsData.length,
            itemBuilder: (context, index) {
              final stat = statisticsData[index];
              return Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                  ),
                ),
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: stat['icon'] as String,
                          size: 16,
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            stat['label'] as String,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      stat['value'] as String,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
