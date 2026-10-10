import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/city.dart';
import '../models/weather.dart';

/// An error with a message that is safe to show directly to the user.
class WeatherException implements Exception {
  final String message;
  const WeatherException(this.message);

  @override
  String toString() => message;
}

/// Talks to the free Open-Meteo APIs (no API key needed).
class WeatherService {
  static const _geoHost = 'geocoding-api.open-meteo.com';
  static const _forecastHost = 'api.open-meteo.com';

  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  /// Finds cities matching [query] (used by the search screen).
  Future<List<City>> searchCities(String query) async {
    final uri = Uri.https(_geoHost, '/v1/search', {
      'name': query,
      'count': '10',
      'language': 'en',
      'format': 'json',
    });
    final json = await _getJson(uri);

    // When nothing matches, the API leaves out the "results" key entirely.
    final results = json['results'] as List?;
    if (results == null) return [];
    return results
        .map((e) => City.fromGeocoding(e as Map<String, dynamic>))
        .toList();
  }

  /// Gets current weather, the hourly forecast and a 7-day forecast.
  Future<WeatherData> fetchWeather(City city) async {
    final uri = Uri.https(_forecastHost, '/v1/forecast', {
      'latitude': city.latitude.toString(),
      'longitude': city.longitude.toString(),
      'current':
      'temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code,is_day',
      'hourly': 'temperature_2m,weather_code,is_day',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
      'timezone': 'auto',
      'forecast_days': '7',
    });
    final json = await _getJson(uri);

    try {
      return WeatherData.fromJson(json);
    } catch (_) {
      throw const WeatherException(
          'Received unexpected data from the weather service.');
    }
  }

  /// Shared GET + JSON decode, turning every failure into a friendly message.
  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final response =
      await _client.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw WeatherException(
            'The weather service returned an error (${response.statusCode}). Please try again.');
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on WeatherException {
      rethrow;
    } on TimeoutException {
      throw const WeatherException(
          'The request timed out. Check your connection and try again.');
    } on http.ClientException {
      throw const WeatherException(
          'No internet connection. Check your network and try again.');
    } on FormatException {
      throw const WeatherException(
          'Received unexpected data from the weather service.');
    } catch (_) {
      throw const WeatherException('Something went wrong. Please try again.');
    }
  }
}