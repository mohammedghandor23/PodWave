import 'package:flutter/material.dart';

class AppLocalizationsDelegate {
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  static const Locale fallbackLocale = Locale('en');

  static bool isRtl(Locale locale) => locale.languageCode == 'ar';
}
