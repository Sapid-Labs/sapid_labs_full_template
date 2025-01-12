import 'package:auto_route/auto_route.dart';
import 'package:foolscript/app/constants.dart';
import 'package:flutter/material.dart';
import 'package:foolscript/features/settings/services/settings_service.dart';
import 'package:signals/signals_flutter.dart';

@RoutePage()
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Theme Mode'),
            subtitle: Watch((context) {
              final mode = settingsThemeMode.value;
              return Text(mode.name.toUpperCase());
            }),
            trailing: Watch((context) {
              final mode = settingsThemeMode.value;
              return DropdownButton<ThemeMode>(
                value: mode,
                onChanged: (newMode) {
                  if (newMode != null) {
                    settingsThemeMode.value = newMode;
                  }
                },
                items: ThemeMode.values.map((mode) {
                  return DropdownMenuItem(
                    value: mode,
                    child: Text(mode.name.toUpperCase()),
                  );
                }).toList(),
              );
            }),
          ),
          gap16,
        ],
      ),
    );
  }
}