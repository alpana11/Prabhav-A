import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NearbyIssuesWidget extends StatelessWidget {
  const NearbyIssuesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // No hard-coded nearby issues. Load nearby issues from the backend API.
    final List<Map<String, dynamic>> nearbyIssues = [];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nearby Issues',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/public-feed');
                },
                child: Text(
                  'View Map',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          SizedBox(
            height: 25.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: nearbyIssues.length,
              separatorBuilder: (context, index) => SizedBox(width: 3.w),
              itemBuilder: (context, index) {
                final issue = nearbyIssues[index];
                return _buildIssueCard(context, issue);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueCard(BuildContext context, Map<String, dynamic> issue) {
    final theme = Theme.of(context);

    return Container(
      width: 70.w,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/issue-details', arguments: issue);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: CustomImageWidget(
                imageUrl: issue["image"] as String,
                width: double.infinity,
                height: 12.h,
                fit: BoxFit.cover,
                semanticLabel: issue["semanticLabel"] as String,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(
                                      issue["category"] as String, theme)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getCategoryLabel(issue["category"] as String),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _getCategoryColor(
                                    issue["category"] as String, theme),
                                fontWeight: FontWeight.w500,
                                fontSize: 8.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      issue["title"] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Flexible(
                      child: Text(
                        issue["description"] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'thumb_up',
                              color: theme.colorScheme.primary,
                              size: 14,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '${issue["upvotes"]}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                      issue["status"] as String, theme)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _getStatusLabel(issue["status"] as String),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _getStatusColor(
                                    issue["status"] as String, theme),
                                fontWeight: FontWeight.w500,
                                fontSize: 7.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
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
      ),
    );
  }

  Color _getCategoryColor(String category, ThemeData theme) {
    switch (category) {
      case 'electricity':
        return Colors.amber;
      case 'road':
        return Colors.brown;
      case 'water':
        return Colors.blue;
      case 'waste':
        return Colors.green;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'electricity':
        return 'ELECTRICITY';
      case 'road':
        return 'ROAD';
      case 'water':
        return 'WATER';
      case 'waste':
        return 'WASTE';
      default:
        return 'OTHER';
    }
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'resolved':
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
      case 'in_progress':
        return 'IN PROGRESS';
      case 'submitted':
        return 'SUBMITTED';
      default:
        return 'UNKNOWN';
    }
  }
}
