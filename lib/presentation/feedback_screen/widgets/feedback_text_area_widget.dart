import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FeedbackTextAreaWidget extends StatefulWidget {
  final String? initialText;
  final ValueChanged<String> onTextChanged;
  final int maxLength;
  final List<String> prompts;

  const FeedbackTextAreaWidget({
    super.key,
    this.initialText,
    required this.onTextChanged,
    this.maxLength = 500,
    this.prompts = const [
      'How was the resolution process?',
      'What could be improved?',
      'Rate your overall experience',
    ],
  });

  @override
  State<FeedbackTextAreaWidget> createState() => _FeedbackTextAreaWidgetState();
}

class _FeedbackTextAreaWidgetState extends State<FeedbackTextAreaWidget> {
  late TextEditingController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
    _controller.addListener(() {
      widget.onTextChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isExpanded
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: _isExpanded ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _controller.text.isEmpty
                        ? 'Share your detailed feedback...'
                        : _controller.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _controller.text.isEmpty
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                          : theme.colorScheme.onSurface,
                    ),
                    maxLines: _isExpanded ? null : 2,
                    overflow: _isExpanded ? null : TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 2.w),
                CustomIconWidget(
                  iconName: _isExpanded ? 'expand_less' : 'expand_more',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          SizedBox(height: 2.h),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  maxLines: 6,
                  maxLength: widget.maxLength,
                  decoration: InputDecoration(
                    hintText: 'Write your detailed feedback here...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(4.w),
                    counterStyle: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
                if (widget.prompts.isNotEmpty) ...[
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need inspiration? Try these prompts:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Wrap(
                          spacing: 2.w,
                          runSpacing: 1.h,
                          children: widget.prompts.map((prompt) {
                            return GestureDetector(
                              onTap: () => _insertPrompt(prompt),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  prompt,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _insertPrompt(String prompt) {
    final currentText = _controller.text;
    final newText =
        currentText.isEmpty ? '$prompt ' : '$currentText\n\n$prompt ';

    if (newText.length <= widget.maxLength) {
      _controller.text = newText;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: newText.length),
      );
    }
  }
}
