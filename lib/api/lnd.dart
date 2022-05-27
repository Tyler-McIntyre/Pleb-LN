import 'dart:convert';
import 'package:firebolt/models/channels.dart';
import 'package:firebolt/models/open_channel_response.dart';
import 'package:firebolt/models/payment_request.dart';
import 'package:firebolt/models/transactions.dart';
import 'package:firebolt/models/utxos_request.dart';
import 'package:http/src/response.dart';
import '../constants/payment_status.dart';
import '../models/blockchain_balance.dart';
import '../models/channel_balance.dart';
import '../models/invoice.dart';
import '../models/invoice_request.dart';
import '../models/invoices.dart';
import '../models/open_channel.dart';
import '../models/payment.dart';
import '../models/payments.dart';
import '../models/utxos.dart';
import '../util/formatting.dart';
import 'rest.dart';

class LND {
  RestApi rest = RestApi();
  Future<ChannelBalance> getChannelsBalance() async {
    Response response = await rest.getRequest('/v1/balance/channels');
    String responseBody = response.body;
    return ChannelBalance.fromJson(jsonDecode(responseBody));
  }

  Future<BlockchainBalance> getBlockchainBalance() async {
    Response response = await rest.getRequest('/v1/balance/blockchain');
    String responseBody = response.body;
    return BlockchainBalance.fromJson(jsonDecode(responseBody));
  }

  Future<UTXOS> getUnspentUTXOS(UTXOSRequest params) async {
    Response response =
        await rest.postRequest('/v2/wallet/utxos', params.toJson());
    String responseBody = response.body;
    return UTXOS.fromJson(jsonDecode(responseBody));
  }

  Future<Payments> getPayments() async {
    Response response = await rest.getRequest('/v1/payments');
    String responseBody = response.body;
    return Payments.fromJson(jsonDecode(responseBody));
  }

  Future<Invoices> getInvoices() async {
    Response response = await rest
        .getRequest('/v1/invoices?reversed=true&num_max_invoices=100');
    String responseBody = response.body;

    return Invoices.fromJson(jsonDecode(responseBody));
  }

  Future<Channels> getChannels() async {
    Response response = await rest.getRequest('/v1/channels');
    String responseBody = response.body;

    return Channels.fromJson(jsonDecode(responseBody));
  }

  Future<OpenChannelResponse> openChannel(OpenChannel params) async {
    // List<int> bytes = utf8.encode(params.nodePubkey);
    // String base64Str = base64.encode(bytes);
    // params.nodePubkey = base64Str;
    // print(base64Str);
    Response response = await rest.postRequest('/v1/channels', params.toJson());
    print(response);
    String responseBody = response.body;
    print(response.body);

    return OpenChannelResponse.fromJson(jsonDecode(responseBody));
  }

  Future<Transactions> getTransactions() async {
    Response response = await rest.getRequest('/v1/transactions');
    String responseBody = response.body;
    return Transactions.fromJson(jsonDecode(responseBody));
  }

  Future<PaymentStatus> payLightningInvoice(Payment data) async {
    Response response =
        await rest.postRequest('/v2/router/send', data.toJson());
    int statusCode = response.statusCode;
    switch (statusCode) {
      case 200:
        return PaymentStatus.successful;
      case 409:
        return PaymentStatus.invoice_already_paid;
      default:
        return PaymentStatus.unknown;
    }
  }

  Future<PaymentRequest> decodePaymentRequest(String invoice) async {
    Response response = await rest.getRequest('/v1/payreq/$invoice');
    String responseBody = response.body;
    return PaymentRequest.fromJson(jsonDecode(responseBody));
  }

  Future<Invoice> createInvoice(InvoiceRequest data) async {
    Response response = await rest.postRequest('/v1/invoices', data.toJson());
    String responseBody = response.body;
    return Invoice.fromJson(jsonDecode(responseBody));
  }

  Future<Invoice> getInvoice(String rHash) async {
    String hex = Formatting.base64ToHex(rHash);
    Response response = await rest.getRequest('/v1/invoice/$hex');
    String responseBody = response.body;
    return Invoice.fromJson(jsonDecode(responseBody));
  }
}
