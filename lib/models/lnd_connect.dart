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
    // //create a new instance of LNDConnect
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

    //iterate through each regex pattern and set the LNDConnect instance properties
    hostMatch != null
        ? lndConnectParams.host = _formatHost(hostMatch)
        : lndConnectParams.host = '';
    portMatch != null
        ? lndConnectParams.port = portMatch
        : lndConnectParams.port = '';
    macaroonMatch != null
        ? lndConnectParams.macaroonHexFormat = _formatMacaroon(macaroonMatch)
        : lndConnectParams.macaroonHexFormat = '';

    return lndConnectParams;
  }

  static _formatHost(String host) {
    return host.replaceFirst('lndconnect', 'https');
  }

  static _formatMacaroon(String macaroon) {
    return macaroon.replaceFirst('&', '=');
  }

  /* In Polar, select a node then find these variable settings under 'connect'
    * Rest host contains your host + port number
    * Select Base64 and copy the admin macaroon
    */
  //!Move to a DB seed script
  // LNDConnect lndConnectParams = LNDConnect();
  //!Android emulator uses 10.0.2.2 as an alias for localHost
  // lndConnectParams.host = 'https://10.0.0.2';
  // lndConnectParams.port = '8082';
  //!Macaroon is in base64
  // lndConnectParams.macaroonHexFormat =
  //     'AgEDbG5kAvgBAwoQXWsJKsn/MYMu3OfS/ZiTCxIBMBoWCgdhZGRyZXNzEgRyZWFkEgV3cml0ZRoTCgRpbmZvEgRyZWFkEgV3cml0ZRoXCghpbnZvaWNlcxIEcmVhZBIFd3JpdGUaIQoIbWFjYXJvb24SCGdlbmVyYXRlEgRyZWFkEgV3cml0ZRoWCgdtZXNzYWdlEgRyZWFkEgV3cml0ZRoXCghvZmZjaGFpbhIEcmVhZBIFd3JpdGUaFgoHb25jaGFpbhIEcmVhZBIFd3JpdGUaFAoFcGVlcnMSBHJlYWQSBXdyaXRlGhgKBnNpZ25lchIIZ2VuZXJhdGUSBHJlYWQAAAYg0zf4WeyEHOW3ETg1rpJogPSH0PGvO4/nECKgM9TFUxE=';
}
