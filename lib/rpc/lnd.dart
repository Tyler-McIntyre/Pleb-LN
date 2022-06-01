import 'dart:async';
import 'package:firebolt/constants/node_setting.dart';
import 'package:grpc/grpc.dart';
import '../database/secure_storage.dart';
import '../generated/lightning.pbgrpc.dart';
import '../models/exceptions.dart';
import '../constants/grpc_exception_type.dart';

class LND {
  static Future<LightningClient> get _stub => createClientInstance();

  static Future<LightningClient> createClientInstance() async {
    String host = await SecureStorage.readValue(NodeSetting.host.name) ?? '';
    String gRPCPort =
        await SecureStorage.readValue(NodeSetting.grpcport.name) ?? '';

    if (gRPCPort.isNotEmpty && host.isNotEmpty) {
      int port = int.parse(gRPCPort);

      final channel = ClientChannel(
        host,
        port: port,
        options: ChannelOptions(
          idleTimeout: Duration(seconds: 20),
          connectionTimeout: Duration(seconds: 20),
          credentials: ChannelCredentials.secure(
            // --- WORKAROUND FOR SELF-SIGNED DEVELOPMENT CA ---
            onBadCertificate: (cert, host) => true,
          ),
        ),
      );
      final String macaroon =
          await SecureStorage.readValue(NodeSetting.macaroon.name) ?? '';

      Map<String, String> headers = {
        'macaroon': macaroon,
      };

      CallOptions callOptions =
          CallOptions(metadata: headers, timeout: Duration(seconds: 1));

      return LightningClient(channel, options: callOptions);
    } else {
      throw Exception('Unable to retrieve connection params');
    }
  }

  Future<WalletBalanceResponse> getWalletBalance() async {
    WalletBalanceResponse response = WalletBalanceResponse();
    LightningClient stub = await _stub;
    try {
      response =
          await stub.walletBalance(WalletBalanceRequest(), CallOptions());
    } on GrpcError catch (ex) {
      if (ex.codeName == gRPCExceptionType.UNAVAILABLE.name) {
        if (ex.message!.toLowerCase().contains('failed host lookup')) {
          throw FailedHostLookup(
                  'Unable to connect to host, check your node settings and try again.')
              .message;
        }
      } else if (ex.codeName == gRPCExceptionType.DEADLINE_EXCEEDED.name) {
        throw TimeoutException(
            'Unable to connect. This could be due to invalid settings, the server being offline, or an unstable connection');
      } else {
        throw Exception(ex.message);
      }
    }

    return response;
  }
}
