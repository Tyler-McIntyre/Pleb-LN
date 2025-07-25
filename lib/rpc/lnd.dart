import 'dart:async';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/node_setting.dart';
import 'package:grpc/grpc.dart';
import '../database/secure_storage.dart';
import '../generated/lightning.pbgrpc.dart';
import '../generated/router.pbgrpc.dart';
import '../provider/balance_provider.dart';
import '../provider/channel_provider.dart';
import '../provider/transaction_provider.dart';

class LND {
  static Future<LightningClient> get _lightningStub => createLightningClient();
  static Future<RouterClient> get _routerStub => createRouterClient();

  static Future<T> _executeRpc<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on GrpcError catch (ex) {
      throw Exception(ex.message);
    } catch (ex) {
      throw Exception(ex);
    }
  }

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
      throw Exception('Missing node settings');
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
      throw Exception('Missing node settings');
    }
  }

  Future<GetInfoResponse> getInfo() async {
    LightningClient stub = await _lightningStub;
    return _executeRpc(() => stub.getInfo(GetInfoRequest()));
  }

  Future<WalletBalanceResponse> getWalletBalance() async {
    LightningClient stub = await _lightningStub;
    return _executeRpc(
        () => stub.walletBalance(WalletBalanceRequest(), CallOptions()));
  }

  Future<ChannelBalanceResponse> getChannelBalance() async {
    LightningClient stub = await _lightningStub;
    return _executeRpc(() => stub.channelBalance(ChannelBalanceRequest()));
  }

  Future<ListPaymentsResponse> getPayments() async {
    LightningClient stub = await _lightningStub;
    return _executeRpc(() => stub.listPayments(ListPaymentsRequest()));
  }

  Future<ListInvoiceResponse> listInvoices() async {
    LightningClient stub = await _lightningStub;
    return _executeRpc(() => stub.listInvoices(ListInvoiceRequest()));
  }

  Future<ListChannelsResponse> getChannels() async {
    LightningClient stub = await _lightningStub;
    return _executeRpc(() => stub.listChannels(ListChannelsRequest()));
  }

  Future<PendingChannelsResponse> getPendingChannels() async {
    LightningClient stub = await _lightningStub;
    return _executeRpc(() => stub.pendingChannels(PendingChannelsRequest()));
  }

  Future<AddInvoiceResponse> createInvoice(
      Int64 value, String? memo, Int64? expiry) async {
    LightningClient stub = await _lightningStub;
    return _executeRpc(() => stub
        .addInvoice(Invoice(value: value, memo: memo, expiry: expiry)));
  }

  Future<Invoice> invoiceSubscription(
      InvoiceSubscription invoiceSubscription) async {
    LightningClient stub = await _lightningStub;
    return _executeRpc(() async {
      Invoice response = Invoice();
      await for (Invoice event in stub.subscribeInvoices(invoiceSubscription,
          options: CallOptions(timeout: Duration(days: 1)))) {
        if (event.addIndex == invoiceSubscription.addIndex &&
            event.state == Invoice_InvoiceState.SETTLED) {
          response = event;
          break;
        }
      }
      return response;
    });
  }

  Future<PayReq> decodePaymentRequest(PayReqString payReqStr) async {
    LightningClient stub = await _lightningStub;
    return _executeRpc(() => stub.decodePayReq(payReqStr));
  }

  Future<Payment> sendPaymentV2(SendPaymentRequest sendPaymentRequest) async {
    RouterClient stub = await _routerStub;
    return _executeRpc(() async {
      List<Payment> paymentList = [];
      await for (Payment payment in stub.sendPaymentV2(sendPaymentRequest)) {
        paymentList.add(payment);
      }
      return paymentList.last;
    });
  }

  Future<FeeReportResponse> feeReport() async {
    LightningClient stub = await _lightningStub;
    return _executeRpc(() => stub.feeReport(FeeReportRequest()));
  }

  Future<PolicyUpdateResponse> updateChannelPolicy(
      PolicyUpdateRequest policyUpdateRequest) async {
    LightningClient stub = await _lightningStub;
    return _executeRpc(() => stub.updateChannelPolicy(policyUpdateRequest));
  }

  Future<CloseStatusUpdate> closeChannel(
      CloseChannelRequest closeChannelRequest) async {
    LightningClient stub = await _lightningStub;
    return _executeRpc(
        () => stub.closeChannel(closeChannelRequest).first);
  }

  Future<OpenStatusUpdate> openChannel(
      OpenChannelRequest openChannelRequest) async {
    LightningClient stub = await _lightningStub;
    return _executeRpc(
        () => stub.openChannel(openChannelRequest).first);
  }

  static Future<bool> fetchEssentialData(WidgetRef ref) async {
    try {
      LND rpc = LND();
      //on-chain balance
      WalletBalanceResponse walletBalance = await rpc.getWalletBalance();
      ref.read(BalanceProvider.onChainBalance.notifier).state = walletBalance;
      //off-chain balance
      ChannelBalanceResponse channelBalance = await rpc.getChannelBalance();
      ref.read(BalanceProvider.channelBalance.notifier).state = channelBalance;
      //payments
      ListPaymentsResponse payments = await rpc.getPayments();
      ref.read(TransactionProvider.payments.notifier).state = payments;
      //invoices
      ListInvoiceResponse invoices = await rpc.listInvoices();
      ref.read(TransactionProvider.invoices.notifier).state = invoices;
      //open channels
      ListChannelsResponse openChannels = await rpc.getChannels();
      ref.read(ChannelProvider.openChannels.notifier).state = openChannels;
      //pending channels
      PendingChannelsResponse pendingChannels = await rpc.getPendingChannels();
      ref.read(ChannelProvider.pendingChannels.notifier).state =
          pendingChannels;
      return true;
    } catch (ex) {
      throw Exception(ex);
    }
  }
}
