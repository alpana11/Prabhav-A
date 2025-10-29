import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ComplaintQueueWidget extends StatelessWidget {
  const ComplaintQueueWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Priority Complaint Queue',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'priority_high',
                        color: theme.colorScheme.error,
                        size: 12,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '3 Urgent',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _getComplaintQueue().length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
            itemBuilder: (context, index) {
              final complaint = _getComplaintQueue()[index];
              return _buildComplaintItem(complaint, theme, context);
            },
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Navigate to full complaint list
                },
                child: Text('View All Complaints'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintItem(
    Map<String, dynamic> complaint,
    ThemeData theme,
    BuildContext context,
  ) {
    final isUrgent = complaint['priority'] == 'urgent';

    return InkWell(
      onTap: () {
        _showComplaintDetails(context, complaint);
      },
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: _getCategoryColor(complaint['category'])
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: _getCategoryIcon(complaint['category']),
                  color: _getCategoryColor(complaint['category']),
                  size: 20,
                ),
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
                          complaint['title'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUrgent)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 1.5.w, vertical: 0.3.h),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'URGENT',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onError,
                              fontWeight: FontWeight.w600,
                              fontSize: 8.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${complaint['location']} • ${complaint['submittedBy']}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'access_time',
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        size: 12,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        complaint['timeAgo'] as String,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.3.h),
                        decoration: BoxDecoration(
                          color: _getStatusColor(complaint['status'])
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          complaint['status'] as String,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getStatusColor(complaint['status']),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showComplaintDetails(
      BuildContext context, Map<String, dynamic> complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildComplaintDetailsSheet(context, complaint),
    );
  }

  Widget _buildComplaintDetailsSheet(
      BuildContext context, Map<String, dynamic> complaint) {
    final theme = Theme.of(context);

    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 10.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Complaint Details',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Title', complaint['title'], theme),
                  _buildDetailRow('Category', complaint['category'], theme),
                  _buildDetailRow('Location', complaint['location'], theme),
                  _buildDetailRow(
                      'Submitted By', complaint['submittedBy'], theme),
                  _buildDetailRow('Status', complaint['status'], theme),
                  _buildDetailRow('Priority', complaint['priority'], theme),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showAssignAuthorityDialog(context);
                          },
                          icon: CustomIconWidget(
                            iconName: 'person_add',
                            color: theme.colorScheme.onPrimary,
                            size: 18,
                          ),
                          label: const Text('Assign Authority'),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showUpdateStatusDialog(context);
                          },
                          icon: CustomIconWidget(
                            iconName: 'update',
                            color: theme.colorScheme.primary,
                            size: 18,
                          ),
                          label: const Text('Update Status'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignAuthorityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Authority'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select department to assign this complaint:'),
            SizedBox(height: 2.h),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'roads', child: Text('Roads & Infrastructure')),
                DropdownMenuItem(value: 'water', child: Text('Water Supply')),
                DropdownMenuItem(
                    value: 'electricity', child: Text('Electricity Board')),
                DropdownMenuItem(
                    value: 'sanitation', child: Text('Sanitation')),
              ],
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Authority assigned successfully')),
              );
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Update complaint status:'),
            SizedBox(height: 2.h),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'under_review', child: Text('Under Review')),
                DropdownMenuItem(
                    value: 'in_progress', child: Text('In Progress')),
                DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                DropdownMenuItem(value: 'closed', child: Text('Closed')),
              ],
              onChanged: (value) {},
            ),
            SizedBox(height: 2.h),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Update Message (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Status updated successfully')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getComplaintQueue() {
    return [
      {
        'id': 'CMP001',
        'title': 'Major pothole causing traffic jam',
        'category': 'Road Issues',
        'location': 'Sector 15, Main Road',
        'submittedBy': 'Rajesh Kumar',
        'status': 'Submitted',
        'priority': 'urgent',
        'timeAgo': '2 hours ago',
      },
      {
        'id': 'CMP002',
        'title': 'Water supply disruption since morning',
        'category': 'Water Supply',
        'location': 'Sector 22, Block A',
        'submittedBy': 'Priya Sharma',
        'status': 'Under Review',
        'priority': 'urgent',
        'timeAgo': '4 hours ago',
      },
      {
        'id': 'CMP003',
        'title': 'Street light not working for 3 days',
        'category': 'Electricity',
        'location': 'Sector 18, Park Street',
        'submittedBy': 'Amit Singh',
        'status': 'In Progress',
        'priority': 'high',
        'timeAgo': '1 day ago',
      },
      {
        'id': 'CMP004',
        'title': 'Garbage collection missed for 2 days',
        'category': 'Sanitation',
        'location': 'Sector 12, Residential Area',
        'submittedBy': 'Sunita Devi',
        'status': 'Submitted',
        'priority': 'urgent',
        'timeAgo': '6 hours ago',
      },
      {
        'id': 'CMP005',
        'title': 'Broken footpath near school',
        'category': 'Road Issues',
        'location': 'Sector 20, School Road',
        'submittedBy': 'Vikram Gupta',
        'status': 'Under Review',
        'priority': 'medium',
        'timeAgo': '1 day ago',
      },
    ];
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'road issues':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'water supply':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'electricity':
        return AppTheme.lightTheme.colorScheme.error;
      case 'sanitation':
        return const Color(0xFF4CAF50);
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'road issues':
        return 'construction';
      case 'water supply':
        return 'water_drop';
      case 'electricity':
        return 'electrical_services';
      case 'sanitation':
        return 'delete';
      default:
        return 'report_problem';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'under review':
        return const Color(0xFF2196F3);
      case 'in progress':
        return const Color(0xFFFF9800);
      case 'resolved':
        return const Color(0xFF4CAF50);
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }
}
