import 'dart:convert';
import 'package:firebolt/database/secure_storage.dart';
import 'package:http/http.dart' as http;

class RestApi {
  Future<http.Response> getRequest(String route) =>
      _request(route, 'get', null);

  Future<http.Response> postRequest(String route, dynamic data) =>
      _request(route, 'post', data);

  Future<http.Response> _request(
    String route,
    String method,
    Map<String, dynamic>? data,
  ) async {
    final String host = await SecureStorage.readValue('host') ?? '';
    final String restPort = await SecureStorage.readValue('restPort') ?? '';
    int port = int.parse(restPort);
    final String macaroon = await SecureStorage.readValue('macaroon') ?? '';

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

  Future<http.Response> _restReq(
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

    return response;
  }
}
