import 'package:flutter/material.dart';
// ignore_for_file: deprecated_member_use
import '../const/my_const.dart';
import '../widgets/custom_app_bar_widget.dart';
import '../widgets/vt_menu_row_widget.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    String currentThemeStr = 'Automatic';
    if (themeProvider.themeMode == ThemeMode.dark) {
      currentThemeStr = 'Dark Theme';
    }
    if (themeProvider.themeMode == ThemeMode.light) {
      currentThemeStr = 'Light Theme';
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'SETTINGS', centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          VTMenuRow(
            icon: Icons.color_lens_outlined,
            text: "THEME",
            subtitle: currentThemeStr,
            onTap: () => _showThemeDialog(context, themeProvider),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    String currentThemeStr = 'Automatic';
    if (themeProvider.themeMode == ThemeMode.dark) {
      currentThemeStr = 'Dark Theme';
    }
    if (themeProvider.themeMode == ThemeMode.light) {
      currentThemeStr = 'Light Theme';
    }
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    "CHOOSE THEME",
                    style: textTitle.copyWith(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                _buildThemeOption('Dark Theme', currentThemeStr, themeProvider),
                _buildThemeOption(
                  'Light Theme',
                  currentThemeStr,
                  themeProvider,
                ),
                _buildThemeOption('Automatic', currentThemeStr, themeProvider),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "CANCEL",
                        style: textLabel.copyWith(
                          color: vtAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    String themeName,
    String currentVal,
    ThemeProvider provider,
  ) {
    return RadioListTile<String>(
      title: Text(
        themeName,
        style: textLabel.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 14,
        ),
      ),
      value: themeName,
      groupValue: currentVal,
      activeColor: vtAccent,
      onChanged: (value) {
        if (value != null) {
          provider.setTheme(value);
          Navigator.pop(context);
        }
      },
    );
  }
}
