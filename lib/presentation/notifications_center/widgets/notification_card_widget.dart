import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotificationCardWidget extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;
  final VoidCallback? onAction;
  final VoidCallback? onDelete;

  const NotificationCardWidget({
    Key? key,
    required this.notification,
    required this.onTap,
    this.onAction,
    this.onDelete,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (notification['color']) {
      case 'success':
        return AppTheme.successColor;
      case 'warning':
        return AppTheme.warningColor;
      case 'error':
        return AppTheme.errorColor;
      case 'primary':
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  Color _getPriorityColor() {
    switch (notification['priority']) {
      case 'high':
        return AppTheme.errorColor;
      case 'medium':
        return AppTheme.warningColor;
      case 'low':
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _formatTime() {
    final DateTime createdAt = DateTime.parse(notification['createdAt']);
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !notification['read'];
    final bool isActionable = notification['actionable'] ?? false;
    final String? actionText = notification['actionText'];

    return Dismissible(
      key: Key(notification['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(3.w),
        ),
        child: CustomIconWidget(
          iconName: 'delete',
          color: Colors.white,
          size: 6.w,
        ),
      ),
      onDismissed: (direction) {
        onDelete?.call();
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: isUnread
                ? AppTheme.lightTheme.colorScheme.primaryContainer
                    .withValues(alpha: 0.1)
                : AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(3.w),
            border: isUnread
                ? Border.all(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.3),
                    width: 1,
                  )
                : Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                    width: 1,
                  ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowLight,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Icon
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: notification['iconName'] ?? 'notifications',
                        color: _getStatusColor(),
                        size: 5.w,
                      ),
                    ),
                  ),

                  SizedBox(width: 3.w),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                notification['title'],
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: isUnread
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isUnread
                                          ? AppTheme
                                              .lightTheme.colorScheme.onSurface
                                          : AppTheme.lightTheme.colorScheme
                                              .onSurfaceVariant,
                                    ),
                              ),
                            ),

                            // Priority Indicator
                            if (notification['priority'] == 'high')
                              Container(
                                margin: EdgeInsets.only(left: 2.w),
                                width: 2.w,
                                height: 2.w,
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(),
                                  shape: BoxShape.circle,
                                ),
                              ),

                            // Unread Indicator
                            if (isUnread)
                              Container(
                                margin: EdgeInsets.only(left: 2.w),
                                width: 3.w,
                                height: 3.w,
                                decoration: const BoxDecoration(
                                  color: AppTheme.accentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),

                        SizedBox(height: 1.h),

                        // Body Text
                        Text(
                          notification['body'],
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                    height: 1.4,
                                  ),
                        ),

                        SizedBox(height: 2.h),

                        // Footer Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Category and Time
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 2.w, vertical: 0.5.h),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor()
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(1.h),
                                  ),
                                  child: Text(
                                    notification['category'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: _getStatusColor(),
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  _formatTime(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppTheme.lightTheme.colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),

                            // Action Button
                            if (isActionable && actionText != null)
                              GestureDetector(
                                onTap: onAction,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 3.w, vertical: 1.h),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(),
                                    borderRadius: BorderRadius.circular(1.5.h),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        actionText,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      SizedBox(width: 1.w),
                                      CustomIconWidget(
                                        iconName: 'arrow_forward',
                                        color: Colors.white,
                                        size: 3.w,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
