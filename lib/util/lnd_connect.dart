class LNDConnect {
  String? host;
  String? port;
  String? macaroonHexFormat;

  static Map<String, RegExp> _lndConnectParsePatterns = {
    'findHost': RegExp('.*(?=:)'), //Replace LNDConnect with https?
    'findPort': RegExp('(?<=:)[0-9]*'),
    'findMacaroon': RegExp('(?<=macaroon=).*') //convert this to hex
  };

  static Future<LNDConnect> parseConnectionString(
      String connectionString) async {
    //create a new instance of LNDConnect
    LNDConnect lndConnectParams = LNDConnect();
    RegExpMatch? hostMatch =
        _lndConnectParsePatterns['findHost']?.firstMatch(connectionString);
    RegExpMatch? portMatch =
        _lndConnectParsePatterns['findPort']?.firstMatch(connectionString);
    RegExpMatch? macaroonMatch =
        _lndConnectParsePatterns['findMacaroon']?.firstMatch(connectionString);

    //iterate through each regex pattern and set the LNDConnect instance properties
    hostMatch != null
        ? lndConnectParams.host = hostMatch.input
        : lndConnectParams.host = null;
    portMatch != null
        ? lndConnectParams.host = portMatch.input
        : lndConnectParams.host = null;
    macaroonMatch != null
        ? lndConnectParams.host = _convertToHex(macaroonMatch.input).toString()
        : lndConnectParams.host = null;

    return lndConnectParams;
  }

  static String _convertToHex(String macaroon) {
    String macaroonAsHexString = '';
    for (int i = 0; i <= macaroon.length - 8; i += 8) {
      final hex = macaroon.substring(i, i + 8);
      macaroonAsHexString = int.parse(hex, radix: 36).toString();
    }
    return macaroonAsHexString;
  }
}
