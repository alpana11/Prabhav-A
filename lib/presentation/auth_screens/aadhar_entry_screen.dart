import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/api_service.dart';
// ...existing code...

class AadharEntryScreen extends StatefulWidget {
  const AadharEntryScreen({Key? key}) : super(key: key);

  @override
  State<AadharEntryScreen> createState() => _AadharEntryScreenState();
}

class _AadharEntryScreenState extends State<AadharEntryScreen> {
  final _aadharController = TextEditingController();
  final _phoneController = TextEditingController();
  final _aadharFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _aadharController.dispose();
    _phoneController.dispose();
    _aadharFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final aadhar = _aadharController.text.replaceAll(' ', '');
      final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');

      // Validation
      if (aadhar.isEmpty || aadhar.length != 12) {
        throw Exception('Aadhar must be 12 digits');
      }
      if (phone.isEmpty || phone.length != 10) {
        throw Exception('Phone must be 10 digits');
      }

      // Call backend API to send OTP via SMS
      final apiService = ApiService();
      final result = await apiService.sendOtp(aadhar: aadhar, phone: phone);

      if (!result['success']) {
        throw Exception(result['message'] ?? 'Failed to send OTP');
      }

      print('[OTP_SEND] OTP sent via ${result['provider'] ?? 'SMS'} to +91$phone');

      // Navigate to OTP verification screen
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacementNamed(
          context,
          '/otp-verify',
          arguments: {
            'aadhar': aadhar,
            'phone': phone,
            'verificationId': null,
            'autoVerified': false,
            'useBackendOtp': true, // Flag to use backend OTP instead of Firebase
          },
        );
      }

    } catch (e) {
      print('[OTP_SEND_ERROR] Exception: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aadhar Verification'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 30.h),
            Text(
              'Enter Your Details',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Your Aadhar number and phone will be used for verification',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 30.h),
            Text(
              'Aadhar Number',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _aadharController,
              focusNode: _aadharFocusNode,
              enabled: !_isLoading,
              readOnly: false,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ],
              decoration: InputDecoration(
                hintText: '123456789012',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                counterText: '',
                errorText: (_errorMessage != null && (_aadharController.text.isEmpty || _aadharController.text.length != 12))
                    ? 'Aadhaar must be 12 digits'
                    : null,
              ),
              textInputAction: TextInputAction.next,
              onChanged: (value) {
                if (value.length == 12) {
                  FocusScope.of(context).requestFocus(_phoneFocusNode);
                }
              },
              onSubmitted: (_) {
                FocusScope.of(context).requestFocus(_phoneFocusNode);
              },
            ),
            SizedBox(height: 20.h),
            Text(
              'Phone Number',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                hintText: '9876543210',
                prefixText: '+91 ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                counterText: '',
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _sendOtp(),
            ),
            if (_errorMessage != null)
              Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border.all(color: Colors.red[300]!),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
            SizedBox(height: 30.h),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendOtp,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Send OTP',
                      style: TextStyle(fontSize: 16.sp),
                    ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(child: Divider(height: 1.h)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(child: Divider(height: 1.h)),
              ],
            ),
            SizedBox(height: 20.h),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Already have password? Login',
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
