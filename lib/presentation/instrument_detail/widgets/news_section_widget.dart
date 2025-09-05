import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NewsSectionWidget extends StatelessWidget {
  final String instrumentName;

  const NewsSectionWidget({
    Key? key,
    required this.instrumentName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> newsData = [
      {
        "id": 1,
        "title":
            "\$instrumentName Reports Strong Q3 Earnings, Beats Analyst Expectations",
        "summary":
            "The company delivered impressive quarterly results with revenue growth of 15% year-over-year, driven by strong demand in key markets.",
        "source": "Financial Express",
        "timestamp": DateTime.now().subtract(Duration(hours: 2)),
        "imageUrl":
            "https://images.pexels.com/photos/6801648/pexels-photo-6801648.jpeg?auto=compress&cs=tinysrgb&w=800",
      },
      {
        "id": 2,
        "title":
            "Market Analysis: \$instrumentName Stock Shows Bullish Momentum",
        "summary":
            "Technical indicators suggest continued upward trend as institutional investors increase their positions in the stock.",
        "source": "The Daily Star",
        "timestamp": DateTime.now().subtract(Duration(hours: 5)),
        "imageUrl":
            "https://images.pexels.com/photos/7567486/pexels-photo-7567486.jpeg?auto=compress&cs=tinysrgb&w=800",
      },
      {
        "id": 3,
        "title":
            "\$instrumentName Announces Strategic Partnership with Leading Tech Firm",
        "summary":
            "The collaboration aims to enhance digital capabilities and expand market reach in the growing technology sector.",
        "source": "Business Standard",
        "timestamp": DateTime.now().subtract(Duration(hours: 8)),
        "imageUrl":
            "https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg?auto=compress&cs=tinysrgb&w=800",
      },
      {
        "id": 4,
        "title":
            "Analyst Upgrade: \$instrumentName Receives Buy Rating from Major Brokerage",
        "summary":
            "Leading investment firm raises price target citing strong fundamentals and positive industry outlook.",
        "source": "Reuters",
        "timestamp": DateTime.now().subtract(Duration(days: 1)),
        "imageUrl":
            "https://images.pexels.com/photos/6802049/pexels-photo-6802049.jpeg?auto=compress&cs=tinysrgb&w=800",
      },
    ];

    String formatTimestamp(DateTime timestamp) {
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Related News',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full news section
                },
                child: Text(
                  'View All',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: newsData.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              final news = newsData[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to news detail
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  padding: EdgeInsets.all(3.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // News image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CustomImageWidget(
                          imageUrl: news['imageUrl'] as String,
                          width: 20.w,
                          height: 15.w,
                          fit: BoxFit.cover,
                        ),
                      ),

                      SizedBox(width: 3.w),

                      // News content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              news['title'] as String,
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              news['summary'] as String,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 1.5.h),
                            Row(
                              children: [
                                Text(
                                  news['source'] as String,
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(
                                  formatTimestamp(
                                      news['timestamp'] as DateTime),
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
