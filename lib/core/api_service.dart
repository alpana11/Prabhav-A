import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'app_config.dart';
import 'auth_service.dart';

class ApiService {
  static String get baseUrl => AppConfig.baseUrl;
  static const Duration apiTimeout = Duration(seconds: 90);

  // In-memory temp token (keeps available synchronously)
  static String? _tempToken;

  /// Synchronous getter for in-memory temp token (may be null)
  static String? get tempToken => _tempToken;

  /// Save temp token (in-memory + SharedPreferences)
  Future<void> saveTempToken(String token) async {
    _tempToken = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tempToken', token);
    } catch (e) {
      // ignore errors for prefs but keep in-memory token
      print('[ApiService] saveTempToken prefs error: $e');
    }
  }

  /// Load token from SharedPreferences into memory (call during app init if needed)
  Future<void> loadTempTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('tempToken');
      if (stored != null && stored.isNotEmpty) {
        _tempToken = stored;
      }
    } catch (e) {
      print('[ApiService] loadTempTokenFromStorage error: $e');
    }
  }

  /// Clear temp token (both memory + storage)
  Future<void> clearTempToken() async {
    _tempToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('tempToken');
    } catch (e) {
      print('[ApiService] clearTempToken prefs error: $e');
    }
  }

  static Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body, {Map<String, String>? headers}) async {
    if (!AppConfig.useRealApi) {
      throw Exception('Real API disabled');
    }
    try {
      final uri = Uri.parse('$baseUrl$path');
      final token = AuthService().token; // regular auth token (if logged in)
      final authHeaders = token != null ? {'Authorization': 'Bearer $token'} : {};

      final response = await http
          .post(uri, headers: {'Content-Type': 'application/json', ...authHeaders, ...?headers}, body: jsonEncode(body))
          .timeout(apiTimeout);

      if (response.statusCode >= 400) {
        try {
          final error = jsonDecode(response.body) as Map<String, dynamic>;
          throw Exception(error['message'] ?? 'API Error: ${response.statusCode}');
        } catch (e) {
          throw Exception('API Error: ${response.statusCode} - ${response.body}');
        }
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> get(String path, {Map<String, String>? headers}) async {
    if (!AppConfig.useRealApi) {
      throw Exception('Real API disabled');
    }
    try {
      final uri = Uri.parse('$baseUrl$path');
      final token = AuthService().token;
      final authHeaders = token != null ? {'Authorization': 'Bearer $token'} : {};
      final response = await http.get(uri, headers: {...authHeaders, ...?headers}).timeout(apiTimeout);

      if (response.statusCode >= 400) {
        try {
          final error = jsonDecode(response.body) as Map<String, dynamic>;
          throw Exception(error['message'] ?? 'API Error: ${response.statusCode}');
        } catch (e) {
          throw Exception('API Error: ${response.statusCode} - ${response.body}');
        }
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}
