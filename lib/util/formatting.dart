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

  static DateTime timestampToDateTime(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return date;
  }

  static DateTime timestampNanoSecondsToDate(int creationTimeNanoSeconds) {
    DateTime date = DateTime.fromMicrosecondsSinceEpoch(
        (creationTimeNanoSeconds / 1000).round());
    return date;
  }

  static String dateTimeToShortDate(DateTime date) {
    return formatter.format(date);
  }

  static Duration getDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    int twoDigitMinutes =
        int.parse(twoDigits(duration.inMinutes.remainder(60)));
    int twoDigitSeconds =
        int.parse(twoDigits(duration.inSeconds.remainder(60)));
    return Duration(
        hours: duration.inHours,
        minutes: twoDigitMinutes,
        seconds: twoDigitSeconds);
  }

  static DateTime getExpirationDate(int timestamp, int expiryInSeconds) {
    DateTime formattedTimestamp = Formatting.timestampToDateTime(timestamp);
    DateTime expirationDate =
        formattedTimestamp.add(Duration(seconds: expiryInSeconds));
    return expirationDate.toLocal();
  }
}
