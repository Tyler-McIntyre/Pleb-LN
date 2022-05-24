import 'dart:convert';
import 'package:firebolt/models/payment_request.dart';
import 'package:firebolt/models/transactions.dart';
import 'package:http/src/response.dart';
import '../UI/Constants/payment_status.dart';
import '../models/blockchain_balance.dart';
import '../models/channel_balance.dart';
import '../models/invoice.dart';
import '../models/invoice_request.dart';
import '../models/invoices.dart';
import '../models/payment.dart';
import '../models/payments.dart';
import '../util/formatting.dart';
import 'rest.dart';

class LND {
  RestApi rest = RestApi();
  Future<ChannelBalance> getChannelsBalance() async {
    Response response = await rest.getRequest('/v1/balance/channels');
    String textReponse = response.body;
    return ChannelBalance.fromJson(jsonDecode(textReponse));
  }

  Future<BlockchainBalance> getBlockchainBalance() async {
    Response response = await rest.getRequest('/v1/balance/blockchain');
    String textReponse = response.body;
    return BlockchainBalance.fromJson(jsonDecode(textReponse));
  }

  Future<Payments> getPayments() async {
    Response response = await rest.getRequest('/v1/payments');
    String textReponse = response.body;
    return Payments.fromJson(jsonDecode(textReponse));
  }

  Future<Invoices> getInvoices() async {
    Response response = await rest
        .getRequest('/v1/invoices?reversed=true&num_max_invoices=100');
    String textReponse = response.body;

    return Invoices.fromJson(jsonDecode(textReponse));
  }

  Future<Transactions> getTransactions() async {
    Response response = await rest.getRequest('/v1/transactions');
    String textReponse = response.body;
    return Transactions.fromJson(jsonDecode(textReponse));
  }

  Future<PaymentStatus> payLightningInvoice(Payment data) async {
    Response response =
        await rest.postRequest('/v2/router/send', data.toJson());
    int statusCode = response.statusCode;
    //TODO: add the status codes for in_flight, failed, and unknown
    print(response.body);
    if (statusCode == 200) {
      return PaymentStatus.successful;
    } else {
      return PaymentStatus.failed;
    }
  }

  Future<PaymentRequest> decodePaymentRequest(String invoice) async {
    Response response = await rest.getRequest('/v1/payreq/$invoice');
    String textReponse = response.body;
    return PaymentRequest.fromJson(jsonDecode(textReponse));
  }

  Future<Invoice> createInvoice(InvoiceRequest data) async {
    Response response = await rest.postRequest('/v1/invoices', data.toJson());
    String textReponse = response.body;
    return Invoice.fromJson(jsonDecode(textReponse));
  }

  Future<Invoice> getInvoice(String rHash) async {
    String hex = Formatting.base64ToHex(rHash);
    Response response = await rest.getRequest('/v1/invoice/$hex');
    String textReponse = response.body;
    return Invoice.fromJson(jsonDecode(textReponse));
  }
}
