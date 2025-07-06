import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:signals/signals_flutter.dart';
import 'package:slapp/app/services.dart';

final settingsThemeMode = signal(settingsService.getThemeMode());

@singleton
class SettingsService {
  void setThemeMode(ThemeMode mode) {
    settingsThemeMode.value = mode;
    sharedPrefs.setString('settings_theme', mode.name);
  }

  ThemeMode getThemeMode() {
    String mode = sharedPrefs.getString('settings_theme') ?? '';

    return ThemeMode.values.firstWhereOrNull((e) => e.name == mode) ??
        ThemeMode.system;
  }
}
