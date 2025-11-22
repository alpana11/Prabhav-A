import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  Locale _locale = const Locale('en', 'US');
  Locale get locale => _locale;

  String get languageCode => _locale.languageCode;
  String get countryCode => _locale.countryCode ?? '';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language') ?? 'en';
    final savedCountry = prefs.getString('country') ?? 'US';
    _locale = Locale(savedLanguage, savedCountry);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode, {String? countryCode}) async {
    final prefs = await SharedPreferences.getInstance();
    _locale = Locale(languageCode, countryCode ?? '');
    await prefs.setString('language', languageCode);
    if (countryCode != null) {
      await prefs.setString('country', countryCode);
    }
    notifyListeners();
  }

  Future<void> setToEnglish() async {
    await setLanguage('en', countryCode: 'US');
  }

  Future<void> setToHindi() async {
    await setLanguage('hi', countryCode: 'IN');
  }

  bool get isEnglish => _locale.languageCode == 'en';
  bool get isHindi => _locale.languageCode == 'hi';
}
