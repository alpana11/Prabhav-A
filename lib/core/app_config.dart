class AppConfig {
  // Toggle to use real backend API. Set to true for integrated demo.
  static const bool useRealApi = true;
  // Change baseUrl based on where you're running from:
  // - Desktop/Emulator: http://127.0.0.1:4000/api
  // - Physical mobile on LAN: http://192.168.29.50:4000/api (your PC's IP)
  static const String baseUrl = "http://10.227.94.92:5000/api";
}
