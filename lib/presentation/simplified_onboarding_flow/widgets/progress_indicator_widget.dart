import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressIndicatorWidget({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: currentStep / totalSteps,
            backgroundColor: AppTheme.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
            minHeight: 4,
          ),

          SizedBox(height: 2.h),

          // Step indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalSteps, (index) {
              final stepNumber = index + 1;
              final isCompleted = stepNumber < currentStep;
              final isCurrent = stepNumber == currentStep;

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted || isCurrent
                            ? AppTheme.primaryLight
                            : AppTheme.borderLight,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const CustomIconWidget(
                                iconName: 'check',
                                size: 16,
                                color: Colors.white,
                              )
                            : Text(
                                stepNumber.toString(),
                                style: TextStyle(
                                  color: isCurrent
                                      ? Colors.white
                                      : AppTheme.textSecondaryLight,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                    if (index < totalSteps - 1) ...[
                      SizedBox(width: 2.w),
                      Container(
                        width: 8.w,
                        height: 2,
                        color: isCompleted
                            ? AppTheme.primaryLight
                            : AppTheme.borderLight,
                      ),
                      SizedBox(width: 2.w),
                    ],
                  ],
                ),
              );
            }),
          ),

          SizedBox(height: 1.h),

          // Step description
          Text(
            'Step $currentStep of $totalSteps',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
          ),
        ],
      ),
    );
  }
}
