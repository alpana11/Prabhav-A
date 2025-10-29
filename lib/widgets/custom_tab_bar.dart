import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';

/// Tab item for CustomTabBar
class TabItem {
  final String label;
  final IconData? icon;
  final Widget? content;

  const TabItem({
    required this.label,
    this.icon,
    this.content,
  });
}

/// Custom Tab Bar for civic engagement application
/// Implements clean navigation with civic-appropriate styling
class CustomTabBar extends StatelessWidget {
  final List<TabItem> tabs;
  final TabController? controller;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Color? indicatorColor;
  final bool isScrollable;
  final TabBarIndicatorSize indicatorSize;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
    this.backgroundColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorColor,
    this.isScrollable = false,
    this.indicatorSize = TabBarIndicatorSize.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: controller,
        onTap: onTap,
        isScrollable: isScrollable,
        labelColor: labelColor ?? colorScheme.primary,
        unselectedLabelColor: unselectedLabelColor ??
            colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorColor: indicatorColor ?? colorScheme.primary,
        indicatorSize: indicatorSize,
        indicatorWeight: 2.0,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabs: tabs.map((tab) => _buildTab(tab)).toList(),
      ),
    );
  }

  Tab _buildTab(TabItem tabItem) {
    if (tabItem.icon != null) {
      return Tab(
        icon: Icon(tabItem.icon, size: 20),
        text: tabItem.label,
        iconMargin: const EdgeInsets.only(bottom: 4),
      );
    } else {
      return Tab(
        text: tabItem.label,
        height: 48,
      );
    }
  }
}

/// Custom Tab Bar View for displaying tab content
class CustomTabBarView extends StatelessWidget {
  final List<Widget> children;
  final TabController? controller;
  final DragStartBehavior dragStartBehavior;

  const CustomTabBarView({
    super.key,
    required this.children,
    this.controller,
    this.dragStartBehavior = DragStartBehavior.start,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller,
      dragStartBehavior: dragStartBehavior,
      children: children,
    );
  }
}

/// Complete Custom Tab Widget combining TabBar and TabBarView
class CustomTabWidget extends StatefulWidget {
  final List<TabItem> tabs;
  final int initialIndex;
  final ValueChanged<int>? onTabChanged;
  final Color? backgroundColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Color? indicatorColor;
  final bool isScrollable;

  const CustomTabWidget({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onTabChanged,
    this.backgroundColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorColor,
    this.isScrollable = false,
  });

  @override
  State<CustomTabWidget> createState() => _CustomTabWidgetState();
}

class _CustomTabWidgetState extends State<CustomTabWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      initialIndex: widget.initialIndex.clamp(0, widget.tabs.length - 1),
      vsync: this,
    );
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (widget.onTabChanged != null && _tabController.indexIsChanging) {
      widget.onTabChanged!(_tabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTabBar(
          tabs: widget.tabs,
          controller: _tabController,
          backgroundColor: widget.backgroundColor,
          labelColor: widget.labelColor,
          unselectedLabelColor: widget.unselectedLabelColor,
          indicatorColor: widget.indicatorColor,
          isScrollable: widget.isScrollable,
        ),
        Expanded(
          child: CustomTabBarView(
            controller: _tabController,
            children: widget.tabs
                .map((tab) => tab.content ?? const SizedBox.shrink())
                .toList(),
          ),
        ),
      ],
    );
  }
}
