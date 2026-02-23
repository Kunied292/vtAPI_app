import 'package:flutter/material.dart';
import '../const/my_const.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ส่วน Header ของ Profile
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: vtAccent, width: 2),
                ),
                child: const CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ADMINISTRATOR",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Courier',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: vtAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "PRO PLAN ACTIVE",
                      style: TextStyle(
                        color: vtAccent,
                        fontFamily: 'Courier',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 40),
          const Text(
            "SETTINGS",
            style: TextStyle(
              color: Colors.grey,
              fontFamily: 'Courier',
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 15),

          // เมนูต่างๆ
          _buildMenuRow(Icons.person_outline, "ACCOUNT DETAILS"),
          const SizedBox(height: 12),
          _buildMenuRow(Icons.api, "API KEYS CONFIGURATION"),
          const SizedBox(height: 12),
          _buildMenuRow(Icons.notifications_none, "ALERTS & NOTIFICATIONS"),
          const SizedBox(height: 12),
          _buildMenuRow(Icons.history, "SCAN HISTORY EXPORT"),

          const Spacer(),

          // ปุ่ม Logout แยกส่วนชัดเจน
          SizedBox(
            width: double.infinity,
            height: 55,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: ใส่คำสั่ง Logout Firebase ที่นี่
                debugPrint("Logging out...");
              },
              icon: Icon(Icons.power_settings_new, color: vtRed),
              label: Text(
                "DISCONNECT",
                style: TextStyle(
                  color: vtRed,
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1,
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

  Widget _buildMenuRow(IconData icon, String text) {
    return Material(
      color: vtCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Courier',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
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
