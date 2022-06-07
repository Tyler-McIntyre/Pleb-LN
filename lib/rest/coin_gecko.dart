import 'package:coingecko_api/coingecko_api.dart';
import 'package:coingecko_api/data/exchange_rate.dart';
import 'package:coingecko_api/coingecko_result.dart';

class CoinGecko {
  static Future<double> fetchBtcExchangeRate() async {
    CoinGeckoApi api = CoinGeckoApi();
    CoinGeckoResult<Map<String, ExchangeRate>> exchanges;
    try {
      exchanges = await api.exchangeRates.getBtcExchangeRates();
    } catch (ex) {
      throw Exception(ex);
    }

    double usdToBtcRate = exchanges.data['usd']!.value;

    return usdToBtcRate;
  }
}
