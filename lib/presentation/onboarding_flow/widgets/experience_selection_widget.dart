import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExperienceSelectionWidget extends StatelessWidget {
  final String selectedLevel;
  final Function(String) onLevelSelected;
  final VoidCallback? onNext;

  const ExperienceSelectionWidget({
    Key? key,
    required this.selectedLevel,
    required this.onLevelSelected,
    this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> experienceLevels = [
      {
        'level': 'Beginner',
        'description': 'New to investing, want to learn the basics',
        'icon': 'school',
        'color': AppTheme.accentColor,
      },
      {
        'level': 'Intermediate',
        'description': 'Some experience, ready to explore more',
        'icon': 'trending_up',
        'color': AppTheme.warningColor,
      },
      {
        'level': 'Advanced',
        'description': 'Experienced investor, looking for tools',
        'icon': 'analytics',
        'color': AppTheme.lightTheme.colorScheme.primary,
      },
    ];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        child: Column(
          children: [
            // Header
            Text(
              'What\'s your investing experience?',
              style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 1.h),

            Text(
              'This helps us personalize your learning journey',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 4.h),

            // Experience level cards
            Expanded(
              child: ListView.separated(
                itemCount: experienceLevels.length,
                separatorBuilder: (context, index) => SizedBox(height: 2.h),
                itemBuilder: (context, index) {
                  final level = experienceLevels[index];
                  final isSelected = selectedLevel == level['level'];

                  return GestureDetector(
                    onTap: () => onLevelSelected(level['level'] as String),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (level['color'] as Color).withValues(alpha: 0.1)
                            : AppTheme.lightTheme.colorScheme.surface,
                        border: Border.all(
                          color: isSelected
                              ? level['color'] as Color
                              : AppTheme.lightTheme.colorScheme.outline,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: (level['color'] as Color)
                                      .withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            width: 12.w,
                            height: 12.w,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? level['color'] as Color
                                  : AppTheme.lightTheme.colorScheme.outline,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CustomIconWidget(
                              iconName: level['icon'] as String,
                              color: Colors.white,
                              size: 6.w,
                            ),
                          ),

                          SizedBox(width: 4.w),

                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  level['level'] as String,
                                  style: AppTheme
                                      .lightTheme.textTheme.titleLarge
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? level['color'] as Color
                                        : AppTheme
                                            .lightTheme.colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  level['description'] as String,
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Selection indicator
                          if (isSelected)
                            CustomIconWidget(
                              iconName: 'check_circle',
                              color: level['color'] as Color,
                              size: 6.w,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 2.h),

            // Continue button
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: selectedLevel.isNotEmpty ? onNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedLevel.isNotEmpty
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
