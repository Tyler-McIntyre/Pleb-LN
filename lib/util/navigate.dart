import 'refresh_timer.dart';

class Navigate {
  /// Cancels the [RefreshTimer] and executes the provided navigation [action].
  static Future<T?> toRoute<T>(Future<T?> Function() action) {
    if (RefreshTimer.refreshTimer != null) {
      RefreshTimer.refreshTimer!.cancel();
    }
    return action();
  }
}
