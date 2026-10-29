import 'package:flutter/material.dart';

/// Reusable button strictly implemented using [ElevatedButton] or [OutlinedButton].
/// Supports icons, loading state via CircularProgressIndicator, disabled state, and custom colors.
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 48,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    Widget childContent;
    if (isLoading) {
      childContent = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined
                ? (backgroundColor ?? const Color(0xFFB48D54))
                : Colors.white,
          ),
        ),
      );
    } else if (icon != null) {
      childContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else {
      childContent = Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    Widget button;
    if (isOutlined) {
      button = OutlinedButton(
        onPressed: effectiveOnPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? backgroundColor ?? const Color(0xFFB48D54),
          side: BorderSide(
            color: backgroundColor ?? const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          minimumSize: Size(width ?? 0, height),
        ),
        child: childContent,
      );
    } else {
      button = ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? const Color(0xFFB48D54),
          foregroundColor: textColor ?? Colors.white,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          minimumSize: Size(width ?? 0, height),
        ),
        child: childContent,
      );
    }

    if (width != null) {
      return SizedBox(width: width, child: button);
    }

    return button;
  }
}
