import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:podwave/core/storage/hive_initializer.dart';

final localeControllerProvider = StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController();
});

class LocaleController extends StateNotifier<Locale> {
  LocaleController() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  static const String _localeKey = 'app_locale';

  Future<void> _loadSavedLocale() async {
    final box = Hive.box<dynamic>(HiveBoxNames.settings);
    final savedLocale = box.get(_localeKey) as String?;
    if (savedLocale != null) {
      state = Locale(savedLocale);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final box = Hive.box<dynamic>(HiveBoxNames.settings);
    await box.put(_localeKey, locale.languageCode);
  }

  bool get isRtl => state.languageCode == 'ar';
}
