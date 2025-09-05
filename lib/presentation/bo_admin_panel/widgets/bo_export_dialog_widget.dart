import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BoExportDialogWidget extends StatefulWidget {
  final List<Map<String, dynamic>> applications;
  final List<String> selectedIds;
  final Function(List<Map<String, dynamic>>) onExport;

  const BoExportDialogWidget({
    Key? key,
    required this.applications,
    required this.selectedIds,
    required this.onExport,
  }) : super(key: key);

  @override
  State<BoExportDialogWidget> createState() => _BoExportDialogWidgetState();
}

class _BoExportDialogWidgetState extends State<BoExportDialogWidget> {
  bool _exportSelectedOnly = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _exportSelectedOnly = widget.selectedIds.isNotEmpty;
  }

  Future<void> _performExport() async {
    setState(() => _isLoading = true);

    try {
      List<Map<String, dynamic>> applicationsToExport;

      if (_exportSelectedOnly && widget.selectedIds.isNotEmpty) {
        applicationsToExport = widget.applications
            .where((app) => widget.selectedIds.contains(app['id']))
            .toList();
      } else {
        applicationsToExport = widget.applications;
      }

      await widget.onExport(applicationsToExport);
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _isLoading = false);
      // Error is handled by parent
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = widget.selectedIds.length;
    final totalCount = widget.applications.length;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'download',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 5.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Export Applications',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  'Download as CSV file',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Export options
          Text(
            'Export Options',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),

          SizedBox(height: 2.h),

          // Export all option
          InkWell(
            onTap: () {
              setState(() {
                _exportSelectedOnly = false;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: !_exportSelectedOnly
                    ? AppTheme.lightTheme.colorScheme.primaryContainer
                        .withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: !_exportSelectedOnly
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                  width: !_exportSelectedOnly ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Radio<bool>(
                    value: false,
                    groupValue: _exportSelectedOnly,
                    onChanged: (value) {
                      setState(() {
                        _exportSelectedOnly = value!;
                      });
                    },
                    activeColor: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export All Applications',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          'Export all $totalCount filtered applications',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 1.h),

          // Export selected option
          InkWell(
            onTap: selectedCount > 0
                ? () {
                    setState(() {
                      _exportSelectedOnly = true;
                    });
                  }
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: _exportSelectedOnly
                    ? AppTheme.lightTheme.colorScheme.primaryContainer
                        .withValues(alpha: 0.1)
                    : selectedCount == 0
                        ? AppTheme.lightTheme.colorScheme.surfaceContainer
                            .withValues(alpha: 0.05)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _exportSelectedOnly
                      ? AppTheme.lightTheme.colorScheme.primary
                      : selectedCount == 0
                          ? AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.1)
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.2),
                  width: _exportSelectedOnly ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: _exportSelectedOnly,
                    onChanged: selectedCount > 0
                        ? (value) {
                            setState(() {
                              _exportSelectedOnly = value!;
                            });
                          }
                        : null,
                    activeColor: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export Selected Applications',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: selectedCount == 0
                                    ? AppTheme
                                        .lightTheme.colorScheme.onSurfaceVariant
                                    : AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                        ),
                        Text(
                          selectedCount > 0
                              ? 'Export $selectedCount selected applications'
                              : 'No applications selected',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // CSV info
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceContainer
                  .withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 4.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'CSV Export Details',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  'The CSV will include: userId, userName, nid, fullName, dob, mobile, bankAccount, status, createdAt, updatedAt',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _performExport,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
          child: _isLoading
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 4.w,
                      height: 4.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text('Exporting...'),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'download',
                      color: Colors.white,
                      size: 4.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Export CSV',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
