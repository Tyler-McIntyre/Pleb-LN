import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'balance_state.freezed.dart';

/// Modern balance state management with proper error handling

/// Bitcoin balance information
@freezed
class BitcoinBalance with _$BitcoinBalance {
  const factory BitcoinBalance({
    @Default(0) int confirmedBalance,
    @Default(0) int unconfirmedBalance,
    @Default(0) int totalBalance,
    @Default(0) int lockedBalance,
  }) = _BitcoinBalance;

  /// Get total balance in satoshis
  int get totalSats => totalBalance;

  /// Get total balance in BTC
  double get totalBtc => totalBalance / 100000000.0;

  /// Get available balance (confirmed - locked)
  int get availableBalance => confirmedBalance - lockedBalance;

  /// Check if wallet has sufficient balance
  bool hasSufficientBalance(int requiredAmount) {
    return availableBalance >= requiredAmount;
  }
}

/// Lightning channel balance information
@freezed
class LightningBalance with _$LightningBalance {
  const factory LightningBalance({
    @Default(0) int localBalance,
    @Default(0) int remoteBalance,
    @Default(0) int unsettledLocalBalance,
    @Default(0) int unsettledRemoteBalance,
    @Default(0) int pendingOpenLocalBalance,
    @Default(0) int pendingOpenRemoteBalance,
  }) = _LightningBalance;

  /// Get total local balance including unsettled
  int get totalLocalBalance => localBalance + unsettledLocalBalance;

  /// Get total remote balance including unsettled
  int get totalRemoteBalance => remoteBalance + unsettledRemoteBalance;

  /// Get total channel capacity
  int get totalCapacity => totalLocalBalance + totalRemoteBalance;

  /// Get local balance ratio (0.0 to 1.0)
  double get localBalanceRatio {
    if (totalCapacity == 0) return 0.0;
    return totalLocalBalance / totalCapacity;
  }

  /// Get remote balance ratio (0.0 to 1.0)
  double get remoteBalanceRatio {
    if (totalCapacity == 0) return 0.0;
    return totalRemoteBalance / totalCapacity;
  }

  /// Check if channels are balanced (within threshold)
  bool get isBalanced {
    const balanceThreshold = 0.3; // 30%
    return localBalanceRatio >= balanceThreshold && 
           localBalanceRatio <= (1.0 - balanceThreshold);
  }
}

/// Combined balance state
@freezed
class BalanceState with _$BalanceState {
  const factory BalanceState({
    @Default(BitcoinBalance()) BitcoinBalance onChain,
    @Default(LightningBalance()) LightningBalance lightning,
    @Default(false) bool isLoading,
    @Default(false) bool isRefreshing,
    String? error,
    DateTime? lastUpdated,
  }) = _BalanceState;

  /// Get total balance across on-chain and lightning
  int get totalBalance => onChain.totalBalance + lightning.localBalance;

  /// Get total balance in BTC
  double get totalBtc => totalBalance / 100000000.0;

  /// Check if any balance data is available
  bool get hasBalance => totalBalance > 0;
}

/// Balance state notifier with modern patterns
class BalanceNotifier extends StateNotifier<BalanceState> {
  BalanceNotifier() : super(const BalanceState());

  /// Update on-chain balance
  void updateOnChainBalance(BitcoinBalance balance) {
    state = state.copyWith(
      onChain: balance,
      lastUpdated: DateTime.now(),
      error: null,
    );
  }

  /// Update lightning balance
  void updateLightningBalance(LightningBalance balance) {
    state = state.copyWith(
      lightning: balance,
      lastUpdated: DateTime.now(),
      error: null,
    );
  }

  /// Set loading state
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// Set refreshing state
  void setRefreshing(bool isRefreshing) {
    state = state.copyWith(isRefreshing: isRefreshing);
  }

  /// Set error state
  void setError(String error) {
    state = state.copyWith(
      error: error,
      isLoading: false,
      isRefreshing: false,
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh all balances
  Future<void> refreshBalances() async {
    setRefreshing(true);
    try {
      // Implement balance refresh logic here
      // This would call your LND RPC methods
      await Future.delayed(const Duration(seconds: 1)); // Placeholder
      setRefreshing(false);
    } catch (e) {
      setError('Failed to refresh balances: $e');
    }
  }
}

/// Main balance provider
final balanceProvider = StateNotifierProvider<BalanceNotifier, BalanceState>(
  (ref) => BalanceNotifier(),
);

/// Helper providers for specific balance data
final onChainBalanceProvider = Provider<BitcoinBalance>((ref) {
  return ref.watch(balanceProvider.select((state) => state.onChain));
});

final lightningBalanceProvider = Provider<LightningBalance>((ref) {
  return ref.watch(balanceProvider.select((state) => state.lightning));
});

final totalBalanceProvider = Provider<int>((ref) {
  return ref.watch(balanceProvider.select((state) => state.totalBalance));
});

final totalBalanceBtcProvider = Provider<double>((ref) {
  return ref.watch(balanceProvider.select((state) => state.totalBtc));
});

final balanceLoadingProvider = Provider<bool>((ref) {
  return ref.watch(balanceProvider.select((state) => state.isLoading));
});

final balanceErrorProvider = Provider<String?>((ref) {
  return ref.watch(balanceProvider.select((state) => state.error));
});

/// Auto-refresh balance every 30 seconds
final balanceAutoRefreshProvider = StreamProvider<void>((ref) {
  return Stream.periodic(const Duration(seconds: 30), (_) {
    ref.read(balanceProvider.notifier).refreshBalances();
  });
});
