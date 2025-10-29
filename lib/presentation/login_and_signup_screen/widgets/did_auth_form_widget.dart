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
    super.dispose();
  }

  void _validateForm() {
    bool isValid = _usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  void _handleIDVerified(GovernmentIDType idType, String idNumber) {
    setState(() {
      _isIDVerified = true;
    });

    widget.onIDVerified?.call(idType, idNumber);

    // If this is create account flow, proceed to username/password setup
    if (!widget.isLogin && _isIDVerified) {
      _proceedToUsernamePasswordSetup();
    }
  }

  void _proceedToUsernamePasswordSetup() {
    if (_usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      widget.onUsernamePasswordSet?.call(
        _usernameController.text,
        _passwordController.text,
      );
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
    }
  }

  String _getButtonText() {
    if (widget.isLogin) {
      return 'Sign In';
    } else {
      return _isIDVerified ? 'Continue' : 'Verify Government ID';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Government ID verification section (only for create account)
          if (!widget.isLogin && !_isIDVerified)
            GovernmentIDSelectionWidget(
              onIDVerified: _handleIDVerified,
              isLoading: widget.isLoading,
            ),

          // Show username/password fields after ID verification or for login
          if (widget.isLogin || _isIDVerified) ...[
            SizedBox(height: 3.h),

            // Username Field
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Enter your username',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'person',
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                    size: 5.w,
                  ),
                ),
              ),
              textInputAction: TextInputAction.next,
              validator: _validateUsername,
              onChanged: (value) => _validateForm(),
            ),

            SizedBox(height: 3.h),

            // Password Field
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'lock',
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                    size: 5.w,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: CustomIconWidget(
                    iconName:
                        _obscurePassword ? 'visibility' : 'visibility_off',
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                    size: 5.w,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              validator: _validatePassword,
              onChanged: (value) => _validateForm(),
            ),

            SizedBox(height: 4.h),

            // Submit Button
            SizedBox(
              height: 6.h,
              child: ElevatedButton(
                onPressed: (_isFormValid || _isIDVerified) && !widget.isLoading
                    ? (widget.isLogin ? _handleLogin : _handleCreateAccount)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: widget.isLoading
                    ? SizedBox(
                        height: 5.w,
                        width: 5.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isIDVerified && !widget.isLogin)
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 5.w,
                            ),
                          if (_isIDVerified && !widget.isLogin)
                            SizedBox(width: 3.w),
                          Text(
                            _getButtonText(),
                            style: AppTheme.lightTheme.textTheme.labelLarge
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
