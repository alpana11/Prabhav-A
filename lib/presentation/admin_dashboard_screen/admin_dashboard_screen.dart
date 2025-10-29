import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/ai_summary_widget.dart';
import './widgets/complaint_chart_widget.dart';
import './widgets/complaint_queue_widget.dart';
import './widgets/metrics_card_widget.dart';
import './widgets/navigation_drawer_widget.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentRoute = '/admin-dashboard-screen';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(theme),
      drawer: NavigationDrawerWidget(
        currentRoute: _currentRoute,
        onNavigate: _handleNavigation,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(theme),
                _buildMetricsGrid(),
                const ComplaintChartWidget(),
                const AiSummaryWidget(),
                const ComplaintQueueWidget(),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 2,
      leading: IconButton(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        icon: CustomIconWidget(
          iconName: 'menu',
          color: theme.colorScheme.onPrimary,
          size: 24,
        ),
      ),
      title: Text(
        'Admin Dashboard',
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _showNotifications,
          icon: Stack(
            children: [
              CustomIconWidget(
                iconName: 'notifications',
                color: theme.colorScheme.onPrimary,
                size: 24,
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 3.w,
                  height: 3.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: theme.colorScheme.onError,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _showProfile,
          icon: Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'person',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
            ),
          ),
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildWelcomeSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, Admin',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Today is October 16, 2025',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: 'admin_panel_settings',
                  color: theme.colorScheme.onPrimary,
                  size: 32,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  color: theme.colorScheme.onPrimary,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    '3 urgent complaints require immediate attention',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Metrics',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: MetricsCardWidget(
                  title: 'Total Complaints',
                  value: '1,247',
                  trend: '+12%',
                  isPositive: true,
                  cardColor: Theme.of(context).colorScheme.primary,
                  icon: Icons.report_problem,
                ),
              ),
              Expanded(
                child: MetricsCardWidget(
                  title: 'Pending Review',
                  value: '89',
                  trend: '-8%',
                  isPositive: false,
                  cardColor: Theme.of(context).colorScheme.tertiary,
                  icon: Icons.pending_actions,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: MetricsCardWidget(
                  title: 'In Progress',
                  value: '156',
                  trend: '+5%',
                  isPositive: true,
                  cardColor: const Color(0xFFFF9800),
                  icon: Icons.work_outline,
                ),
              ),
              Expanded(
                child: MetricsCardWidget(
                  title: 'Resolved This Month',
                  value: '342',
                  trend: '+18%',
                  isPositive: true,
                  cardColor: const Color(0xFF4CAF50),
                  icon: Icons.check_circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: _showQuickActions,
      backgroundColor: theme.colorScheme.tertiary,
      foregroundColor: theme.colorScheme.onTertiary,
      icon: CustomIconWidget(
        iconName: 'add',
        color: theme.colorScheme.onTertiary,
        size: 24,
      ),
      label: const Text('Quick Action'),
    );
  }

  void _handleNavigation(String route) {
    Navigator.pop(context); // Close drawer

    if (route != _currentRoute) {
      setState(() {
        _currentRoute = route;
      });

      // Handle navigation based on route
      switch (route) {
        case '/admin-dashboard-screen':
          // Already on dashboard, no navigation needed
          break;
        case '/analytics':
          _showComingSoon('Analytics');
          break;
        case '/all-complaints':
          _showComingSoon('All Complaints');
          break;
        case '/priority-queue':
          _showComingSoon('Priority Queue');
          break;
        case '/complaint-map':
          _showComingSoon('Complaint Map');
          break;
        case '/announcements':
          _showComingSoon('Announcements');
          break;
        case '/authorities':
          _showComingSoon('Authorities Management');
          break;
        case '/categories':
          _showComingSoon('Categories Management');
          break;
        case '/settings':
          _showComingSoon('Settings');
          break;
        case '/help':
          _showComingSoon('Help & Support');
          break;
        default:
          _showComingSoon('Feature');
      }
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildNotificationsSheet(),
    );
  }

  Widget _buildNotificationsSheet() {
    final theme = Theme.of(context);

    return Container(
      height: 60.h,
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
                  'Notifications',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Mark All Read'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(4.w),
              itemCount: 5,
              separatorBuilder: (context, index) => SizedBox(height: 2.h),
              itemBuilder: (context, index) {
                return _buildNotificationItem(
                  'New urgent complaint submitted',
                  'Road pothole reported in Sector 15 - requires immediate attention',
                  '2 hours ago',
                  true,
                  theme,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String description,
    String time,
    bool isUnread,
    ThemeData theme,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isUnread
            ? theme.colorScheme.primary.withValues(alpha: 0.05)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          if (isUnread)
            Container(
              width: 2.w,
              height: 2.w,
              margin: EdgeInsets.only(right: 3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  time,
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

  void _showProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildProfileSheet(),
    );
  }

  Widget _buildProfileSheet() {
    final theme = Theme.of(context);

    return Container(
      height: 40.h,
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
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'person',
                      color: theme.colorScheme.primary,
                      size: 40,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Admin Officer',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'admin@prabhav.gov.in',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: 3.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profile-screen');
                    },
                    icon: CustomIconWidget(
                      iconName: 'edit',
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                    label: const Text('Edit Profile'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildQuickActionsSheet(),
    );
  }

  Widget _buildQuickActionsSheet() {
    final theme = Theme.of(context);

    return Container(
      height: 50.h,
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
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                _buildQuickActionItem(
                  'Create Announcement',
                  'Broadcast important updates to citizens',
                  Icons.campaign,
                  theme.colorScheme.primary,
                  () => _showComingSoon('Create Announcement'),
                  theme,
                ),
                _buildQuickActionItem(
                  'Assign Authority',
                  'Assign complaints to relevant departments',
                  Icons.person_add,
                  theme.colorScheme.tertiary,
                  () => _showComingSoon('Assign Authority'),
                  theme,
                ),
                _buildQuickActionItem(
                  'Generate Report',
                  'Create analytics and performance reports',
                  Icons.assessment,
                  const Color(0xFF4CAF50),
                  () => _showComingSoon('Generate Report'),
                  theme,
                ),
                _buildQuickActionItem(
                  'Emergency Alert',
                  'Send urgent notifications to all users',
                  Icons.warning,
                  theme.colorScheme.error,
                  () => _showComingSoon('Emergency Alert'),
                  theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(
    String title,
    String description,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(3.w),
        margin: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: _getIconName(icon),
                color: iconColor,
                size: 24,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
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

  String _getIconName(IconData icon) {
    if (icon == Icons.campaign) return 'campaign';
    if (icon == Icons.person_add) return 'person_add';
    if (icon == Icons.assessment) return 'assessment';
    if (icon == Icons.warning) return 'warning';
    return 'dashboard';
  }

  Future<void> _refreshDashboard() async {
    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dashboard refreshed successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
