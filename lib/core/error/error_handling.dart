import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/utils/app_colors.dart';
import '../../shared/widgets/common/common_widgets.dart';

/// Modern error handling and display utilities

/// Custom exception types for better error categorization
abstract class AppException implements Exception {
  const AppException(this.message, [this.code]);
  
  final String message;
  final String? code;
  
  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

class LightningException extends AppException {
  const LightningException(super.message, [super.code]);
}

class BitcoinException extends AppException {
  const BitcoinException(super.message, [super.code]);
}

class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}

class AuthenticationException extends AppException {
  const AuthenticationException(super.message, [super.code]);
}

/// Error state for UI components
@immutable
class ErrorState {
  const ErrorState({
    required this.message,
    this.title,
    this.code,
    this.isRetryable = true,
    this.exception,
  });

  final String message;
  final String? title;
  final String? code;
  final bool isRetryable;
  final Exception? exception;

  /// Create error state from exception
  factory ErrorState.fromException(Exception exception) {
    if (exception is AppException) {
      return ErrorState(
        message: exception.message,
        code: exception.code,
        exception: exception,
        isRetryable: exception is! ValidationException,
      );
    }
    
    return ErrorState(
      message: exception.toString(),
      exception: exception,
    );
  }

  /// Create network error
  factory ErrorState.network([String? message]) {
    return ErrorState(
      title: 'Connection Error',
      message: message ?? 'Please check your internet connection and try again.',
      isRetryable: true,
    );
  }

  /// Create lightning network error
  factory ErrorState.lightning([String? message]) {
    return ErrorState(
      title: 'Lightning Network Error',
      message: message ?? 'Failed to connect to Lightning Network.',
      isRetryable: true,
    );
  }

  /// Create validation error
  factory ErrorState.validation(String message) {
    return ErrorState(
      title: 'Validation Error',
      message: message,
      isRetryable: false,
    );
  }

  /// Create unknown error
  factory ErrorState.unknown([String? message]) {
    return ErrorState(
      title: 'Unknown Error',
      message: message ?? 'An unexpected error occurred.',
      isRetryable: true,
    );
  }
}

/// Error display widget
class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({
    super.key,
    required this.error,
    this.onRetry,
    this.showDetails = false,
    this.compact = false,
  });

  final ErrorState error;
  final VoidCallback? onRetry;
  final bool showDetails;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _CompactErrorDisplay(
        error: error,
        onRetry: onRetry,
      );
    }

    return _FullErrorDisplay(
      error: error,
      onRetry: onRetry,
      showDetails: showDetails,
    );
  }
}

/// Full error display with details
class _FullErrorDisplay extends StatelessWidget {
  const _FullErrorDisplay({
    required this.error,
    this.onRetry,
    this.showDetails = false,
  });

  final ErrorState error;
  final VoidCallback? onRetry;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      backgroundColor: AppColors.error.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error.title ?? 'Error',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            error.message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.white,
            ),
          ),
          if (showDetails && error.code != null) ...[
            const SizedBox(height: 8),
            Text(
              'Error Code: ${error.code}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.grey,
                fontFamily: 'monospace',
              ),
            ),
          ],
          if (error.isRetryable && onRetry != null) ...[
            const SizedBox(height: 16),
            CustomButton(
              text: 'Try Again',
              onPressed: onRetry,
              style: CustomButtonStyle.secondary,
              size: ButtonSize.small,
              icon: Icons.refresh,
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact error display for small spaces
class _CompactErrorDisplay extends StatelessWidget {
  const _CompactErrorDisplay({
    required this.error,
    this.onRetry,
  });

  final ErrorState error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error.message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (error.isRetryable && onRetry != null) ...[
            const SizedBox(width: 8),
            CustomIconButton(
              icon: Icons.refresh,
              onPressed: onRetry,
              size: 16,
              color: AppColors.error,
            ),
          ],
        ],
      ),
    );
  }
}

/// Snackbar for error notifications
class ErrorSnackBar {
  static void show(BuildContext context, ErrorState error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error.message,
                style: const TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Global error handler provider
final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  return ErrorHandler();
});

/// Error handler service
class ErrorHandler {
  /// Handle and categorize exceptions
  ErrorState handleException(Exception exception) {
    if (exception is AppException) {
      return ErrorState.fromException(exception);
    }

    // Categorize common errors
    final message = exception.toString().toLowerCase();
    
    if (message.contains('network') || 
        message.contains('connection') ||
        message.contains('timeout')) {
      return ErrorState.network(exception.toString());
    }

    if (message.contains('lightning') ||
        message.contains('channel') ||
        message.contains('invoice')) {
      return ErrorState.lightning(exception.toString());
    }

    return ErrorState.unknown(exception.toString());
  }

  /// Log error for debugging
  void logError(Exception exception, [StackTrace? stackTrace]) {
    // In production, you would send this to a logging service
    debugPrint('Error: $exception');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }
}

/// Mixin for handling errors in widgets
mixin ErrorHandlingMixin {
  void handleError(BuildContext context, Exception exception) {
    final errorHandler = ProviderScope.containerOf(context).read(errorHandlerProvider);
    final errorState = errorHandler.handleException(exception);
    errorHandler.logError(exception);
    
    ErrorSnackBar.show(context, errorState);
  }

  void showSuccess(BuildContext context, String message) {
    ErrorSnackBar.showSuccess(context, message);
  }
}
