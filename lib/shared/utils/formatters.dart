import 'package:intl/intl.dart';
import 'package:money_formatter/money_formatter.dart';

/// Formatting utilities for the application
class AppFormatters {
  AppFormatters._();

  /// Format satoshis to readable string
  static String formatSatoshis(int satoshis, {bool showUnit = true}) {
    final formatted = MoneyFormatter(
      amount: satoshis.toDouble(),
    ).output.withoutFractionDigits;
    
    return showUnit ? '$formatted sats' : formatted;
  }

  /// Format satoshis to BTC
  static String formatSatoshisToBtc(int satoshis, {int decimalPlaces = 8}) {
    final btc = satoshis / 100000000; // 1 BTC = 100,000,000 satoshis
    return btc.toStringAsFixed(decimalPlaces);
  }

  /// Format number with thousand separators
  static String formatNumber(num number) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(number);
  }

  /// Format percentage
  static String formatPercentage(double percentage, {int decimalPlaces = 1}) {
    return '${percentage.toStringAsFixed(decimalPlaces)}%';
  }

  /// Format date and time
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('MMM dd, yyyy HH:mm');
    return formatter.format(dateTime);
  }

  /// Format date only
  static String formatDate(DateTime dateTime) {
    final formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(dateTime);
  }

  /// Format time only
  static String formatTime(DateTime dateTime) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }

  /// Format duration in a human readable way
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Truncate string with ellipsis
  static String truncateString(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  /// Truncate from middle (useful for addresses/hashes)
  static String truncateMiddle(String text, {int startLength = 6, int endLength = 6}) {
    if (text.length <= startLength + endLength + 3) {
      return text;
    }
    return '${text.substring(0, startLength)}...${text.substring(text.length - endLength)}';
  }
}
