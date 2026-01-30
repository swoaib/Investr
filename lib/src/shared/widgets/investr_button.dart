import 'package:flutter/material.dart';
import '../../shared/theme/app_theme.dart';

class InvestrButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const InvestrButton({
    required this.text,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.primaryGreen,
          foregroundColor: foregroundColor ?? Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(text),
      );
    } else {
      // Secondary / Neutral Button
      return ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).cardTheme.color,
          foregroundColor:
              foregroundColor ?? Theme.of(context).textTheme.bodyLarge?.color,
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
          side: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    Theme.of(context).primaryColor,
                  ),
                ),
              )
            : Text(text),
      );
    }
  }
}
