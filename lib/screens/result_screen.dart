import 'package:flutter/material.dart';
import '../const/my_const.dart';

class ResultScreen extends StatelessWidget {
  final String targetName;
  final int maliciousCount;
  final int totalEngines;

  const ResultScreen({
    super.key,
    required this.targetName,
    required this.maliciousCount,
    required this.totalEngines,
  });

  @override
  Widget build(BuildContext context) {
    // กำหนดสีและข้อความตามสถานะ (ปลอดภัย / อันตราย)
    final bool isSafe = maliciousCount == 0;

    final Color statusColor = isSafe ? vtGreen : vtRed;
    final IconData statusIcon = isSafe ? Icons.verified_user : Icons.gpp_bad;
    final String statusText = isSafe ? "CLEAN" : "MALICIOUS";
    final String score = "$maliciousCount / $totalEngines";

    return Scaffold(
      backgroundColor: vtBackground,
      appBar: AppBar(
        backgroundColor: vtBackground,
        elevation: 0,
        automaticallyImplyLeading: false, // เอาปุ่ม Back ของระบบออก
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            // กด X เพื่อเด้งกลับไปหน้าแรกสุด (หน้า Scanner)
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 1. Icon และสถานะหลัก
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, size: 100, color: statusColor),
            ),
            const SizedBox(height: 20),
            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontFamily: 'Courier',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Security vendors flagged this as ${isSafe ? 'safe' : 'malicious'}",
              style: const TextStyle(color: Colors.grey, fontFamily: 'Courier'),
            ),

            const SizedBox(height: 40),

            // 2. ข้อมูลไฟล์/ลิงก์ ที่สแกน
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: vtCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "TARGET",
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Courier',
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    targetName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Courier',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.grey, height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "DETECTION SCORE",
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Courier',
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        score,
                        style: TextStyle(
                          color: statusColor,
                          fontFamily: 'Courier',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
