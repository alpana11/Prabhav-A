import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/api_service.dart';

class SetUsernameScreen extends StatefulWidget {
  final String aadhar;

  const SetUsernameScreen({Key? key, required this.aadhar}) : super(key: key);

  @override
  State<SetUsernameScreen> createState() => _SetUsernameScreenState();
}

class _SetUsernameScreenState extends State<SetUsernameScreen> {
  final _usernameController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAvailable = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _setUsername() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final username = _usernameController.text.trim();

      if (username.isEmpty) {
        throw Exception('Username cannot be empty');
      }
      if (username.length < 3) {
        throw Exception('Username must be at least 3 characters');
      }

      final result = await _apiService.setUsername(
        aadhar: widget.aadhar,
        username: username,
      );

      if (result['success']) {
        if (mounted) {
          // Navigate to home or permissions screen
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        }
      } else {
        setState(() => _errorMessage = result['message']);
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Username'),
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
              'Choose Your Username',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'This is your public profile name (can be changed later)',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 30.h),
            Text(
              'Username',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _usernameController,
              enabled: true,
              readOnly: false,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'e.g., john_doe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  _isAvailable ? Icons.check_circle : Icons.info,
                  color: _isAvailable ? Colors.green : Colors.grey,
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _isAvailable
                        ? 'Username is available'
                        : 'Enter a username (3+ characters)',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: _isAvailable ? Colors.green : Colors.grey[600],
                    ),
                  ),
                ),
              ],
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
              onPressed: (_isLoading || _usernameController.text.isEmpty)
                  ? null
                  : _setUsername,
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
                      'Complete Setup',
                      style: TextStyle(fontSize: 16.sp),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
