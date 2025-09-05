import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BoAdminTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> applications;
  final List<String> selectedIds;
  final Function(List<String>) onSelectionChanged;
  final Function(String, String) onStatusUpdate;

  const BoAdminTableWidget({
    Key? key,
    required this.applications,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.onStatusUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'assignment',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 16.w,
            ),
            SizedBox(height: 2.h),
            Text(
              'No BO applications found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Applications will appear here once users submit them',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 100.w),
        child: DataTable(
          showCheckboxColumn: true,
          columnSpacing: 3.w,
          headingRowColor: WidgetStateProperty.all(
            AppTheme.lightTheme.colorScheme.surfaceContainer
                .withValues(alpha: 0.05),
          ),
          dataRowColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTheme.lightTheme.colorScheme.primaryContainer
                  .withValues(alpha: 0.1);
            }
            return null;
          }),
          border: TableBorder(
            horizontalInside: BorderSide(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          columns: [
            _buildDataColumn(context, 'User Name'),
            _buildDataColumn(context, 'NID'),
            _buildDataColumn(context, 'DOB'),
            _buildDataColumn(context, 'Mobile'),
            _buildDataColumn(context, 'Bank Account'),
            _buildDataColumn(context, 'Status'),
            _buildDataColumn(context, 'Created At'),
            _buildDataColumn(context, 'Actions'),
          ],
          rows: applications.map((app) => _buildDataRow(context, app)).toList(),
        ),
      ),
    );
  }

  DataColumn _buildDataColumn(BuildContext context, String label) {
    return DataColumn(
      label: Expanded(
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, Map<String, dynamic> app) {
    final isSelected = selectedIds.contains(app['id']);

    return DataRow(
      selected: isSelected,
      onSelectChanged: (selected) {
        final newSelectedIds = List<String>.from(selectedIds);
        if (selected == true) {
          newSelectedIds.add(app['id']);
        } else {
          newSelectedIds.remove(app['id']);
        }
        onSelectionChanged(newSelectedIds);
      },
      cells: [
        // User Name
        DataCell(
          Container(
            constraints: BoxConstraints(maxWidth: 25.w),
            child: Text(
              app['user_profiles']?['full_name'] ?? 'Unknown User',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        // NID (masked for privacy)
        DataCell(
          Container(
            constraints: BoxConstraints(maxWidth: 20.w),
            child: Text(
              _maskNid(app['nid']?.toString() ?? ''),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        // Date of Birth
        DataCell(
          Text(
            _formatDate(app['date_of_birth']),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),

        // Mobile
        DataCell(
          Container(
            constraints: BoxConstraints(maxWidth: 20.w),
            child: Text(
              app['mobile']?.toString() ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        // Bank Account
        DataCell(
          Container(
            constraints: BoxConstraints(maxWidth: 20.w),
            child: Text(
              app['bank_account']?.toString() ?? 'N/A',
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        // Status
        DataCell(
          _buildStatusChip(context, app['status']),
        ),

        // Created At
        DataCell(
          Text(
            _formatDateTime(app['created_at']),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),

        // Actions
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status update button
              IconButton(
                onPressed: () => onStatusUpdate(app['id'], app['status']),
                icon: CustomIconWidget(
                  iconName: 'edit',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 4.w,
                ),
                tooltip: 'Update Status',
                constraints: BoxConstraints(minWidth: 8.w, minHeight: 8.w),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context, String? status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status?.toLowerCase()) {
      case 'submitted':
        backgroundColor = AppTheme.warningColor.withValues(alpha: 0.1);
        textColor = AppTheme.warningColor;
        displayText = 'Submitted';
        break;
      case 'in_review':
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
        displayText = 'In Review';
        break;
      case 'approved':
        backgroundColor = AppTheme.successColor.withValues(alpha: 0.1);
        textColor = AppTheme.successColor;
        displayText = 'Approved';
        break;
      case 'rejected':
        backgroundColor = AppTheme.errorColor.withValues(alpha: 0.1);
        textColor = AppTheme.errorColor;
        displayText = 'Rejected';
        break;
      default:
        backgroundColor = AppTheme.lightTheme.colorScheme.surfaceContainer
            .withValues(alpha: 0.1);
        textColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
        displayText = status ?? 'Unknown';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  String _maskNid(String nid) {
    if (nid.length <= 4) return nid;
    final start = nid.substring(0, 2);
    final end = nid.substring(nid.length - 2);
    final middle = '*' * (nid.length - 4);
    return '$start$middle$end';
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }
}
