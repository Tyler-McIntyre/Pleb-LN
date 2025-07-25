import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Customizable snackbar utilities
class AppSnackBar {
  AppSnackBar._();

  /// Show error snackbar
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 5),
  }) {
    final cleanMessage = message.replaceAll('Exception:', '').trim();

    final snackBar = SnackBar(
      duration: duration,
      content: Text(
        cleanMessage,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Show success snackbar
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final snackBar = SnackBar(
      duration: duration,
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Show info snackbar
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final snackBar = SnackBar(
      duration: duration,
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: AppColors.info,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Show warning snackbar
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final snackBar = SnackBar(
      duration: duration,
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: AppColors.warning,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Show invalid input snackbar
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showInvalid(
    BuildContext context,
    String input, {
    Duration duration = const Duration(seconds: 3),
  }) {
    return showError(context, 'Invalid $input', duration: duration);
  }

  /// Show coming soon snackbar
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showComingSoon(
    BuildContext context,
    String feature, {
    Duration duration = const Duration(seconds: 3),
  }) {
    return showInfo(context, 'Coming Soon -> $feature!', duration: duration);
  }
}
