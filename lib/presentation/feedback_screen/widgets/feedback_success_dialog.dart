import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FeedbackSuccessDialog extends StatelessWidget {
  final VoidCallback? onSharePressed;
  final VoidCallback? onClosePressed;

  const FeedbackSuccessDialog({
    super.key,
    this.onSharePressed,
    this.onClosePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'check_circle',
                color: Colors.green,
                size: 48,
              ),
            ),

            SizedBox(height: 3.h),

            // Title
            Text(
              'Thank You!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 1.h),

            // Message
            Text(
              'Your feedback has been submitted successfully. It helps us improve our services and serve you better.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 3.h),

            // Feedback Impact Info
            Container(
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
                  CustomIconWidget(
                    iconName: 'info',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Your feedback will be reviewed by our team and used to improve government services.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // Action Buttons
            Column(
              children: [
                // Share Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        onSharePressed ?? () => _shareExperience(context),
                    icon: CustomIconWidget(
                      iconName: 'share',
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text('Share Your Experience'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 2.h),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed:
                        onClosePressed ?? () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                    child: Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _shareExperience(BuildContext context) {
    // Close dialog first
    Navigator.of(context).pop();

    // Show share options
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _ShareOptionsBottomSheet(),
    );
  }
}

class _ShareOptionsBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          SizedBox(height: 3.h),

          Text(
            'Share Your Positive Experience',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 1.h),

          Text(
            'Help others by sharing your positive experience with government services',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4.h),

          // Share Options
          Column(
            children: [
              _buildShareOption(
                context,
                'WhatsApp',
                'whatsapp',
                Colors.green,
                () => _shareToWhatsApp(context),
              ),
              SizedBox(height: 2.h),
              _buildShareOption(
                context,
                'Twitter',
                'alternate_email',
                Colors.blue,
                () => _shareToTwitter(context),
              ),
              SizedBox(height: 2.h),
              _buildShareOption(
                context,
                'Facebook',
                'facebook',
                Colors.indigo,
                () => _shareToFacebook(context),
              ),
              SizedBox(height: 2.h),
              _buildShareOption(
                context,
                'Copy Link',
                'content_copy',
                theme.colorScheme.primary,
                () => _copyLink(context),
              ),
            ],
          ),

          SizedBox(height: 4.h),

          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Maybe Later'),
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context,
    String title,
    String iconName,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _shareToWhatsApp(BuildContext context) {
    Navigator.of(context).pop();
    _showShareSuccess(context, 'WhatsApp');
  }

  void _shareToTwitter(BuildContext context) {
    Navigator.of(context).pop();
    _showShareSuccess(context, 'Twitter');
  }

  void _shareToFacebook(BuildContext context) {
    Navigator.of(context).pop();
    _showShareSuccess(context, 'Facebook');
  }

  void _copyLink(BuildContext context) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Link copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showShareSuccess(BuildContext context, String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Shared to $platform successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
