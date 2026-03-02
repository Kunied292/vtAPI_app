import 'package:flutter/material.dart';
import 'dart:async';
import 'result_screen.dart';
import '../const/my_const.dart';
import '../services/vt_api.dart';
import '../services/firestore_service.dart';

class AnalyzingScreen extends StatefulWidget {
  final String targetName; // รับชื่อไฟล์ หรือ URL มาเพื่อแสดงบนจอ
  final String analysisId; // รับ ID จากการอัปโหลดไฟล์

  const AnalyzingScreen({
    super.key,
    required this.targetName,
    required this.analysisId,
  });

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
    _pollScanResult();
  }

  Future<void> _pollScanResult() async {
    final apiService = VtApiService();
    bool isCompleted = false;

    while (!isCompleted) {
      // หน่วงเวลา 5 วินาที ป้องกัน API โดนแบน (Rate Limit ของฟรีให้ 4 request/นาที)
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return; // ถ้าผู้ใช้กดปิดหน้าไปแล้ว ให้หยุดทำงาน

      final reportOrFailure = await apiService.getAnalysisReport(
        widget.analysisId,
      );

      reportOrFailure.fold(
        (failure) {
          // ถ้าเกิด Failure ให้หยุดการรัน loop และแสดง Error กลับไปหน้าก่อน
          isCompleted = true;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Report Error: ${failure.message}'),
                backgroundColor: Colors.redAccent,
              ),
            );
            Navigator.pop(context);
          }
        },
        (report) {
          // แกะสถานะปัจจุบันออกมาดู (queued, in-progress, completed)
          final status = report['data']['attributes']['status'];

          if (status == 'completed') {
            isCompleted = true; // ออกจากลูป while

            // ดึงสถิติออกมา
            final stats = report['data']['attributes']['stats'];
            int malicious = stats['malicious'] ?? 0;
            int undetected = stats['undetected'] ?? 0;
            int harmless = stats['harmless'] ?? 0;
            int suspicious = stats['suspicious'] ?? 0;
            int total = malicious + undetected + harmless + suspicious;

            final bool isSafe = malicious == 0;
            // เช็คแบบง่ายๆ ว่าเป็น URL หรือ File (ถ้าขึ้นต้นด้วย http ให้ถือว่าเป็น url)
            final String type = widget.targetName.startsWith('http')
                ? 'url'
                : 'file';

            final Map<String, dynamic> vendorResults =
                report['data']['attributes']['results'];

            // สั่งบันทึกโดยไม่ต้องรอ (ไม่ต้องใส่ await) เพื่อความรวดเร็วของ UX
            FirestoreService().saveScanResult(
              targetName: widget.targetName,
              isSafe: isSafe,
              scanType: type,
              vendorResults: vendorResults,
              maliciousCount: malicious,
              totalEngines: total,
            );

            // เด้งไปหน้าผลลัพธ์ พร้อมส่งตัวเลขจริงไปให้
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultScreen(
                    targetName: widget.targetName,
                    maliciousCount: malicious,
                    totalEngines: total,
                    vendorResults: vendorResults,
                  ),
                ),
              );
            }
          } else {
            // ถ้ายังไม่เสร็จ ให้อัปเดตข้อความบนหน้าจอเรื่อยๆ
            if (mounted) {
              setState(() {
                _statusText = "STATUS: ${status.toUpperCase()}...";
              });
            }
          }
        },
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
            Text(
              "ANALYZING TARGET",
              style: textLabel.copyWith(fontSize: 20, letterSpacing: 2),
            ),
            const SizedBox(height: 10),
            Text(
              widget.targetName,
              style: textLabel.copyWith(fontSize: 14, color: vtAccent),
            ),
            const SizedBox(height: 30),
            Text(
              _statusText,
              style: textLabel.copyWith(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
