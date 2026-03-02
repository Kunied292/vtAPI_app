import 'package:flutter/material.dart';
import '../const/my_const.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultScreen extends StatefulWidget {
  final String targetName;
  final int maliciousCount;
  final int totalEngines;
  final Map<String, dynamic> vendorResults;

  const ResultScreen({
    super.key,
    required this.targetName,
    required this.maliciousCount,
    required this.totalEngines,
    required this.vendorResults,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final Color vtGrey =
      Colors.grey; // เพิ่มสีเทาสำหรับสถานะที่ไม่สามารถประมวลผลได้
  late List<String> _sortedVendorNames;

  @override
  void initState() {
    super.initState();
    _sortedVendorNames = widget.vendorResults.keys.toList();
    _sortedVendorNames.sort((a, b) {
      final pA = _getPriority(widget.vendorResults[a]['category']);
      final pB = _getPriority(widget.vendorResults[b]['category']);
      if (pA != pB) return pA.compareTo(pB); // เรียงตามความสำคัญ
      return a.compareTo(b); // ถ้าความสำคัญเท่ากัน เรียงตามตัวอักษร A-Z
    });
  }

  // ฟังก์ชันจัดความสำคัญ (แดงอยู่บน -> เขียวตรงกลาง -> เทาอยู่ล่างสุด)
  int _getPriority(String? category) {
    if (category == 'malicious' || category == 'suspicious') return 0;
    if (category == 'undetected' || category == 'harmless') return 1;
    return 2; // พวก type-unsupported, timeout, failure
  }

  @override
  Widget build(BuildContext context) {
    final bool isSafe = widget.maliciousCount == 0;
    final Color statusColor = isSafe ? vtGreen : vtRed;
    final IconData statusIcon = isSafe ? Icons.verified_user : Icons.gpp_bad;
    final String statusText = isSafe ? "CLEAN" : "MALICIOUS";
    final String score = "${widget.maliciousCount} / ${widget.totalEngines}";

    return Scaffold(
      backgroundColor: vtBackground,
      appBar: AppBar(
        backgroundColor: vtBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- ส่วนหัว (เหมือนเดิม) ---
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, size: 40, color: statusColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(statusText, style: textTitle.copyWith(fontSize: 24)),
                      Text("Detection Score: $score", style: textDescription),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(color: Colors.grey),
            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "DETECTION DETAILS",
                style: textDescription.copyWith(fontSize: 12),
              ),
            ),
            const SizedBox(height: 10),

            // --- ลิสต์ผลการสแกนที่แยก 3 สถานะแล้ว ---
            Expanded(
              child: ListView.builder(
                itemCount: _sortedVendorNames.length,
                itemBuilder: (context, index) {
                  final vendorName = _sortedVendorNames[index];
                  final resultData = widget.vendorResults[vendorName];

                  final String category = resultData['category'] ?? 'unknown';
                  final String? malwareName = resultData['result'];

                  // 💡 ตัวแปรสำหรับคุม UI สีและไอคอน
                  Color vColor;
                  IconData vIcon;
                  String vStatusText;

                  // เช็ค 3 กลุ่มหลัก
                  if (category == 'malicious' || category == 'suspicious') {
                    // กลุ่มอันตราย (สีแดง)
                    vColor = vtRed;
                    vIcon = Icons.bug_report_outlined;
                    vStatusText = "DETECTED";
                  } else if (category == 'undetected' ||
                      category == 'harmless') {
                    // กลุ่มปลอดภัย (สีเขียว)
                    vColor = vtGreen;
                    vIcon = Icons.check_circle_outline;
                    vStatusText = "UNDETECTED";
                  } else {
                    // กลุ่มสีเทา (เช่น type-unsupported, timeout)
                    vColor = vtGrey;
                    vIcon = Icons.do_not_disturb_alt;
                    // แปลงชื่อ category ให้สวยขึ้น เช่น type-unsupported -> UNSUPPORTED
                    vStatusText = category == 'type-unsupported'
                        ? "UNSUPPORTED"
                        : category.toUpperCase();
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: vtCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border(left: BorderSide(color: vColor, width: 4)),
                    ),
                    child: Row(
                      children: [
                        Icon(vIcon, color: vColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vendorName,
                                style: TextStyle(
                                  color: vColor == vtGrey
                                      ? Colors.grey
                                      : Colors.white,
                                  fontFamily:
                                      GoogleFonts.jetBrainsMono().fontFamily,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),

                              // โชว์ชื่อไวรัสเฉพาะกลุ่มสีแดง
                              if (vColor == vtRed && malwareName != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  malwareName,
                                  style: textDescription.copyWith(
                                    color: vtRed,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // ป้ายกำกับด้านขวา
                        Text(
                          vStatusText,
                          style: textLabel.copyWith(
                            color: vColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
