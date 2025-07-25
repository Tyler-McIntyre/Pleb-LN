import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_state.freezed.dart';

/// Modern state management using Riverpod 2.x patterns

/// App-wide state for the Lightning Network wallet
@freezed
class AppState with _$AppState {
  const factory AppState({
    @Default(false) bool isLoading,
    @Default(false) bool isConnected,
    @Default('') String nodeAlias,
    @Default('') String pubkey,
    String? error,
  }) = _AppState;
}

/// Global app state provider
class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState());

  /// Set loading state
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// Set connection state
  void setConnection(bool isConnected) {
    state = state.copyWith(isConnected: isConnected);
  }

  /// Set node information
  void setNodeInfo({required String alias, required String pubkey}) {
    state = state.copyWith(
      nodeAlias: alias,
      pubkey: pubkey,
    );
  }

  /// Set error state
  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset app state
  void reset() {
    state = const AppState();
  }
}

/// Provider for app state
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(),
);

/// Helper providers for common state checks
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider.select((state) => state.isLoading));
});

final isConnectedProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider.select((state) => state.isConnected));
});

final hasErrorProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider.select((state) => state.error != null));
});

final errorProvider = Provider<String?>((ref) {
  return ref.watch(appStateProvider.select((state) => state.error));
});

final nodeInfoProvider = Provider<({String alias, String pubkey})>((ref) {
  final state = ref.watch(appStateProvider);
  return (alias: state.nodeAlias, pubkey: state.pubkey);
});
