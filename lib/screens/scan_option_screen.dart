import 'package:flutter/material.dart';

import 'file_scan_screen.dart';
import 'url_scan_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'setting_screen.dart';
import 'treat_news_screen.dart';
import 'device_scan_screen.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../const/my_const.dart';
import '../widgets/custom_app_bar_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ScanOptionScreen extends StatefulWidget {
  const ScanOptionScreen({super.key});

  @override
  State<ScanOptionScreen> createState() => _ScanOptionScreenState();
}

class _ScanOptionScreenState extends State<ScanOptionScreen> {
  int _selectedIndex = 0;

  // รายชื่อหน้าจอที่จะให้สลับไปมาตาม Bottom Nav Bar
  late final List<Widget> _pages = [
    _buildScannerHome(), // Index 0: หน้า Scanner เดิม
    const DashboardScreen(), // Index 1: หน้า Dashboard
    const ThreatIntelScreen(), // Index 2: หน้า Threat Intel
    const ProfileScreen(), // Index 3: หน้า Profile
  ];

  // ชื่อ Title ของแต่ละหน้า
  final List<String> _titles = [
    'VIRUS SCANNER',
    'DASHBOARD',
    'THREAT INTEL',
    'USER PROFILE',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vtBackground,
      appBar: CustomAppBar(
        title: _titles[_selectedIndex], // เปลี่ยน Title ตามหน้าที่เลือก
        trailing: _selectedIndex == 0
            ? IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingScreen(),
                    ),
                  );
                },
              )
            : null,
      ),

      // สลับ Widget ของ body ตาม Index ที่ถูกคลิก พร้อมทำ Animation
      body: _pages[_selectedIndex]
          .animate(key: ValueKey(_selectedIndex))
          .fade(duration: 300.ms)
          .slideY(begin: 0.05, duration: 300.ms, curve: Curves.easeOut),

      bottomNavigationBar: SizedBox(
        height: 100, // ยืดความสูงขึ้นเล็กน้อย
        child: BottomNavigationBar(
          backgroundColor: vtCard,
          unselectedItemColor: vtTextSecondary,
          selectedItemColor: vtAccent,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shield_outlined),
              activeIcon: Icon(Icons.shield),
              label: 'Scanner',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.newspaper_outlined),
              activeIcon: Icon(Icons.newspaper),
              label: 'News',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          selectedLabelStyle: textDescription,
          unselectedLabelStyle: textDescription,
        ),
      ),
    );
  }

  // แยก Widget หน้า Scanner หลักออกมา เพื่อให้โค้ดดูสะอาด
  Widget _buildScannerHome() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select an option to analyze files or URLs.",
            style: textDescription,
          ),
          const SizedBox(height: 40),
          _buildOptionCard(
            title: "SCAN FILE",
            subtitle: "Upload file from device",
            icon: FontAwesomeIcons.fileArrowUp,
            color: Colors.indigoAccent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FileScanScreen()),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildOptionCard(
            title: "SCAN URL",
            subtitle: "Check website safety",
            icon: FontAwesomeIcons.link,
            color: vtAccent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UrlScanScreen()),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildOptionCard(
            title: "SCAN APP",
            subtitle: "Check app safety",
            icon: Icons.android,
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeviceScanScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: vtCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textLabel),
                  const SizedBox(height: 6),
                  Text(subtitle, style: textDescription),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}
