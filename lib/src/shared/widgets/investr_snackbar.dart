import 'package:flutter/material.dart';
import '../../shared/theme/app_theme.dart';

class InvestrSnackBar {
  static void show(
    BuildContext context,
    String message, {
    VoidCallback? onUndo,
    String undoLabel = 'Undo',
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        backgroundColor: isError
            ? AppTheme.errorRed
            : null, // Use theme default if not error
        action: onUndo != null
            ? SnackBarAction(
                label: undoLabel,
                onPressed: onUndo,
                textColor: AppTheme.primaryGreen,
              )
            : null,
      ),
    );
  }
}
