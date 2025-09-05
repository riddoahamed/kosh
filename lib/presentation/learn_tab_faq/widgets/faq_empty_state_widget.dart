import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FaqEmptyStateWidget extends StatelessWidget {
  final String searchQuery;
  final String selectedCategory;
  final VoidCallback onResetFilters;

  const FaqEmptyStateWidget({
    Key? key,
    required this.searchQuery,
    required this.selectedCategory,
    required this.onResetFilters,
  }) : super(key: key);

  List<String> get _popularQuestions => [
        'How do I open a BO account?',
        'What is the minimum investment amount?',
        'How are trading fees calculated?',
        'How do I withdraw my money?',
      ];

  @override
  Widget build(BuildContext context) {
    final hasFilters = searchQuery.isNotEmpty || selectedCategory != 'All';

    return Container(
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty state icon
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: AppTheme.textSecondaryLight.withAlpha(26),
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: Icon(
              hasFilters ? Icons.search_off : Icons.help_outline,
              size: 10.w,
              color: AppTheme.textSecondaryLight,
            ),
          ),

          SizedBox(height: 3.h),

          // Title
          Text(
            hasFilters ? 'No matching FAQs found' : 'No FAQs available',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 1.h),

          // Description
          Text(
            hasFilters
                ? 'Try adjusting your search or browse popular questions below.'
                : 'FAQ content is loading or temporarily unavailable.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4.h),

          if (hasFilters) ...[
            // Reset Filters Button
            ElevatedButton.icon(
              onPressed: onResetFilters,
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            SizedBox(height: 4.h),
          ],

          // Popular Questions Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.borderLight,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: AppTheme.warningColor,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Popular Questions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textPrimaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                ..._popularQuestions.map((question) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 1.h),
                    child: InkWell(
                      onTap: () {
                        // Navigate back with this question as search
                        Navigator.pop(context, question);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: EdgeInsets.all(2.w),
                        child: Row(
                          children: [
                            Icon(
                              Icons.help_outline,
                              size: 4.w,
                              color: AppTheme.primaryLight,
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Text(
                                question,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.textPrimaryLight,
                                    ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 3.w,
                              color: AppTheme.textSecondaryLight,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
