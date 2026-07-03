import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Nadpisywany w [main] realną instancją [SharedPreferences] po jej wczytaniu.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  );
});

/// Reaktywne ustawienia aplikacji: motyw + język.
/// [locale] == null oznacza "język systemu".
@immutable
class AppSettings {
  final ThemeMode themeMode;
  final Locale? locale;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool resetLocale = false,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: resetLocale ? null : (locale ?? this.locale),
    );
  }
}

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._prefs) : super(const AppSettings()) {
    _load();
  }

  final SharedPreferences _prefs;

  static const _themeKey = 'theme_mode';
  static const _localeKey = 'locale';

  void _load() {
    final themeName = _prefs.getString(_themeKey);
    final localeCode = _prefs.getString(_localeKey);
    state = AppSettings(
      themeMode: _themeFromString(themeName),
      locale: _localeFromCode(localeCode),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _prefs.setString(_themeKey, mode.name);
  }

  /// [locale] == null ustawia język systemu.
  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      state = state.copyWith(resetLocale: true);
      await _prefs.remove(_localeKey);
    } else {
      state = state.copyWith(locale: locale);
      await _prefs.setString(_localeKey, locale.languageCode);
    }
  }

  static ThemeMode _themeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static Locale? _localeFromCode(String? code) {
    if (code == null || code.isEmpty) return null;
    return Locale(code);
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AppSettings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsController(prefs);
});
