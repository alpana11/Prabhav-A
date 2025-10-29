import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ActionGridWidget extends StatelessWidget {
  final Function(String)? onActionTap;

  const ActionGridWidget({
    super.key,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> actions = [
      {
        "id": "register_complaint",
        "title": "Register Complaint",
        "subtitle": "Report civic issues",
        "icon": "report_problem",
        "route": "/register-complaint-screen",
        "isPrimary": true,
        "color": theme.colorScheme.tertiary,
      },
      {
        "id": "track_complaints",
        "title": "Track Complaints",
        "subtitle": "Monitor progress",
        "icon": "track_changes",
        "route": "/track-complaints",
        "isPrimary": false,
        "color": theme.colorScheme.primary,
      },
      {
        "id": "give_feedback",
        "title": "Give Feedback",
        "subtitle": "Rate services",
        "icon": "star_rate",
        "route": "/feedback-screen",
        "isPrimary": false,
        "color": theme.colorScheme.primary,
      },
      {
        "id": "public_issues",
        "title": "Public Issues",
        "subtitle": "View community",
        "icon": "public",
        "route": "/public-feed",
        "isPrimary": false,
        "color": theme.colorScheme.primary,
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 3.w,
          mainAxisSpacing: 2.h,
          childAspectRatio: 1.1,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return _buildActionCard(context, action);
        },
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, Map<String, dynamic> action) {
    final theme = Theme.of(context);
    final isPrimary = action["isPrimary"] as bool;

    return GestureDetector(
      onTap: () {
        if (onActionTap != null) {
          onActionTap!(action["route"] as String);
        } else {
          Navigator.pushNamed(context, action["route"] as String);
        }
      },
      onLongPress: () => _showActionShortcuts(context, action),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary
              ? Border.all(
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                  width: 2,
                )
              : Border.all(
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: (action["color"] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: CustomIconWidget(
                  iconName: action["icon"] as String,
                  color: action["color"] as Color,
                  size: isPrimary ? 32 : 28,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                action["title"] as String,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.5.h),
              Text(
                action["subtitle"] as String,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (isPrimary) ...[
                SizedBox(height: 1.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'QUICK ACCESS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.tertiary,
                      fontWeight: FontWeight.w600,
                      fontSize: 8.sp,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showActionShortcuts(BuildContext context, Map<String, dynamic> action) {
    final theme = Theme.of(context);

    List<Map<String, String>> shortcuts = [];

    switch (action["id"]) {
      case "register_complaint":
        shortcuts = [
          {
            "title": "Road Issues",
            "route": "/register-complaint-screen?category=road"
          },
          {
            "title": "Water Problems",
            "route": "/register-complaint-screen?category=water"
          },
          {
            "title": "Electricity",
            "route": "/register-complaint-screen?category=electricity"
          },
          {
            "title": "Waste Management",
            "route": "/register-complaint-screen?category=waste"
          },
        ];
        break;
      case "give_feedback":
        shortcuts = [
          {"title": "Service Rating", "route": "/feedback-screen?type=service"},
          {"title": "App Feedback", "route": "/feedback-screen?type=app"},
          {"title": "Suggestion", "route": "/feedback-screen?type=suggestion"},
        ];
        break;
      default:
        return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ...shortcuts.map((shortcut) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CustomIconWidget(
                    iconName: 'arrow_forward_ios',
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                  title: Text(
                    shortcut["title"]!,
                    style: theme.textTheme.bodyMedium,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, shortcut["route"]!);
                  },
                )),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
