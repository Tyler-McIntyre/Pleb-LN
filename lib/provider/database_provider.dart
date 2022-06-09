import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/node_setting.dart';
import '../database/secure_storage.dart';

class DatabaseProvider {
  static final remotePubKeyLabel = FutureProvider.autoDispose
      .family<String?, String>((ref, remotePubKey) async {
    String? label = await SecureStorage.readValue(remotePubKey);
    return label;
  });
  static final channelLabel =
      FutureProvider.autoDispose.family<String, String>((ref, chanId) async {
    String label = await SecureStorage.readValue(chanId) ?? '';

    return label;
  });
  static final alias = FutureProvider.autoDispose<String>((ref) async =>
      await SecureStorage.readValue(NodeSetting.alias.name) ?? '');
  static final host = FutureProvider.autoDispose<String>((ref) async =>
      await SecureStorage.readValue(NodeSetting.host.name) ?? '');
  static final grpcport = FutureProvider.autoDispose<String>((ref) async =>
      await SecureStorage.readValue(NodeSetting.grpcport.name) ?? '');
  static final macaroon = FutureProvider.autoDispose<String>((ref) async =>
      await SecureStorage.readValue(NodeSetting.macaroon.name) ?? '');
  static final useTor = FutureProvider.autoDispose<String>((ref) async =>
      await SecureStorage.readValue(NodeSetting.useTor.name) ?? '');
}
