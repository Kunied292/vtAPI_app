import 'package:flutter/material.dart';
import '../const/my_const.dart';

/// Helper function to show a styled SnackBar consistently across the app.
void showVTSnackBar(
  BuildContext context,
  String message,
  Color backgroundColor,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: textLabel.copyWith(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ),
  );
}
