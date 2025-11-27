import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class NavigationDrawerWidget extends StatelessWidget {
  final String currentRoute;
  final Function(String) onNavigate;

  const NavigationDrawerWidget({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(theme),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerSection(
                      'OVERVIEW',
                      [
                        _DrawerItem(
                          icon: Icons.dashboard,
                          title: 'Dashboard',
                          route: '/admin-dashboard-screen',
                        ),
                        _DrawerItem(
                          icon: Icons.analytics,
                          title: 'Analytics',
                          route: '/analytics',
                        ),
                      ],
                      theme),
                  _buildDrawerSection(
                      'COMPLAINTS',
                      [
                        _DrawerItem(
                          icon: Icons.list_alt,
                          title: 'All Complaints',
                          route: '/all-complaints',
                        ),
                        _DrawerItem(
                          icon: Icons.priority_high,
                          title: 'Priority Queue',
                          route: '/priority-queue',
                        ),
                        _DrawerItem(
                          icon: Icons.map,
                          title: 'Complaint Map',
                          route: '/complaint-map',
                        ),
                      ],
                      theme),
                  _buildDrawerSection(
                      'MANAGEMENT',
                      [
                        _DrawerItem(
                          icon: Icons.campaign,
                          title: 'Announcements',
                          route: '/announcements',
                        ),
                        _DrawerItem(
                          icon: Icons.people,
                          title: 'Authorities',
                          route: '/authorities',
                        ),
                        _DrawerItem(
                          icon: Icons.category,
                          title: 'Categories',
                          route: '/categories',
                        ),
                      ],
                      theme),
                  _buildDrawerSection(
                      'ACCOUNT',
                      [
                        _DrawerItem(
                          icon: Icons.settings,
                          title: 'Settings',
                          route: '/settings',
                        ),
                        _DrawerItem(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          route: '/help',
                        ),
                      ],
                      theme),
                ],
              ),
            ),
            _buildDrawerFooter(theme, context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'admin_panel_settings',
                    color: theme.colorScheme.onPrimary,
                    size: 28,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Panel',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Prabhav Governance',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'person',
                  color: theme.colorScheme.onPrimary,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Admin Officer',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSection(
    String title,
    List<_DrawerItem> items,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.h),
          child: Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items.map((item) => _buildDrawerItem(item, theme)),
      ],
    );
  }

  Widget _buildDrawerItem(_DrawerItem item, ThemeData theme) {
    final isSelected = currentRoute == item.route;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CustomIconWidget(
          iconName: _getIconName(item.icon),
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          size: 20,
        ),
        title: Text(
          item.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        onTap: () => onNavigate(item.route),
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
        dense: true,
      ),
    );
  }

  Widget _buildDrawerFooter(ThemeData theme, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: CustomIconWidget(
              iconName: 'logout',
              color: theme.colorScheme.error,
              size: 20,
            ),
            title: Text(
              'Logout',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => _showLogoutDialog(context),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
          SizedBox(height: 2.h),
          Text(
            'Prabhav Admin v1.0.0',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content:
            const Text('Are you sure you want to logout from admin panel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login-and-signup-screen',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  String _getIconName(IconData icon) {
    if (icon == Icons.dashboard) return 'dashboard';
    if (icon == Icons.analytics) return 'analytics';
    if (icon == Icons.list_alt) return 'list_alt';
    if (icon == Icons.priority_high) return 'priority_high';
    if (icon == Icons.map) return 'map';
    if (icon == Icons.campaign) return 'campaign';
    if (icon == Icons.people) return 'people';
    if (icon == Icons.category) return 'category';
    if (icon == Icons.settings) return 'settings';
    if (icon == Icons.help_outline) return 'help_outline';
    if (icon == Icons.logout) return 'logout';
    return 'dashboard';
  }
}

class _DrawerItem {
  final IconData icon;
  final String title;
  final String route;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.route,
  });
}
