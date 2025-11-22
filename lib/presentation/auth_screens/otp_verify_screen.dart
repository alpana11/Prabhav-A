import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String aadhar;
  final String phone;
  final String? verificationId;
  final bool autoVerified;
  final String? firebaseIdToken;
  final bool useBackendOtp;

  const OtpVerifyScreen({
    Key? key,
    required this.aadhar,
    required this.phone,
    this.verificationId,
    this.autoVerified = false,
    this.firebaseIdToken,
    this.useBackendOtp = false,
  }) : super(key: key);

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _otpController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // If already auto-verified, verify immediately
    if (widget.autoVerified && widget.firebaseIdToken != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _verifyWithToken(widget.firebaseIdToken!, widget.aadhar);
      });
    }
  }

  Future<void> _verifyBackendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final otp = _otpController.text.trim();

      // Strict validation: OTP must be exactly 6 digits
      if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
        throw Exception('OTP must be exactly 6 digits');
      }

      print('[OTP_VERIFY] Verifying OTP with backend for Aadhar: ${widget.aadhar}');
      final result = await _apiService.verifyOtp(
        aadhar: widget.aadhar,
        otp: otp,
      );

      print('[OTP_VERIFY] Backend response: $result');

      if (result['success'] && mounted) {
        // Save temp token if provided by backend
        if (result['tempToken'] != null) {
          await _apiService.saveTempToken(result['tempToken']);
        }
        // Navigate to set-password
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/set-password',
          (route) => false,
          arguments: {'aadhar': widget.aadhar},
        );
      } else if (mounted) {
        setState(() => _errorMessage = result['message'] ?? 'Invalid OTP');
      }
    } catch (e) {
      print('[OTP_VERIFY_ERROR] $e');
      if (mounted) {
        setState(() => _errorMessage = 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyWithToken(String idToken, String aadhar) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('[OTP_AUTO] Using pre-verified Firebase ID token');
      await _postIdTokenToBackend(idToken, aadhar);
    } catch (e) {
      print('[OTP_AUTO_ERROR] $e');
      if (mounted) {
        setState(() => _errorMessage = 'Auto-verification error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyOtp() async {
    // Use backend OTP verification if flag is set
    if (widget.useBackendOtp) {
      await _verifyBackendOtp();
      return;
    }

    // Otherwise use Firebase verification (fallback)
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final otp = _otpController.text.trim();

      // Strict validation: OTP must be exactly 6 digits
      if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
        throw Exception('OTP must be exactly 6 digits');
      }

      final verificationId = widget.verificationId;
      if (verificationId == null) {
        throw Exception('Verification ID missing - cannot verify OTP');
      }

      print('[OTP_VERIFY] Creating Firebase credential with SMS code: $otp');
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      print('[OTP_VERIFY] Signing in with Firebase credential');
      final userCred = await FirebaseAuth.instance.signInWithCredential(credential);

      final idToken = await userCred.user?.getIdToken();
      print('[OTP_VERIFY] Firebase sign-in successful, obtained ID Token: ${idToken?.substring(0, 20)}...');

      if (idToken == null) {
        throw Exception('Failed to obtain Firebase ID token after verification');
      }

      // POST ID token to backend for server-side verification and user linking
      await _postIdTokenToBackend(idToken, widget.aadhar);
    } catch (e) {
      print('[OTP_VERIFY_ERROR] $e');
      // Return exact Firebase error message - no fallback, no demo
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _postIdTokenToBackend(String idToken, String aadhar) async {
    try {
      print('[OTP_BACKEND] Posting Firebase ID token to backend verify-otp endpoint');
      final result = await _apiService.verifyOtp(
        aadhar: aadhar,
        firebaseIdToken: idToken,
      );

      print('[OTP_BACKEND] Backend response: $result');

      if (result['success'] && mounted) {
        // Save temp token if provided by backend
        if (result['tempToken'] != null) {
          await _apiService.saveTempToken(result['tempToken']);
        }
        // Navigate to set-password
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/set-password',
          (route) => false,
          arguments: {'aadhar': aadhar},
        );
      } else if (mounted) {
        setState(() => _errorMessage = result['message'] ?? 'Backend verification failed');
      }
    } catch (e) {
      print('[OTP_BACKEND_ERROR] $e');
      if (mounted) {
        setState(() => _errorMessage = 'Backend error: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
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
              'Enter OTP',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'We sent a 6-digit SMS to +91 ${widget.phone.substring(widget.phone.length - 4)}',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 30.h),
            if (widget.autoVerified)
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green[300]!),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Firebase auto-verified your SMS code. Verifying with backend...',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 12.sp,
                  ),
                ),
              )
            else
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.sp,
                  letterSpacing: 10.w,
                  fontWeight: FontWeight.bold,
                ),
                enabled: !_isLoading,
                readOnly: false,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  hintText: '000000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                  errorText: (_errorMessage != null && (_otpController.text.length != 6))
                      ? 'OTP must be 6 digits'
                      : null,
                ),
                onSubmitted: (_) => _verifyOtp(),
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
              onPressed: (widget.autoVerified || _isLoading) ? null : _verifyOtp,
              key: const Key('verify_otp_button'),
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
                      widget.autoVerified ? 'Verifying...' : 'Verify OTP',
                      style: TextStyle(fontSize: 16.sp),
                    ),
            ),
            if (!widget.autoVerified)
              Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Resend OTP feature coming soon')),
                      );
                    },
                    child: Text(
                      "Didn't receive code? Resend",
                      style: TextStyle(fontSize: 14.sp),
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

