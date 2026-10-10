import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App preferences: theme mode and metric/imperial units.
/// Weather data is always stored in °C and km/h; conversion happens
/// only when displaying, so switching units never needs a new request.
class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _useImperial = false;

  ThemeMode get themeMode => _themeMode;
  bool get useImperial => _useImperial;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('themeMode');
    _themeMode = ThemeMode.values.firstWhere(
          (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
    _useImperial = prefs.getBool('useImperial') ?? false;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
  }

  Future<void> setUseImperial(bool value) async {
    _useImperial = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useImperial', value);
  }

  /// "34°" in °C or °F depending on the unit setting.
  String formatTemp(double celsius) {
    final value = _useImperial ? celsius * 9 / 5 + 32 : celsius;
    return '${value.round()}°';
  }

  /// "12 km/h" or "7 mph".
  String formatWind(double kmh) {
    final value = _useImperial ? kmh * 0.621371 : kmh;
    return '${value.round()} ${_useImperial ? 'mph' : 'km/h'}';
  }
}