// lib/providers/locale_provider.dart

import 'package:flutter/material.dart';
// Import your AppLocalizations helper to access supported locales
// Adjust the path based on where your app_string.dart is located
// If app_string.dart is in lib/services/, this path is correct:
import '../services/app_string.dart';

class LocaleProvider with ChangeNotifier {
  // --- Private Variable ---
  // Holds the current locale. Start with English as the default.
  Locale _locale = const Locale('en');

  // --- Getter ---
  // Allows other parts of the app to read the current locale.
  Locale get locale => _locale;

  // --- Setter Method ---
  // This is how you will change the language in your app (e.g., from a settings screen).
  void setLocale(Locale newLocale) {
    // 1. Check if the new locale is actually supported by your app.
    //    We use the delegate from AppLocalizations which knows the supported codes.
    if (!AppLocalizations.delegate.isSupported(newLocale)) {
      print(
          "LocaleProvider: Locale '${newLocale.languageCode}' is not supported.");
      return; // Do nothing if the language isn't supported
    }

    // 2. Check if the new locale is actually different from the current one.
    if (_locale == newLocale) {
      print(
          "LocaleProvider: Locale '${newLocale.languageCode}' is already selected.");
      return; // Do nothing if it's the same language
    }

    // 3. If it's different and supported, update the internal locale.
    _locale = newLocale;
    print("LocaleProvider: Locale changed to '${_locale.languageCode}'.");

    // 4. IMPORTANT: Notify all listeners (like MaterialApp) that the locale has changed.
    //    This triggers a rebuild where needed, applying the new language strings.
    notifyListeners();
  }

  // --- Optional: Helper to get current language name ---
  String get currentLanguageDisplayName {
    // You can expand this map if you add more languages
    final languageMap = {
      'en': 'English',
      'am': 'አማርኛ', // Amharic
    };
    return languageMap[_locale.languageCode] ??
        'English'; // Default to English name
  }
}
