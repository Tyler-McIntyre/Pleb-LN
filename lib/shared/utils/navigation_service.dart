import 'package:flutter/material.dart';

/// Navigation service for consistent routing throughout the app
class NavigationService {
  NavigationService._();

  /// Navigate to a new route
  static Future<T?> navigateTo<T extends Object?>(
    BuildContext context,
    Widget destination, {
    bool replace = false,
    bool clearStack = false,
  }) async {
    if (clearStack) {
      return Navigator.of(context).pushAndRemoveUntil(
        _createRoute(destination),
        (route) => false,
      );
    } else if (replace) {
      return Navigator.of(context).pushReplacement(_createRoute(destination));
    } else {
      return Navigator.of(context).push(_createRoute(destination));
    }
  }

  /// Navigate back
  static void goBack<T extends Object?>(BuildContext context, [T? result]) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(result);
    }
  }

  /// Navigate to route with custom transition
  static Future<T?> navigateWithTransition<T extends Object?>(
    BuildContext context,
    Widget destination, {
    RouteTransitionsBuilder? transitionBuilder,
    Duration transitionDuration = const Duration(milliseconds: 300),
    bool replace = false,
  }) async {
    final route = PageRouteBuilder<T>(
      pageBuilder: (context, animation, _) => destination,
      transitionDuration: transitionDuration,
      transitionsBuilder: transitionBuilder ?? _defaultTransition,
    );

    if (replace) {
      return Navigator.of(context).pushReplacement(route);
    } else {
      return Navigator.of(context).push(route);
    }
  }

  /// Navigate to route and clear all previous routes
  static Future<T?> navigateAndClearStack<T extends Object?>(
    BuildContext context,
    Widget destination,
  ) async {
    return Navigator.of(context).pushAndRemoveUntil(
      _createRoute(destination),
      (route) => false,
    );
  }

  /// Show modal bottom sheet
  static Future<T?> showBottomSheet<T>(
    BuildContext context,
    Widget content, {
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => content,
    );
  }

  /// Show dialog
  static Future<T?> showAppDialog<T>(
    BuildContext context,
    Widget dialog, {
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => dialog,
    );
  }

  /// Create a material page route
  static MaterialPageRoute<T> _createRoute<T>(Widget destination) {
    return MaterialPageRoute<T>(builder: (context) => destination);
  }

  /// Default transition animation
  static Widget _defaultTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  /// Fade transition
  static Widget fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  /// Scale transition
  static Widget scaleTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: animation,
      child: child,
    );
  }
}
