import 'package:flutter/material.dart';
import '../const/my_const.dart';
import '../widgets/custom_app_bar_widget.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'HELP & SUPPORT', centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildHelpSection(
            context,
            "How to use Malware Scanner?",
            "You can choose to scan files from your device, input a URL to check website safety, or scan all installed apps on your device to immediately identify malicious applications.",
          ),
          const SizedBox(height: 20),
          _buildHelpSection(
            context,
            "What implies a 'Safe' result?",
            "A file or URL is marked safe if no vendor flag it as malicious. However, we recommend maintaining best practices even if marked safe.",
          ),
          const SizedBox(height: 20),
          _buildHelpSection(
            context,
            "Need further assistance?",
            "If you experience any issue, please reach out to our support team at support@vtscanner.app.",
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(
    BuildContext context,
    String title,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textLabel.copyWith(
              color: vtAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: textDescription.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
