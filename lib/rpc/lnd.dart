import 'dart:async';
import 'package:fixnum/fixnum.dart';
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
          CallOptions(metadata: headers, timeout: Duration(seconds: 30));

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

  Future<ListPaymentsResponse> getPayments() async {
    ListPaymentsResponse response = ListPaymentsResponse();
    LightningClient stub = await _stub;
    try {
      response = await stub.listPayments(ListPaymentsRequest());
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

  Future<ListInvoiceResponse> getInvoices() async {
    ListInvoiceResponse response = ListInvoiceResponse();
    LightningClient stub = await _stub;
    try {
      response = await stub.listInvoices(ListInvoiceRequest());
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

  Future<ListChannelsResponse> getChannels() async {
    ListChannelsResponse response = ListChannelsResponse();
    LightningClient stub = await _stub;
    try {
      response = await stub.listChannels(ListChannelsRequest());
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

  Future<PendingChannelsResponse> getPendingChannels() async {
    PendingChannelsResponse response = PendingChannelsResponse();
    LightningClient stub = await _stub;
    try {
      response = await stub.pendingChannels(PendingChannelsRequest());
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

  Future<AddInvoiceResponse> createInvoice(
      Int64 value, String? memo, Int64? expiry) async {
    AddInvoiceResponse response = AddInvoiceResponse();
    LightningClient stub = await _stub;

    try {
      response = await stub
          .addInvoice(Invoice(value: value, memo: memo, expiry: expiry));
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

  Future<FeeReportResponse> feeReport() async {
    FeeReportResponse response = FeeReportResponse();
    LightningClient stub = await _stub;

    try {
      response = await stub.feeReport(FeeReportRequest());
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

  Future<PolicyUpdateResponse> updateChannelPolicy(
      PolicyUpdateRequest policyUpdateRequest) async {
    PolicyUpdateResponse response = PolicyUpdateResponse();
    LightningClient stub = await _stub;

    try {
      response = await stub.updateChannelPolicy(policyUpdateRequest);
    } on GrpcError catch (ex) {
      throw Exception(ex.message);
    } catch (ex) {
      throw Exception(ex);
    }

    return response;
  }

  Future<CloseStatusUpdate> closeChannel(
      CloseChannelRequest closeChannelRequest) async {
    CloseStatusUpdate response = CloseStatusUpdate();
    LightningClient stub = await _stub;

    try {
      response = await stub.closeChannel(closeChannelRequest).first;
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

  Future<OpenStatusUpdate> openChannel(
      OpenChannelRequest openChannelRequest) async {
    OpenStatusUpdate response = OpenStatusUpdate();
    LightningClient stub = await _stub;

    try {
      response = await stub.openChannel(openChannelRequest).first;
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
        if (ex.message!.toLowerCase().contains('pending channels exceed')) {
          throw Exception(
              'Maximum amount of pending channels reached with this node');
        }
        throw Exception(ex.message);
      }
    } catch (ex) {
      throw Exception(ex);
    }

    return response;
  }
}