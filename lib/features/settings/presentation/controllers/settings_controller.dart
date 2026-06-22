import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:podwave/core/storage/hive_initializer.dart';

/// Resume playback modes for saved positions
enum ResumeMode {
  /// Always prompt user to resume or start over
  prompt,
  /// Automatically resume from saved position
  auto,
}

final settingsControllerProvider = StateNotifierProvider<SettingsController, SettingsState>((ref) {
  return SettingsController();
});

class SettingsState {
  final ResumeMode resumeMode;
  final Locale locale;

  const SettingsState({
    this.resumeMode = ResumeMode.prompt,
    this.locale = const Locale('en'),
  });

  SettingsState copyWith({
    ResumeMode? resumeMode,
    Locale? locale,
  }) {
    return SettingsState(
      resumeMode: resumeMode ?? this.resumeMode,
      locale: locale ?? this.locale,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController() : super(const SettingsState()) {
    _loadSettings();
  }

  static const String _resumeModeKey = 'resume_mode';
  static const String _localeKey = 'app_locale';

  Future<void> _loadSettings() async {
    final box = Hive.box<dynamic>(HiveBoxNames.settings);
    final savedMode = box.get(_resumeModeKey) as String?;
    final savedLocale = box.get(_localeKey) as String? ?? 'en';

    final resumeMode = ResumeMode.values.firstWhere(
      (e) => e.name == savedMode,
      orElse: () => ResumeMode.prompt,
    );

    state = state.copyWith(
      resumeMode: resumeMode,
      locale: Locale(savedLocale),
    );
  }

  Future<void> setResumeMode(ResumeMode mode) async {
    state = state.copyWith(resumeMode: mode);
    final box = Hive.box<dynamic>(HiveBoxNames.settings);
    await box.put(_resumeModeKey, mode.name);
  }

  Future<void> setLocale(Locale locale) async {
    state = state.copyWith(locale: locale);
    final box = Hive.box<dynamic>(HiveBoxNames.settings);
    await box.put(_localeKey, locale.languageCode);
  }

  bool get isRtl => state.locale.languageCode == 'ar';

  /// Whether resume functionality is enabled (always true now, controlled by mode)
  bool get resumeEnabled => true;
}
