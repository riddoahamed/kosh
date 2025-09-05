import 'package:flutter/material.dart';

class GlobalLastUpdatedWidget extends StatelessWidget {
  final DateTime? lastUpdated;
  final VoidCallback onRefresh;

  const GlobalLastUpdatedWidget({
    super.key,
    required this.lastUpdated,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Last Updated',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withAlpha(179),
                    ),
              ),
              Text(
                lastUpdated != null ? _formatTime(lastUpdated!) : '--:--',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: _getStatusColor(context),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
                size: 20,
              ),
              onPressed: onRefresh,
              tooltip: 'Refresh global timestamp',
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      // Show time in HH:MM format
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  Color _getStatusColor(BuildContext context) {
    if (lastUpdated == null) {
      return Colors.grey;
    }

    final now = DateTime.now();
    final difference = now.difference(lastUpdated!);

    if (difference.inMinutes < 30) {
      return Theme.of(context).colorScheme.secondary; // Fresh - green
    } else if (difference.inHours < 2) {
      return Colors.orange; // Moderate - orange
    } else {
      return Theme.of(context).colorScheme.error; // Stale - red
    }
  }
}
