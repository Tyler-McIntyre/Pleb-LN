import 'refresh_timer.dart';

class Navigate {
  static void toRoute(Future<dynamic> route) {
    if (RefreshTimer.refreshTimer != null) {
      RefreshTimer.refreshTimer!.cancel();
    }
    route;
  }
}
