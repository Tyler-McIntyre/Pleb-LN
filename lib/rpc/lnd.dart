import 'dart:async';
import 'package:fixnum/fixnum.dart';
import 'package:firebolt/constants/node_setting.dart';
import 'package:grpc/grpc.dart';
import '../database/secure_storage.dart';
import '../generated/lightning.pbgrpc.dart';
import '../generated/router.pbgrpc.dart';

class LND {
  static Future<LightningClient> get _lightningStub => createLightningClient();
  static Future<RouterClient> get _routerStub => createRouterClient();

  static Future<LightningClient> createLightningClient() async {
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

  static Future<RouterClient> createRouterClient() async {
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

      CallOptions callOptions = CallOptions(
        metadata: headers,
        timeout: Duration(seconds: 30),
      );

      return RouterClient(channel, options: callOptions);
    } else {
      throw Exception('Unable to retrieve connection params');
    }
  }

  Future<GetInfoResponse> getInfo() async {
    GetInfoResponse response = GetInfoResponse();
    LightningClient stub = await _lightningStub;
    try {
      response = await stub.getInfo(GetInfoRequest());
    } on GrpcError catch (ex) {
      throw Exception(ex.message);
    } catch (ex) {
      throw Exception(ex);
    }

    return response;
  }

  Future<WalletBalanceResponse> getWalletBalance() async {
    WalletBalanceResponse response = WalletBalanceResponse();
    LightningClient stub = await _lightningStub;
    try {
      response =
          await stub.walletBalance(WalletBalanceRequest(), CallOptions());
    } on GrpcError catch (ex) {
      throw Exception(ex.message);
    } catch (ex) {
      throw Exception(ex);
    }

    return response;
  }

  Future<ChannelBalanceResponse> getChannelBalance() async {
    ChannelBalanceResponse response = ChannelBalanceResponse();
    LightningClient stub = await _lightningStub;
    try {
      response = await stub.channelBalance(ChannelBalanceRequest());
    } on GrpcError catch (ex) {
      throw Exception(ex.message);
    } catch (ex) {
      throw Exception(ex);
    }

    return response;
  }

  Future<ListPaymentsResponse> getPayments() async {
    ListPaymentsResponse response = ListPaymentsResponse();
    LightningClient stub = await _lightningStub;
    try {
      response = await stub.listPayments(ListPaymentsRequest());
    } on GrpcError catch (ex) {
      throw Exception(ex.message);
    } catch (ex) {
      throw Exception(ex);
    }

    return response;
  }

  Future<ListInvoiceResponse> listInvoices() async {
    ListInvoiceResponse response = ListInvoiceResponse();
    LightningClient stub = await _lightningStub;
    try {
      response = await stub.listInvoices(ListInvoiceRequest());
    } on GrpcError catch (ex) {
      throw Exception(ex.message);
    } catch (ex) {
      throw Exception(ex);
    }

    return response;
  }

  Future<ListChannelsResponse> getChannels() async {
    ListChannelsResponse response = ListChannelsResponse();
    LightningClient stub = await _lightningStub;
    try {
      response = await stub.listChannels(ListChannelsRequest());
    } on GrpcError catch (ex) {
      throw Exception(ex.message);
    } catch (ex) {
      throw Exception(ex);
    }

    return response;
  }

  Future<PendingChannelsResponse> getPendingChannels() async {
    PendingChannelsResponse response = PendingChannelsResponse();
    LightningClient stub = await _lightningStub;
    try {
      response = await stub.pendingChannels(PendingChannelsRequest());
    } on GrpcError catch (ex) {
      throw Exception(ex.message);
    } catch (ex) {
      throw Exception(ex);
    }

    return response;
  }

  Future<AddInvoiceResponse> createInvoice(
      Int64 value, String? memo, Int64? expiry) async {
    AddInvoiceResponse response = AddInvoiceResponse();
    LightningClient stub = await _lightningStub;

    try {
      response = await stub
          .addInvoice(Invoice(value: value, memo: memo, expiry: expiry));
    } on GrpcError catch (ex) {
      throw Exception(ex.message);
    } catch (ex) {
      throw Exception(ex);
    }

    return response;
  }

  Future<Invoice> invoiceSubscription(
      InvoiceSubscription invoiceSubscription) async {
    Invoice response = Invoice();
    LightningClient stub = await _lightningStub;

    try {
      await for (Invoice event in stub.subscribeInvoices(invoiceSubscription,
          options: CallOptions(timeout: Duration(days: 1)))) {
        if (event.state == Invoice_InvoiceState.SETTLED) {
          response = event;
          break;
        }
      }
    } on GrpcError catch (ex) {
      throw Exception(ex.message);
    } catch (ex) {
      throw Exception(ex);
    }

    return response;
  }

  Future<PayReq> decodePaymentRequest(PayReqString payReqStr) async {
    PayReq response = PayReq();
    LightningClient stub = await _lightningStub;

    try {
      response = await stub.decodePayReq(payReqStr);
    } on GrpcError catch (ex) {
      throw Exception(ex.message);
    } catch (ex) {
      throw Exception(ex);
    }

    return response;
  }

  Future<Payment> sendPaymentV2(SendPaymentRequest sendPaymentRequest) async {
    Payment response = Payment();
    RouterClient stub = await _routerStub;
    List<Payment> paymentList = [];
    try {
      await for (Payment payment in stub.sendPaymentV2(sendPaymentRequest)) {
        paymentList.add(payment);
      }
      response = paymentList.last;
    } on GrpcError catch (ex) {
      throw Exception(ex.message);
    } catch (ex) {
      throw Exception(ex);
    }

    return response;
  }

  Future<FeeReportResponse> feeReport() async {
    FeeReportResponse response = FeeReportResponse();
    LightningClient stub = await _lightningStub;

    try {
      response = await stub.feeReport(FeeReportRequest());
    } on GrpcError catch (ex) {
      throw Exception(ex.message);
    } catch (ex) {
      throw Exception(ex);
    }

    return response;
  }

  Future<PolicyUpdateResponse> updateChannelPolicy(
      PolicyUpdateRequest policyUpdateRequest) async {
    PolicyUpdateResponse response = PolicyUpdateResponse();
    LightningClient stub = await _lightningStub;

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
    LightningClient stub = await _lightningStub;

    try {
      response = await stub.closeChannel(closeChannelRequest).first;
    } on GrpcError catch (ex) {
      throw Exception(ex.message);
    } catch (ex) {
      throw Exception(ex);
    }

    return response;
  }

  Future<OpenStatusUpdate> openChannel(
      OpenChannelRequest openChannelRequest) async {
    OpenStatusUpdate response = OpenStatusUpdate();
    LightningClient stub = await _lightningStub;

    try {
      response = await stub.openChannel(openChannelRequest).first;
    } on GrpcError catch (ex) {
      throw Exception(ex.message);
    } catch (ex) {
      throw Exception(ex);
    }

    return response;
  }
}
