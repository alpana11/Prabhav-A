import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/user_data_service.dart';
import './widgets/did_auth_form_widget.dart';
import './widgets/did_illustration_widget.dart';
import './widgets/government_id_selection_widget.dart';
import './widgets/language_toggle_widget.dart';
import './widgets/logo_widget.dart';
import './widgets/tab_selector_widget.dart';
import './set_username_password_screen.dart';
import '../../theme/app_theme.dart';

class LoginAndSignupScreen extends StatefulWidget {
  const LoginAndSignupScreen({super.key});

  @override
  State<LoginAndSignupScreen> createState() => _LoginAndSignupScreenState();
}

class _LoginAndSignupScreenState extends State<LoginAndSignupScreen>
    with TickerProviderStateMixin {
  bool _isLoginSelected = true;
  bool _isLoading = false;
  String _currentLanguage = 'English';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTabChange(bool isLogin) {
    if (_isLoginSelected != isLogin) {
      setState(() {
        _isLoginSelected = isLogin;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _handleLanguageChange(String language) {
    setState(() {
      _currentLanguage = language;
    });
  }

  Future<void> _handleAuthentication() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate authentication delay
    await Future.delayed(const Duration(seconds: 2));

    // Save a minimal user record (in real app populate with real response)
    UserDataService().setUserData(
      username: 'Demo User',
      governmentIdType: 'Aadhar Card',
      governmentIdNumber: '123456789012',
    );

    setState(() {
      _isLoading = false;
    });

    HapticFeedback.mediumImpact();

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home-dashboard',
      (route) => false,
    );
  }

  void _handleIDVerified(GovernmentIDType idType, String idNumber) {
    HapticFeedback.lightImpact();

    UserDataService().setUserData(
      username: UserDataService().username ?? '',
      governmentIdType: idType == GovernmentIDType.aadhar
          ? 'Aadhar Card'
          : idType == GovernmentIDType.voterId
              ? 'Voter ID'
              : 'PAN Card',
      governmentIdNumber: idNumber,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetUsernamePasswordScreen(
          connectedDID: 'Government ID verified',
        ),
      ),
    );
  }

  void _handleUsernamePasswordSet(String username, String password) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetUsernamePasswordScreen(
          connectedDID: 'Government ID verified',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
                    AppTheme.lightTheme.scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),

            Positioned(
              top: 2.h,
              right: 4.w,
              child: LanguageToggleWidget(
                currentLanguage: _currentLanguage,
                onLanguageChanged: _handleLanguageChange,
              ),
            ),

            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 8.h),

                      const Center(child: LogoWidget(showTagline: true)),

                      SizedBox(height: 4.h),

                      const Center(child: DIDIllustrationWidget(size: 18, animate: true)),

                      SizedBox(height: 4.h),

                      TabSelectorWidget(
                        isLoginSelected: _isLoginSelected,
                        onTabChanged: _handleTabChange,
                      ),

                      SizedBox(height: 4.h),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: DIDAuthFormWidget(
                          key: ValueKey(_isLoginSelected),
                          isLogin: _isLoginSelected,
                          isLoading: _isLoading,
                          onSubmit: _handleAuthentication,
                          onIDVerified: _handleIDVerified,
                          onUsernamePasswordSet: _handleUsernamePasswordSet,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      Center(
                        child: Text(
                          _currentLanguage == 'English'
                              ? 'For transparency and secure participation, every user must sign in using a verified Government ID.'
                              : 'पारदर्शिता और सुरक्षित भागीदारी के लिए, प्रत्येक उपयोगकर्ता को एक सत्यापित सरकारी पहचान पत्र का उपयोग करके साइन इन करना होगा।',
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: 3.h),

                      if (_isLoginSelected) ...[
                        Row(
                          children: [
                            Expanded(child: Divider(color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3))),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Text(
                                _currentLanguage == 'English' ? 'OR' : 'या',
                                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3))),
                          ],
                        ),
                        SizedBox(height: 3.h),
                        SizedBox(
                          height: 6.h,
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _isLoginSelected = false;
                              });
                              HapticFeedback.lightImpact();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppTheme.lightTheme.colorScheme.primary, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_add, color: AppTheme.lightTheme.colorScheme.primary, size: 5.w),
                                SizedBox(width: 3.w),
                                Text(
                                  _currentLanguage == 'English' ? 'Create an Account' : 'खाता बनाएं',
                                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      if (!_isLoginSelected) ...[
                        SizedBox(height: 3.h),
                        Row(
                          children: [
                            Expanded(child: Divider(color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3))),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Text(
                                _currentLanguage == 'English' ? 'OR' : 'या',
                                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3))),
                          ],
                        ),
                        SizedBox(height: 3.h),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _isLoginSelected = true;
                              });
                              HapticFeedback.lightImpact();
                            },
                            child: RichText(
                              text: TextSpan(
                                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                                children: [
                                  TextSpan(text: _currentLanguage == 'English' ? 'Already have an account? ' : 'पहले से खाता है? '),
                                  TextSpan(
                                    text: _currentLanguage == 'English' ? 'Sign In' : 'साइन इन करें',
                                    style: TextStyle(color: AppTheme.lightTheme.colorScheme.primary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
