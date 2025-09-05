import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import './instrument_card_widget.dart';

class CategorySectionWidget extends StatelessWidget {
  final String categoryName;
  final List<Map<String, dynamic>> instruments;
  final Function(Map<String, dynamic>) onInstrumentTap;
  final Function(Map<String, dynamic>) onQuickBuy;
  final Function(Map<String, dynamic>) onAddToWatchlist;

  const CategorySectionWidget({
    Key? key,
    required this.categoryName,
    required this.instruments,
    required this.onInstrumentTap,
    required this.onQuickBuy,
    required this.onAddToWatchlist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (instruments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header with horizontal scrollable categories
        Container(
          height: 8.h,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              Container(
                width: 1.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: _getCategoryColor(categoryName),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      // Stocks category
                      _buildCategoryChip(
                        'Stocks',
                        categoryName == 'Stocks',
                      ),
                      SizedBox(width: 2.w),
                      // Mutual Funds category
                      _buildCategoryChip(
                        'Mutual Funds',
                        categoryName == 'Mutual Funds',
                      ),
                      SizedBox(width: 2.w),
                      // Gold category
                      _buildCategoryChip(
                        'Gold',
                        categoryName == 'Gold',
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to category-specific view
                },
                child: Text(
                  'View All',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Vertical scrollable instrument list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: instruments.length,
          itemBuilder: (context, index) {
            final instrument = instruments[index];
            return InstrumentCardWidget(
              instrument: instrument,
              onTap: () => onInstrumentTap(instrument),
              onQuickBuy: () => onQuickBuy(instrument),
              onAddToWatchlist: () => onAddToWatchlist(instrument),
            );
          },
        ),
        SizedBox(height: 2.h),
      ],
    );
  }

  Widget _buildCategoryChip(String category, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isSelected
            ? _getCategoryColor(category).withAlpha(51)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? _getCategoryColor(category)
              : AppTheme.lightTheme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Text(
        category,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: isSelected
              ? _getCategoryColor(category)
              : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'stocks':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'mutual funds':
        return AppTheme.accentColor;
      case 'gold':
        return AppTheme.warningColor;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }
}
