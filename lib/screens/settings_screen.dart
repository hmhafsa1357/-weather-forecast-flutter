import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/weather_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _sectionLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).hintColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _sectionLabel(context, 'Preferences'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark mode'),
            value: isDark,
            onChanged: (value) => settings
                .setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.thermostat),
            title: const Text('Imperial units'),
            subtitle: Text(settings.useImperial ? '°F, mph' : '°C, km/h'),
            value: settings.useImperial,
            onChanged: settings.setUseImperial,
          ),
          _sectionLabel(context, 'Data'),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Clear recent searches'),
            onTap: () {
              context.read<WeatherProvider>().clearRecent();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recent searches cleared')),
              );
            },
          ),
        ],
      ),
    );
  }
}