import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inclusive_connect/data/services/cache_service.dart';

void main() {
  group('CacheService', () {
    late CacheService cacheService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      cacheService = CacheService();
    });

    test('should save and retrieve a value before expiration', () async {
      const key = 'test_key';
      const value = 'test_value';
      final expirationDate = DateTime.now().add(const Duration(hours: 1));

      await cacheService.save(key, value, expirationDate);
      final retrievedValue = await cacheService.get(key);

      expect(retrievedValue, equals(value));
    });

    test('should return null and remove key if value is expired', () async {
      const key = 'expired_key';
      const value = 'expired_value';
      // Set expiration in the past
      final expirationDate = DateTime.now().subtract(const Duration(hours: 1));

      await cacheService.save(key, value, expirationDate);

      // Attempt to retrieve
      final retrievedValue = await cacheService.get(key);

      expect(retrievedValue, isNull);

      // Verify it was removed from prefs
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(key), isFalse);
    });

    test('should handle different data types', () async {
      const key = 'int_key';
      const value = 123;
      final expirationDate = DateTime.now().add(const Duration(hours: 1));

      await cacheService.save(key, value, expirationDate);
      final retrievedValue = await cacheService.get(key);

      expect(retrievedValue, equals(value));
    });

    test('should return null for non-existent key', () async {
      final retrievedValue = await cacheService.get('non_existent');
      expect(retrievedValue, isNull);
    });
  });
}
