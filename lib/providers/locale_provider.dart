import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _prefKey = 'app_language_code';

  Locale _locale = const Locale('en');

  LocaleProvider() {
    _loadSavedLocale();
  }

  Locale get locale => _locale;
  bool get isMarathi => _locale.languageCode == 'mr';

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefKey);
      if (savedCode != null && (savedCode == 'en' || savedCode == 'mr')) {
        _locale = Locale(savedCode);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading saved locale: $e");
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (!['en', 'mr'].contains(newLocale.languageCode)) return;
    if (_locale == newLocale) return;

    _locale = newLocale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, newLocale.languageCode);
    } catch (e) {
      debugPrint("Error saving locale: $e");
    }
  }

  Future<void> setLanguageCode(String code) async {
    await setLocale(Locale(code));
  }

  Future<void> toggleLanguage() async {
    if (isMarathi) {
      await setLocale(const Locale('en'));
    } else {
      await setLocale(const Locale('mr'));
    }
  }
}
