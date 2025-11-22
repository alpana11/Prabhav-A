import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';


class LanguageToggleWidget extends StatefulWidget {
  final Function(String) onLanguageChanged;
  final String currentLanguage;

  const LanguageToggleWidget({
    Key? key,
    required this.onLanguageChanged,
    this.currentLanguage = 'English',
  }) : super(key: key);

  @override
  State<LanguageToggleWidget> createState() => _LanguageToggleWidgetState();
}

class _LanguageToggleWidgetState extends State<LanguageToggleWidget> {
  late String _selectedLanguage;

  final List<String> _languages = ['English', 'Hindi'];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _languages.map((lang) {
        final bool isSelected = _selectedLanguage == lang;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: ChoiceChip(
            label: Text(lang),
            selected: isSelected,
            onSelected: (selected) {
              if (selected && !isSelected) {
                setState(() {
                  _selectedLanguage = lang;
                });
                widget.onLanguageChanged(lang);
              }
            },
            selectedColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        );
      }).toList(),
    );
  }
}

