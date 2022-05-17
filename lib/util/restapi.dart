import 'dart:convert';
import 'package:firebolt/database/secure_storage.dart';
import 'package:firebolt/models/blockchain_balance.dart';
import 'package:http/http.dart' as http;
import '../models/channel_balance.dart';
import '../models/invoice.dart';
import '../models/invoice_request.dart';
import '../models/payment.dart';
import '../models/payment_response.dart';

class RestApi {
  Future<ChannelBalance> getChannelsBalance() async {
    String response = await _getRequest('/v1/balance/channels');
    return ChannelBalance.fromJson(jsonDecode(response));
  }

  Future<BlockchainBalance> getBlockchainBalance() async {
    String response = await _getRequest('/v1/balance/blockchain');
    return BlockchainBalance.fromJson(jsonDecode(response));
  }

  Future<PaymentResponse> payLightningInvoice(Payment data) async {
    String response = await _postRequest('/v2/router/send', data.toJson());
    if (response.contains('SUCCEEDED')) {
      return PaymentResponse('SUCCESS', hackOutThePaymentHash(response));
    } else if (response.contains('error')) {
      return PaymentResponse('ERROR', 'Invoice has already been paid');
    } else if (response.contains('IN_FLIGHT')) {
      return PaymentResponse('NO ROUTE', '');
    }
    return PaymentResponse('FAILED', hackOutThePaymentHash(response));
  }

  //TODO: parse the lightning payment response correctly
  /// Look for the first instance of "payment_hash" followed by 64 hex characters and return those characters
  String hackOutThePaymentHash(String response) {
    RegExp reg1 = RegExp(r'("payment_hash":"[0-9a-fA-F]{64})');
    Match? firstMatch = reg1.firstMatch(response);
    if (firstMatch == null) return '';
    String firstMatchString =
        response.substring(firstMatch.start, firstMatch.end);
    return firstMatchString.substring(firstMatchString.length - 64);
  }

  Future<Invoice> createInvoice(InvoiceRequest data) async {
    String response = await _postRequest('/v1/invoices', data.toJson());
    return Invoice.fromJson(jsonDecode(response));
  }

  Future<Invoice> getInvoice(String rHash) async {
    String hex = base64ToHex(rHash);
    String response = await _getRequest('/v1/invoice/$hex');
    return Invoice.fromJson(jsonDecode(response));
  }

  String base64ToHex(String source) =>
      base64Decode(LineSplitter.split(source).join())
          .map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join();

  Future<String> _getRequest(String route) => _request(route, 'get', null);

  Future<String> _postRequest(String route, dynamic data) =>
      _request(route, 'post', data);

  Future<String> _request(
    String route,
    String method,
    Map<String, dynamic>? data,
  ) async {
    final String host = await SecureStorage.readValue('host') ?? '';
    final String restPort = await SecureStorage.readValue('restPort') ?? '';
    int port = int.parse(restPort);
    final String macaroon = await SecureStorage.readValue('macaroon') ?? '';
    // const String host = 'https://10.0.2.2';
    // const int port = 8082;
    // //!Admin Macaroon HEX
    // const String macaroonHex =
    //     '0201036c6e6402f801030a10c01c88e04f42bb66550b480a5580f1411201301a160a0761646472657373120472656164120577726974651a130a04696e666f120472656164120577726974651a170a08696e766f69636573120472656164120577726974651a210a086d616361726f6f6e120867656e6572617465120472656164120577726974651a160a076d657373616765120472656164120577726974651a170a086f6666636861696e120472656164120577726974651a160a076f6e636861696e120472656164120577726974651a140a057065657273120472656164120577726974651a180a067369676e6572120867656e657261746512047265616400000620a857db5bf3c465433105712d8df2d2dcff300efa662dda470a1a23c5f3234d66';

    String url = _getURL(host, port, route);
    Map<String, String> headers = {
      'Grpc-Metadata-macaroon': macaroon,
      'Content-Type': 'application/json',
    };

    return _restReq(headers, url, method, data);
  }

  _getURL(
    String host,
    int port,
    String route,
  ) {
    var baseUrl = '$host:$port';

    if (baseUrl[baseUrl.length - 1] == '/') {
      baseUrl = baseUrl.substring(0, -1);
    }

    return '$baseUrl$route';
  }

  Future<String> _restReq(
    Map<String, String> headers,
    String url,
    String method,
    Map<String, dynamic>? data,
  ) async {
    late http.Response response;

    if (method == 'get') {
      response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
    } else if (method == 'post') {
      response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(
          data,
        ),
      );
    }

    return response.body;
  }
}
