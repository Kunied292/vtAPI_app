import 'package:flutter/material.dart';
import '../const/my_const.dart';

/// Reusable TextField widget used across Sign In, Sign Up, and other screens.
class VTTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final bool obscureText;
  final VoidCallback? onObscureToggle;

  const VTTextField({
    super.key,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.onChanged,
    this.obscureText = true,
    this.onObscureToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: isPassword ? obscureText : false,
      style: textDescription.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: textDescription.copyWith(color: Colors.grey),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onObscureToggle,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: vtAccent, width: 2),
        ),
      ),
    );
  }
}
