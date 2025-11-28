import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../core/app_export.dart';
import '../../core/user_data_service.dart';
import '../../services/profile_service.dart';
import '../../services/feedback_service.dart';
import '../../services/complaint_service.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_bottom_bar.dart';

// Extra widgets restored from original
import './widgets/stats_cards_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/achievement_badges_widget.dart';
import './widgets/complaint_history_widget.dart';
import './widgets/feedback_history_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/saved_complaints_widget.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomNavIndex = 3; // Profile tab active

  // Dynamic data from API
  Map<String, dynamic>? _statsData; // total, resolved, avgResolution, impactScore
  List<Map<String, dynamic>> _complaints = [];
  List<Map<String, dynamic>> _feedback = [];
  List<Map<String, dynamic>> _savedComplaints = [];
  List<Map<String, dynamic>> _achievements = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadProfileData();
  }

  // USER DATA MAP (DO NOT TOUCH)
  Map<String, dynamic> get userData {
    final user = UserDataService();
    return {
      "name": user.username ?? "",
      "email": user.email ?? "",
      "phone": user.phone ?? "",
      "location": user.location ?? "",
      "avatar": user.avatar,
    };
  }

  Future<void> _loadProfileData() async {
    final user = UserDataService();
    final api = ApiService();

    try {
      // Load main profile
      final profileRes = await api.getUserProfile();

      user.setUserData(
        username: profileRes["username"] ?? user.username,
        governmentIdType: user.governmentIdType ?? "",
        governmentIdNumber: user.governmentIdNumber ?? "",
        email: profileRes["email"] ?? user.email,
        phone: profileRes["phone"] ?? user.phone,
        location: profileRes["location"] ?? user.location,
        avatar: profileRes["avatar"] ?? user.avatar,
      );

      // Load complaints

        final complaintRes = await ComplaintService().getUserComplaints();
        if (complaintRes["success"] == true) {
          _complaints = (complaintRes["complaints"] as List).map((c) {
            return {
              "title": c["title"] ?? c["subject"] ?? "Complaint",
              "category": c["department"] ?? c["category"] ?? "General",
              "status": c["status"] ?? "Submitted",
              "submissionDate": c["createdAt"] ?? "",
              "location": c["address"] ?? "",
              "thumbnail": (c["images"] != null && c["images"].isNotEmpty)
                   ? c["images"][0]
                   : null,
            };
          }).toList();
        }


      // Load feedback
      final feedbackRes = await FeedbackService().getFeedbackHistory();
      if (feedbackRes["success"] == true) {
        _feedback = (feedbackRes["data"] as List).map((f) {
          return {
            "complaintTitle":
                f["serviceTitle"] ?? f["complaintTitle"] ?? "Complaint",
            "rating": (f["rating"] ?? 0).toInt(),
            "comment": f["message"] ?? "",
            "date": f["submittedDate"] ?? "",
          };
        }).toList();
      }

    

      // Stats updated using complaintRes["total"]
      _statsData = {
        "totalComplaints": complaintRes["total"] ?? 0,   // FIXED ✔
        "resolvedIssues": profileRes["resolvedIssues"] ?? 0,
        "avgResolutionTime": profileRes["avgResolution"] ?? "0 days",
        "impactScore": profileRes["impactScore"] ?? 0,
      };


      // Load saved complaints
      _savedComplaints = []; // leave empty unless backend returns data

      // Load achievements (optional)
      _achievements = []; // leave empty unless backend returns data

      if (mounted) setState(() {});
    } catch (e) {
      // ignore silently
    }
  }

  // UI STARTS —
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
            onEditProfile: _editProfilePopup,
          ),

          // ⭐ RESTORED — Stats Cards Section ⭐
          if (_statsData != null)
            StatsCardsWidget(statsData: _statsData!)
          else
            SizedBox(height: 2.h),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 1.h),

                  // TAB SECTION
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          labelColor: colorScheme.primary,
                          unselectedLabelColor:
                              colorScheme.onSurface.withOpacity(0.6),
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
                              ComplaintHistoryWidget(complaints: _complaints),
                              FeedbackHistoryWidget(feedbackList: _feedback),
                              SavedComplaintsWidget(
                                  savedComplaints: _savedComplaints),
                              AchievementBadgesWidget(
                                  achievements: _achievements),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // ⭐ RESTORED — ACCOUNT SETTINGS ⭐
                  SettingsSectionWidget(
                    settingsData: {
                      "language": "English",
                      "theme": "System",
                    },
                    onSettingChanged: (k, v) {},
                  ),

                  SizedBox(height: 3.h),

                  // LOGOUT BUTTON
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    child: ElevatedButton(
                      onPressed: _handleLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorLight,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                      ),
                      child: Text("Logout"),
                    ),
                  ),
                  SizedBox(height: 2.h),
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

  // Profile Edit Popup
  void _editProfilePopup() {
    final user = UserDataService();

    final nameCtrl = TextEditingController(text: user.username ?? '');
    final emailCtrl = TextEditingController(text: user.email ?? '');
    final phoneCtrl = TextEditingController(text: user.phone ?? '');
    final locCtrl = TextEditingController(text: user.location ?? '');
    final picker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final XFile? img =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (img != null) {
                    final result = await ProfileService().uploadProfilePicture(
                      userId: user.username ?? '',
                      imageFile: File(img.path),
                    );
                    if (result["success"] == true) {
                      user.setUserData(
                        username: user.username ?? '',
                        governmentIdType: user.governmentIdType ?? "",
                        governmentIdNumber: user.governmentIdNumber ?? "",
                        avatar: result["imageUrl"],
                        email: emailCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        location: locCtrl.text.trim(),
                      );

                      if (mounted) setState(() {});
                    }
                  }
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: user.avatar != null
                      ? NetworkImage(user.avatar!)
                      : null,
                  child: user.avatar == null
                      ? Icon(Icons.camera_alt, size: 30)
                      : null,
                ),
              ),
              SizedBox(height: 1.h),
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Name")),
              TextField(controller: emailCtrl, decoration: InputDecoration(labelText: "Email")),
              TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: "Phone")),
              TextField(controller: locCtrl, decoration: InputDecoration(labelText: "Location")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              user.setUserData(
                username: nameCtrl.text.trim(),
                governmentIdType: user.governmentIdType ?? "",
                governmentIdNumber: user.governmentIdNumber ?? "",
                email: emailCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                location: locCtrl.text.trim(),
              );
              Navigator.pop(context);
              setState(() {});
            },
            child: Text("Save"),
          )
        ],
      ),
    );
  }

  // Navigation
  void _handleBottomNavTap(int index) {
    if (index == _currentBottomNavIndex) return;

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
        break;
    }
  }

  void _handleLogout() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login-and-signup-screen',
      (route) => false,
    );
  }
}