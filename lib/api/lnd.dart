import 'dart:convert';
import 'package:firebolt/models/channels.dart';
import 'package:firebolt/models/channel_point.dart';
import 'package:firebolt/models/close_channel_response.dart';
import 'package:firebolt/models/open_channel_stream_result.dart';
import 'package:firebolt/models/open_channel_stream.dart';
import 'package:firebolt/models/payment_request.dart';
import 'package:firebolt/models/transactions.dart';
import 'package:firebolt/models/update_channel_policy.dart';
import 'package:firebolt/models/utxos_request.dart';
import 'package:http/src/response.dart';
import '../constants/payment_status.dart';
import '../models/accept_open_channel.dart';
import '../models/accept_open_channel_response.dart';
import '../models/channel_balance.dart';
import '../models/fee_report.dart';
import '../models/invoice.dart';
import '../models/invoice_request.dart';
import '../models/open_channel.dart';
import '../models/payment.dart';
import '../models/pending_channels.dart';
import '../models/update_channel_policy_response.dart';
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

  // Future<BlockchainBalance> getBlockchainBalance() async {
  //   Response response = await rest.getRequest('/v1/balance/blockchain');
  //   String responseBody = response.body;
  //   return BlockchainBalance.fromJson(jsonDecode(responseBody));
  // }

  Future<UTXOS> getUnspentUTXOS(UTXOSRequest params) async {
    Response response =
        await rest.postRequest('/v2/wallet/utxos', params.toJson());
    String responseBody = response.body;
    return UTXOS.fromJson(jsonDecode(responseBody));
  }

  // Future<Payments> getPayments() async {
  //   Response response = await rest.getRequest('/v1/payments');
  //   String responseBody = response.body;
  //   return Payments.fromJson(jsonDecode(responseBody));
  // }

  // Future<Invoices> getInvoices() async {
  //   Response response = await rest
  //       .getRequest('/v1/invoices?reversed=true&num_max_invoices=100');
  //   String responseBody = response.body;

  //   return Invoices.fromJson(jsonDecode(responseBody));
  // }

  Future<Channels> getChannels() async {
    Response response = await rest.getRequest('/v1/channels');
    String responseBody = response.body;

    return Channels.fromJson(jsonDecode(responseBody));
  }

  Future<PendingChannels> getPendingChannels() async {
    Response response = await rest.getRequest('/v1/channels/pending');
    String responseBody = response.body;

    return PendingChannels.fromJson(jsonDecode(responseBody));
  }

  Future<ChannelPoint> openChannel(OpenChannel params) async {
    Response response = await rest.postRequest('/v1/channels', params.toJson());
    String responseBody = response.body;

    return ChannelPoint.fromJson(jsonDecode(responseBody));
  }

  Future<AcceptOpenChannelResponse> acceptOpenChannel(
      AcceptOpenChannel params) async {
    Response response =
        await rest.postRequest('/v1/channels/acceptor', params.toJson());
    String responseBody = response.body;

    return AcceptOpenChannelResponse.fromJson(jsonDecode(responseBody));
  }

  Future<FeeReport> getFeeReport() async {
    Response response = await rest.getRequest('/v1/fees');
    String responseBody = response.body;

    return FeeReport.fromJson(jsonDecode(responseBody));
  }

  Future<UpdateChannelPolicyResponse> updateChannelPolicy(
      UpdateChannelPolicy params) async {
    Response response =
        await rest.postRequest('/v1/chanpolicy', params.toJson());
    String responseBody = response.body;

    return UpdateChannelPolicyResponse.fromJson(jsonDecode(responseBody));
  }

  Future<OpenChannelStreamResult> openChannelStream(
      OpenChannelStream params) async {
    Response response =
        await rest.postRequest('/v1/channels/stream', params.toJson());
    /*
        The stream will return multiple responses, one for pending and another
        once the the tx has been funded. We don't need to do anything with the
        response at this point other than verify we got a success response.
        TODO: if we receive an error, return it to the user, otherwise return successfully
        */
    return OpenChannelStreamResult.fromJson(jsonDecode(response.body));
  }

  Future<CloseChannelResponse> closeChannel(String channelPoint) async {
    channelPoint = channelPoint.replaceFirst(':', '/');

    Response response =
        await rest.deleteRequest('/v1/channels/${channelPoint}');

    return CloseChannelResponse.fromJson(jsonDecode(response.body));
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
