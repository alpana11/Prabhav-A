import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';

class PublicIssuesScreen extends StatefulWidget {
  const PublicIssuesScreen({super.key});

  @override
  State<PublicIssuesScreen> createState() => _PublicIssuesScreenState();
}

class _PublicIssuesScreenState extends State<PublicIssuesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedFilter = 'All';
  String _selectedSort = 'Recent';

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
        title: 'Public Issues',
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'search',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Show search
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Filter and Sort Section
              Container(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFilterChip(
                        theme,
                        'Filter',
                        _selectedFilter,
                        () => _showFilterOptions(theme),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: _buildFilterChip(
                        theme,
                        'Sort',
                        _selectedSort,
                        () => _showSortOptions(theme),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1),

              // Issue Cards List
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Info Banner
                      _buildInfoBanner(theme),

                      SizedBox(height: 4.h),

                      // Public Issues List
                      _buildIssueCard(
                        theme,
                        category: 'Streetlight',
                        title: 'Streetlight fixed near Sector 15',
                        area: 'Sector 15, Chandigarh',
                        status: 'Resolved',
                        date: '2024-01-20',
                        upvotes: 45,
                      ),

                      SizedBox(height: 2.h),

                      _buildIssueCard(
                        theme,
                        category: 'Road',
                        title: 'Pothole repair completed on Main Street',
                        area: 'Sector 14, Chandigarh',
                        status: 'Resolved',
                        date: '2024-01-18',
                        upvotes: 78,
                      ),

                      SizedBox(height: 2.h),

                      _buildIssueCard(
                        theme,
                        category: 'Water Supply',
                        title: 'Water pressure issue in Sector 12',
                        area: 'Sector 12, Chandigarh',
                        status: 'In Progress',
                        date: '2024-01-22',
                        upvotes: 32,
                      ),

                      SizedBox(height: 2.h),

                      _buildIssueCard(
                        theme,
                        category: 'Waste Management',
                        title: 'Regular garbage collection reinstated',
                        area: 'Sector 11, Chandigarh',
                        status: 'Resolved',
                        date: '2024-01-19',
                        upvotes: 56,
                      ),

                      SizedBox(height: 2.h),

                      _buildIssueCard(
                        theme,
                        category: 'Electricity',
                        title: 'Power outage resolved in Sector 9',
                        area: 'Sector 9, Chandigarh',
                        status: 'Resolved',
                        date: '2024-01-21',
                        upvotes: 67,
                      ),

                      SizedBox(height: 2.h),

                      _buildIssueCard(
                        theme,
                        category: 'Public Park',
                        title: 'Park maintenance scheduled',
                        area: 'Sector 7, Chandigarh',
                        status: 'Pending',
                        date: '2024-01-23',
                        upvotes: 24,
                      ),

                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 0, // Home tab active
        onTap: (index) {
          final routes = CustomBottomBar.routes;
          if (index < routes.length) {
            final route = routes[index];
            if (route != '/public-feed') {
              Navigator.pushReplacementNamed(context, route);
            }
          }
        },
      ),
    );
  }

  Widget _buildFilterChip(
    ThemeData theme,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            CustomIconWidget(
              iconName: 'arrow_drop_down',
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.tertiary.withValues(alpha: 0.1),
            theme.colorScheme.tertiary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomIconWidget(
              iconName: 'public',
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
                  'Community Feed',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'View verified public issues and their resolution status',
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

  Widget _buildIssueCard(
    ThemeData theme, {
    required String category,
    required String title,
    required String area,
    required String status,
    required String date,
    required int upvotes,
  }) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'Resolved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Resolved';
        break;
      case 'In Progress':
        statusColor = Colors.blue;
        statusIcon = Icons.build;
        statusText = 'In Progress';
        break;
      case 'Pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'Pending';
        break;
      default:
        statusColor = theme.colorScheme.outline;
        statusIcon = Icons.circle;
        statusText = status;
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: _getCategoryIcon(category),
                              color: theme.colorScheme.primary,
                              size: 16,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              category,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        color: statusColor,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        statusText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Location
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'location_on',
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                  size: 18,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    area,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 1.h),

            // Date and Upvotes
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'calendar_today',
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 18,
                ),
                SizedBox(width: 2.w),
                Text(
                  date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(width: 4.w),
                CustomIconWidget(
                  iconName: 'thumb_up',
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                  size: 18,
                ),
                SizedBox(width: 2.w),
                Text(
                  '$upvotes upvotes',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'streetlight':
        return 'lightbulb';
      case 'road':
        return 'road';
      case 'water supply':
        return 'water_drop';
      case 'waste management':
        return 'delete';
      case 'electricity':
        return 'bolt';
      case 'public park':
        return 'park';
      default:
        return 'category';
    }
  }

  void _showFilterOptions(ThemeData theme) {
    final filters = ['All', 'Resolved', 'Pending', 'In Progress'];

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
              'Filter by Status',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ...filters.map((filter) => ListTile(
                  leading: CustomIconWidget(
                    iconName:
                        filter == _selectedFilter ? 'check_circle' : 'circle',
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  title: Text(filter),
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter;
                    });
                    Navigator.pop(context);
                  },
                )),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showSortOptions(ThemeData theme) {
    final sorts = ['Recent', 'Popular', 'Oldest', 'Category'];

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
              'Sort by',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ...sorts.map((sort) => ListTile(
                  leading: CustomIconWidget(
                    iconName: sort == _selectedSort ? 'check_circle' : 'circle',
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  title: Text(sort),
                  onTap: () {
                    setState(() {
                      _selectedSort = sort;
                    });
                    Navigator.pop(context);
                  },
                )),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
