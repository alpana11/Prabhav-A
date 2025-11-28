import 'package:flutter/material.dart';


class ThemeToggleWidget extends StatefulWidget {
  const ThemeToggleWidget({super.key});

  @override
  State<ThemeToggleWidget> createState() => _ThemeToggleWidgetState();
}

class _ThemeToggleWidgetState extends State<ThemeToggleWidget> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: isDark,
      onChanged: (value) {
        setState(() => isDark = value);
      },
    );
  }
}
