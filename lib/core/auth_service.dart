class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Simple in-memory token storage. This avoids a hard dependency on
  // `shared_preferences` so the project can be analyzed and compiled
  // before running `flutter pub get` locally. For production/demo builds
  // we recommend restoring persistence using `SharedPreferences`.
  String? _token;

  Future<void> init() async {
    // No-op for in-memory fallback. If you run `flutter pub get` and
    // want persistence, we can reimplement using SharedPreferences.
    return;
  }

  String? get token => _token;

  Future<void> setToken(String token) async {
    _token = token;
  }

  Future<void> clearToken() async {
    _token = null;
  }
}
