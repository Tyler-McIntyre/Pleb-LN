import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../../core/config/app_config.dart';

/// Custom button with consistent styling
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isDisabled && !isLoading && onPressed != null;
    
    return SizedBox(
      width: width,
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: _getButtonStyle(),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          color: _getContentColor(),
          strokeWidth: 2,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: 8),
          Text(text, style: _getTextStyle()),
        ],
      );
    }

    return Text(text, style: _getTextStyle());
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 36;
      case AppButtonSize.medium:
        return 48;
      case AppButtonSize.large:
        return 56;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }

  ButtonStyle _getButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _getBackgroundColor(),
      foregroundColor: _getContentColor(),
      elevation: AppConfig.defaultElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
        side: _getBorder(),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isDisabled || isLoading) {
      return AppColors.grey.withOpacity(0.3);
    }

    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.blue;
      case AppButtonVariant.secondary:
        return Colors.transparent;
      case AppButtonVariant.success:
        return AppColors.success;
      case AppButtonVariant.error:
        return AppColors.error;
    }
  }

  Color _getContentColor() {
    if (isDisabled || isLoading) {
      return AppColors.grey;
    }

    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.success:
      case AppButtonVariant.error:
        return AppColors.white;
      case AppButtonVariant.secondary:
        return AppColors.blue;
    }
  }

  BorderSide _getBorder() {
    if (variant == AppButtonVariant.secondary) {
      return const BorderSide(color: AppColors.blue, width: 1);
    }
    return BorderSide.none;
  }

  TextStyle _getTextStyle() {
    final fontSize = size == AppButtonSize.small ? 14.0 : 
                    size == AppButtonSize.medium ? 16.0 : 18.0;
    
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: _getContentColor(),
    );
  }
}

enum AppButtonVariant { primary, secondary, success, error }
enum AppButtonSize { small, medium, large }
