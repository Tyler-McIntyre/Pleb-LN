import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/secure_storage.dart';
import '../constants/node_setting.dart';
import '../rpc/lnd.dart';

/// Handles application start up logic.
class AppInitializer {
  /// Reads the stored configuration and fetches essential data if available.
  static Future<void> initialize(WidgetRef ref) async {
    final result =
        await SecureStorage.readValue(NodeSetting.isConfigured.name) ?? 'false';
    final isConfigured = result == 'true';
    if (isConfigured) {
      await LND.fetchEssentialData(ref);
    }
  }
}
