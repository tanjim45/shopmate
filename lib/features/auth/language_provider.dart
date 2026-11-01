import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

final languageProvider =
    NotifierProvider<LanguageController, Locale>(
  LanguageController.new,
);

class LanguageController extends Notifier<Locale> {
  late Box _settingsBox;

  @override
  Locale build() {
    _settingsBox = Hive.box('shopmate_settings');

    final savedLanguage = _settingsBox.get(
      'language',
      defaultValue: 'en',
    );

    return Locale(savedLanguage);
  }

  Future<void> changeLanguage(String languageCode) async {
    state = Locale(languageCode);
    await _settingsBox.put('language', languageCode);
  }
}