import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'signin_screen.dart';
import '../const/my_const.dart';
import '../widgets/vt_primary_button_widget.dart';

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isGuest ? Colors.grey : vtAccent,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: vtCard,
                  child: Icon(
                    isGuest ? Icons.person_outline : Icons.person,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. ใช้ FutureBuilder เพื่อดึงชื่อจาก Firestore
                    isGuest
                        ? Text(
                            "GUEST USER",
                            style: textLabel.copyWith(
                              fontSize: 20,
                              letterSpacing: 1.5,
                              color: vtTextPrimary,
                            ),
                          )
                        : FutureBuilder<DocumentSnapshot>(
                            // วิ่งไปหาไฟล์ (Document) ที่ชื่อตรงกับ UID ของ User
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .get(),
                            builder: (context, snapshot) {
                              // ระหว่างรอข้อมูล (หมุนโหลดเล็กๆ หรือขึ้นข้อความรอ)
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text(
                                  "LOADING...",
                                  style: textLabel.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    color: vtTextSecondary,
                                    fontSize: 20,
                                  ),
                                );
                              }

                              // ถ้าดึงข้อมูลสำเร็จและมีไฟล์อยู่จริง
                              if (snapshot.hasData && snapshot.data!.exists) {
                                // แกะข้อมูลออกมาเป็น Map
                                final data =
                                    snapshot.data!.data()
                                        as Map<String, dynamic>;
                                // ดึงฟิลด์ 'name' ออกมา ถ้าไม่มีให้ใช้คำว่า 'PRO USER' แทน
                                final String userName =
                                    data['name'] ?? 'PRO USER';

                                return Text(
                                  userName, // แปลงเป็นตัวพิมพ์ใหญ่ให้เข้ากับธีม
                                  style: textLabel.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    fontSize: 20,
                                    color: vtTextPrimary,
                                  ),
                                  overflow: TextOverflow
                                      .ellipsis, // ถ้าชื่อยาวไปให้ใส่ ...
                                );
                              }

                              // ถ้าเกิด Error หรือหาข้อมูลไม่เจอ
                              return Text(
                                "PRO USER",
                                style: textLabel.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  fontSize: 20,
                                  color: vtTextPrimary,
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 5),
                    Text(
                      isGuest
                          ? "Sign in to sync your history"
                          : (user.email ?? "No Email"),
                      style: textDescription.copyWith(
                        color: isGuest ? Colors.grey : vtAccent,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),
          Text("PREFERENCES", style: textDescription),
          const SizedBox(height: 15),

          _buildMenuRow(
            FontAwesomeIcons.imagePortrait,
            "CHANGE PROFILE PICTURE",
            isEnabled: !isGuest,
          ),
          const SizedBox(height: 12),
          _buildMenuRow(
            FontAwesomeIcons.key,
            "API KEYS CONFIGURATION",
            isEnabled: !isGuest,
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
                      side: BorderSide(color: vtRed.withOpacity(0.5)),
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

  Widget _buildMenuRow(IconData icon, String text, {bool isEnabled = true}) {
    return Material(
      color: vtCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isEnabled ? () {} : null,
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
}
