import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:signals/signals_flutter.dart';

@singleton
class SettingsService {
  final themeMode = signal(ThemeMode.system);

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
  }
}
