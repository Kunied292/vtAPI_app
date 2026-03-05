import 'package:flutter/material.dart';
import '../const/my_const.dart';
import '../widgets/custom_app_bar_widget.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vtBackground,
      appBar: const CustomAppBar(title: 'SETTINGS'),
      body: Center(child: Text('under development', style: textDescription)),
    );
  }
}
