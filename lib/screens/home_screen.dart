import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/weather_provider.dart';
import '../utils/formatters.dart';
import '../widgets/app_drawer.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/daily_list.dart';
import '../widgets/error_view.dart';
import '../widgets/hourly_list.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>();
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = weather.weather;

    Widget body;
    if (data == null) {
      // Nothing to show yet: either still loading, or the first load failed.
      body = weather.status == LoadStatus.error
          ? ErrorView(message: weather.error, onRetry: weather.refresh)
          : const Center(child: CircularProgressIndicator());
    } else {
      body = RefreshIndicator(
        onRefresh: weather.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            // A refresh failed but we still have older data to show.
            if (weather.status == LoadStatus.error)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cloud_off,
                        size: 18, color: scheme.onErrorContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Couldn't refresh. Showing the last update.",
                        style: TextStyle(color: scheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            CurrentWeatherCard(
              city: weather.city,
              current: data.current,
              onCityTap: () => _openSearch(context),
            ),
            _sectionLabel(context, 'Hourly'),
            HourlyList(hours: data.hourly),
            _sectionLabel(context, '7-day forecast'),
            DailyList(days: data.daily),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Updated ${formatTime(data.current.time)} local time\n'
                    'Weather data by Open-Meteo.com',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Weather'),
        actions: [
          IconButton(
            tooltip: 'Search city',
            icon: const Icon(Icons.search),
            onPressed: () => _openSearch(context),
          ),
          IconButton(
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => context
                .read<SettingsProvider>()
                .setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark),
          ),
        ],
      ),
      body: body,
    );
  }
}