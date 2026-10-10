import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/city.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';

enum LoadStatus { loading, success, error }

/// Holds the selected city, its weather, and the loading/error state.
/// Screens listen to this and rebuild automatically.
class WeatherProvider extends ChangeNotifier {
  static const _cityKey = 'city';
  static const _recentKey = 'recent_cities';

  static const defaultCity = City(
    name: 'Karachi',
    region: 'Sindh',
    country: 'Pakistan',
    latitude: 24.8608,
    longitude: 67.0104,
  );

  final WeatherService _service;

  City _city = defaultCity;
  WeatherData? _weather;
  LoadStatus _status = LoadStatus.loading;
  String _error = '';
  List<City> _recent = [];
  int _fetchId = 0; // ignores out-of-date responses

  WeatherProvider({WeatherService? service})
      : _service = service ?? WeatherService();

  City get city => _city;
  WeatherData? get weather => _weather;
  LoadStatus get status => _status;
  String get error => _error;
  List<City> get recent => List.unmodifiable(_recent);

  /// Loads the saved city and recent searches, then fetches the weather.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final savedCity = prefs.getString(_cityKey);
    if (savedCity != null) {
      try {
        _city = City.fromJson(jsonDecode(savedCity) as Map<String, dynamic>);
      } catch (_) {
        // Corrupt data: fall back to the default city.
      }
    }

    _recent = (prefs.getStringList(_recentKey) ?? [])
        .map((e) {
      try {
        return City.fromJson(jsonDecode(e) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    })
        .whereType<City>()
        .toList();

    await refresh();
  }

  /// Fetches fresh weather for the current city.
  Future<void> refresh() async {
    final id = ++_fetchId;
    final city = _city;
    _status = LoadStatus.loading;
    _error = '';
    notifyListeners();

    try {
      final data = await _service.fetchWeather(city);
      if (id != _fetchId) return; // a newer request replaced this one
      _weather = data;
      _status = LoadStatus.success;
    } on WeatherException catch (e) {
      if (id != _fetchId) return;
      _error = e.message;
      _status = LoadStatus.error;
    } catch (_) {
      if (id != _fetchId) return;
      _error = 'Something went wrong. Please try again.';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  /// Switches to a new city and loads its weather.
  Future<void> selectCity(City city) async {
    _city = city;
    _weather = null; // show the loading spinner for the new city
    _recent.removeWhere((c) => c.sameLocation(city));
    _recent.insert(0, city);
    if (_recent.length > 5) _recent = _recent.sublist(0, 5);
    _status = LoadStatus.loading;
    notifyListeners();

    await _persist();
    await refresh();
  }

  Future<void> clearRecent() async {
    _recent = [];
    notifyListeners();
    await _persist();
  }

  /// Used by the search screen.
  Future<List<City>> searchCities(String query) =>
      _service.searchCities(query);

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cityKey, jsonEncode(_city.toJson()));
    await prefs.setStringList(
      _recentKey,
      _recent.map((c) => jsonEncode(c.toJson())).toList(),
    );
  }
}