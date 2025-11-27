import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'app_config.dart';
import 'auth_service.dart';

class ApiService {
  static String get baseUrl => AppConfig.baseUrl;
  static const Duration apiTimeout = Duration(seconds: 60);

  // temp token storage
  static String? _tempToken;

  static String? get tempToken => _tempToken;

  Future<void> saveTempToken(String token) async {
    _tempToken = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("tempToken", token);
    } catch (_) {}
  }

  Future<void> loadTempTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString("tempToken");
    if (t != null && t.isNotEmpty) _tempToken = t;
  }

  Future<void> clearTempToken() async {
    _tempToken = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("tempToken");
  }

  /// ------------ POST ------------
  static Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    try {
      final uri = Uri.parse('$baseUrl$path');

      // ⭐ FIX: Use login token OR temp token
      final token = AuthService().token ?? _tempToken;

      final authHeaders =
          token != null ? {'Authorization': 'Bearer $token'} : {};

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              ...authHeaders,
              ...?headers
            },
            body: jsonEncode(body),
          )
          .timeout(apiTimeout);

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 400) {
        throw Exception(decoded['message'] ?? 'API Error');
      }

      return decoded;
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }

  /// ------------ GET ------------
  static Future<Map<String, dynamic>> get(String path,
      {Map<String, String>? headers}) async {
    try {
      final uri = Uri.parse('$baseUrl$path');

      // ⭐ FIX: Use login token OR temp token
      final token = AuthService().token ?? _tempToken;

      final authHeaders =
          token != null ? {'Authorization': 'Bearer $token'} : {};

      final response = await http
          .get(uri, headers: {...authHeaders, ...?headers})
          .timeout(apiTimeout);

      final decoded = jsonDecode(response.body);

      if (response.statusCode >= 400) {
        throw Exception(decoded['message'] ?? 'API Error');
      }

      return decoded;
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }
}
