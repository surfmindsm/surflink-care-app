import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool loading;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const LoadingButton({
    super.key,
    this.onPressed,
    required this.child,
    this.loading = false,
    this.width,
    this.height = 48,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              )
            : child,
      ),
    );
  }
}
