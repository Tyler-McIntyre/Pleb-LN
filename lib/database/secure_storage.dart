import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//TODO: test if further settings are needed for IOS Storage. currently only tested on Android.

class SecureStorage {
  // Create storage
  static const _storage = FlutterSecureStorage();

  static Future<String?> readValue(String key) async {
    // Read value
    return await _storage.read(key: key);
  }

  static Future writeValue(String key, String? value) async {
    // Write value
    return await _storage.write(key: key, value: value);
  }

  static Future readAllValues(key) async {
    // Read all values
    return await _storage.readAll();
  }

  static Future wipeStorage() async {
    // Delete all
    await _storage.deleteAll();
  }
}
