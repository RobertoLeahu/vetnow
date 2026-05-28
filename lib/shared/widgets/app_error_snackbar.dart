import 'package:flutter/material.dart';

class AppErrorSnackBar {
  static void show(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: colorScheme.errorContainer,
        content: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
