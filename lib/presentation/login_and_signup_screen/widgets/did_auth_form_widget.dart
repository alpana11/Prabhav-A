// did_auth_form_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import 'government_id_selection_widget.dart';

class DIDAuthFormWidget extends StatefulWidget {
  final bool isLogin;
  final bool isLoading;
  final VoidCallback? onSubmit;
  final Function(GovernmentIDType, String)? onIDVerified;
  final Function(String, String)? onUsernamePasswordSet;

  const DIDAuthFormWidget({
    super.key,
    required this.isLogin,
    this.isLoading = false,
    this.onSubmit,
    this.onIDVerified,
    this.onUsernamePasswordSet,
  });

  @override
  State<DIDAuthFormWidget> createState() => _DIDAuthFormWidgetState();
}

class _DIDAuthFormWidgetState extends State<DIDAuthFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _isFormValid = false;
  bool _isIDVerified = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _validateForm() {
    bool isValid = _usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty;

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Username is required';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }

  /// Called when GovernmentIDSelectionWidget says ID is verified.
  /// We set local flag and call parent's onIDVerified callback.
  void _handleIDVerified(GovernmentIDType idType, String idNumber) {
    setState(() {
      _isIDVerified = true;
    });

    widget.onIDVerified?.call(idType, idNumber);

    // If this is create-account mode, we show the username/password UI.
    // We DO NOT force navigation here; parent (LoginAndSignupScreen) may navigate immediately.
    // But to keep widget usable standalone, we focus the username field so user can continue.
    if (!widget.isLogin) {
      // give the UI a short delay then focus username
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _usernameFocusNode.requestFocus();
      });
    }
  }

  void _proceedToUsernamePasswordSetup() {
    if (_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      widget.onUsernamePasswordSet?.call(_usernameController.text.trim(), _passwordController.text.trim());
    }
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit?.call();
    }
  }

  void _handleCreateAccount() {
    if (_isIDVerified && _formKey.currentState!.validate()) {
      _proceedToUsernamePasswordSetup();
    } else {
      // if not verified, show helpful message
      if (!_isIDVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please verify your Government ID first')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // LOGIN MODE: Always show username/password fields with the action button above
    if (widget.isLogin) {
      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 3.h),

            // Sign In Button (above fields)
            SizedBox(
              height: 6.h,
              child: ElevatedButton(
                onPressed: _isFormValid && !widget.isLoading ? _handleLogin : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: widget.isLoading
                    ? SizedBox(
                        height: 5.w,
                        width: 5.w,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                    : Text(
                        'Sign In',
                        style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
              ),
            ),

            SizedBox(height: 4.h),

            // Username
            TextFormField(
              controller: _usernameController,
              focusNode: _usernameFocusNode,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Enter your username',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(iconName: 'person', color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6), size: 5.w),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.lightTheme.colorScheme.primary, width: 2),
                ),
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              enableSuggestions: false,
              validator: _validateUsername,
              onChanged: (v) => _validateForm(),
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
            ),

            SizedBox(height: 3.h),

            // Password
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(iconName: 'lock', color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6), size: 5.w),
                ),
                suffixIcon: IconButton(
                  icon: CustomIconWidget(iconName: _obscurePassword ? 'visibility' : 'visibility_off', color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6), size: 5.w),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.lightTheme.colorScheme.primary, width: 2)),
              ),
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              enableSuggestions: false,
              validator: _validatePassword,
              onChanged: (v) => _validateForm(),
              onFieldSubmitted: (_) => _handleLogin(),
            ),
          ],
        ),
      );
    }

    // CREATE ACCOUNT MODE
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // If not verified, show Government ID flow widget.
          if (!_isIDVerified)
            GovernmentIDSelectionWidget(
              onIDVerified: (t, num) => _handleIDVerified(t, num),
              isLoading: widget.isLoading,
            ),

          // After verification show username/password fields (and Continue button above them)
          if (_isIDVerified) ...[
            // Continue button above fields (Create Account action)
            SizedBox(
              height: 6.h,
              child: ElevatedButton(
                onPressed: (_isFormValid && _isIDVerified) && !widget.isLoading ? _handleCreateAccount : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: widget.isLoading
                    ? SizedBox(
                        height: 5.w,
                        width: 5.w,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 5.w),
                          SizedBox(width: 3.w),
                          Text('Continue', style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            ),

            SizedBox(height: 4.h),

            // Username field
            TextFormField(
              controller: _usernameController,
              focusNode: _usernameFocusNode,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Enter your username',
                prefixIcon: Padding(padding: EdgeInsets.all(3.w), child: CustomIconWidget(iconName: 'person', color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6), size: 5.w)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.lightTheme.colorScheme.primary, width: 2)),
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              enableSuggestions: false,
              validator: _validateUsername,
              onChanged: (v) => _validateForm(),
              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
            ),

            SizedBox(height: 3.h),

            // Password field
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Padding(padding: EdgeInsets.all(3.w), child: CustomIconWidget(iconName: 'lock', color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6), size: 5.w)),
                suffixIcon: IconButton(icon: CustomIconWidget(iconName: _obscurePassword ? 'visibility' : 'visibility_off', color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6), size: 5.w), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.lightTheme.colorScheme.primary, width: 2)),
              ),
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              enableSuggestions: false,
              validator: _validatePassword,
              onChanged: (v) => _validateForm(),
              onFieldSubmitted: (_) => _handleCreateAccount(),
            ),
          ],
        ],
      ),
    );
  }
}


