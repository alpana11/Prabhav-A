import 'package:flutter/material.dart';

/// Stub widget to remove legacy references.
class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key, this.size, this.showTagline = true});
  final double? size;
  final bool showTagline;
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
