import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather.dart';
import '../providers/settings_provider.dart';
import '../utils/formatters.dart';
import '../utils/weather_codes.dart';

/// Horizontally scrolling strip of the next 24 hours.
class HourlyList extends StatelessWidget {
  final List<HourlyForecast> hours;

  const HourlyList({super.key, required this.hours});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final brightness = Theme.of(context).brightness;
    final hint = Theme.of(context).hintColor;

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hours.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final hour = hours[index];
          final info = weatherInfo(hour.weatherCode, isDay: hour.isDay);

          return SizedBox(
            width: 64,
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    index == 0 ? 'Now' : formatHour(hour.time),
                    style: TextStyle(fontSize: 12, color: hint),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    info.icon,
                    size: 22,
                    color: weatherIconColor(info.kind, brightness),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    settings.formatTemp(hour.temperature),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}