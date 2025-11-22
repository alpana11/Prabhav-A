import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config/api_constants.dart';


class ApiService {
  static const String _baseUrl = ApiConstants.baseUrl;
  static const String _tokenKey = 'auth_token';
  static const Duration _defaultTimeout = Duration(minutes: 2);

  final _secureStorage = const FlutterSecureStorage();

  // Auth endpoints
  Future<Map<String, dynamic>> sendOtp({
    required String aadhar,
    String? phone,
  }) async {
    try {
      final body = <String, dynamic>{'aadhar': aadhar};
      if (phone != null) body['phone'] = phone;

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(_defaultTimeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data;
      }
      return data; // Return error response from backend
    } catch (e) {
      throw Exception('Error sending OTP: $e');
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String aadhar,
    String? otp,
    String? firebaseIdToken,
  }) async {
    try {
      final body = <String, dynamic>{'aadhar': aadhar};
      if (otp != null) body['otp'] = otp;
      if (firebaseIdToken != null) body['idToken'] = firebaseIdToken;

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(_defaultTimeout);

      final data = jsonDecode(response.body);
      if (data['tempToken'] != null) {
        await _secureStorage.write(key: 'temp_token', value: data['tempToken']);
      }
      return data;
    } catch (e) {
      throw Exception('Error verifying OTP: $e');
    }
  }

  Future<Map<String, dynamic>> setPassword({
    required String aadhar,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final tempToken = await _secureStorage.read(key: 'temp_token');
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/set-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tempToken',
        },
        body: jsonEncode({
          'aadhar': aadhar,
          'password': password,
          'confirmPassword': confirmPassword,
        }),
      ).timeout(_defaultTimeout);

      await _secureStorage.delete(key: 'temp_token');
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error setting password: $e');
    }
  }

  Future<Map<String, dynamic>> setUsername({
    required String aadhar,
    required String username,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/set-username'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'aadhar': aadhar, 'username': username}),
      ).timeout(_defaultTimeout);

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error setting username: $e');
    }
  }

  Future<Map<String, dynamic>> login({
    String? aadhar,
    String? username,
    String? mobile,
    required String password,
  }) async {
    try {
      final body = <String, dynamic>{'password': password};
      if (aadhar != null) body['aadhar'] = aadhar;
      if (username != null) body['username'] = username;
      if (mobile != null) body['mobile'] = mobile;

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(_defaultTimeout);

      final data = jsonDecode(response.body);
      if (data['success'] && data['token'] != null) {
        await saveToken(data['token']);
      }
      return data;
    } catch (e) {
      throw Exception('Error logging in: $e');
    }
  }

  // User endpoints
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/user/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(_defaultTimeout);

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
    String? address,
    double? accuracy,
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/user/location'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
          'accuracy': accuracy,
        }),
      ).timeout(_defaultTimeout);

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error updating location: $e');
    }
  }

  Future<Map<String, dynamic>> updatePermissions({
    String? location,
    String? camera,
    String? microphone,
    String? gallery,
    String? files,
  }) async {
    try {
      final token = await getToken();
      final data = <String, dynamic>{};
      if (location != null) data['location'] = location;
      if (camera != null) data['camera'] = camera;
      if (microphone != null) data['microphone'] = microphone;
      if (gallery != null) data['gallery'] = gallery;
      if (files != null) data['files'] = files;

      final response = await http.post(
        Uri.parse('$_baseUrl/user/permissions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error updating permissions: $e');
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/test/status'),
      ).timeout(const Duration(seconds: 10));

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error checking health: $e');
    }
  }

  // Token management
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<void> saveTempToken(String token) async {
    await _secureStorage.write(key: 'temp_token', value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: 'temp_token');
  }
}
