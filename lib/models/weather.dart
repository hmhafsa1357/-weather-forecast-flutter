/// Weather right now.
class CurrentWeather {
  final DateTime time; // local time at the city
  final double temperature; // always stored in °C
  final double feelsLike; // °C
  final int humidity; // %
  final double windSpeed; // km/h
  final int weatherCode; // WMO code, see utils/weather_codes.dart
  final bool isDay;

  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.isDay,
  });
}

/// One hour in the hourly strip.
class HourlyForecast {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final bool isDay;

  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.isDay,
  });
}

/// One day in the 7-day forecast.
class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double maxTemp;
  final double minTemp;

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
  });
}

/// Everything the dashboard needs, parsed from one API response.
class WeatherData {
  final CurrentWeather current;
  final List<HourlyForecast> hourly; // next 24 hours
  final List<DailyForecast> daily; // 7 days

  const WeatherData({
    required this.current,
    required this.hourly,
    required this.daily,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    // ---- current ----
    final c = json['current'] as Map<String, dynamic>;
    final current = CurrentWeather(
      time: DateTime.parse(c['time'] as String),
      temperature: (c['temperature_2m'] as num).toDouble(),
      feelsLike: (c['apparent_temperature'] as num).toDouble(),
      humidity: (c['relative_humidity_2m'] as num).round(),
      windSpeed: (c['wind_speed_10m'] as num).toDouble(),
      weatherCode: (c['weather_code'] as num).toInt(),
      isDay: (c['is_day'] as num) == 1,
    );

    // ---- hourly: start from the current hour, keep the next 24 ----
    final h = json['hourly'] as Map<String, dynamic>;
    final hTimes = (h['time'] as List).cast<String>();
    final hTemps = h['temperature_2m'] as List;
    final hCodes = h['weather_code'] as List;
    final hDay = h['is_day'] as List;

    final now = current.time;
    final startHour = DateTime(now.year, now.month, now.day, now.hour);
    final hourly = <HourlyForecast>[];
    for (var i = 0; i < hTimes.length && hourly.length < 24; i++) {
      final t = DateTime.parse(hTimes[i]);
      if (t.isBefore(startHour)) continue;
      hourly.add(HourlyForecast(
        time: t,
        temperature: (hTemps[i] as num).toDouble(),
        weatherCode: (hCodes[i] as num).toInt(),
        isDay: (hDay[i] as num) == 1,
      ));
    }

    // ---- daily ----
    final d = json['daily'] as Map<String, dynamic>;
    final dTimes = (d['time'] as List).cast<String>();
    final dCodes = d['weather_code'] as List;
    final dMax = d['temperature_2m_max'] as List;
    final dMin = d['temperature_2m_min'] as List;

    final daily = <DailyForecast>[
      for (var i = 0; i < dTimes.length; i++)
        DailyForecast(
          date: DateTime.parse(dTimes[i]),
          weatherCode: (dCodes[i] as num).toInt(),
          maxTemp: (dMax[i] as num).toDouble(),
          minTemp: (dMin[i] as num).toDouble(),
        ),
    ];

    return WeatherData(current: current, hourly: hourly, daily: daily);
  }
}