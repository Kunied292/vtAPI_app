import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'signin_screen.dart';
import 'manage_account_screen.dart';
import 'setting_screen.dart';
import 'help_screen.dart';
import 'about_screen.dart';
import '../const/my_const.dart';
import '../widgets/vt_primary_button_widget.dart';
import '../widgets/vt_menu_row_widget.dart';
import '../services/vt_api.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // เช็คสถานะ User ปัจจุบัน
    final user = FirebaseAuth.instance.currentUser;
    final bool isGuest = user == null;

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        if (isGuest) ...[
          _buildGuestHeader(context),
          const SizedBox(height: 30),
        ],

        if (!isGuest) ...[
          VTMenuRow(
            icon: FontAwesomeIcons.solidUser,
            text: "MANAGE ACCOUNT",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageAccountScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],

        VTMenuRow(
          icon: FontAwesomeIcons.chartLine,
          text: "API USAGE",
          onTap: () {
            _showApiUsageDialog(context);
          },
        ),
        const SizedBox(height: 12),

        VTMenuRow(
          icon: Icons.settings,
          text: "SETTINGS",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingScreen()),
            );
          },
        ),
        const SizedBox(height: 12),

        VTMenuRow(
          icon: Icons.help_outline,
          text: "HELP & SUPPORT",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpScreen()),
            );
          },
        ),
        const SizedBox(height: 12),

        VTMenuRow(
          icon: Icons.info_outline,
          text: "ABOUT APP",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            );
          },
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildGuestHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: vtAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.no_accounts, color: Colors.grey, size: 32),
              const SizedBox(width: 15),
              Text(
                "You're not signed in",
                style: textTitle.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            "Sign in to access all features, sync your history, and unlock API usage tracking.",
            style: textDescription.copyWith(height: 1.5),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: VTPrimaryButton(
              text: "SIGN IN",
              textColor: Theme.of(context).colorScheme.onSurface,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showApiUsageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.chartLine,
                      color: vtAccent,
                      size: 24,
                    ),
                    const SizedBox(width: 15),
                    Text(
                      "VIRUSTOTAL API USAGE",
                      style: textTitle.copyWith(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FutureBuilder(
                  future: VtApiService().getApiUsage(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return Text(
                        "Failed to load API usage data.",
                        style: textDescription.copyWith(color: vtRed),
                      );
                    }

                    final result = snapshot.data!;
                    return result.fold(
                      (failure) => Text(
                        failure.message,
                        style: textDescription.copyWith(color: vtRed),
                      ),
                      (data) {
                        final dailyData = data['data']?['daily'];
                        int totalUsedToday = 0;

                        if (dailyData != null) {
                          // Get today's date in YYYY-MM-DD format (UTC)
                          final now = DateTime.now().toUtc();
                          final todayStr =
                              "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

                          final todayUsage = dailyData[todayStr];
                          if (todayUsage != null) {
                            // Sum up specific usage endpoints
                            final fileUploads =
                                todayUsage['/api/v3/(file_upload)'] ?? 0;
                            final urlSubmissions =
                                todayUsage['/api/v3/(url_submission)'] ?? 0;
                            totalUsedToday = fileUploads + urlSubmissions;
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildUsageRow(
                              context,
                              "Today's Requests",
                              totalUsedToday,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "CLOSE",
                      style: textLabel.copyWith(
                        color: vtAccent,
                        fontWeight: FontWeight.bold,
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

  Widget _buildUsageRow(BuildContext context, String title, int usedCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: textDescription.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "$usedCount Requests",
              style: textLabel.copyWith(fontSize: 14, color: vtAccent),
            ),
          ],
        ),
      ],
    );
  }
}
