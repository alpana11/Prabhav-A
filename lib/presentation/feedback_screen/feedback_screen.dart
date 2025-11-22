import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/feedback_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/feedback_success_dialog.dart';
import './widgets/feedback_text_area_widget.dart';
import './widgets/photo_upload_widget.dart';
import './widgets/service_aspect_rating_widget.dart';
import './widgets/star_rating_widget.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  // Mock data for the complaint/service being reviewed
  final Map<String, dynamic> _serviceData = {
    "id": "COMP-2024-001",
    "title": "Road Repair Request",
    "category": "Infrastructure",
    "categoryIcon": "construction",
    "resolutionDate": "2024-10-14",
    "status": "Resolved",
    "description":
        "Pothole repair on MG Road near City Mall completed successfully",
    "location": "MG Road, Sector 15, Gurgaon",
    "resolvedBy": "Municipal Corporation",
  };

  // Form state
  double _overallRating = 0.0;
  String _feedbackText = '';
  List<XFile> _uploadedPhotos = [];
  Map<String, double> _aspectRatings = {};
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  bool _isDraftSaved = false;

  // Mock feedback history
  List<Map<String, dynamic>> _feedbackHistory = [
    {
      "id": "FB-001",
      "serviceTitle": "Water Supply Issue",
      "rating": 4.5,
      "submittedDate": "2024-10-10",
      "status": "Reviewed",
    },
    {
      "id": "FB-002",
      "serviceTitle": "Street Light Repair",
      "rating": 3.0,
      "submittedDate": "2024-10-05",
      "status": "Under Review",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadDraftFeedback();
    _loadFeedbackHistory();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Feedback',
        actions: [
          IconButton(
            onPressed: _showFeedbackHistory,
            icon: CustomIconWidget(
              iconName: 'history',
              color: theme.colorScheme.onPrimary,
              size: 24,
            ),
            tooltip: 'Feedback History',
          ),
        ],
      ),
      body: _buildBody(theme),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: CustomBottomBar.getIndexForRoute('/feedback-screen'),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceHeader(theme),
          SizedBox(height: 3.h),
          _buildOverallRating(theme),
          SizedBox(height: 3.h),
          _buildFeedbackTextArea(theme),
          SizedBox(height: 3.h),
          _buildPhotoUpload(theme),
          SizedBox(height: 3.h),
          _buildServiceAspectRating(theme),
          SizedBox(height: 3.h),
          _buildAnonymousToggle(theme),
          SizedBox(height: 4.h),
          _buildSubmitButton(theme),
          SizedBox(height: 2.h),
          _buildDraftInfo(theme),
          SizedBox(height: 10.h), // Extra space for bottom navigation
        ],
      ),
    );
  }

  Widget _buildServiceHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: _serviceData['categoryIcon'],
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _serviceData['title'],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _serviceData['category'],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _serviceData['status'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'event',
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 16,
              ),
              SizedBox(width: 2.w),
              Text(
                'Resolved on ${_serviceData['resolutionDate']}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverallRating(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'star',
              color: theme.colorScheme.tertiary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Overall Rating',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              ' *',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _overallRating > 0
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              StarRatingWidget(
                rating: _overallRating,
                onRatingChanged: (rating) {
                  setState(() {
                    _overallRating = rating;
                  });
                  _saveDraft();
                },
                size: 40,
                allowHalfRating: true,
              ),
              SizedBox(height: 2.h),
              if (_overallRating > 0) ...[
                Text(
                  _getRatingDescription(_overallRating),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: _getRatingColor(_overallRating),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Thank you for rating our service!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ] else ...[
                Text(
                  'Tap stars to rate your experience',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackTextArea(ThemeData theme) {
    return FeedbackTextAreaWidget(
      initialText: _feedbackText,
      onTextChanged: (text) {
        setState(() {
          _feedbackText = text;
        });
        _saveDraft();
      },
      maxLength: 500,
      prompts: const [
        'How was the resolution process?',
        'What could be improved?',
        'How satisfied are you with the communication?',
        'Would you recommend this service?',
      ],
    );
  }

  Widget _buildPhotoUpload(ThemeData theme) {
    return PhotoUploadWidget(
      initialPhotos: _uploadedPhotos,
      onPhotosChanged: (photos) {
        setState(() {
          _uploadedPhotos = photos;
        });
        _saveDraft();
      },
      maxPhotos: 4,
      showBeforeAfter: true,
    );
  }

  Widget _buildServiceAspectRating(ThemeData theme) {
    return ServiceAspectRatingWidget(
      initialRatings: _aspectRatings,
      onRatingsChanged: (ratings) {
        setState(() {
          _aspectRatings = ratings;
        });
        _saveDraft();
      },
    );
  }

  Widget _buildAnonymousToggle(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'visibility_off',
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            size: 20,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Submit Anonymous Feedback',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Your identity will not be shared with authorities',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAnonymous,
            onChanged: (value) {
              setState(() {
                _isAnonymous = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    final isEnabled = _overallRating > 0 && !_isSubmitting;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? _submitFeedback : null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          backgroundColor: isEnabled
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.12),
          foregroundColor: isEnabled
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface.withValues(alpha: 0.38),
        ),
        child: _isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text('Submitting...'),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'send',
                    color: isEnabled
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text('Submit Feedback'),
                ],
              ),
      ),
    );
  }

  Widget _buildDraftInfo(ThemeData theme) {
    if (!_isDraftSaved) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'save',
            color: theme.colorScheme.primary,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Text(
            'Draft saved automatically',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _loadDraftFeedback() {
    // Simulate loading draft from local storage
    // In real app, this would load from SharedPreferences or local database
    setState(() {
      _isDraftSaved = false;
    });
  }

  Future<void> _loadFeedbackHistory() async {
    try {
      final feedbackService = FeedbackService();
      final result = await feedbackService.getFeedbackHistory();

      if (result['success']) {
        setState(() {
          _feedbackHistory = List<Map<String, dynamic>>.from(result['data'] ?? []);
        });
      }
    } catch (e) {
      // Silently handle error
    }
  }

  void _saveDraft() {
    // Simulate saving draft to local storage
    setState(() {
      _isDraftSaved = true;
    });

    // Hide draft indicator after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isDraftSaved = false;
        });
      }
    });
  }

  Future<void> _submitFeedback() async {
    if (_overallRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please provide an overall rating'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final feedbackService = FeedbackService();
      final result = await feedbackService.submitFeedback(
        complaintId: _serviceData['id'],
        rating: _overallRating,
        feedbackText: _feedbackText,
        aspectRatings: _aspectRatings,
        isAnonymous: _isAnonymous,
      );

      if (mounted) {
        if (result['success']) {
          // Show success dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => FeedbackSuccessDialog(
              onClosePressed: () {
                Navigator.of(context).pop();
                _resetForm();
                Navigator.pushNamedAndRemoveUntil(context, '/profile-screen', (route) => false);
              },
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to submit feedback'),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Retry',
                onPressed: _submitFeedback,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit feedback. Please try again.'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _submitFeedback,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _resetForm() {
    setState(() {
      _overallRating = 0.0;
      _feedbackText = '';
      _uploadedPhotos.clear();
      _aspectRatings.clear();
      _isAnonymous = false;
      _isDraftSaved = false;
    });
  }

  void _showFeedbackHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildFeedbackHistorySheet(),
    );
  }

  Widget _buildFeedbackHistorySheet() {
    final theme = Theme.of(context);

    return Container(
      height: 70.h,
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Handle
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          SizedBox(height: 3.h),

          Text(
            'Feedback History',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 3.h),

          Expanded(
            child: _feedbackHistory.isEmpty
                ? _buildEmptyHistory(theme)
                : ListView.separated(
                    itemCount: _feedbackHistory.length,
                    separatorBuilder: (context, index) => SizedBox(height: 2.h),
                    itemBuilder: (context, index) {
                      final feedback = _feedbackHistory[index];
                      return _buildFeedbackHistoryItem(feedback, theme);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'feedback',
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Feedback History',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Your submitted feedback will appear here',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackHistoryItem(
      Map<String, dynamic> feedback, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  feedback['serviceTitle'] ?? 'Service',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(feedback['status'] ?? 'Reviewed')
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  feedback['status'] ?? 'Reviewed',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(feedback['status'] ?? 'Reviewed'),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              StarRatingWidget(
                rating: (feedback['rating'] as num?)?.toDouble() ?? 0.0,
                onRatingChanged: (_) {},
                size: 16,
                allowHalfRating: true,
              ),
              SizedBox(width: 2.w),
              Text(
                (feedback['rating'] ?? 0).toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            feedback['message'] ?? feedback['feedbackText'] ?? 'No message',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Text(
                'By: ${feedback['userName'] ?? 'User'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                'on ${feedback['submittedDate'] ?? feedback['submittedOn'] ?? 'Unknown date'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getRatingDescription(double rating) {
    if (rating <= 1.5) return 'Poor Experience';
    if (rating <= 2.5) return 'Fair Experience';
    if (rating <= 3.5) return 'Good Experience';
    if (rating <= 4.5) return 'Very Good Experience';
    return 'Excellent Experience';
  }

  Color _getRatingColor(double rating) {
    if (rating <= 2) return Colors.red;
    if (rating <= 3) return Colors.orange;
    if (rating <= 4) return Colors.blue;
    return Colors.green;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'reviewed':
        return Colors.green;
      case 'under review':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
