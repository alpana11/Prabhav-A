import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Navigation item for CustomBottomBar
class BottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String route;

  const BottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.route,
  });
}

/// Custom Bottom Navigation Bar for civic engagement application
/// Implements adaptive navigation with civic-appropriate styling
class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double elevation;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation = 8.0,
  });

  // Hardcoded navigation items for civic engagement app
  static const List<BottomNavItem> _navItems = [
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
      route: '/home-dashboard',
    ),
    BottomNavItem(
      icon: Icons.report_problem_outlined,
      activeIcon: Icons.report_problem,
      label: 'Report',
      route: '/register-complaint-screen',
    ),
    BottomNavItem(
      icon: Icons.feedback_outlined,
      activeIcon: Icons.feedback,
      label: 'Feedback',
      route: '/feedback-screen',
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      route: '/profile-screen',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: elevation,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex.clamp(0, _navItems.length - 1),
        onTap: (index) {
          if (onTap != null) {
            onTap!(index);
          } else {
            _handleNavigation(context, index);
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: backgroundColor ?? colorScheme.surface,
        selectedItemColor: selectedItemColor ?? colorScheme.primary,
        unselectedItemColor:
            unselectedItemColor ?? colorScheme.onSurface.withOpacity(0.6),
        elevation: 0, // We handle elevation with container shadow
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        items: _navItems.map((item) => _buildBottomNavItem(item)).toList(),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem(BottomNavItem item) {
    return BottomNavigationBarItem(
      icon: Icon(item.icon, size: 24),
      activeIcon: Icon(item.activeIcon ?? item.icon, size: 24),
      label: item.label,
      tooltip: item.label,
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index >= 0 && index < _navItems.length) {
      final route = _navItems[index].route;
      final currentRoute = ModalRoute.of(context)?.settings.name;

      // Only navigate if not already on the target route
      if (currentRoute != route) {
        // Use pushReplacementNamed to avoid black screen issues
        Navigator.pushReplacementNamed(context, route);
      }
    }
  }

  /// Get the index for a given route
  static int getIndexForRoute(String route) {
    for (int i = 0; i < _navItems.length; i++) {
      if (_navItems[i].route == route) {
        return i;
      }
    }
    return 0; // Default to home
  }

  /// Get all available routes
  static List<String> get routes =>
      _navItems.map((item) => item.route).toList();
}
