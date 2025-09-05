import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BoAdminFiltersWidget extends StatefulWidget {
  final String? selectedStatus;
  final DateTime? startDate;
  final DateTime? endDate;
  final String searchQuery;
  final List<String> statusOptions;
  final Function({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) onFiltersChanged;
  final VoidCallback onClearFilters;

  const BoAdminFiltersWidget({
    Key? key,
    required this.selectedStatus,
    required this.startDate,
    required this.endDate,
    required this.searchQuery,
    required this.statusOptions,
    required this.onFiltersChanged,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  State<BoAdminFiltersWidget> createState() => _BoAdminFiltersWidgetState();
}

class _BoAdminFiltersWidgetState extends State<BoAdminFiltersWidget> {
  final _searchController = TextEditingController();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: widget.startDate != null && widget.endDate != null
          ? DateTimeRange(start: widget.startDate!, end: widget.endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.lightTheme.colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onFiltersChanged(
        status: widget.selectedStatus,
        startDate: picked.start,
        endDate: picked.end,
        searchQuery: widget.searchQuery,
      );
    }
  }

  void _clearDateRange() {
    widget.onFiltersChanged(
      status: widget.selectedStatus,
      startDate: null,
      endDate: null,
      searchQuery: widget.searchQuery,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = widget.selectedStatus != null ||
        widget.startDate != null ||
        widget.searchQuery.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Main filter bar
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by NID, mobile, or name',
                      prefixIcon: Container(
                        margin: EdgeInsets.only(left: 2.w, right: 1.w),
                        child: CustomIconWidget(
                          iconName: 'search',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 5.w,
                        ),
                      ),
                      prefixIconConstraints:
                          BoxConstraints(minWidth: 10.w, minHeight: 5.w),
                      suffixIcon: widget.searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                widget.onFiltersChanged(
                                  status: widget.selectedStatus,
                                  startDate: widget.startDate,
                                  endDate: widget.endDate,
                                  searchQuery: '',
                                );
                              },
                              icon: CustomIconWidget(
                                iconName: 'clear',
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                                size: 4.w,
                              ),
                            )
                          : null,
                      filled: true,
                      fillColor: AppTheme
                          .lightTheme.colorScheme.surfaceContainer
                          .withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 2.5.w,
                      ),
                    ),
                    onSubmitted: (value) {
                      widget.onFiltersChanged(
                        status: widget.selectedStatus,
                        startDate: widget.startDate,
                        endDate: widget.endDate,
                        searchQuery: value,
                      );
                    },
                  ),
                ),

                SizedBox(width: 2.w),

                // Filter toggle button
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon: Badge(
                    isLabelVisible: hasActiveFilters,
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    child: CustomIconWidget(
                      iconName: 'tune',
                      color: hasActiveFilters
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 6.w,
                    ),
                  ),
                  tooltip: 'Filters',
                ),

                // Clear filters button
                if (hasActiveFilters)
                  IconButton(
                    onPressed: () {
                      _searchController.clear();
                      widget.onClearFilters();
                    },
                    icon: CustomIconWidget(
                      iconName: 'clear_all',
                      color: AppTheme.lightTheme.colorScheme.error,
                      size: 5.w,
                    ),
                    tooltip: 'Clear All',
                  ),
              ],
            ),
          ),

          // Expanded filters
          if (_isExpanded)
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(3.w, 0, 3.w, 3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surfaceContainer
                    .withValues(alpha: 0.03),
                border: Border(
                  top: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),

                  // Status filter
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            SizedBox(height: 1.h),
                            DropdownButtonFormField<String>(
                              value: widget.selectedStatus,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    AppTheme.lightTheme.colorScheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: AppTheme
                                        .lightTheme.colorScheme.outline
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: AppTheme
                                        .lightTheme.colorScheme.outline
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 3.w,
                                  vertical: 2.w,
                                ),
                              ),
                              hint: const Text('All Statuses'),
                              items: widget.statusOptions.map((status) {
                                return DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(_capitalizeStatus(status)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                widget.onFiltersChanged(
                                  status: value,
                                  startDate: widget.startDate,
                                  endDate: widget.endDate,
                                  searchQuery: widget.searchQuery,
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 4.w),

                      // Date range filter
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date Range',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            SizedBox(height: 1.h),
                            GestureDetector(
                              onTap: _selectDateRange,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3.w,
                                  vertical: 2.5.w,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.lightTheme.colorScheme.surface,
                                  border: Border.all(
                                    color: AppTheme
                                        .lightTheme.colorScheme.outline
                                        .withValues(alpha: 0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.startDate != null &&
                                                widget.endDate != null
                                            ? '${_formatDate(widget.startDate!)} - ${_formatDate(widget.endDate!)}'
                                            : 'Select date range',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: widget.startDate != null
                                                  ? AppTheme.lightTheme
                                                      .colorScheme.onSurface
                                                  : AppTheme
                                                      .lightTheme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                            ),
                                      ),
                                    ),
                                    if (widget.startDate != null)
                                      GestureDetector(
                                        onTap: _clearDateRange,
                                        child: CustomIconWidget(
                                          iconName: 'clear',
                                          color: AppTheme.lightTheme.colorScheme
                                              .onSurfaceVariant,
                                          size: 4.w,
                                        ),
                                      )
                                    else
                                      CustomIconWidget(
                                        iconName: 'calendar_today',
                                        color: AppTheme.lightTheme.colorScheme
                                            .onSurfaceVariant,
                                        size: 4.w,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _capitalizeStatus(String status) {
    switch (status) {
      case 'submitted':
        return 'Submitted';
      case 'in_review':
        return 'In Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
