import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';

class TrackComplaintsScreen extends StatefulWidget {
  const TrackComplaintsScreen({super.key});

  @override
  State<TrackComplaintsScreen> createState() => _TrackComplaintsScreenState();
}

class _TrackComplaintsScreenState extends State<TrackComplaintsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Track Complaints',
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Show filter options
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Banner
                _buildInfoBanner(theme),

                SizedBox(height: 4.h),

                // Active Complaints Section
                Text(
                  'Active Complaints',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 2.h),

                // Complaint Timeline Cards
                _buildComplaintCard(
                  theme,
                  complaintNumber: 'CMP-2024-001',
                  category: 'Road Issue',
                  title: 'Pothole on Main Street',
                  submittedDate: '2024-01-15',
                  status: 'In Progress',
                  stage: 2, // In Progress
                  authority: 'Public Works Department',
                ),

                SizedBox(height: 2.h),

                _buildComplaintCard(
                  theme,
                  complaintNumber: 'CMP-2024-002',
                  category: 'Water Supply',
                  title: 'Low Water Pressure in Sector 15',
                  submittedDate: '2024-01-10',
                  status: 'Under Review',
                  stage: 1, // Under Review
                  authority: 'Water Department',
                ),

                SizedBox(height: 4.h),

                // Resolved Complaints Section
                Text(
                  'Resolved Complaints',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 2.h),

                _buildComplaintCard(
                  theme,
                  complaintNumber: 'CMP-2023-156',
                  category: 'Street Light',
                  title: 'Streetlight fixed near Sector 15',
                  submittedDate: '2023-12-20',
                  status: 'Resolved',
                  stage: 4, // Resolved
                  authority: 'Electricity Department',
                ),

                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 1, // Report tab active
        onTap: (index) {
          final routes = CustomBottomBar.routes;
          if (index < routes.length) {
            final route = routes[index];
            if (route != '/track-complaints') {
              Navigator.pushReplacementNamed(context, route);
            }
          }
        },
      ),
    );
  }

  Widget _buildInfoBanner(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomIconWidget(
              iconName: 'timeline',
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Track Your Complaints',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Monitor the progress of all your submitted complaints',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(
    ThemeData theme, {
    required String complaintNumber,
    required String category,
    required String title,
    required String submittedDate,
    required String status,
    required int stage,
    String? authority,
  }) {
    Color statusColor;
    switch (status) {
      case 'Resolved':
        statusColor = Colors.green;
        break;
      case 'In Progress':
        statusColor = Colors.blue;
        break;
      case 'Under Review':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = theme.colorScheme.outline;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Title
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 1.h),

            Text(
              'ID: $complaintNumber',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),

            SizedBox(height: 2.h),

            // Progress Timeline
            _buildProgressTimeline(theme, stage),

            SizedBox(height: 2.h),

            // Authority
            if (authority != null)
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'verified_user',
                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    size: 18,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Assigned to: $authority',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),

            SizedBox(height: 1.h),

            // Date
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'calendar_today',
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 18,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Submitted: $submittedDate',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTimeline(ThemeData theme, int currentStage) {
    final stages = [
      {'name': 'Submitted', 'icon': 'check_circle'},
      {'name': 'Under Review', 'icon': 'search'},
      {'name': 'In Progress', 'icon': 'build'},
      {'name': 'Resolved', 'icon': 'check_circle_outline'},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(stages.length, (index) {
            final isCompleted = index < currentStage;
            final isCurrent = index == currentStage - 1;

            return Expanded(
              child: Row(
                children: [
                  // Connector line
                  if (index > 0)
                    Expanded(
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                        ),
                      ),
                    ),

                  // Stage dot
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: isCurrent || isCompleted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      border: isCurrent
                          ? Border.all(
                              color: theme.colorScheme.primary,
                              width: 3,
                            )
                          : null,
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: isCompleted
                            ? stages[index]['icon'] as String
                            : 'circle',
                        color: isCompleted || isCurrent
                            ? Colors.white
                            : theme.colorScheme.outline,
                        size: isCompleted ? 16 : 12,
                      ),
                    ),
                  ),

                  // Connector line (for next)
                  if (index < stages.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),

        SizedBox(height: 1.h),

        // Stage labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(stages.length, (index) {
            return Expanded(
              child: Text(
                stages[index]['name'] as String,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: index < currentStage
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  fontWeight: index == currentStage - 1
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ),
      ],
    );
  }
}
