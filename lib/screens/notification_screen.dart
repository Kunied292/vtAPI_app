import 'package:flutter/material.dart';
import '../const/my_const.dart';
import '../widgets/custom_app_bar_widget.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'NOTIFICATION'),
      body: Center(child: Text('under development', style: textDescription)),
    );
  }
}
