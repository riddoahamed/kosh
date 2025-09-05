import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ProgressDotsWidget extends StatelessWidget {
  final PageController controller;
  final int count;
  final int currentPage;

  const ProgressDotsWidget({
    Key? key,
    required this.controller,
    required this.count,
    required this.currentPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Progress Text
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${currentPage + 1} of $count',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryLight,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),

          // Dots Indicator
          SmoothPageIndicator(
            controller: controller,
            count: count,
            effect: ExpandingDotsEffect(
              activeDotColor: AppTheme.primaryLight,
              dotColor: AppTheme.borderLight,
              dotHeight: 2.w,
              dotWidth: 2.w,
              expansionFactor: 3,
              spacing: 1.w,
            ),
          ),

          // Progress Percentage
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${((currentPage + 1) / count * 100).round()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
