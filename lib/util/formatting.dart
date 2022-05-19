import 'dart:convert';
import 'package:intl/intl.dart';

class Formatting {
  static DateFormat formatter = DateFormat('MM/dd/yyyy');

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

  static String timestampToDateTime(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return formatter.format(date);
  }

  static String timestampNanoSecondsToDate(int creationTimeNanoSeconds) {
    DateTime date = DateTime.fromMicrosecondsSinceEpoch(
        (creationTimeNanoSeconds / 1000).round());
    return formatter.format(date);
  }
}
