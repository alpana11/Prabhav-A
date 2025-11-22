import 'package:flutter/material.dart';

/// Stub widget to remove legacy references.
class TabSelectorWidget extends StatelessWidget {
  const TabSelectorWidget({super.key, this.isLoginSelected = true, this.onTabChanged});
  final bool isLoginSelected;
  final Function(bool)? onTabChanged;
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
