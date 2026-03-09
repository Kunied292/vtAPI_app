import 'package:flutter/material.dart';
import 'dart:async';
import 'result_screen.dart';
import '../const/my_const.dart';
import '../services/vt_api.dart';
import '../services/firestore_service.dart';
import '../models/scan_history_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

  String _statusText = "INITIALIZING SECURE CONNECTION...";

  @override
  void initState() {
    super.initState();

    // 1. ตั้งค่า Animation ให้เป็นคลื่นโซนาร์กระจายออก
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 3,
      ), // รอบละ 3 วินาทีเพื่อให้คลื่นดูนุ่มนวล
    )..repeat(); // วนลูปการแผ่ออกไปเรื่อยๆ ทิศทางเดียว

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
            // แต่เนื่องจากตอนนี้ return เป็น Either เราสามารถแกะค่าได้
            FirestoreService()
                .saveScanResult(
                  ScanHistoryModel(
                    id: '', // Firestore sets the ID, we don't know it yet
                    targetName: widget.targetName,
                    isSafe: isSafe,
                    scanType: type,
                    timestamp: DateTime.now(),
                    vendorResults: vendorResults,
                    maliciousCount: malicious,
                    totalEngines: total,
                  ),
                )
                .then((result) {
                  result.fold(
                    (failure) => debugPrint(
                      "Failed to save history: ${failure.message}",
                    ),
                    (_) => debugPrint("History saved successfully."),
                  );
                });

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ส่วนประกอบของ Animation
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // วงแหวนโซนาร์ 3 วงซ้อนกัน
                    ...List.generate(3, (index) {
                      double progress =
                          (_animationController.value - (index * 0.3333)) % 1.0;
                      if (progress < 0) progress += 1.0;

                      return Transform.scale(
                        scale:
                            1.0 +
                            (progress * 2.5), // ขยายจาก 1 เท่า ไป 3.5 เท่า
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: vtAccent.withValues(
                              alpha: (1.0 - progress) * 0.1,
                            ), // พื้นในจางๆ
                            border: Border.all(
                              color: vtAccent.withValues(
                                alpha: 1.0 - progress,
                              ), // ขอบค่อยๆ จาง
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    }),
                    // ไอคอนตรงกลาง (ไม่ขยายตัว)
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: vtAccent, width: 2),
                      ),
                      child: Icon(
                        LucideIcons.radar,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 40,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 120),

            // ข้อความที่เปลี่ยนไปเรื่อยๆ
            Text(
              "ANALYZING TARGET",
              style: textLabel.copyWith(fontSize: 20, letterSpacing: 2),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: vtAccent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: vtAccent.withValues(alpha: 0.3)),
              ),
              child: Text(
                widget.targetName,
                style: textLabel.copyWith(fontSize: 14, color: vtAccent),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
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
