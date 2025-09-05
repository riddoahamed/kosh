import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_export.dart';
import './widgets/bo_admin_filters_widget.dart';
import './widgets/bo_admin_table_widget.dart';
import './widgets/bo_export_dialog_widget.dart';
import './widgets/bo_status_update_dialog_widget.dart';

class BoAdminPanel extends StatefulWidget {
  const BoAdminPanel({Key? key}) : super(key: key);

  @override
  State<BoAdminPanel> createState() => _BoAdminPanelState();
}

class _BoAdminPanelState extends State<BoAdminPanel> {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _applications = [];
  List<Map<String, dynamic>> _filteredApplications = [];
  bool _isLoading = false;

  // Filter state
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';
  List<String> _selectedApplicationIds = [];

  final List<String> _statusOptions = [
    'submitted',
    'in_review',
    'approved',
    'rejected',
  ];

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);

    try {
      // Get applications with user profile data
      var query = _supabase.from('bo_applications').select('''
            *,
            user_profiles (
              full_name,
              email
            )
          ''');

      final response = await query.order('created_at', ascending: false);

      setState(() {
        _applications = List<Map<String, dynamic>>.from(response);
        _applyFilters();
      });
    } catch (e) {
      debugPrint('Error loading applications: $e');
      Fluttertoast.showToast(
        msg: "Failed to load applications",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    var filtered = List<Map<String, dynamic>>.from(_applications);

    // Status filter
    if (_selectedStatus != null) {
      filtered =
          filtered.where((app) => app['status'] == _selectedStatus).toList();
    }

    // Date range filter
    if (_startDate != null) {
      filtered = filtered.where((app) {
        final createdAt = DateTime.parse(app['created_at']);
        return createdAt.isAfter(_startDate!) ||
            createdAt.isAtSameMomentAs(_startDate!);
      }).toList();
    }

    if (_endDate != null) {
      final endOfDay =
          DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
      filtered = filtered.where((app) {
        final createdAt = DateTime.parse(app['created_at']);
        return createdAt.isBefore(endOfDay) ||
            createdAt.isAtSameMomentAs(endOfDay);
      }).toList();
    }

    // Search filter (NID, mobile, name)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((app) {
        final query = _searchQuery.toLowerCase();
        final nid = app['nid']?.toString().toLowerCase() ?? '';
        final mobile = app['mobile']?.toString().toLowerCase() ?? '';
        final userName =
            app['user_profiles']?['full_name']?.toString().toLowerCase() ?? '';

        return nid.contains(query) ||
            mobile.contains(query) ||
            userName.contains(query);
      }).toList();
    }

    setState(() {
      _filteredApplications = filtered;
      _selectedApplicationIds.clear(); // Clear selection when filters change
    });
  }

  void _onFiltersChanged({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) {
    setState(() {
      _selectedStatus = status;
      _startDate = startDate;
      _endDate = endDate;
      _searchQuery = searchQuery ?? '';
    });
    _applyFilters();
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _startDate = null;
      _endDate = null;
      _searchQuery = '';
    });
    _applyFilters();
  }

  void _onApplicationSelectionChanged(List<String> selectedIds) {
    setState(() {
      _selectedApplicationIds = selectedIds;
    });
  }

  Future<void> _updateApplicationStatus(
      String applicationId, String newStatus) async {
    try {
      await _supabase.from('bo_applications').update({
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', applicationId);

      // Create notification for user
      await _createNotification(applicationId, newStatus);

      // Reload data
      await _loadApplications();

      Fluttertoast.showToast(
        msg: "Status updated successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      debugPrint('Error updating status: $e');
      Fluttertoast.showToast(
        msg: "Failed to update status",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _createNotification(String applicationId, String status) async {
    try {
      // Get application to find user_id
      final application = await _supabase
          .from('bo_applications')
          .select('user_id')
          .eq('id', applicationId)
          .single();

      String title = '';
      String body = '';

      switch (status) {
        case 'approved':
          title = 'BO Application Approved';
          body = 'Your BO is approved. We\'ll reach out for the final step.';
          break;
        case 'in_review':
          title = 'BO Application In Review';
          body = 'We\'re processing your BO with our partner.';
          break;
        case 'rejected':
          title = 'BO Application Update';
          body =
              'We couldn\'t process your BO this time. Tap to contact support.';
          break;
      }

      if (title.isNotEmpty) {
        await _supabase.from('notifications').insert({
          'user_id': application['user_id'],
          'type': 'bo_status',
          'title': title,
          'body': body,
          'created_at': DateTime.now().toIso8601String(),
          'read': false,
        });
      }
    } catch (e) {
      debugPrint('Error creating notification: $e');
    }
  }

  void _showStatusUpdateDialog(String applicationId, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) => BoStatusUpdateDialogWidget(
        applicationId: applicationId,
        currentStatus: currentStatus,
        availableStatuses: _statusOptions,
        onStatusUpdate: _updateApplicationStatus,
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => BoExportDialogWidget(
        applications: _filteredApplications,
        selectedIds: _selectedApplicationIds,
        onExport: _exportToCsv,
      ),
    );
  }

  Future<void> _exportToCsv(
      List<Map<String, dynamic>> applicationsToExport) async {
    try {
      // Generate CSV content
      final csvHeaders = [
        'userId',
        'userName',
        'nid',
        'fullName',
        'dob',
        'mobile',
        'bankAccount',
        'status',
        'createdAt',
        'updatedAt'
      ];

      final csvRows = <List<String>>[csvHeaders];

      for (final app in applicationsToExport) {
        csvRows.add([
          app['user_id']?.toString() ?? '',
          app['user_profiles']?['full_name']?.toString() ?? '',
          app['nid']?.toString() ?? '',
          app['full_name']?.toString() ?? '',
          app['date_of_birth']?.toString() ?? '',
          app['mobile']?.toString() ?? '',
          app['bank_account']?.toString() ?? '',
          app['status']?.toString() ?? '',
          app['created_at']?.toString() ?? '',
          app['updated_at']?.toString() ?? '',
        ]);
      }

      // Convert to CSV string
      final csvContent = csvRows
          .map((row) =>
              row.map((field) => '"${field.replaceAll('"', '""')}"').join(','))
          .join('\n');

      // Download file
      await _downloadCsv(csvContent);

      Fluttertoast.showToast(
        msg: "CSV exported successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      debugPrint('Export error: $e');
      Fluttertoast.showToast(
        msg: "Export failed. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _downloadCsv(String csvContent) async {
    final fileName =
        'bo_applications_${DateTime.now().millisecondsSinceEpoch}.csv';

    if (kIsWeb) {
      // Web download
      final bytes = Uint8List.fromList(csvContent.codeUnits);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();

      html.Url.revokeObjectUrl(url);
    } else {
      // Mobile download
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvContent);

      Fluttertoast.showToast(
        msg: "File saved to ${file.path}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('BO Applications'),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        actions: [
          // Export button
          IconButton(
            onPressed: _filteredApplications.isEmpty ? null : _showExportDialog,
            icon: CustomIconWidget(
              iconName: 'download',
              color: _filteredApplications.isEmpty
                  ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  : AppTheme.lightTheme.colorScheme.primary,
              size: 6.w,
            ),
            tooltip: 'Export CSV',
          ),

          // Refresh button
          IconButton(
            onPressed: _isLoading ? null : _loadApplications,
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filters section
            BoAdminFiltersWidget(
              selectedStatus: _selectedStatus,
              startDate: _startDate,
              endDate: _endDate,
              searchQuery: _searchQuery,
              statusOptions: _statusOptions,
              onFiltersChanged: _onFiltersChanged,
              onClearFilters: _clearFilters,
            ),

            // Applications table
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    )
                  : BoAdminTableWidget(
                      applications: _filteredApplications,
                      selectedIds: _selectedApplicationIds,
                      onSelectionChanged: _onApplicationSelectionChanged,
                      onStatusUpdate: _showStatusUpdateDialog,
                    ),
            ),

            // Summary footer
            if (_filteredApplications.isNotEmpty)
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${_filteredApplications.length} of ${_applications.length} applications',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                    ),
                    if (_selectedApplicationIds.isNotEmpty)
                      Text(
                        '${_selectedApplicationIds.length} selected',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
