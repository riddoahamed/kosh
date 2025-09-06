import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/notification_card_widget.dart';

class NotificationsCenter extends StatefulWidget {
  const NotificationsCenter({Key? key}) : super(key: key);

  @override
  State<NotificationsCenter> createState() => _NotificationsCenterState();
}

class _NotificationsCenterState extends State<NotificationsCenter>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Notification categories
  final List<String> _categories = [
    'All',
    'BO Account',
    'Portfolio',
    'Market Alerts',
    'System',
  ];

  // Notification filters
  String _selectedCategory = 'All';
  bool _showUnreadOnly = false;
  String _searchQuery = '';

  // Mock notification data - in real app this would come from backend
  List<Map<String, dynamic>> _notifications = [
    {
      'id': 'bo_001',
      'type': 'bo_status',
      'category': 'BO Account',
      'title': 'BO Application Approved',
      'body': 'Your BO is approved. We\'ll reach out for the final step.',
      'createdAt': '2025-09-04T14:30:00Z',
      'read': false,
      'priority': 'high',
      'actionable': true,
      'actionText': 'Contact Support',
      'iconName': 'check_circle',
      'color': 'success',
    },
    {
      'id': 'portfolio_001',
      'type': 'portfolio_update',
      'category': 'Portfolio',
      'title': 'Portfolio Performance Update',
      'body': 'Your portfolio gained +2.5% today. Great performance!',
      'createdAt': '2025-09-04T12:00:00Z',
      'read': false,
      'priority': 'medium',
      'actionable': false,
      'iconName': 'trending_up',
      'color': 'success',
    },
    {
      'id': 'bo_002',
      'type': 'bo_status',
      'category': 'BO Account',
      'title': 'BO Application In Review',
      'body': 'We\'re processing your BO with our partner.',
      'createdAt': '2025-09-04T10:15:00Z',
      'read': true,
      'priority': 'medium',
      'actionable': false,
      'iconName': 'hourglass_empty',
      'color': 'warning',
    },
    {
      'id': 'market_001',
      'type': 'market_alert',
      'category': 'Market Alerts',
      'title': 'Price Alert: SQUARE',
      'body': 'SQUARE has reached your target price of ৳45.00',
      'createdAt': '2025-09-04T09:30:00Z',
      'read': true,
      'priority': 'high',
      'actionable': true,
      'actionText': 'View Chart',
      'iconName': 'notifications_active',
      'color': 'primary',
    },
    {
      'id': 'system_001',
      'type': 'system_announcement',
      'category': 'System',
      'title': 'App Update Available',
      'body': 'New features and improvements are ready. Update now!',
      'createdAt': '2025-09-03T18:00:00Z',
      'read': true,
      'priority': 'low',
      'actionable': true,
      'actionText': 'Update Now',
      'iconName': 'system_update',
      'color': 'primary',
    },
    {
      'id': 'bo_003',
      'type': 'bo_status',
      'category': 'BO Account',
      'title': 'BO Application Update',
      'body': 'We couldn\'t process your BO this time. Tap to contact support.',
      'createdAt': '2025-09-03T16:45:00Z',
      'read': false,
      'priority': 'high',
      'actionable': true,
      'actionText': 'Contact Support',
      'iconName': 'error',
      'color': 'error',
    },
  ];

  // Notification preferences
  Map<String, bool> _notificationPreferences = {
    'bo_application_updates': true,
    'portfolio_performance': true,
    'price_movements': true,
    'educational_content': false,
    'system_maintenance': true,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    // Simulate loading from backend
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      // Sort notifications by date (newest first)
      _notifications.sort((a, b) => DateTime.parse(b['createdAt'])
          .compareTo(DateTime.parse(a['createdAt'])));
    });
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    List<Map<String, dynamic>> filtered = _notifications;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where(
              (notification) => notification['category'] == _selectedCategory)
          .toList();
    }

    // Filter by unread only
    if (_showUnreadOnly) {
      filtered =
          filtered.where((notification) => !notification['read']).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((notification) =>
              notification['title']
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              notification['body']
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  int get _unreadCount {
    return _notifications.where((notification) => !notification['read']).length;
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
      _tabController.animateTo(_categories.indexOf(category));
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _toggleUnreadFilter() {
    setState(() {
      _showUnreadOnly = !_showUnreadOnly;
    });
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final notificationIndex = _notifications
          .indexWhere((notification) => notification['id'] == notificationId);
      if (notificationIndex != -1) {
        _notifications[notificationIndex]['read'] = true;
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['read'] = true;
      }
    });

    Fluttertoast.showToast(
      msg: "All notifications marked as read",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _deleteNotification(String notificationId) {
    setState(() {
      _notifications
          .removeWhere((notification) => notification['id'] == notificationId);
    });

    Fluttertoast.showToast(
      msg: "Notification deleted",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onNotificationAction(Map<String, dynamic> notification) {
    final String type = notification['type'];
    final String? actionText = notification['actionText'];

    switch (type) {
      case 'bo_status':
        if (actionText == 'Contact Support') {
          _showContactSupportDialog();
        }
        break;
      case 'market_alert':
        if (actionText == 'View Chart') {
          Navigator.pushNamed(context, AppRoutes.instrumentDetail);
        }
        break;
      case 'system_announcement':
        if (actionText == 'Update Now') {
          _showUpdateDialog();
        }
        break;
    }

    // Mark as read when action is taken
    _markAsRead(notification['id']);
  }

  void _showContactSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'support_agent',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Contact Support',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get help with your BO application or any other queries.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📧 support@kosh.com.bd',
                      style: Theme.of(context).textTheme.bodySmall),
                  SizedBox(height: 1.h),
                  Text('📞 +8801XXXXXXXXX',
                      style: Theme.of(context).textTheme.bodySmall),
                  SizedBox(height: 1.h),
                  Text('⏰ Available: 9 AM - 6 PM',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: "Opening email client...",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            child: Text('Send Email'),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'system_update',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'App Update',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        content: Text(
          'Update KOSH to get the latest features and security improvements.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: "Redirecting to app store...",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showNotificationPreferences() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Notification Preferences',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 2.h),
            ...(_notificationPreferences.entries.map((entry) => 
              SwitchListTile(
                title: Text(entry.key.replaceAll('_', ' ').toUpperCase()),
                value: entry.value,
                onChanged: (value) {
                  setState(() {
                    _notificationPreferences[entry.key] = value;
                  });
                },
              )
            ).toList()),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _filteredNotifications;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Text('Notifications'),
            if (_unreadCount > 0) ...[
              SizedBox(width: 2.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(1.h),
                ),
                child: Text(
                  '$_unreadCount',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ],
        ),
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
          IconButton(
            onPressed: _showNotificationPreferences,
            icon: CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          if (_unreadCount > 0)
            IconButton(
              onPressed: _markAllAsRead,
              icon: CustomIconWidget(
                iconName: 'mark_email_read',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 6.w,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: AppTheme.lightTheme.colorScheme.surface,
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search notifications...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: _onSearchChanged,
                ),

                SizedBox(height: 2.h),

                // Filter Controls
                Row(
                  children: [
                    Checkbox(
                      value: _showUnreadOnly,
                      onChanged: (value) => _toggleUnreadFilter(),
                    ),
                    Text('Show unread only'),
                  ],
                ),
              ],
            ),
          ),

          // Category Tabs
          Container(
            color: AppTheme.lightTheme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: _categories.map((category) {
                final count = category == 'All'
                    ? _notifications.length
                    : _notifications
                        .where((n) => n['category'] == category)
                        .length;

                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(category),
                      if (count > 0) ...[
                        SizedBox(width: 1.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 1.5.w, vertical: 0.3.h),
                          decoration: BoxDecoration(
                            color: _selectedCategory == category
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                            borderRadius: BorderRadius.circular(0.8.h),
                          ),
                          child: Text(
                            '$count',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
              onTap: (index) => _onCategoryChanged(_categories[index]),
            ),
          ),

          // Notifications List
          Expanded(
            child: filteredNotifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 15.w),
                        SizedBox(height: 2.h),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No notifications found'
                              : _showUnreadOnly
                                  ? 'No unread notifications'
                                  : _selectedCategory != 'All'
                                      ? 'No $_selectedCategory notifications'
                                      : 'No notifications',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(4.w),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = filteredNotifications[index];

                      // Group notifications by date
                      bool showDateHeader = false;
                      if (index == 0) {
                        showDateHeader = true;
                      } else {
                        final currentDate =
                            DateTime.parse(notification['createdAt']);
                        final previousDate = DateTime.parse(
                            filteredNotifications[index - 1]['createdAt']);
                        showDateHeader = !_isSameDay(currentDate, previousDate);
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDateHeader) ...[
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 1.h),
                              child: Text(
                                _formatDate(DateTime.parse(notification['createdAt'])),
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                          ],
                          NotificationCardWidget(
                            notification: notification,
                            onTap: () => _markAsRead(notification['id']),
                            onAction: () => _onNotificationAction(notification),
                            onDelete: () =>
                                _deleteNotification(notification['id']),
                          ),
                          SizedBox(height: 2.h),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Add helper method for date formatting
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}