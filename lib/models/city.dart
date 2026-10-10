/// A searchable location (returned by the geocoding API).
class City {
  final String name;
  final String region; // state/province, may be empty
  final String country; // may be empty
  final double latitude;
  final double longitude;

  const City({
    required this.name,
    this.region = '',
    this.country = '',
    required this.latitude,
    required this.longitude,
  });

  /// Shown on the dashboard, e.g. "Karachi, Pakistan".
  String get displayName => country.isEmpty ? name : '$name, $country';

  /// Shown under the name in search results, e.g. "Sindh, Pakistan".
  String get subtitle => [
    if (region.isNotEmpty && region != name) region,
    if (country.isNotEmpty) country,
  ].join(', ');

  /// Two cities count as the same place if their coordinates are very close.
  bool sameLocation(City other) =>
      (latitude - other.latitude).abs() < 0.01 &&
          (longitude - other.longitude).abs() < 0.01;

  factory City.fromGeocoding(Map<String, dynamic> json) => City(
    name: json['name'] as String,
    region: (json['admin1'] as String?) ?? '',
    country: (json['country'] as String?) ?? '',
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'region': region,
    'country': country,
    'latitude': latitude,
    'longitude': longitude,
  };

  factory City.fromJson(Map<String, dynamic> json) => City(
    name: json['name'] as String,
    region: json['region'] as String? ?? '',
    country: json['country'] as String? ?? '',
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
  );
}