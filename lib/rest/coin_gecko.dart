import '../services/price_service.dart';

class CoinGecko {
  static Future<double> fetchBtcExchangeRate() async {
    final priceService = PriceService();
    try {
      final bitcoinPrice = await priceService.getBitcoinPrice();
      return bitcoinPrice.currentPrice;
    } catch (ex) {
      throw Exception(ex);
    }
  }

  static Future<bool> serverStatus() async {
    final priceService = PriceService();
    try {
      await priceService.getBitcoinPrice();
      return true;
    } catch (ex) {
      return false;
    }
  }
}
