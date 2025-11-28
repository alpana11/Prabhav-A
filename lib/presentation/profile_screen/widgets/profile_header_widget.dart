import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/theme_toggle_widget.dart';


import '../../../core/app_export.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onEditProfile;

  const ProfileHeaderWidget({
    super.key,
    required this.userData,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.onPrimary,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: (userData["avatar"] as String?) != null &&
                                (userData["avatar"] as String).isNotEmpty
                            ? CustomImageWidget(
                                imageUrl: userData["avatar"] as String,
                                width: 20.w,
                                height: 20.w,
                                fit: BoxFit.cover,
                                semanticLabel: userData["avatarSemanticLabel"] as String? ??
                                    "User profile photo",
                              )
                            : Container(
                                color: Colors.transparent,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.person,
                                  size: 12.w,
                                  color: colorScheme.onPrimary.withValues(alpha: 0.9),
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: onEditProfile,
                        child: Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: colorScheme.tertiary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.onPrimary,
                              width: 2,
                            ),
                          ),
                          child: CustomIconWidget(
                            iconName: 'edit',
                            color: colorScheme.onTertiary,
                            size: 3.w,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userData["name"] as String? ?? "User Name",
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'location_on',
                            color: colorScheme.onPrimary.withValues(alpha: 0.8),
                            size: 4.w,
                          ),
                          SizedBox(width: 1.w),
                          Expanded(
                            child: Text(
                              userData["location"] as String? ?? "Location",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimary
                                    .withValues(alpha: 0.8),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'email',
                            color: colorScheme.onPrimary.withValues(alpha: 0.8),
                            size: 4.w,
                          ),
                          SizedBox(width: 1.w),
                          Expanded(
                            child: Text(
                              userData["email"] as String? ??
                                  "email@example.com",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onPrimary
                                    .withValues(alpha: 0.8),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
