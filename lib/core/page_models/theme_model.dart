import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final NotifierProvider<ThemeModel, ThemeModelData> themeModelProvider =
    NotifierProvider<ThemeModel, ThemeModelData>(() => ThemeModel());

class ThemeModelData {
  const ThemeModelData({
    required this.themeMode,
    this.isLoading = false,
  });

  final ThemeMode themeMode;
  final bool isLoading;

  ThemeModelData copyWith({ThemeMode? themeMode, bool? isLoading}) {
    return ThemeModelData(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ThemeModel extends Notifier<ThemeModelData> {
  static const String _themeModeKey = 'muvees_theme_mode';

  @override
  ThemeModelData build() {
    _loadThemeMode();
    return const ThemeModelData(themeMode: ThemeMode.system);
  }

  Future<void> _loadThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? value = prefs.getString(_themeModeKey);
    if (value != null) {
      final ThemeMode themeMode = ThemeMode.values.firstWhere(
        (ThemeMode mode) => mode.name == value,
        orElse: () => ThemeMode.system,
      );
      state = state.copyWith(themeMode: themeMode);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
    state = state.copyWith(themeMode: mode);
  }
}
