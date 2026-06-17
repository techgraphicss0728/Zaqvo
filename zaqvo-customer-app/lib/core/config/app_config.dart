/// Global app configuration (API base URL, feature flags).
class AppConfig {
  final String apiBaseUrl;

  /// Used for Google Maps tiles, Geocoding API, etc. Set via `.env` as `GOOGLE_MAPS_API_KEY`.
  final String? googleMapsApiKey;

  const AppConfig({
    required this.apiBaseUrl,
    this.googleMapsApiKey,
  });
}
