import '../util/formatting.dart';

class LNDConnect {
  String host = '';
  String port = '';
  String macaroonHexFormat = '';
  bool useTor = false;

  static Map<String, RegExp> _lndConnectParsePatterns = {
    'findHost': RegExp('.*(?=:)'),
    'findPort': RegExp('(?<=:)[0-9]*'),
    'findMacaroon': RegExp('(?<=macaroon=).*[&]')
  };

  static LNDConnect parseConnectionString(String connectionString) {
    LNDConnect lndConnectParams = LNDConnect();
    String? hostMatch;
    String? portMatch;
    String? macaroonMatch;
    try {
      hostMatch = _lndConnectParsePatterns['findHost']
          ?.firstMatch(connectionString)!
          .group(0);
      portMatch = _lndConnectParsePatterns['findPort']
          ?.allMatches(connectionString)
          .last
          .group(0);

      macaroonMatch = _lndConnectParsePatterns['findMacaroon']
          ?.firstMatch(connectionString)!
          .group(0);
    } catch (ex) {
      throw Exception(
          'Invalid LND connection string. Format: lndconnect://{host}:{gRPCPort}?macaroon={macaroon}&cert={cert}');
    }

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
