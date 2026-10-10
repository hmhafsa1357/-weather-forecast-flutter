import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/city.dart';
import '../models/weather.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/weather_codes.dart';

/// The big card at the top: city, icon, temperature, humidity and wind.
class CurrentWeatherCard extends StatelessWidget {
  final City city;
  final CurrentWeather current;
  final VoidCallback onCityTap;

  const CurrentWeatherCard({
    super.key,
    required this.city,
    required this.current,
    required this.onCityTap,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final brightness = Theme.of(context).brightness;
    final info = weatherInfo(current.weatherCode, isDay: current.isDay);
    final fg = AppTheme.heroText(brightness);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppTheme.heroBackground(brightness),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onCityTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_outlined, size: 18, color: fg),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      city.displayName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fg,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(Icons.expand_more, size: 18, color: fg),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Icon(
            info.icon,
            size: 64,
            color: weatherIconColor(info.kind, brightness),
          ),
          const SizedBox(height: 4),
          Text(
            settings.formatTemp(current.temperature),
            style: TextStyle(
              color: fg,
              fontSize: 56,
              fontWeight: FontWeight.w500,
              height: 1.1,
            ),
          ),
          Text(info.description, style: TextStyle(color: fg, fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            'Feels like ${settings.formatTemp(current.feelsLike)}',
            style: TextStyle(color: fg.withValues(alpha: 0.8), fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Detail(
                icon: Icons.water_drop_outlined,
                label: '${current.humidity}% humidity',
                color: fg,
              ),
              const SizedBox(width: 24),
              _Detail(
                icon: Icons.air,
                label: settings.formatWind(current.windSpeed),
                color: fg,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Detail({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 13)),
      ],
    );
  }
}