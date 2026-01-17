import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import '../models/event_models.dart';

class GeocodingService {
  static final _functions = FirebaseFunctions.instance;

  GeocodingService();

  Future<Map<String, double>?> geocodeAddress({
    String? street,
    String? streetNumber,
    String? postalCode,
    required String city,
    required String province,
    String country = "Italy",
  }) async {
    debugPrint(
      'geocodeAddress: $street $streetNumber $postalCode $city $province $country',
    );
    try {
      final response = await _functions.httpsCallable('geocode_address').call({
        if (street != null) 'street': street,
        if (streetNumber != null) 'streetNumber': streetNumber,
        if (postalCode != null) 'postalCode': postalCode,
        'city': city,
        'province': province,
        'country': country,
      });
      debugPrint('geocodeAddress Response: ${response.data}');
      if (response.data != null && response.data['location'] != null) {
        final location = response.data['location'];
        return {
          'latitude': location['latitude'] is double
              ? location['latitude']
              : double.tryParse(location['latitude'].toString()) ?? 0.0,
          'longitude': location['longitude'] is double
              ? location['longitude']
              : double.tryParse(location['longitude'].toString()) ?? 0.0,
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error geocoding address: ${e.toString()}');
      return null;
    }
  }

  Future<List<Event>> getEventsInRadius({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    debugPrint('getEventsInRadius: $latitude $longitude $radius');
    try {
      final response = await _functions
          .httpsCallable('get_nearest_events')
          .call({
            'latitude': latitude,
            'longitude': longitude,
            'radius': radius,
          });
      debugPrint('getEventsInRadius Response: ${response.data}');
      if (response.data is List) {
        return (response.data as List)
            .map((e) => Event.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting events in radius: ${e.toString()}');
      return [];
    }
  }
}
