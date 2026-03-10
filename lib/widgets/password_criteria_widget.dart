import 'package:flutter/material.dart';
import '../const/my_const.dart';

/// Reusable password criteria checklist widget.
/// Used in Sign Up and Change Password screens.
class PasswordCriteriaWidget extends StatelessWidget {
  final String text;
  final bool isMet;

  const PasswordCriteriaWidget({
    super.key,
    required this.text,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, left: 10.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? vtGreen : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? vtGreen : Colors.grey,
              fontFamily: 'Courier',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
