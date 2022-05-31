import 'dart:convert';
import 'dart:io';
import 'package:firebolt/constants/http_methods.dart';
import 'package:firebolt/database/secure_storage.dart';
import 'package:http/src/response.dart';
import 'package:http_plus/http_plus.dart' as http;

class RestApi {
  Future<Response> getRequest(String route) =>
      _request(route, HTTPMethod.GET, null);

  Future<Response> postRequest(String route, dynamic data) =>
      _request(route, HTTPMethod.POST, data);

  Future<Response> deleteRequest(String route) =>
      _request(route, HTTPMethod.DELETE, null);

  Future<Response> _request(
    String route,
    HTTPMethod method,
    Map<String, dynamic>? data,
  ) async {
    final String host = await SecureStorage.readValue('host') ?? '';
    final String restPort = await SecureStorage.readValue('restPort') ?? '';
    int port = int.parse(restPort);
    final String macaroon = await SecureStorage.readValue('macaroon') ?? '';

    String url = _getURL(host, port, route);
    Map<String, String> headers = {
      'Grpc-Metadata-macaroon': macaroon,
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

  Future<Response> _restReq(
    Map<String, String> headers,
    String url,
    HTTPMethod method,
    Map<String, dynamic>? data,
  ) async {
    late Response response;
    http.HttpPlusClient client = http.HttpPlusClient(
      enableHttp2: true,
      context: SecurityContext(withTrustedRoots: true),
      badCertificateCallback: (cert, host, port) => true,
      connectionTimeout: Duration(seconds: 30),
      autoUncompress: true,
      maintainOpenConnections: true,
      maxOpenConnections: -1,
      enableLogging: false,
    );

    switch (method) {
      case (HTTPMethod.GET):
        response = await client.get(
          Uri.parse(url),
          headers: headers,
        );
        break;
      case (HTTPMethod.POST):
        response = await client.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(
            data,
          ),
        );
        break;
      case (HTTPMethod.DELETE):
        response = await client.delete(
          Uri.parse(url),
          headers: headers,
        );
        break;
    }
    // http.closeAllConnections();

    return response;
  }
}
