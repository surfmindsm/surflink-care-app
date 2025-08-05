import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final Color? borderColor;
  final VoidCallback? onPressed;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    this.borderColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: BorderSide(
            color: borderColor ?? backgroundColor,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: textColor,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
