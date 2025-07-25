import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/price_service.dart';
import '../../../util/app_colors.dart';

/// Bitcoin price display widget
class BitcoinPriceWidget extends ConsumerWidget {
  const BitcoinPriceWidget({
    super.key,
    this.showChange = true,
    this.compact = false,
  });

  final bool showChange;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final priceAsync = ref.watch(bitcoinPriceProvider);
    final marketDataAsync = ref.watch(bitcoinMarketDataProvider);

    return Container(
      padding: EdgeInsets.all(compact ? 8.0 : 16.0),
      decoration: BoxDecoration(
        color: AppColors.black2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.bitcoin.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.currency_bitcoin,
                color: AppColors.bitcoin,
                size: compact ? 16 : 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Bitcoin',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.grey,
                  fontSize: compact ? 12 : 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Price display
          priceAsync.when(
            data: (prices) {
              final usdPrice = prices['usd'] ?? 0.0;
              return Text(
                '\$${usdPrice.toStringAsFixed(2)}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: compact ? 18 : 24,
                ),
              );
            },
            loading: () => _buildLoadingPrice(compact),
            error: (error, stack) => _buildErrorPrice(compact),
          ),
          
          // Price change (if enabled)
          if (showChange) ...[
            const SizedBox(height: 4),
            marketDataAsync.when(
              data: (data) => _buildPriceChange(
                data.priceChangePercentage24h,
                compact,
                theme,
              ),
              loading: () => _buildLoadingChange(compact),
              error: (error, stack) => const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingPrice(bool compact) {
    return Container(
      width: compact ? 80 : 120,
      height: compact ? 18 : 24,
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildErrorPrice(bool compact) {
    return Text(
      'Price unavailable',
      style: TextStyle(
        color: AppColors.error,
        fontSize: compact ? 12 : 14,
      ),
    );
  }

  Widget _buildPriceChange(double changePercent, bool compact, ThemeData theme) {
    final isPositive = changePercent >= 0;
    final color = isPositive ? AppColors.green : AppColors.error;
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: compact ? 12 : 16,
        ),
        const SizedBox(width: 4),
        Text(
          '${changePercent.toStringAsFixed(2)}%',
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: compact ? 10 : 12,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '24h',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.grey,
            fontSize: compact ? 10 : 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingChange(bool compact) {
    return Container(
      width: compact ? 60 : 80,
      height: compact ? 12 : 16,
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Compact price widget for headers/nav bars
class CompactBitcoinPrice extends StatelessWidget {
  const CompactBitcoinPrice({super.key});

  @override
  Widget build(BuildContext context) {
    return const BitcoinPriceWidget(
      compact: true,
      showChange: false,
    );
  }
}

/// Detailed price card for main screens
class DetailedBitcoinPrice extends StatelessWidget {
  const DetailedBitcoinPrice({super.key});

  @override
  Widget build(BuildContext context) {
    return const BitcoinPriceWidget(
      compact: false,
      showChange: true,
    );
  }
}
