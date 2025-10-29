import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LanguageToggleWidget extends StatefulWidget {
  final Function(String) onLanguageChanged;
  final String currentLanguage;

  const LanguageToggleWidget({
    super.key,
    required this.onLanguageChanged,
    this.currentLanguage = 'English',
  });

  @override
  State<LanguageToggleWidget> createState() => _LanguageToggleWidgetState();
}

class _LanguageToggleWidgetState extends State<LanguageToggleWidget> {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLanguage,
          icon: CustomIconWidget(
            iconName: 'keyboard_arrow_down',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 4.w,
          ),
          items: const [
            DropdownMenuItem(
              value: 'English',
              child: Text('English'),
            ),
            DropdownMenuItem(
              value: 'हिंदी',
              child: Text('हिंदी'),
            ),
          ],
          onChanged: (String? newValue) {
            if (newValue != null && newValue != _selectedLanguage) {
              setState(() {
                _selectedLanguage = newValue;
              });
              widget.onLanguageChanged(newValue);

              // Show language change confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    newValue == 'English'
                        ? 'Language changed to English'
                        : 'भाषा हिंदी में बदल दी गई',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: AppTheme.lightTheme.colorScheme.surface,
        ),
      ),
    );
  }
}
