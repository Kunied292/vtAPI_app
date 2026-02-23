import 'package:flutter/material.dart';
import 'dart:async';
import 'result_screen.dart';
import '../const/my_const.dart';

class AnalyzingScreen extends StatefulWidget {
  final String targetName; // รับชื่อไฟล์ หรือ URL มาเพื่อแสดงบนจอ

  const AnalyzingScreen({super.key, required this.targetName});

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

// ต้องใส่ SingleTickerProviderStateMixin เพื่อให้รัน Animation ได้
class _AnalyzingScreenState extends State<AnalyzingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  String _statusText = "INITIALIZING SECURE CONNECTION...";

  @override
  void initState() {
    super.initState();

    // 1. ตั้งค่า Animation ให้กระเพื่อมเข้าออก (Pulse) ใช้เวลา 1 วินาที
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true); // สั่งให้เล่นวนลูปไป-กลับ

    // กำหนดขนาดการขยายตัว (จาก 1 เท่า ไป 1.5 เท่า)
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 2. เริ่มจำลองการทำงานของแอป (เปลี่ยนข้อความไปเรื่อยๆ)
    _simulateScanning();
  }

  Future<void> _simulateScanning() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted)
      setState(() => _statusText = "UPLOADING TO VIRUSTOTAL CLOUD...");

    await Future.delayed(const Duration(seconds: 2));
    if (mounted)
      setState(() => _statusText = "QUERYING 70+ ANTIVIRUS ENGINES...");

    await Future.delayed(const Duration(seconds: 2));
    if (mounted)
      setState(() => _statusText = "ANALYZING HEURISTICS & SIGNATURES...");

    await Future.delayed(const Duration(seconds: 2));

    // 3. จำลองผลลัพธ์ (สมมติว่าถ้ามีคำว่า exe หรือ apk ให้เป็นไวรัส)
    bool isSafe =
        !widget.targetName.toLowerCase().contains("exe") &&
        !widget.targetName.toLowerCase().contains("apk");

    // โหลดเสร็จแล้ว ย้ายไปหน้า Result
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ResultScreen(targetName: widget.targetName, isSafe: isSafe),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController
        .dispose(); // ทิ้ง Animation เมื่อออกจากหน้า ป้องกัน Memory Leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vtBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ส่วนประกอบของ Animation
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // วงแหวนที่ขยายตัว (Ripple)
                    Container(
                      width: 100 * _pulseAnimation.value, // ขยายตามค่าอนิเมชัน
                      height: 100 * _pulseAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: vtAccent.withOpacity(
                          0.2 / _pulseAnimation.value,
                        ), // ยิ่งกว้างยิ่งจาง
                      ),
                    ),
                    // ไอคอนตรงกลาง (ไม่ขยายตัว)
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: vtBackground,
                        shape: BoxShape.circle,
                        border: Border.all(color: vtAccent, width: 2),
                      ),
                      child: const Icon(
                        Icons.radar,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 60),

            // ข้อความที่เปลี่ยนไปเรื่อยๆ
            const Text(
              "ANALYZING TARGET",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Courier',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.targetName,
              style: TextStyle(
                color: vtAccent,
                fontFamily: 'Courier',
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              _statusText,
              style: const TextStyle(
                color: Colors.grey,
                fontFamily: 'Courier',
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
