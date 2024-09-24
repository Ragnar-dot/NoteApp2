import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = Locale('de');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!supportedLocales.contains(locale)) return;
    _locale = locale;
    notifyListeners();
  }

  void clearLocale() {
    _locale = Locale('de');
    notifyListeners();
  }

  static const supportedLocales = [
    Locale('en', ''),
    Locale('de', ''),
    Locale('pl', ''),
    Locale('ru', ''),
    // Weitere Sprachen hinzufügen
  ];
}