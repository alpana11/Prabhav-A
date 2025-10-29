import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StarRatingWidget extends StatefulWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;
  final double size;
  final bool allowHalfRating;
  final Color? activeColor;
  final Color? inactiveColor;

  const StarRatingWidget({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.size = 32.0,
    this.allowHalfRating = true,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  double _currentRating = 0.0;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor =
        widget.activeColor ?? AppTheme.lightTheme.colorScheme.tertiary;
    final inactiveColor = widget.inactiveColor ?? theme.colorScheme.outline;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => _handleTap(index + 1.0),
          onPanUpdate: (details) => _handlePanUpdate(details, index),
          child: Container(
            padding: EdgeInsets.all(1.w),
            child: CustomIconWidget(
              iconName: _getStarIcon(index + 1),
              color: _getStarColor(index + 1, activeColor, inactiveColor),
              size: widget.size,
            ),
          ),
        );
      }),
    );
  }

  String _getStarIcon(int starIndex) {
    if (_currentRating >= starIndex) {
      return 'star';
    } else if (widget.allowHalfRating && _currentRating >= starIndex - 0.5) {
      return 'star_half';
    } else {
      return 'star_border';
    }
  }

  Color _getStarColor(int starIndex, Color activeColor, Color inactiveColor) {
    if (_currentRating >= starIndex) {
      return activeColor;
    } else if (widget.allowHalfRating && _currentRating >= starIndex - 0.5) {
      return activeColor;
    } else {
      return inactiveColor;
    }
  }

  void _handleTap(double rating) {
    setState(() {
      _currentRating = rating;
    });
    widget.onRatingChanged(rating);
  }

  void _handlePanUpdate(DragUpdateDetails details, int starIndex) {
    if (!widget.allowHalfRating) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final starWidth = widget.size + (2.w);
    final starPosition = localPosition.dx - (starIndex * starWidth);

    double rating;
    if (starPosition < starWidth / 2) {
      rating = starIndex + 0.5;
    } else {
      rating = starIndex + 1.0;
    }

    rating = rating.clamp(0.5, 5.0);

    if (rating != _currentRating) {
      setState(() {
        _currentRating = rating;
      });
      widget.onRatingChanged(rating);
    }
  }
}
