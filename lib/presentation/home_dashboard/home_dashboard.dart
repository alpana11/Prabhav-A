import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/user_data_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/action_grid_widget.dart';
import './widgets/civic_message_banner_widget.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/nearby_issues_widget.dart';
import './widgets/quick_stats_widget.dart';
import './widgets/recent_activity_widget.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool _isGuest = false;

  // Mock user data
  final Map<String, dynamic> _userData = {
    "name": "Rahul Sharma",
    "location": "Sector 15, Chandigarh",
    "isGuest": false,
    "notificationCount": 3,
  };

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  void _checkUserStatus() {
    // Check if user is logged in using UserDataService
    final userService = UserDataService();
    setState(() {
      _isGuest = !userService.isLoggedIn;
    });
  }

  Future<void> _refreshDashboard() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Show refresh feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dashboard updated successfully'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _handleActionTap(String route) {
    if (_isGuest && _requiresAuthentication(route)) {
      _showGuestLimitationDialog();
      return;
    }
    Navigator.pushNamed(context, route);
  }

  bool _requiresAuthentication(String route) {
    final authRequiredRoutes = [
      '/register-complaint-screen',
      '/feedback-screen',
      '/profile-screen',
    ];
    return authRequiredRoutes.contains(route);
  }

  void _showGuestLimitationDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'info',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Sign In Required',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Please sign in to access this feature and enjoy full functionality of Prabhav.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login-and-signup-screen');
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap() {
    Navigator.pushNamed(context, '/notifications');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refreshDashboard,
          color: theme.colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Header
                GreetingHeaderWidget(
                  userName: _isGuest
                      ? 'Guest User'
                      : (UserDataService().username ?? 'User'),
                  location: _userData["location"] as String,
                  notificationCount:
                      _isGuest ? 0 : (_userData["notificationCount"] as int),
                  onNotificationTap: _isGuest ? null : _handleNotificationTap,
                ),

                // Guest Banner
                if (_isGuest) _buildGuestBanner(),

                // Civic Message Banner
                const CivicMessageBannerWidget(),

                SizedBox(height: 2.h),

                // Action Grid
                ActionGridWidget(
                  onActionTap: _handleActionTap,
                ),

                SizedBox(height: 3.h),

                // Recent Activity (only for authenticated users)
                if (!_isGuest) ...[
                  const RecentActivityWidget(),
                  SizedBox(height: 3.h),
                ],

                // Nearby Issues
                const NearbyIssuesWidget(),

                SizedBox(height: 3.h),

                // Quick Stats
                const QuickStatsWidget(),

                SizedBox(height: 10.h), // Bottom padding for FAB
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 0, // Home tab active
        onTap: (index) {
          final routes = CustomBottomBar.routes;
          if (index < routes.length) {
            final route = routes[index];
            if (_isGuest && _requiresAuthentication(route)) {
              _showGuestLimitationDialog();
              return;
            }
            if (route != '/home-dashboard') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                route,
                (route) => false,
              );
            }
          }
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildGuestBanner() {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.tertiary.withValues(alpha: 0.1),
            theme.colorScheme.tertiary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'person_add',
            color: theme.colorScheme.tertiary,
            size: 24,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign Up for Full Access',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Register complaints, track progress, and give feedback',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login-and-signup-screen');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.tertiary,
              foregroundColor: theme.colorScheme.onTertiary,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Sign Up',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_isGuest) return null;

    final theme = Theme.of(context);

    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.pushNamed(context, '/register-complaint-screen');
      },
      backgroundColor: theme.colorScheme.tertiary,
      foregroundColor: theme.colorScheme.onTertiary,
      elevation: 4.0,
      icon: CustomIconWidget(
        iconName: 'add',
        color: theme.colorScheme.onTertiary,
        size: 24,
      ),
      label: Text(
        'New Complaint',
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onTertiary,
        ),
      ),
    );
  }
}
