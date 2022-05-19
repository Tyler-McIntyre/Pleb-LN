import '../util/formatting.dart';

class LNDConnect {
  late String host;
  late String port;
  late String macaroonHexFormat;
  bool useTor = false;

  static Map<String, RegExp> _lndConnectParsePatterns = {
    'findHost': RegExp('.*(?=:)'), //Replace LNDConnect with https?
    'findPort': RegExp('(?<=:)[0-9]*'),
    'findMacaroon': RegExp('(?<=macaroon=).*(?<=&)') //convert this to hex
  };

  static Future<LNDConnect> parseConnectionString(
      String connectionString) async {
    //TODO: Error handling for null matches
    LNDConnect lndConnectParams = LNDConnect();
    String? hostMatch = _lndConnectParsePatterns['findHost']
        ?.firstMatch(connectionString)!
        .group(0);
    String? portMatch = _lndConnectParsePatterns['findPort']
        ?.allMatches(connectionString)
        .last
        .group(0);
    String? macaroonMatch = _lndConnectParsePatterns['findMacaroon']
        ?.firstMatch(connectionString)!
        .group(0);

    hostMatch != null
        ? lndConnectParams.host = Formatting.formatHost(hostMatch)
        : lndConnectParams.host = '';
    portMatch != null
        ? lndConnectParams.port = portMatch
        : lndConnectParams.port = '';
    macaroonMatch != null
        ? lndConnectParams.macaroonHexFormat =
            Formatting.base64ToHex(Formatting.formatMacaroon(macaroonMatch))
        : lndConnectParams.macaroonHexFormat = '';

    return lndConnectParams;
  }
}
