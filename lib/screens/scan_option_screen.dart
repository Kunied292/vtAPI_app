import 'package:flutter/material.dart';

import 'file_scan_screen.dart';
import 'url_scan_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
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

  // Cache หน้าจอไว้ เพื่อไม่ให้สร้างใหม่ทุกครั้งที่ build()
  late final List<Widget> _pages = [
    _buildScannerHome(), // Index 0: หน้า Scanner เดิม
    const DashboardScreen(), // Index 1: หน้า Dashboard
    const ThreatIntelScreen(), // Index 2: หน้า Threat Intel
    const ProfileScreen(), // Index 3: หน้า Profile
  ];

  // ชื่อ Title ของแต่ละหน้า
  final List<String> _titles = [
    'VT SCANNER',
    'DASHBOARD',
    'THREAT INTEL',
    'ACCOUNT',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: _titles[_selectedIndex], // เปลี่ยน Title ตามหน้าที่เลือก
        centerTitle: false, // ชิดซ้ายทั้งหมด
      ),

      // สลับ Widget ของ body ตาม Index ที่ถูกคลิก พร้อมทำ Animation
      // ใช้ IndexedStack เพื่อเก็บ State ของแต่ละหน้าไว้ (เช่น scroll position, loaded data)
      body: IndexedStack(index: _selectedIndex, children: _pages),

      bottomNavigationBar: SizedBox(
        height: 100, // ยืดความสูงขึ้นเล็กน้อย
        child: BottomNavigationBar(
          backgroundColor: Theme.of(context).cardColor,
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
              label: 'Account',
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          // ปุ่มสแกนแบบวงกลมตรงกลาง
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeviceScanScreen(),
                  ),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // วงแหวนคลื่นเรดาร์ด้านหลัง
                  Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.8),
                            width: 2,
                          ),
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.6, 1.6),
                        duration: 2.seconds,
                        curve: Curves.easeOut,
                      )
                      .fade(
                        begin: 0.8,
                        end: 0.0,
                        duration: 2.seconds,
                        curve: Curves.easeOut,
                      ),

                  // ปุ่มวงกลมหลัก อยู่นิ่งๆ
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withValues(alpha: 0.15),
                      border: Border.all(color: Colors.green, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //Icon(Icons.radar, color: Colors.green, size: 60),
                        SizedBox(height: 12),
                        Text(
                          "SCAN NOW",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 22, // ปรับให้ใหญ่ขึ้นนิดหน่อย
                            fontWeight: FontWeight.w900, // หนาสุด
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 60),

          // ข้อความอธิบายการสแกนแอป
          Text(
            "Tap to scan your device for malicious apps\nand security threats.",
            style: textDescription,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // ปุ่ม File และ URL ยังคงเค้าโครงเดิม
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
          color: Theme.of(context).cardColor,
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
