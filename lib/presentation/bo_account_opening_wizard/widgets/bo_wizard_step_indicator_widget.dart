import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BoWizardStepIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;

  const BoWizardStepIndicatorWidget({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isActive = index == currentStep;
            final isUpcoming = index > currentStep;

            return Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppTheme.successColor
                            : isActive
                                ? AppTheme.primaryLight
                                : AppTheme.borderLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive
                              ? AppTheme.primaryLight
                              : AppTheme.borderLight,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: isCompleted
                            ? CustomIconWidget(
                                iconName: 'check',
                                size: 16,
                                color: Colors.white,
                              )
                            : Text(
                                '${index + 1}',
                                style: AppTheme.lightTheme.textTheme.labelMedium
                                    ?.copyWith(
                                  color: isActive
                                      ? Colors.white
                                      : AppTheme.textSecondaryLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    SizedBox(
                      width: 20.w,
                      child: Text(
                        stepTitles[index],
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: isActive
                              ? AppTheme.primaryLight
                              : isCompleted
                                  ? AppTheme.successColor
                                  : AppTheme.textSecondaryLight,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (index < totalSteps - 1)
                  Container(
                    width: 6.w,
                    height: 2,
                    margin: EdgeInsets.only(bottom: 6.h, left: 2.w, right: 2.w),
                    color: isCompleted
                        ? AppTheme.successColor
                        : AppTheme.borderLight,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
