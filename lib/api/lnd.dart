import 'dart:convert';
import 'package:firebolt/models/transactions.dart';

import '../models/blockchain_balance.dart';
import '../models/channel_balance.dart';
import '../models/invoice.dart';
import '../models/invoice_request.dart';
import '../models/invoices.dart';
import '../models/payments.dart';
import '../util/formatting.dart';
import 'rest.dart';

class LND {
  RestApi rest = RestApi();
  Future<ChannelBalance> getChannelsBalance() async {
    String response = await rest.getRequest('/v1/balance/channels');
    return ChannelBalance.fromJson(jsonDecode(response));
  }

  Future<BlockchainBalance> getBlockchainBalance() async {
    String response = await rest.getRequest('/v1/balance/blockchain');
    return BlockchainBalance.fromJson(jsonDecode(response));
  }

  Future<Payments> getPayments() async {
    String response = await rest.getRequest('/v1/payments');
    return Payments.fromJson(jsonDecode(response));
  }

  Future<Invoices> getInvoices() async {
    String response = await rest
        .getRequest('/v1/invoices?reversed=true&num_max_invoices=100');
    return Invoices.fromJson(jsonDecode(response));
  }

  Future<Transactions> getTransactions() async {
    String response = await rest.getRequest('/v1/transactions');
    print(response);
    return Transactions.fromJson(jsonDecode(response));
  }

  // Future<PaymentResponse> payLightningInvoice(Payment data) async {
  //   String response = await rest.postRequest('/v2/router/send', data.toJson());

  //   return );
  // }

  //TODO: parse the lightning payment response correctly, wrap in an annotated result class with a property of type paymentResponse
  String hackOutThePaymentHash(String response) {
    RegExp reg1 = RegExp(r'("payment_hash":"[0-9a-fA-F]{64})');
    Match? firstMatch = reg1.firstMatch(response);
    if (firstMatch == null) return '';
    String firstMatchString =
        response.substring(firstMatch.start, firstMatch.end);
    return firstMatchString.substring(firstMatchString.length - 64);
  }

  Future<Invoice> createInvoice(InvoiceRequest data) async {
    String response = await rest.postRequest('/v1/invoices', data.toJson());
    return Invoice.fromJson(jsonDecode(response));
  }

  Future<Invoice> getInvoice(String rHash) async {
    String hex = Formatting.base64ToHex(rHash);
    String response = await rest.getRequest('/v1/invoice/$hex');
    return Invoice.fromJson(jsonDecode(response));
  }
}
