import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ComplaintHistoryWidget extends StatefulWidget {
  final List<Map<String, dynamic>> complaints;

  const ComplaintHistoryWidget({
    super.key,
    required this.complaints,
  });

  @override
  State<ComplaintHistoryWidget> createState() => _ComplaintHistoryWidgetState();
}

class _ComplaintHistoryWidgetState extends State<ComplaintHistoryWidget> {
  String selectedFilter = "All";
  final List<String> filterOptions = [
    "All",
    "Submitted",
    "Under Review",
    "In Progress",
    "Resolved"
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final filteredComplaints = selectedFilter == "All"
        ? widget.complaints
        : (widget.complaints as List)
            .where((complaint) =>
                (complaint["status"] as String) == selectedFilter)
            .toList();

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "My Complaints",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    selectedFilter = value;
                  });
                },
                itemBuilder: (context) => filterOptions.map((filter) {
                  return PopupMenuItem<String>(
                    value: filter,
                    child: Text(filter),
                  );
                }).toList(),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedFilter,
                        style: theme.textTheme.bodyMedium,
                      ),
                      SizedBox(width: 1.w),
                      CustomIconWidget(
                        iconName: 'arrow_drop_down',
                        color: colorScheme.onSurface,
                        size: 4.w,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          filteredComplaints.isEmpty
              ? _buildEmptyState(context)
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredComplaints.length,
                  separatorBuilder: (context, index) => SizedBox(height: 2.h),
                  itemBuilder: (context, index) {
                    final complaint =
                        filteredComplaints[index] as Map<String, dynamic>;
                    return _buildComplaintCard(context, complaint);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'inbox',
            color: colorScheme.onSurface.withValues(alpha: 0.3),
            size: 15.w,
          ),
          SizedBox(height: 2.h),
          Text(
            "No complaints found",
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "Try adjusting your filter or submit your first complaint",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(
      BuildContext context, Map<String, dynamic> complaint) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              complaint["thumbnail"] != null
                  ? Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CustomImageWidget(
                          imageUrl: complaint["thumbnail"] as String,
                          width: 12.w,
                          height: 12.w,
                          fit: BoxFit.cover,
                          semanticLabel:
                              complaint["thumbnailSemanticLabel"] as String? ??
                                  "Complaint image thumbnail",
                        ),
                      ),
                    )
                  : Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'report_problem',
                        color: colorScheme.primary,
                        size: 6.w,
                      ),
                    ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      complaint["title"] as String? ?? "Complaint Title",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      complaint["category"] as String? ?? "General",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(
                  context, complaint["status"] as String? ?? "Submitted"),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                size: 4.w,
              ),
              SizedBox(width: 1.w),
              Text(
                complaint["submissionDate"] as String? ?? "Oct 16, 2025",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const Spacer(),
              CustomIconWidget(
                iconName: 'location_on',
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                size: 4.w,
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: Text(
                  complaint["location"] as String? ?? "Location",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final theme = Theme.of(context);
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case "Resolved":
        backgroundColor = AppTheme.successLight.withValues(alpha: 0.1);
        textColor = AppTheme.successLight;
        break;
      case "In Progress":
        backgroundColor = AppTheme.warningLight.withValues(alpha: 0.1);
        textColor = AppTheme.warningLight;
        break;
      case "Under Review":
        backgroundColor = theme.colorScheme.primary.withValues(alpha: 0.1);
        textColor = theme.colorScheme.primary;
        break;
      default:
        backgroundColor = theme.colorScheme.outline.withValues(alpha: 0.1);
        textColor = theme.colorScheme.onSurface.withValues(alpha: 0.7);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
