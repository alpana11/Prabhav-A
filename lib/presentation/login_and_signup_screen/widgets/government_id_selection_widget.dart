import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

enum GovernmentIDType {
  aadhar,
  voterId,
  panCard,
}

class GovernmentIDSelectionWidget extends StatefulWidget {
  final Function(GovernmentIDType, String)? onIDVerified;
  final bool isLoading;

  const GovernmentIDSelectionWidget({
    super.key,
    this.onIDVerified,
    this.isLoading = false,
  });

  @override
  State<GovernmentIDSelectionWidget> createState() =>
      _GovernmentIDSelectionWidgetState();
}

class _GovernmentIDSelectionWidgetState
    extends State<GovernmentIDSelectionWidget> with TickerProviderStateMixin {
  GovernmentIDType? _selectedIDType;
  final _idNumberController = TextEditingController();
  bool _isVerifying = false;
  bool _isVerified = false;
  String? _verifiedIDNumber;

  late AnimationController _successController;
  late Animation<double> _successAnimation;

  @override
  void initState() {
    super.initState();

    _successController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _idNumberController.dispose();
    _successController.dispose();
    super.dispose();
  }

  String _getIDTypeName(GovernmentIDType type) {
    switch (type) {
      case GovernmentIDType.aadhar:
        return 'Aadhar Card';
      case GovernmentIDType.voterId:
        return 'Voter ID';
      case GovernmentIDType.panCard:
        return 'PAN Card';
    }
  }

  String _getIDTypeHint(GovernmentIDType type) {
    switch (type) {
      case GovernmentIDType.aadhar:
        return 'Enter 12-digit Aadhar number';
      case GovernmentIDType.voterId:
        return 'Enter Voter ID number';
      case GovernmentIDType.panCard:
        return 'Enter 10-character PAN number';
    }
  }

  String _getIDTypeIcon(GovernmentIDType type) {
    switch (type) {
      case GovernmentIDType.aadhar:
        return 'badge';
      case GovernmentIDType.voterId:
        return 'how_to_vote';
      case GovernmentIDType.panCard:
        return 'credit_card';
    }
  }

  List<TextInputFormatter> _getInputFormatters(GovernmentIDType type) {
    switch (type) {
      case GovernmentIDType.aadhar:
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(12),
        ];
      case GovernmentIDType.voterId:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
          LengthLimitingTextInputFormatter(20),
        ];
      case GovernmentIDType.panCard:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
          LengthLimitingTextInputFormatter(10),
          UpperCaseTextFormatter(),
        ];
    }
  }

  bool _validateIDNumber(String number, GovernmentIDType type) {
    switch (type) {
      case GovernmentIDType.aadhar:
        return number.length == 12 && RegExp(r'^\d{12}$').hasMatch(number);
      case GovernmentIDType.voterId:
        return number.length >= 8 && number.length <= 20;
      case GovernmentIDType.panCard:
        return number.length == 10 &&
            RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(number);
    }
  }

  Future<void> _verifyID() async {
    if (_selectedIDType == null ||
        !_validateIDNumber(_idNumberController.text, _selectedIDType!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Please enter a valid ${_getIDTypeName(_selectedIDType!)} number'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    // Simulate ID verification
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isVerifying = false;
      _isVerified = true;
      _verifiedIDNumber = _idNumberController.text;
    });

    // Trigger success animation
    _successController.forward();

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Notify parent
    widget.onIDVerified?.call(_selectedIDType!, _verifiedIDNumber!);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('${_getIDTypeName(_selectedIDType!)} verified successfully'),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isVerified
              ? AppTheme.lightTheme.colorScheme.tertiary
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: _isVerified ? 2 : 1,
        ),
        boxShadow: _isVerified
            ? [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.tertiary
                      .withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: _isVerified
                      ? AppTheme.lightTheme.colorScheme.tertiary
                      : AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _isVerified ? Icons.verified : Icons.verified_user,
                  color: _isVerified
                      ? Colors.white
                      : AppTheme.lightTheme.colorScheme.primary,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isVerified
                          ? 'Government ID Verified'
                          : 'Verify Government ID',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _isVerified
                            ? AppTheme.lightTheme.colorScheme.tertiary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    if (_isVerified && _verifiedIDNumber != null)
                      Text(
                        '${_getIDTypeName(_selectedIDType!)}: ${_verifiedIDNumber!.substring(0, 4)}****${_verifiedIDNumber!.substring(_verifiedIDNumber!.length - 4)}',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          if (!_isVerified) ...[
            // ID Type Selection
            Text(
              'Select your Government ID',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),

            SizedBox(height: 2.h),

            // ID Type Options
            ...GovernmentIDType.values.map((type) => _buildIDTypeOption(type)),

            SizedBox(height: 3.h),

            // ID Number Input
            if (_selectedIDType != null) ...[
              TextFormField(
                controller: _idNumberController,
                decoration: InputDecoration(
                  labelText: _getIDTypeName(_selectedIDType!),
                  hintText: _getIDTypeHint(_selectedIDType!),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: _getIDTypeIcon(_selectedIDType!),
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                      size: 5.w,
                    ),
                  ),
                ),
                inputFormatters: _getInputFormatters(_selectedIDType!),
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  setState(() {});
                },
              ),

              SizedBox(height: 3.h),

              // Verify Button
              SizedBox(
                height: 6.h,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyID,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isVerifying
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 4.w,
                              height: 4.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              'Verifying...',
                              style: AppTheme.lightTheme.textTheme.labelLarge
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified_user,
                              color: Colors.white,
                              size: 5.w,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              'Verify ${_getIDTypeName(_selectedIDType!)}',
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
          ] else ...[
            // Success State
            AnimatedBuilder(
              animation: _successAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.9 + (_successAnimation.value * 0.1),
                  child: Container(
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 5.w,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'ID Verified',
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
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIDTypeOption(GovernmentIDType type) {
    final isSelected = _selectedIDType == type;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIDType = type;
            _idNumberController.clear();
          });
          HapticFeedback.lightImpact();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
                : AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIDTypeIcon(type) == 'badge'
                      ? Icons.badge
                      : _getIDTypeIcon(type) == 'how_to_vote'
                          ? Icons.how_to_vote
                          : Icons.credit_card,
                  color: isSelected
                      ? Colors.white
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getIDTypeName(type),
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      _getIDTypeHint(type),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 5.w,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

