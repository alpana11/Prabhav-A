import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ComplaintDetailsForm extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String selectedSeverity;
  final Function(String) onSeverityChanged;
  final bool isAnonymous;
  final Function(bool) onAnonymousChanged;

  const ComplaintDetailsForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.selectedSeverity,
    required this.onSeverityChanged,
    required this.isAnonymous,
    required this.onAnonymousChanged,
  });

  @override
  State<ComplaintDetailsForm> createState() => _ComplaintDetailsFormState();
}

class _ComplaintDetailsFormState extends State<ComplaintDetailsForm> {
  final List<Map<String, dynamic>> severityLevels = [
    {
      'value': 'Low',
      'label': 'Low',
      'color': Colors.green,
      'description': 'Minor issue, not urgent'
    },
    {
      'value': 'Medium',
      'label': 'Medium',
      'color': Colors.orange,
      'description': 'Moderate issue, needs attention'
    },
    {
      'value': 'High',
      'label': 'High',
      'color': Colors.red,
      'description': 'Important issue, requires quick action'
    },
    {
      'value': 'Urgent',
      'label': 'Urgent',
      'color': Colors.red.shade700,
      'description': 'Critical issue, immediate action needed'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complaint Details',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),

          // Title Field
          Text(
            'Complaint Title *',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: widget.titleController,
            decoration: InputDecoration(
              hintText: 'Enter a brief title for your complaint',
              prefixIcon: Icon(
                Icons.title,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            maxLength: 100,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a complaint title';
              }
              return null;
            },
          ),
          SizedBox(height: 2.h),

          // Description Field
          Text(
            'Description *',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: widget.descriptionController,
            decoration: InputDecoration(
              hintText: 'Describe your complaint in detail...',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Icon(
                  Icons.description,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            maxLength: 500,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please provide a detailed description';
              }
              if (value.trim().length < 20) {
                return 'Description must be at least 20 characters';
              }
              return null;
            },
          ),
          SizedBox(height: 2.h),

          // Severity Selector
          Text(
            'Severity Level *',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: severityLevels.map((severity) {
                final isSelected = widget.selectedSeverity == severity['value'];
                return GestureDetector(
                  onTap: () =>
                      widget.onSeverityChanged(severity['value'] as String),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 1.h),
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (severity['color'] as Color).withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? severity['color'] as Color
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4.w,
                          height: 2.h,
                          decoration: BoxDecoration(
                            color: severity['color'] as Color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                severity['label'] as String,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: isSelected
                                      ? severity['color'] as Color
                                      : colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                severity['description'] as String,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          CustomIconWidget(
                            iconName: 'check_circle',
                            color: severity['color'] as Color,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 2.h),

          // Anonymous Toggle
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'visibility_off',
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submit Anonymously',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Your identity will be kept private',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: widget.isAnonymous,
                  onChanged: widget.onAnonymousChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
