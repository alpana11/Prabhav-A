import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/user_data_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/achievement_badges_widget.dart';
import './widgets/complaint_history_widget.dart';
import './widgets/feedback_history_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/saved_complaints_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/stats_cards_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomNavIndex = 3; // Profile tab active

  Map<String, dynamic> get userData {
    final userService = UserDataService();
    return {
      "name": userService.username ?? "User",
      "email": "user@example.com",
      "phone": "+91 9876543210",
      "location": "Sector 15, Noida, UP",
      "avatar": "https://images.unsplash.com/photo-1613930281705-21ee0befea10",
      "avatarSemanticLabel":
          "Professional headshot of an Indian man with short black hair wearing a blue shirt, smiling at camera",
      "joinDate": "March 2024",
    };
  }

  // Mock stats data
  final Map<String, dynamic> _statsData = {
    "totalComplaints": 12,
    "resolvedIssues": 8,
    "avgResolutionTime": "7 days",
    "impactScore": 85,
  };

  // Mock settings data
  final Map<String, dynamic> _settingsData = {
    "language": "English",
    "theme": "System",
    "notifications": {
      "push": true,
      "email": false,
      "sms": true,
    },
  };

  // Mock complaints data
  final List<Map<String, dynamic>> _complaintsData = [
    {
      "id": 1,
      "title": "Broken Street Light on Main Road",
      "category": "Infrastructure",
      "status": "Resolved",
      "submissionDate": "Oct 10, 2025",
      "location": "Main Road, Sector 15",
      "thumbnail":
          "https://images.unsplash.com/photo-1575481021676-6455b33730cf",
      "thumbnailSemanticLabel":
          "Broken street light pole on empty road at dusk with orange sky in background",
    },
    {
      "id": 2,
      "title": "Water Logging Issue During Monsoon",
      "category": "Water Management",
      "status": "In Progress",
      "submissionDate": "Oct 8, 2025",
      "location": "Residential Area, Sector 12",
      "thumbnail":
          "https://images.unsplash.com/photo-1648546757131-6a2d7eaca660",
      "thumbnailSemanticLabel":
          "Flooded street with water covering the road surface and buildings visible in background",
    },
    {
      "id": 3,
      "title": "Garbage Collection Not Regular",
      "category": "Sanitation",
      "status": "Under Review",
      "submissionDate": "Oct 5, 2025",
      "location": "Park Avenue, Sector 18",
    },
  ];

  // Mock feedback data
  final List<Map<String, dynamic>> _feedbackData = [
    {
      "id": 1,
      "complaintTitle": "Broken Street Light on Main Road",
      "rating": 5,
      "comment":
          "Excellent response time! The street light was fixed within 3 days of reporting. Very satisfied with the service.",
      "date": "Oct 13, 2025",
    },
    {
      "id": 2,
      "complaintTitle": "Pothole Repair Request",
      "rating": 4,
      "comment":
          "Good work on fixing the pothole, but it took longer than expected.",
      "date": "Sep 28, 2025",
    },
  ];

  // Mock saved complaints data
  final List<Map<String, dynamic>> _savedComplaintsData = [
    {
      "id": 1,
      "title": "Park Maintenance Required",
      "submittedBy": "Priya Sharma",
      "status": "In Progress",
      "savedDate": "Oct 12, 2025",
      "thumbnail":
          "https://images.unsplash.com/photo-1699177438467-0b8bf24d574f",
      "thumbnailSemanticLabel":
          "Public park with overgrown grass and broken benches needing maintenance",
    },
    {
      "id": 2,
      "title": "Traffic Signal Malfunction",
      "submittedBy": "Amit Singh",
      "status": "Under Review",
      "savedDate": "Oct 10, 2025",
    },
  ];

  // Mock achievements data
  final List<Map<String, dynamic>> _achievementsData = [
    {
      "id": 1,
      "title": "First Complaint",
      "description": "Submitted your first complaint",
      "icon": "flag",
      "unlocked": true,
      "earnedDate": "Mar 15, 2024",
    },
    {
      "id": 2,
      "title": "Community Helper",
      "description": "Helped resolve 5+ issues",
      "icon": "people",
      "unlocked": true,
      "earnedDate": "Aug 22, 2024",
    },
    {
      "id": 3,
      "title": "Feedback Champion",
      "description": "Provided feedback on 10+ complaints",
      "icon": "star",
      "unlocked": false,
    },
    {
      "id": 4,
      "title": "Civic Leader",
      "description": "Top contributor in your area",
      "icon": "emoji_events",
      "unlocked": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          ProfileHeaderWidget(
            userData: userData,
            onEditProfile: _handleEditProfile,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  StatsCardsWidget(statsData: _statsData),
                  SizedBox(height: 2.h),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          labelColor: colorScheme.primary,
                          unselectedLabelColor:
                              colorScheme.onSurface.withValues(alpha: 0.6),
                          indicatorColor: colorScheme.primary,
                          tabs: const [
                            Tab(text: "Complaints"),
                            Tab(text: "Feedback"),
                            Tab(text: "Saved"),
                            Tab(text: "Achievements"),
                          ],
                        ),
                        SizedBox(
                          height: 60.h,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              ComplaintHistoryWidget(
                                  complaints: _complaintsData),
                              FeedbackHistoryWidget(
                                  feedbackList: _feedbackData),
                              SavedComplaintsWidget(
                                  savedComplaints: _savedComplaintsData),
                              AchievementBadgesWidget(
                                  achievements: _achievementsData),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  SettingsSectionWidget(
                    settingsData: _settingsData,
                    onSettingChanged: _handleSettingChanged,
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    child: ElevatedButton(
                      onPressed: _handleLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorLight,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'logout',
                            color: Colors.white,
                            size: 5.w,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            "Logout",
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _handleBottomNavTap,
      ),
    );
  }

  void _handleEditProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Profile Photo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'camera_alt',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text("Camera functionality would open here")),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gallery would open here")),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _handleSettingChanged(String key, dynamic value) {
    setState(() {
      if (key == "notifications") {
        _settingsData[key] = value;
      } else {
        _settingsData[key] = value;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Setting updated: $key"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    if (index != _currentBottomNavIndex) {
      setState(() {
        _currentBottomNavIndex = index;
      });

      switch (index) {
        case 0:
          Navigator.pushNamedAndRemoveUntil(
              context, '/home-dashboard', (route) => false);
          break;
        case 1:
          Navigator.pushNamedAndRemoveUntil(
              context, '/register-complaint-screen', (route) => false);
          break;
        case 2:
          Navigator.pushNamedAndRemoveUntil(
              context, '/feedback-screen', (route) => false);
          break;
        case 3:
          // Already on profile screen
          break;
      }
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
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
              backgroundColor: AppTheme.errorLight,
            ),
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }
}
