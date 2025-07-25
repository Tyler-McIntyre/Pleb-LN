import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modern Bitcoin price service using CoinGecko API directly
class PriceService {
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';
  final Dio _dio;

  PriceService() : _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  /// Get Bitcoin price in multiple currencies
  Future<Map<String, double>> getBitcoinPrice({
    List<String> currencies = const ['usd', 'eur', 'gbp'],
  }) async {
    try {
      final response = await _dio.get(
        '/simple/price',
        queryParameters: {
          'ids': 'bitcoin',
          'vs_currencies': currencies.join(','),
          'include_24hr_change': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final bitcoinData = data['bitcoin'] as Map<String, dynamic>;
        
        final prices = <String, double>{};
        for (final currency in currencies) {
          final price = bitcoinData[currency];
          if (price != null) {
            prices[currency] = (price as num).toDouble();
          }
        }
        
        return prices;
      } else {
        throw PriceException('Failed to fetch price: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw PriceException('Network error: ${e.message}');
    } catch (e) {
      throw PriceException('Unexpected error: $e');
    }
  }

  /// Get detailed Bitcoin market data
  Future<BitcoinMarketData> getBitcoinMarketData() async {
    try {
      final response = await _dio.get(
        '/coins/bitcoin',
        queryParameters: {
          'localization': 'false',
          'tickers': 'false',
          'market_data': 'true',
          'community_data': 'false',
          'developer_data': 'false',
          'sparkline': 'false',
        },
      );

      if (response.statusCode == 200) {
        return BitcoinMarketData.fromJson(response.data);
      } else {
        throw PriceException('Failed to fetch market data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw PriceException('Network error: ${e.message}');
    } catch (e) {
      throw PriceException('Unexpected error: $e');
    }
  }

  /// Get price history for chart
  Future<List<PricePoint>> getPriceHistory({
    int days = 7,
    String currency = 'usd',
  }) async {
    try {
      final response = await _dio.get(
        '/coins/bitcoin/market_chart',
        queryParameters: {
          'vs_currency': currency,
          'days': days.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final prices = data['prices'] as List<dynamic>;
        
        return prices.map((point) {
          final pointData = point as List<dynamic>;
          return PricePoint(
            timestamp: DateTime.fromMillisecondsSinceEpoch(pointData[0].toInt()),
            price: (pointData[1] as num).toDouble(),
          );
        }).toList();
      } else {
        throw PriceException('Failed to fetch price history: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw PriceException('Network error: ${e.message}');
    } catch (e) {
      throw PriceException('Unexpected error: $e');
    }
  }
}

/// Bitcoin market data model
class BitcoinMarketData {
  final double currentPrice;
  final double marketCap;
  final double volume24h;
  final double priceChange24h;
  final double priceChangePercentage24h;

  const BitcoinMarketData({
    required this.currentPrice,
    required this.marketCap,
    required this.volume24h,
    required this.priceChange24h,
    required this.priceChangePercentage24h,
  });

  factory BitcoinMarketData.fromJson(Map<String, dynamic> json) {
    final marketData = json['market_data'] as Map<String, dynamic>;
    
    return BitcoinMarketData(
      currentPrice: (marketData['current_price']['usd'] as num).toDouble(),
      marketCap: (marketData['market_cap']['usd'] as num).toDouble(),
      volume24h: (marketData['total_volume']['usd'] as num).toDouble(),
      priceChange24h: (marketData['price_change_24h'] as num).toDouble(),
      priceChangePercentage24h: (marketData['price_change_percentage_24h'] as num).toDouble(),
    );
  }
}

/// Price point for charts
class PricePoint {
  final DateTime timestamp;
  final double price;

  const PricePoint({
    required this.timestamp,
    required this.price,
  });
}

/// Custom exception for price-related errors
class PriceException implements Exception {
  final String message;
  
  const PriceException(this.message);
  
  @override
  String toString() => 'PriceException: $message';
}

/// Price service provider
final priceServiceProvider = Provider<PriceService>((ref) {
  return PriceService();
});

/// Current Bitcoin price provider
final bitcoinPriceProvider = FutureProvider<Map<String, double>>((ref) async {
  final priceService = ref.read(priceServiceProvider);
  return priceService.getBitcoinPrice();
});

/// Bitcoin market data provider
final bitcoinMarketDataProvider = FutureProvider<BitcoinMarketData>((ref) async {
  final priceService = ref.read(priceServiceProvider);
  return priceService.getBitcoinMarketData();
});

/// Price history provider
final priceHistoryProvider = FutureProvider.family<List<PricePoint>, int>((ref, days) async {
  final priceService = ref.read(priceServiceProvider);
  return priceService.getPriceHistory(days: days);
});

/// Formatted price provider for display
final formattedBitcoinPriceProvider = Provider<String>((ref) {
  final priceAsync = ref.watch(bitcoinPriceProvider);
  
  return priceAsync.when(
    data: (prices) {
      final usdPrice = prices['usd'];
      if (usdPrice != null) {
        return '\$${usdPrice.toStringAsFixed(2)}';
      }
      return 'N/A';
    },
    loading: () => 'Loading...',
    error: (error, stack) => 'Error',
  );
});

/// Price change indicator provider
final priceChangeProvider = Provider<({double change, bool isPositive})>((ref) {
  final marketDataAsync = ref.watch(bitcoinMarketDataProvider);
  
  return marketDataAsync.when(
    data: (data) => (
      change: data.priceChangePercentage24h,
      isPositive: data.priceChangePercentage24h >= 0,
    ),
    loading: () => (change: 0.0, isPositive: true),
    error: (error, stack) => (change: 0.0, isPositive: true),
  );
});
