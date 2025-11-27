import 'package:flutter/material.dart';

extension ColorExtension on Color {
  /// Provides a shorthand used across the codebase: `.withValues(alpha: 0.5)`
  /// Maps to the standard `withOpacity` implementation.
  Color withValues({double? alpha}) {
    if (alpha == null) return this;
    return withOpacity(alpha.clamp(0.0, 1.0));
  }
}
