// lib/presentation/feedback_screen/feedback_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_export.dart';
import '../../services/feedback_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/feedback_success_dialog.dart';
import './widgets/feedback_text_area_widget.dart';
import './widgets/photo_upload_widget.dart';
import './widgets/service_aspect_rating_widget.dart';
import './widgets/star_rating_widget.dart';

class FeedbackScreen extends StatefulWidget {
  // Make complaint optional so route creation doesn't require it
  final Map<String, dynamic>? complaint;
  const FeedbackScreen({Key? key, this.complaint}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  late Map<String, dynamic> _serviceData;

  // Form state
  double _overallRating = 0.0;
  String _feedbackText = '';
  List<XFile> _uploadedPhotos = [];
  Map<String, double> _aspectRatings = {};
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  bool _isDraftSaved = false;

  // feedback history displayed in UI
  List<Map<String, dynamic>> _feedbackHistory = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // priority: widget.complaint -> route args -> fallback mock
    final args = ModalRoute.of(context)?.settings.arguments;
    if (widget.complaint != null) {
      _serviceData = widget.complaint!;
    } else if (args is Map<String, dynamic>) {
      _serviceData = args;
    } else {
      _serviceData = {
        "id": "COMP-UNKNOWN",
        "title": "Unknown Service",
        "category": "General",
        "categoryIcon": "feedback",
        "resolutionDate": "",
        "status": "Unknown",
        "description": "",
        "location": "",
        "resolvedBy": "",
      };
    }
  }

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
      padding: EdgeInsets.all(16), // replaced 4.w to avoid dependency on sizer in this snippet
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceHeader(theme),
          const SizedBox(height: 16),
          _buildOverallRating(theme),
          const SizedBox(height: 16),
          _buildFeedbackTextArea(theme),
          const SizedBox(height: 16),
          _buildPhotoUpload(theme),
          const SizedBox(height: 16),
          _buildServiceAspectRating(theme),
          const SizedBox(height: 16),
          _buildAnonymousToggle(theme),
          const SizedBox(height: 24),
          _buildSubmitButton(theme),
          const SizedBox(height: 12),
          _buildDraftInfo(theme),
          const SizedBox(height: 80), // reserve space for bottom bar
        ],
      ),
    );
  }

  Widget _buildServiceHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: _serviceData['categoryIcon'] ?? 'feedback',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _serviceData['title'] ?? 'Service',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _serviceData['category'] ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _serviceData['status'] ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.green, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CustomIconWidget(iconName: 'event', color: theme.colorScheme.onSurface.withOpacity(0.6), size: 16),
              const SizedBox(width: 8),
              Text(
                _serviceData['resolutionDate'] != null && ( _serviceData['resolutionDate'] ?? '' ) != ''
                    ? 'Resolved on ${_serviceData['resolutionDate']}'
                    : '',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
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
            CustomIconWidget(iconName: 'star', color: theme.colorScheme.tertiary, size: 20),
            const SizedBox(width: 8),
            Text('Overall Rating', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            Text(' *', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.error, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _overallRating > 0 ? theme.colorScheme.primary.withOpacity(0.3) : theme.colorScheme.outline.withOpacity(0.2)),
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
              const SizedBox(height: 8),
              if (_overallRating > 0) ...[
                Text(_getRatingDescription(_overallRating), style: theme.textTheme.titleSmall?.copyWith(color: _getRatingColor(_overallRating), fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('Thank you for rating our service!', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
              ] else ...[
                Text('Tap stars to rate your experience', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
              ]
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12))),
      child: Row(
        children: [
          CustomIconWidget(iconName: 'visibility_off', color: theme.colorScheme.onSurface.withOpacity(0.6), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Submit Anonymous Feedback', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('Your identity will not be shared with authorities', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
          ),
          Switch(value: _isAnonymous, onChanged: (value) => setState(() => _isAnonymous = value)),
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
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: isEnabled ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.12),
          foregroundColor: isEnabled ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withOpacity(0.38),
        ),
        child: _isSubmitting
            ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)), const SizedBox(width: 12), const Text('Submitting...')])
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [CustomIconWidget(iconName: 'send', color: isEnabled ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withOpacity(0.38), size: 20), const SizedBox(width: 8), const Text('Submit Feedback')]),
      ),
    );
  }

  Widget _buildDraftInfo(ThemeData theme) {
    if (!_isDraftSaved) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: theme.colorScheme.primary.withOpacity(0.12))),
      child: Row(children: [CustomIconWidget(iconName: 'save', color: theme.colorScheme.primary, size: 16), const SizedBox(width: 8), Text('Draft saved automatically', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary))]),
    );
  }

  void _loadDraftFeedback() {
    // TODO: load from local storage if you have it
    setState(() => _isDraftSaved = false);
  }

  Future<void> _loadFeedbackHistory() async {
    try {
      final feedbackService = FeedbackService();
      final result = await feedbackService.getFeedbackHistory();
      if (result['success'] == true) {
        // ensure structure matches what UI expects
        setState(() {
          _feedbackHistory = List<Map<String, dynamic>>.from(result['data'] ?? []);
        });
      }
    } catch (e) {
      // silent
    }
  }

  void _saveDraft() {
    setState(() => _isDraftSaved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isDraftSaved = false);
    });
  }

  Future<void> _submitFeedback() async {
    if (_overallRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide an overall rating'), behavior: SnackBarBehavior.floating));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final feedbackService = FeedbackService();
      final res = await feedbackService.submitFeedback(
        complaintId: _serviceData['id']?.toString() ?? '',
        rating: _overallRating,
        feedbackText: _feedbackText,
        aspectRatings: _aspectRatings,
        isAnonymous: _isAnonymous,
      );

      if (!mounted) return;

      if (res['success'] == true) {
        // Add new feedback to local list so it appears immediately
        final item = {
          'id': res['data']?['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'serviceTitle': _serviceData['title'] ?? 'Service',
          'rating': _overallRating,
          'submittedDate': DateTime.now().toIso8601String(),
          'status': 'Submitted',
          'message': _feedbackText,
          'userName': _isAnonymous ? 'Anonymous' : (res['data']?['userName'] ?? 'You'),
        };
        setState(() => _feedbackHistory.insert(0, item));

        // Show dialog & navigate back to profile when closed
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => FeedbackSuccessDialog(onClosePressed: () {
            Navigator.of(context).pop();
            _resetForm();
            // go to profile screen (adjust route name if different)
            Navigator.pushNamedAndRemoveUntil(context, '/profile-screen', (route) => false);
          }),
        );
      } else {
        final message = res['message'] ?? 'Failed to submit feedback';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit feedback. Please try again.'), behavior: SnackBarBehavior.floating));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _buildFeedbackHistorySheet(),
    );
  }

  Widget _buildFeedbackHistorySheet() {
    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(width: 48, height: 6, decoration: BoxDecoration(color: theme.colorScheme.outline.withOpacity(0.3), borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 16),
          Text('Feedback History', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Expanded(
            child: _feedbackHistory.isEmpty ? _buildEmptyHistory(theme) : ListView.separated(
              itemCount: _feedbackHistory.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) => _buildFeedbackHistoryItem(_feedbackHistory[index], theme),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyHistory(ThemeData theme) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CustomIconWidget(iconName: 'feedback', color: theme.colorScheme.onSurface.withOpacity(0.3), size: 64),
        const SizedBox(height: 12),
        Text('No Feedback History', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
        const SizedBox(height: 6),
        Text('Your submitted feedback will appear here', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.4))),
      ]),
    );
  }

  Widget _buildFeedbackHistoryItem(Map<String, dynamic> feedback, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(feedback['serviceTitle'] ?? 'Service', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: _getStatusColor((feedback['status'] ?? 'Reviewed')).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(feedback['status'] ?? 'Reviewed', style: theme.textTheme.bodySmall?.copyWith(color: _getStatusColor((feedback['status'] ?? 'Reviewed')), fontWeight: FontWeight.w500)))
        ]),
        const SizedBox(height: 8),
        Row(children: [
          StarRatingWidget(rating: (feedback['rating'] as num?)?.toDouble() ?? 0.0, onRatingChanged: (_) {}, size: 16, allowHalfRating: true),
          const SizedBox(width: 8),
          Text((feedback['rating'] ?? 0).toString(), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500))
        ]),
        const SizedBox(height: 8),
        Text(feedback['message'] ?? 'No message', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        Row(children: [
          Text('By: ${feedback['userName'] ?? 'User'}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w500)),
          const SizedBox(width: 12),
          Text('on ${feedback['submittedDate'] ?? feedback['submittedOn'] ?? 'Unknown date'}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)))
        ])
      ]),
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
