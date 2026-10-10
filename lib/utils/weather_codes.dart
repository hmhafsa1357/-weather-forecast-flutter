import 'package:flutter/material.dart';

/// Open-Meteo returns a numeric WMO "weather code".
/// This file turns a code into a description, an icon and a color.

enum WeatherKind { sun, moon, cloud, fog, rain, snow, storm }

class WeatherInfo {
  final String description;
  final IconData icon;
  final WeatherKind kind;

  const WeatherInfo(this.description, this.icon, this.kind);
}

WeatherInfo weatherInfo(int code, {bool isDay = true}) {
  switch (code) {
    case 0:
      return isDay
          ? const WeatherInfo('Clear sky', Icons.wb_sunny, WeatherKind.sun)
          : const WeatherInfo('Clear night', Icons.nights_stay, WeatherKind.moon);
    case 1:
      return isDay
          ? const WeatherInfo('Mainly clear', Icons.wb_sunny, WeatherKind.sun)
          : const WeatherInfo('Mainly clear', Icons.nights_stay, WeatherKind.moon);
    case 2:
      return const WeatherInfo(
          'Partly cloudy', Icons.wb_cloudy, WeatherKind.cloud);
    case 3:
      return const WeatherInfo('Overcast', Icons.cloud, WeatherKind.cloud);
    case 45:
    case 48:
      return const WeatherInfo('Fog', Icons.foggy, WeatherKind.fog);
    case 51:
    case 53:
    case 55:
    case 56:
    case 57:
      return const WeatherInfo('Drizzle', Icons.grain, WeatherKind.rain);
    case 61:
    case 63:
    case 65:
    case 66:
    case 67:
      return const WeatherInfo('Rain', Icons.water_drop, WeatherKind.rain);
    case 71:
    case 73:
    case 75:
    case 77:
      return const WeatherInfo('Snow', Icons.ac_unit, WeatherKind.snow);
    case 80:
    case 81:
    case 82:
      return const WeatherInfo(
          'Rain showers', Icons.water_drop, WeatherKind.rain);
    case 85:
    case 86:
      return const WeatherInfo('Snow showers', Icons.ac_unit, WeatherKind.snow);
    case 95:
    case 96:
    case 99:
      return const WeatherInfo(
          'Thunderstorm', Icons.thunderstorm, WeatherKind.storm);
    default:
      return const WeatherInfo('Cloudy', Icons.cloud, WeatherKind.cloud);
  }
}

/// Sun is amber/yellow; rain and snow use the blue accent; the rest stay neutral.
Color weatherIconColor(WeatherKind kind, Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  switch (kind) {
    case WeatherKind.sun:
      return isDark ? const Color(0xFFEF9F27) : const Color(0xFFBA7517);
    case WeatherKind.moon:
      return isDark ? const Color(0xFFB4C7E0) : const Color(0xFF5B7DA8);
    case WeatherKind.rain:
    case WeatherKind.snow:
      return isDark ? const Color(0xFF85B7EB) : const Color(0xFF185FA5);
    case WeatherKind.cloud:
    case WeatherKind.fog:
    case WeatherKind.storm:
      return isDark ? const Color(0xFFB4B2A9) : const Color(0xFF888780);
  }
}