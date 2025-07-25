import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

/// Modern loading indicators for the Lightning Network app
class LoadingIndicators {
  LoadingIndicators._();

  /// Primary loading indicator with Lightning theme
  static Widget primary({
    double size = 24.0,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.blue,
        ),
      ),
    );
  }

  /// Bitcoin-colored loading indicator
  static Widget bitcoin({
    double size = 24.0,
    double strokeWidth = 2.0,
  }) {
    return primary(
      size: size,
      color: AppColors.bitcoin,
      strokeWidth: strokeWidth,
    );
  }

  /// Success loading indicator (green)
  static Widget success({
    double size = 24.0,
    double strokeWidth = 2.0,
  }) {
    return primary(
      size: size,
      color: AppColors.green,
      strokeWidth: strokeWidth,
    );
  }

  /// Linear progress indicator with Lightning theme
  static Widget linear({
    Color? backgroundColor,
    Color? valueColor,
  }) {
    return LinearProgressIndicator(
      backgroundColor: backgroundColor ?? AppColors.grey.withOpacity(0.3),
      valueColor: AlwaysStoppedAnimation<Color>(
        valueColor ?? AppColors.blue,
      ),
    );
  }

  /// Full screen loading overlay
  static Widget overlay({
    required String message,
    bool isVisible = true,
  }) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      color: AppColors.black.withOpacity(0.8),
      child: Center(
        child: Card(
          elevation: 8,
          color: AppColors.black2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                primary(size: 48),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shimmer loading effect for list items
  static Widget shimmer({
    required Widget child,
    bool isLoading = true,
  }) {
    if (!isLoading) return child;

    return ShimmerWidget(child: child);
  }
}

/// Shimmer effect widget
class ShimmerWidget extends StatefulWidget {
  const ShimmerWidget({super.key, required this.child});

  final Widget child;

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Colors.transparent,
                AppColors.grey,
                Colors.transparent,
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Loading list item for shimmer effect
class LoadingListItem extends StatelessWidget {
  const LoadingListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading button state
class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? LoadingIndicators.primary(size: 20, color: AppColors.white)
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
