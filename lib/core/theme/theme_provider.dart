import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Keys
// ---------------------------------------------------------------------------

const _kThemeModeKey = 'sidewallet_theme_mode';

// ---------------------------------------------------------------------------
// StateNotifier
// ---------------------------------------------------------------------------

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadFromPrefs();
  }

  // Load persisted value
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kThemeModeKey);
    if (stored != null) {
      state = _fromString(stored);
    }
  }

  // Persist chosen mode
  Future<void> _saveToPrefs(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, _toString(mode));
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Toggles between dark and light. If currently [ThemeMode.system] it moves
  /// to [ThemeMode.dark].
  void toggle() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    _saveToPrefs(next);
  }

  /// Explicitly set a [ThemeMode].
  void setMode(ThemeMode mode) {
    state = mode;
    _saveToPrefs(mode);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static ThemeMode _fromString(String value) {
    switch (value) {
      case 'light':  return ThemeMode.light;
      case 'system': return ThemeMode.system;
      default:       return ThemeMode.dark;
    }
  }

  static String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:  return 'light';
      case ThemeMode.system: return 'system';
      case ThemeMode.dark:   return 'dark';
    }
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Exposes the current [ThemeMode] and its [ThemeModeNotifier].
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);
