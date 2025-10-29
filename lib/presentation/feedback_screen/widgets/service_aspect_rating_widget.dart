import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import './star_rating_widget.dart';

class ServiceAspectRatingWidget extends StatefulWidget {
  final Map<String, double> initialRatings;
  final ValueChanged<Map<String, double>> onRatingsChanged;

  const ServiceAspectRatingWidget({
    super.key,
    this.initialRatings = const {},
    required this.onRatingsChanged,
  });

  @override
  State<ServiceAspectRatingWidget> createState() =>
      _ServiceAspectRatingWidgetState();
}

class _ServiceAspectRatingWidgetState extends State<ServiceAspectRatingWidget> {
  late Map<String, double> _ratings;

  final List<Map<String, dynamic>> _aspects = [
    {
      'key': 'response_time',
      'title': 'Response Time',
      'description': 'How quickly was your complaint addressed?',
      'icon': 'schedule',
    },
    {
      'key': 'communication_quality',
      'title': 'Communication Quality',
      'description': 'How clear and helpful was the communication?',
      'icon': 'chat',
    },
    {
      'key': 'resolution_effectiveness',
      'title': 'Resolution Effectiveness',
      'description': 'How well was your issue resolved?',
      'icon': 'check_circle',
    },
  ];

  @override
  void initState() {
    super.initState();
    _ratings = Map.from(widget.initialRatings);

    // Initialize with default ratings if not provided
    for (final aspect in _aspects) {
      _ratings.putIfAbsent(aspect['key'], () => 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'rate_review',
              color: theme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Rate Service Aspects',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: _aspects.asMap().entries.map((entry) {
              final index = entry.key;
              final aspect = entry.value;
              final isLast = index == _aspects.length - 1;

              return _buildAspectRating(aspect, isLast, theme);
            }).toList(),
          ),
        ),
        SizedBox(height: 2.h),
        _buildOverallSummary(theme),
      ],
    );
  }

  Widget _buildAspectRating(
      Map<String, dynamic> aspect, bool isLast, ThemeData theme) {
    final rating = _ratings[aspect['key']] ?? 0.0;

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
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
                  iconName: aspect['icon'],
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aspect['title'],
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      aspect['description'],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: StarRatingWidget(
                  rating: rating,
                  onRatingChanged: (newRating) =>
                      _updateRating(aspect['key'], newRating),
                  size: 28,
                  allowHalfRating: true,
                ),
              ),
              SizedBox(width: 3.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getRatingColor(rating).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getRatingText(rating),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getRatingColor(rating),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (!isLast) ...[
            SizedBox(height: 2.h),
            Divider(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              height: 1,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverallSummary(ThemeData theme) {
    final averageRating = _calculateAverageRating();
    final totalRatings = _ratings.values.where((rating) => rating > 0).length;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: 'analytics',
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Service Rating',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    StarRatingWidget(
                      rating: averageRating,
                      onRatingChanged: (_) {},
                      size: 20,
                      allowHalfRating: true,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '($totalRatings/3 aspects)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateRating(String aspectKey, double rating) {
    setState(() {
      _ratings[aspectKey] = rating;
    });
    widget.onRatingsChanged(_ratings);
  }

  double _calculateAverageRating() {
    final validRatings = _ratings.values.where((rating) => rating > 0).toList();
    if (validRatings.isEmpty) return 0.0;

    final sum = validRatings.reduce((a, b) => a + b);
    return sum / validRatings.length;
  }

  String _getRatingText(double rating) {
    if (rating == 0) return 'Not Rated';
    if (rating <= 1.5) return 'Poor';
    if (rating <= 2.5) return 'Fair';
    if (rating <= 3.5) return 'Good';
    if (rating <= 4.5) return 'Very Good';
    return 'Excellent';
  }

  Color _getRatingColor(double rating) {
    if (rating == 0) return Colors.grey;
    if (rating <= 2) return Colors.red;
    if (rating <= 3) return Colors.orange;
    if (rating <= 4) return Colors.blue;
    return Colors.green;
  }
}
