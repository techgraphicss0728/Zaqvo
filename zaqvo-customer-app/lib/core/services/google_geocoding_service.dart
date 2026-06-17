import 'package:dio/dio.dart';

/// Reverse geocoding via Google Geocoding API (same key as Maps SDK).
class GoogleGeocodingService {
  GoogleGeocodingService({required this.apiKey, Dio? dio}) : _dio = dio ?? Dio();

  final String? apiKey;
  final Dio _dio;

  Future<String?> reverseGeocode(double latitude, double longitude) async {
    final key = apiKey?.trim();
    if (key == null || key.isEmpty) return null;

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: <String, dynamic>{
          'latlng': '$latitude,$longitude',
          'key': key,
        },
      );
      final data = response.data;
      if (data == null) return null;
      if (data['status'] != 'OK') return null;
      final results = data['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) return null;
      final first = results.first as Map<String, dynamic>?;
      return first?['formatted_address'] as String?;
    } catch (_) {
      return null;
    }
  }
}
