import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../rest/coin_gecko.dart';

class CoinGeckoProvider {
  static FutureProvider<bool> serverStatus =
      FutureProvider<bool>((ref) async => await CoinGecko.serverStatus());
  static FutureProvider<double> usdToBtcRate = FutureProvider<double>(
      (ref) async => await CoinGecko.fetchBtcExchangeRate());
}
