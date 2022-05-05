import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

//   deleteValue(key) async {
// // Delete value
//     await _storage.delete(key: key);
//   }

  static Future wipeStorage() async {
// Delete all
    await _storage.deleteAll();
  }
}
