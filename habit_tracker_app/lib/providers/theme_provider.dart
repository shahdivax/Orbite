import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

const String _themeModeBoxName = 'settings';
const String _themeModeKey = 'themeMode';

// Provider for managing and persisting the theme mode
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  late Box _settingsBox;

  ThemeModeNotifier() : super(ThemeMode.dark) { // Default to dark theme
    _init();
  }

  Future<void> _init() async {
    // Ensure Hive is initialized if not already (e.g. for direct use without full app restart)
    if (!Hive.isBoxOpen(_themeModeBoxName)) {
        // This assumes Hive has been initialized (Hive.initFlutter() or Hive.init())
        // This path might be tricky if Hive isn't fully ready.
        // Ideally, this box is opened along with other Hive boxes at startup.
        // For now, let's open it here if not open.
        _settingsBox = await Hive.openBox(_themeModeBoxName);
    } else {
        _settingsBox = Hive.box(_themeModeBoxName);
    }

    final storedThemeMode = _settingsBox.get(_themeModeKey);
    if (storedThemeMode != null && storedThemeMode is int) {
      state = ThemeMode.values[storedThemeMode];
    } else {
      // If nothing stored, persist the default (dark)
      await _settingsBox.put(_themeModeKey, state.index);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state != mode) {
      state = mode;
      await _settingsBox.put(_themeModeKey, mode.index);
    }
  }
}
