import 'package:flutter/material.dart';
import '../const/my_const.dart';
import '../widgets/custom_app_bar_widget.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'ABOUT APP', centerTitle: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: vtAccent.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.radar, color: vtAccent, size: 60),
            ),
            const SizedBox(height: 30),
            Text(
              "VT SCANNER",
              style: textTitle.copyWith(fontSize: 24, letterSpacing: 2),
            ),
            const SizedBox(height: 10),
            Text(
              "Version 1.0.0",
              style: textDescription.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 40),
            paddingText("Powered by VirusTotal API"),
          ],
        ),
      ),
    );
  }

  Widget paddingText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: textDescription.copyWith(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}
