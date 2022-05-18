import 'dart:convert';

class Formatting {
  static formatHost(String host) {
    return host.replaceFirst('lndconnect', 'https');
  }

  static formatMacaroon(String macaroon) {
    return macaroon.replaceFirst('&', '=');
  }

  static String base64ToHex(String source) =>
      base64Decode(LineSplitter.split(source).join())
          .map((e) => e.toRadixString(16).padLeft(2, '0'))
          .join();
}
