import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/city.dart';
import '../providers/weather_provider.dart';
import '../services/weather_service.dart';

/// Search for a city. Results appear as you type (with a short delay so we
/// don't call the API on every single keystroke).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  int _requestId = 0;
  bool _loading = false;
  String? _error;
  List<City> _results = [];
  String _searchedQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();

    if (query.length < 2) {
      _requestId++; // ignore any request still in flight
      setState(() {
        _results = [];
        _error = null;
        _loading = false;
        _searchedQuery = '';
      });
      return;
    }

    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    final id = ++_requestId;
    final provider = context.read<WeatherProvider>();

    try {
      final results = await provider.searchCities(query);
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = results;
        _error = null;
        _loading = false;
        _searchedQuery = query;
      });
    } on WeatherException catch (e) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = [];
        _error = e.message;
        _loading = false;
        _searchedQuery = query;
      });
    } catch (_) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = [];
        _error = 'Something went wrong. Please try again.';
        _loading = false;
        _searchedQuery = query;
      });
    }
  }

  void _select(City city) {
    context.read<WeatherProvider>().selectCity(city);
    Navigator.of(context).pop(); // back to the dashboard, which shows loading
  }

  Widget _cityTile(City city) {
    return ListTile(
      leading: Icon(
        Icons.location_on_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(city.name),
      subtitle: city.subtitle.isEmpty ? null : Text(city.subtitle),
      onTap: () => _select(city),
    );
  }

  Widget _buildContent() {
    final typed = _controller.text.trim();
    final recent = context.watch<WeatherProvider>().recent;

    // Nothing typed yet: show recent searches.
    if (typed.length < 2) {
      if (recent.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Type at least 2 letters to search for a city.',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Text(
                  'Recent',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      context.read<WeatherProvider>().clearRecent(),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          ...recent.map(_cityTile),
        ],
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }

    if (_results.isEmpty && !_loading && _searchedQuery == typed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No cities found for "$typed".',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(children: _results.map(_cityTile).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search for a city',
            border: InputBorder.none,
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                _onChanged('');
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }
}