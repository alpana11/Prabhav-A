import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CivicMessageBannerWidget extends StatefulWidget {
  const CivicMessageBannerWidget({super.key});

  @override
  State<CivicMessageBannerWidget> createState() =>
      _CivicMessageBannerWidgetState();
}

class _CivicMessageBannerWidgetState extends State<CivicMessageBannerWidget> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _civicMessages = [
    {
      "id": 1,
      "title": "Water Conservation Drive",
      "message":
          "Join our city-wide water conservation initiative. Report water wastage and help save precious resources for future generations.",
      "type": "announcement",
      "priority": "high",
      "date": "2025-10-15",
    },
    {
      "id": 2,
      "title": "Road Maintenance Update",
      "message":
          "Major road repairs scheduled for MG Road from Oct 20-25. Please use alternate routes and report any urgent road issues.",
      "type": "alert",
      "priority": "medium",
      "date": "2025-10-14",
    },
    {
      "id": 3,
      "title": "Digital Governance Initiative",
      "message":
          "Experience faster complaint resolution with our new AI-powered system. Your feedback helps us serve you better.",
      "type": "info",
      "priority": "low",
      "date": "2025-10-13",
    },
    {
      "id": 4,
      "title": "Community Health Drive",
      "message":
          "Free health checkup camps organized in all wards this month. Register through the app or visit your nearest community center.",
      "type": "announcement",
      "priority": "high",
      "date": "2025-10-12",
    },
  ];

  @override
  void initState() {
    super.initState();
    // Auto-play functionality
    _startAutoPlay();
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _nextPage();
        _startAutoPlay();
      }
    });
  }

  void _nextPage() {
    if (_pageController.hasClients) {
      final nextIndex = (_currentIndex + 1) % _civicMessages.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 800),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        children: [
          SizedBox(
            height: 15.h,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _civicMessages.length,
              itemBuilder: (context, index) {
                return _buildMessageCard(context, _civicMessages[index]);
              },
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _civicMessages.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _pageController.animateToPage(
                  entry.key,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                child: Container(
                  width: _currentIndex == entry.key ? 8.w : 2.w,
                  height: 1.h,
                  margin: EdgeInsets.symmetric(horizontal: 1.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentIndex == entry.key
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(BuildContext context, Map<String, dynamic> message) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getPriorityLabel(message["priority"] as String),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              CustomIconWidget(
                iconName: _getMessageIcon(message["type"] as String),
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            message["title"] as String,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 0.5.h),
          Expanded(
            child: Text(
              message["message"] as String,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            _formatDate(message["date"] as String),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'high':
        return 'URGENT';
      case 'medium':
        return 'IMPORTANT';
      case 'low':
        return 'INFO';
      default:
        return 'NOTICE';
    }
  }

  String _getMessageIcon(String type) {
    switch (type) {
      case 'announcement':
        return 'campaign';
      case 'alert':
        return 'warning';
      case 'info':
        return 'info';
      default:
        return 'notifications';
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Yesterday';
      } else {
        return '$difference days ago';
      }
    } catch (e) {
      return dateStr;
    }
  }
}
