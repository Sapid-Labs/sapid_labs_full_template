import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:signals/signals_flutter.dart';

final settingsThemeMode = signal(ThemeMode.system);

@singleton
class SettingsService {
  void setThemeMode(ThemeMode mode) {
    settingsThemeMode.value = mode;
  }
}
