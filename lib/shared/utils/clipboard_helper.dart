import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// Clipboard utility functions
class ClipboardHelper {
  ClipboardHelper._();

  /// Copy text to clipboard and show feedback
  static Future<void> copyToClipboard(
    String text,
    BuildContext context, {
    String? successMessage,
  }) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      
      if (context.mounted) {
        final message = successMessage ?? 'Copied to clipboard';
        _showCopyFeedback(context, message);
      }
    } catch (e) {
      if (context.mounted) {
        _showCopyError(context, 'Failed to copy to clipboard');
      }
    }
  }

  /// Get text from clipboard
  static Future<String?> getFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      return clipboardData?.text;
    } catch (e) {
      return null;
    }
  }

  /// Check if clipboard has data
  static Future<bool> hasClipboardData() async {
    try {
      return await Clipboard.hasStrings();
    } catch (e) {
      return false;
    }
  }

  static void _showCopyFeedback(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.success,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void _showCopyError(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.error,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
