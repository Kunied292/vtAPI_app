import 'package:flutter/material.dart';
import 'file_scan_screen.dart';
import 'url_scan_screen.dart';
import 'dashboard_screen.dart'; // <--- เพิ่ม Import
import 'profile_screen.dart'; // <--- เพิ่ม Import
import '../const/my_const.dart';

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
    const ProfileScreen(), // Index 2: หน้า Profile
  ];

  // ชื่อ Title ของแต่ละหน้า
  final List<String> _titles = ['VIRUS SCANNER', 'DASHBOARD', 'USER PROFILE'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vtBackground,
      appBar: AppBar(
        backgroundColor: vtBackground,
        elevation: 0,
        title: Text(
          _titles[_selectedIndex], // เปลี่ยน Title ตามหน้าที่เลือก
          style: textTitle,
        ),
        centerTitle: true,
      ),

      // สลับ Widget ของ body ตาม Index ที่ถูกคลิก
      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
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
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedLabelStyle: textDescription,
        unselectedLabelStyle: textDescription,
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
            icon: Icons.upload_file,
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
            icon: Icons.link,
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
          color: vtCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
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
