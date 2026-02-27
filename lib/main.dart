import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/signin_screen.dart';
import 'const/my_const.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const VTScannerApp());
}

class VTScannerApp extends StatelessWidget {
  const VTScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VT Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: vtBackground,
        brightness: Brightness.dark,
        fontFamily: 'Courier', // ใช้ฟอนต์แนว Tech
        appBarTheme: const AppBarTheme(
          backgroundColor: vtBackground,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: SignInScreen(),
    );
  }
}
