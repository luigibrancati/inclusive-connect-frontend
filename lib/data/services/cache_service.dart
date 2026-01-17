import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class CacheService {
  Future<void> save(String key, dynamic value, DateTime expirationDate) async {
    debugPrint(
      'Saving cache for key $key with value $value and expiration date $expirationDate',
    );
    final box = Hive.box('cache');
    final data = {
      'value': value,
      'expirationDate': expirationDate.toIso8601String(),
    };
    final jsonString = jsonEncode(data);
    // debugPrint('Saving cache for key $key with JSON string: $jsonString');
    await box.put(key, jsonString);
  }

  Future<dynamic> get(String key) async {
    debugPrint('Getting cache for key: $key');
    final box = Hive.box('cache');
    // await box.reload();
    // debugPrint("All cache keys: ${box.keys}");
    final jsonString = box.get(key);

    if (jsonString == null) {
      debugPrint('Cache not found for key: $key');
      return null;
    }

    try {
      debugPrint('Cache found for key: $key. Len: ${jsonString.length}');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      // debugPrint('Decoded cache found for key $key: $data');
      final expirationDateStr = data['expirationDate'] as String;
      final expirationDate = DateTime.parse(expirationDateStr);

      if (DateTime.now().isAfter(expirationDate)) {
        debugPrint('Cache expired for key: $key');
        await remove(key);
        return null;
      }

      debugPrint('Cache valid for key: $key');
      return data['value'];
    } catch (e) {
      debugPrint('Error parsing cache data: ${e.toString()}');
      await remove(key);
      return null;
    }
  }

  Future<void> remove(String key) async {
    final box = Hive.box('cache');
    await box.delete(key);
    debugPrint('Cache removed for key: $key');
  }
}
