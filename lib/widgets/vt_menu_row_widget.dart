import 'package:flutter/material.dart';
import '../const/my_const.dart';

/// Reusable menu row widget used across Profile, Manage Account, and Settings screens.
class VTMenuRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? subtitle;
  final VoidCallback? onTap;

  const VTMenuRow({
    super.key,
    required this.icon,
    required this.text,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.onSurface,
                size: 24,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: textLabel.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: textDescription.copyWith(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
