import 'package:flutter/material.dart';
import '../presentation/feedback_screen/feedback_screen.dart';
import '../presentation/admin_dashboard_screen/admin_dashboard_screen.dart';
import '../presentation/home_dashboard/home_dashboard.dart';
import '../presentation/login_and_signup_screen/login_and_signup_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/register_complaint_screen/register_complaint_screen.dart';
import '../presentation/track_complaints_screen/track_complaints_screen.dart';
import '../presentation/public_issues_screen/public_issues_screen.dart';
import '../presentation/issue_details_screen/issue_details_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String feedback = '/feedback-screen';
  static const String adminDashboard = '/admin-dashboard-screen';
  static const String homeDashboard = '/home-dashboard';
  static const String loginAndSignup = '/login-and-signup-screen';
  static const String profile = '/profile-screen';
  static const String registerComplaint = '/register-complaint-screen';
  static const String activityHistory = '/activity-history';
  static const String trackComplaints = '/track-complaints';
  static const String publicIssues = '/public-feed';
  static const String issueDetails = '/issue-details';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginAndSignupScreen(),
    feedback: (context) => const FeedbackScreen(),
    adminDashboard: (context) => const AdminDashboardScreen(),
    homeDashboard: (context) => const HomeDashboard(),
    loginAndSignup: (context) => const LoginAndSignupScreen(),
    profile: (context) => const ProfileScreen(),
    registerComplaint: (context) => const RegisterComplaintScreen(),
    activityHistory: (context) =>
        const HomeDashboard(), // Temporary - redirect to home
    trackComplaints: (context) => const TrackComplaintsScreen(),
    publicIssues: (context) => const PublicIssuesScreen(),
    issueDetails: (context) => const IssueDetailsScreen(),
    // TODO: Add your other routes here
  };
}
