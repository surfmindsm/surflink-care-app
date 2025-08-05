import 'package:flutter/material.dart';

enum ButtonType {
  primary,
  secondary,
  text,
  danger,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final Widget? icon;
  final EdgeInsets? padding;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isLoading) {
      return SizedBox(
        width: width,
        height: height ?? 48,
        child: ElevatedButton(
          onPressed: null,
          style: _getButtonStyle(theme),
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    switch (type) {
      case ButtonType.primary:
        return SizedBox(
          width: width,
          height: height ?? 48,
          child: ElevatedButton(
            onPressed: onPressed,
            style: _getButtonStyle(theme),
            child: _buildContent(),
          ),
        );
      case ButtonType.secondary:
        return SizedBox(
          width: width,
          height: height ?? 48,
          child: OutlinedButton(
            onPressed: onPressed,
            style: _getOutlinedButtonStyle(theme),
            child: _buildContent(),
          ),
        );
      case ButtonType.text:
        return SizedBox(
          width: width,
          height: height ?? 48,
          child: TextButton(
            onPressed: onPressed,
            style: _getTextButtonStyle(theme),
            child: _buildContent(),
          ),
        );
      case ButtonType.danger:
        return SizedBox(
          width: width,
          height: height ?? 48,
          child: ElevatedButton(
            onPressed: onPressed,
            style: _getDangerButtonStyle(theme),
            child: _buildContent(),
          ),
        );
    }
  }

  Widget _buildContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }
    return Text(text);
  }

  ButtonStyle _getButtonStyle(ThemeData theme) {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.blue[700],
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  ButtonStyle _getOutlinedButtonStyle(ThemeData theme) {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.blue[700],
      side: BorderSide(color: Colors.blue[700]!),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  ButtonStyle _getTextButtonStyle(ThemeData theme) {
    return TextButton.styleFrom(
      foregroundColor: Colors.blue[700],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  ButtonStyle _getDangerButtonStyle(ThemeData theme) {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.red[600],
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
