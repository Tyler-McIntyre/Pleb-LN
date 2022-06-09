import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/node_setting.dart';
import '../models/settings.dart';

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

  static Future<bool> saveUserSettings(Settings settings) async {
    try {
      await SecureStorage.writeValue(
        NodeSetting.host.name,
        settings.host,
      );
      await SecureStorage.writeValue(
        NodeSetting.grpcport.name,
        settings.gRPCPort,
      );
      await SecureStorage.writeValue(
        NodeSetting.macaroon.name,
        settings.macaroon,
      );
      await SecureStorage.writeValue(
        NodeSetting.useTor.name,
        settings.useTor.toString(),
      );
      return true;
    } catch (ex) {
      return false;
    }
  }
}
