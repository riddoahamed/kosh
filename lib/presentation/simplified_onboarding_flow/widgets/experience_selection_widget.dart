import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExperienceSelectionWidget extends StatelessWidget {
  final String? selectedExperience;
  final Function(String) onExperienceSelected;
  final VoidCallback onComplete;

  const ExperienceSelectionWidget({
    Key? key,
    this.selectedExperience,
    required this.onExperienceSelected,
    required this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final experiences = [
      {
        'id': 'beginner',
        'title': 'Beginner',
        'subtitle': 'New to investing',
        'description':
            'I\'m just getting started with investing and want to learn the basics',
        'icon': 'school',
        'color': AppTheme.primaryLight,
      },
      {
        'id': 'intermediate',
        'title': 'Intermediate',
        'subtitle': 'Some experience',
        'description':
            'I have some knowledge and have made a few investments before',
        'icon': 'trending_up',
        'color': AppTheme.warningColor,
      },
      {
        'id': 'experienced',
        'title': 'Experienced',
        'subtitle': 'Active trader',
        'description':
            'I\'m experienced with trading and investment strategies',
        'icon': 'analytics',
        'color': AppTheme.successColor,
      },
    ];

    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Header
          Text(
            'Your investing knowledge',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryLight,
                ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 2.h),

          Text(
            'This helps us customize your learning experience',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4.h),

          // Experience cards
          Expanded(
            child: ListView.builder(
              itemCount: experiences.length,
              itemBuilder: (context, index) {
                final experience = experiences[index];
                final isSelected = selectedExperience == experience['id'];

                return Container(
                  margin: EdgeInsets.only(bottom: 3.h),
                  child: InkWell(
                    onTap: () =>
                        onExperienceSelected(experience['id'] as String),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (experience['color'] as Color)
                                .withValues(alpha: 0.1)
                            : AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? (experience['color'] as Color)
                              : AppTheme.borderLight,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: (experience['color'] as Color)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CustomIconWidget(
                              iconName: experience['icon'] as String,
                              size: 24,
                              color: experience['color'] as Color,
                            ),
                          ),

                          SizedBox(width: 4.w),

                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  experience['title'] as String,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimaryLight,
                                      ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  experience['subtitle'] as String,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: experience['color'] as Color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  experience['description'] as String,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppTheme.textSecondaryLight,
                                        height: 1.4,
                                      ),
                                ),
                              ],
                            ),
                          ),

                          // Selection indicator
                          if (isSelected)
                            Container(
                              padding: EdgeInsets.all(1.w),
                              decoration: BoxDecoration(
                                color: experience['color'] as Color,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const CustomIconWidget(
                                iconName: 'check',
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedExperience != null ? onComplete : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedExperience != null
                    ? AppTheme.primaryLight
                    : AppTheme.textSecondaryLight,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 4.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: selectedExperience != null ? 2 : 0,
              ),
              child: Text(
                'Start Investing',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}