import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class RecentActivityWidget extends StatelessWidget {
  const RecentActivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> recentActivities = [
      {
        "id": 1,
        "type": "complaint_update",
        "title": "Road Repair Update",
        "description":
            "Your complaint #CR2025001 has been marked as 'In Progress'",
        "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
        "status": "in_progress",
        "icon": "construction",
        "priority": "medium",
      },
      {
        "id": 2,
        "type": "complaint_resolved",
        "title": "Water Supply Restored",
        "description": "Complaint #CR2025002 has been successfully resolved",
        "timestamp": DateTime.now().subtract(const Duration(days: 1)),
        "status": "resolved",
        "icon": "check_circle",
        "priority": "high",
      },
      {
        "id": 3,
        "type": "feedback_submitted",
        "title": "Feedback Submitted",
        "description": "Thank you for rating our waste management service",
        "timestamp": DateTime.now().subtract(const Duration(days: 2)),
        "status": "completed",
        "icon": "star",
        "priority": "low",
      },
      {
        "id": 4,
        "type": "complaint_submitted",
        "title": "New Complaint Registered",
        "description": "Street light issue reported at MG Road Junction",
        "timestamp": DateTime.now().subtract(const Duration(days: 3)),
        "status": "submitted",
        "icon": "report_problem",
        "priority": "medium",
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/activity-history');
                },
                child: Text(
                  'View All',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:
                recentActivities.length > 3 ? 3 : recentActivities.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.h),
            itemBuilder: (context, index) {
              final activity = recentActivities[index];
              return _buildActivityCard(context, activity);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
      BuildContext context, Map<String, dynamic> activity) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.5.w),
            decoration: BoxDecoration(
              color: _getStatusColor(activity["status"] as String, theme)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: CustomIconWidget(
              iconName: activity["icon"] as String,
              color: _getStatusColor(activity["status"] as String, theme),
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        activity["title"] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color:
                            _getStatusColor(activity["status"] as String, theme)
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusLabel(activity["status"] as String),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _getStatusColor(
                              activity["status"] as String, theme),
                          fontWeight: FontWeight.w500,
                          fontSize: 8.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  activity["description"] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.h),
                Text(
                  _formatTimestamp(activity["timestamp"] as DateTime),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'resolved':
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'submitted':
        return theme.colorScheme.primary;
      default:
        return theme.colorScheme.onSurface;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'resolved':
        return 'RESOLVED';
      case 'completed':
        return 'COMPLETED';
      case 'in_progress':
        return 'IN PROGRESS';
      case 'submitted':
        return 'SUBMITTED';
      default:
        return 'UNKNOWN';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
