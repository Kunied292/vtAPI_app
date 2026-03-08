import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'signin_screen.dart';
import '../const/my_const.dart';
import '../widgets/vt_primary_button_widget.dart';
import '../services/vt_api.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // เช็คสถานะ User ปัจจุบัน
    final user = FirebaseAuth.instance.currentUser;
    final bool isGuest = user == null;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- ส่วน Header ---
          isGuest
              ? _buildGuestHeader()
              : StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    String userName = 'PRO USER';
                    String? photoUrl;

                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      userName = data['name'] ?? 'PRO USER';
                      photoUrl = data['photoUrl'];
                    }

                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: vtAccent, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: vtCard,
                            // เช็คถ้ามี photoUrl ให้แสดงรูป ไม่ก็โชว์ไอคอนคน
                            backgroundImage: photoUrl != null
                                ? (photoUrl.startsWith('assets/')
                                      ? AssetImage(photoUrl)
                                      : NetworkImage(photoUrl) as ImageProvider)
                                : null,
                            child: photoUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: textLabel.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  fontSize: 20,
                                  color: vtTextPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                user.email ?? "No Email",
                                style: textDescription.copyWith(
                                  color: vtAccent,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

          const SizedBox(height: 40),
          Text("PREFERENCES", style: textDescription),
          const SizedBox(height: 15),

          _buildMenuRow(
            FontAwesomeIcons.imagePortrait,
            "CHANGE PROFILE PICTURE",
            isEnabled: !isGuest,
            onTap: () {
              if (user != null) {
                _showProfilePicturePicker(context, user);
              }
            },
          ),
          const SizedBox(height: 12),
          _buildMenuRow(
            FontAwesomeIcons.key,
            "API KEYS CONFIGURATION",
            isEnabled: !isGuest,
            onTap: () {
              if (user != null) {
                _showApiUsageDialog(context);
              }
            },
          ),
          const SizedBox(height: 12),
          _buildMenuRow(
            FontAwesomeIcons.bell,
            "ALERTS & NOTIFICATIONS",
            isEnabled: !isGuest,
          ),

          const Spacer(),

          // --- ปุ่ม Action (Sign In / Sign Out) ---
          SizedBox(
            width: double.infinity,
            height: 55,
            child: isGuest
                ? VTPrimaryButton(
                    text: "SIGN IN TO UNLOCK FEATURES",
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ),
                      );
                    },
                  )
                : OutlinedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignInScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(FontAwesomeIcons.powerOff, color: vtRed),
                    label: Text(
                      "LOG OUT",
                      style: textLabel.copyWith(
                        color: vtRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: vtRed.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuRow(
    IconData icon,
    String text, {
    bool isEnabled = true,
    VoidCallback? onTap,
  }) {
    return Material(
      color: vtCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isEnabled ? (onTap ?? () {}) : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                icon,
                color: isEnabled ? Colors.white : Colors.grey.shade700,
                size: 24,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  text,
                  style: textLabel.copyWith(
                    color: isEnabled ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (isEnabled)
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuestHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey, width: 2),
          ),
          child: const CircleAvatar(
            radius: 35,
            backgroundColor: vtCard,
            child: Icon(Icons.person_outline, size: 40, color: Colors.grey),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "GUEST USER",
                style: textLabel.copyWith(
                  fontSize: 20,
                  letterSpacing: 1.5,
                  color: vtTextPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Sign in to sync your history",
                style: textDescription.copyWith(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showProfilePicturePicker(BuildContext context, User user) {
    final List<String> profileImages = [
      'assets/profile_images/aldi-sigun-K-sdQ12jZeY-unsplash.jpg',
      'assets/profile_images/alison-wang-mou0S7ViElQ-unsplash.jpg',
      'assets/profile_images/anshita-nair-0rxLLHD1XxA-unsplash.jpg',
      'assets/profile_images/luthfi-alfarizi-xRMK0ea-Of4-unsplash.jpg',
      'assets/profile_images/shubham-dhage-t0Bv0OBQuTg-unsplash.jpg',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: vtBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Select Profile Picture",
                style: textTitle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: profileImages.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 15),
                  itemBuilder: (context, index) {
                    final imagePath = profileImages[index];
                    return GestureDetector(
                      onTap: () async {
                        Navigator.pop(context); // ปิด popup

                        // อัปเดตข้อมูลบน Firestore
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .update({'photoUrl': imagePath});

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Profile picture updated successfully!",
                                style: textLabel.copyWith(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(imagePath),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  void _showApiUsageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: vtCard,
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
                            _buildUsageRow("Today's Requests", totalUsedToday),
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

  Widget _buildUsageRow(String title, int usedCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: textDescription.copyWith(
                color: Colors.white,
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
