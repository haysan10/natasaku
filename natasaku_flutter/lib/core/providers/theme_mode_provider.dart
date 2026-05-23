import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repository_providers.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._ref) : super(ThemeMode.system) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final settings = await _ref.read(budgetRepositoryProvider).loadUserSettings();
    state = settings.themeMode;
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    final repo = _ref.read(budgetRepositoryProvider);
    final current = await repo.loadUserSettings();
    final updated = current.copyWith(themeMode: mode);
    await repo.saveUserSettings(updated);
    state = updated.themeMode;
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref);
});
