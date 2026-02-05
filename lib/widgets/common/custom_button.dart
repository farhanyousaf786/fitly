import 'package:flutter/material.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? borderRadius;
  final Widget? icon;
  final bool isOutlined;
  final bool isTextButton;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
    this.backgroundColor,
    this.textColor,
    this.height,
    this.borderRadius,
    this.icon,
    this.isOutlined = false,
    this.isTextButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final content = _buildContent();

    if (isTextButton) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle as ButtonStyle?,
        child: content,
      );
    } else if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle as ButtonStyle?,
        child: content,
      );
    } else {
      return ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle as ButtonStyle?,
        child: content,
      );
    }
  }

  Widget _buildContent() {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor ?? Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [icon!, const SizedBox(width: 8), Text(text)],
      );
    }

    return Text(text);
  }

  ButtonStyle _getButtonStyle() {
    final borderRadiusValue = borderRadius ?? 12.0;
    final heightValue = height ?? 48.0;

    if (isTextButton) {
      return TextButton.styleFrom(
        minimumSize: fullWidth ? Size(double.infinity, heightValue) : null,
        textStyle: AppTextStyles.button.copyWith(
          color: textColor ?? AppColors.primary,
        ),
        foregroundColor: textColor ?? AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusValue),
        ),
      );
    } else if (isOutlined) {
      return OutlinedButton.styleFrom(
        minimumSize: fullWidth ? Size(double.infinity, heightValue) : null,
        textStyle: AppTextStyles.button.copyWith(
          color: textColor ?? AppColors.primary,
        ),
        foregroundColor: textColor ?? AppColors.primary,
        side: BorderSide(color: backgroundColor ?? AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusValue),
        ),
      );
    } else {
      return ElevatedButton.styleFrom(
        minimumSize: fullWidth ? Size(double.infinity, heightValue) : null,
        textStyle: AppTextStyles.button.copyWith(
          color: textColor ?? Colors.white,
        ),
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: textColor ?? Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusValue),
        ),
      );
    }
  }
}

// Button variants for easier usage
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final Widget? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      fullWidth: fullWidth,
      icon: icon,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final Widget? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      fullWidth: fullWidth,
      icon: icon,
      isOutlined: true,
      backgroundColor: AppColors.primary,
      textColor: AppColors.primary,
    );
  }
}

class SuccessButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final Widget? icon;

  const SuccessButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      fullWidth: fullWidth,
      icon: icon,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
    );
  }
}

class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final Widget? icon;

  const DangerButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      fullWidth: fullWidth,
      icon: icon,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
    );
  }
}

class TextLinkButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const TextLinkButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isTextButton: true,
      textColor: AppColors.primary,
    );
  }
}

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(50),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: color ?? AppColors.textSecondary,
            size: size ?? 24,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}

class AppFloatingActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;

  const AppFloatingActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: backgroundColor != null
            ? null
            : const LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: backgroundColor ?? AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Icon(icon, color: foregroundColor ?? Colors.white, size: 24),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
