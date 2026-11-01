
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

final themeProvider =
    NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);

class ThemeController extends Notifier<ThemeMode> {
  late Box _settingsBox;

  @override
  ThemeMode build() {
    _settingsBox = Hive.box('shopmate_settings');

    final savedTheme = _settingsBox.get('themeMode', defaultValue: 'system');

    switch (savedTheme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> changeTheme(ThemeMode mode) async {
    state = mode;

    await _settingsBox.put(
      'themeMode',
      mode.name,
    );
  }
}
