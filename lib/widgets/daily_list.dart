import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather.dart';
import '../providers/settings_provider.dart';
import '../utils/formatters.dart';
import '../utils/weather_codes.dart';

/// The 7-day forecast: one row per day with min / max temperature.
class DailyList extends StatelessWidget {
  final List<DailyForecast> days;

  const DailyList({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final brightness = Theme.of(context).brightness;
    final hint = Theme.of(context).hintColor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            for (var i = 0; i < days.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 56,
                      child: Text(
                        i == 0 ? 'Today' : weekdayShort(days[i].date),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Icon(
                      weatherInfo(days[i].weatherCode).icon,
                      size: 20,
                      color: weatherIconColor(
                        weatherInfo(days[i].weatherCode).kind,
                        brightness,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          weatherInfo(days[i].weatherCode).description,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: hint),
                        ),
                      ),
                    ),
                    Text(
                      '${settings.formatTemp(days[i].minTemp)} / '
                          '${settings.formatTemp(days[i].maxTemp)}',
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}