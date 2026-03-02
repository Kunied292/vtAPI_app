import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../const/my_const.dart';

void showScanDetailsDialog(BuildContext context, Map<String, dynamic> data) {
  final targetName = data['targetName'] ?? 'Unknown';
  final isSafe = data['isSafe'] ?? false;
  final scanType = data['scanType'] == 'url' ? 'URL' : 'FILE';
  final statusColor = isSafe ? vtGreen : vtRed;
  final statusIcon = isSafe ? Icons.verified_user : Icons.gpp_bad;
  final statusText = isSafe ? "CLEAN" : "MALICIOUS";

  // จัดการเวลา
  final Timestamp? timestamp = data['timestamp'];
  String formattedDate = "Unknown Date";
  if (timestamp != null) {
    final date = timestamp.toDate();
    // จัดรูปแบบคร่าวๆ: DD/MM/YYYY HH:MM
    formattedDate =
        "${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  // ข้อมูลแบบละเอียดจาก Firestore
  final int? maliciousCount = data['maliciousCount'];
  final int? totalEngines = data['totalEngines'];
  final Map<String, dynamic>? vendorResults = data['vendorResults'];

  final bool hasDetailedData = maliciousCount != null && vendorResults != null;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: vtBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: vtCard, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ส่วนหัว (Header) ---
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "SCAN REPORT",
                      style: textLabel.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Divider(color: Colors.grey),
              const SizedBox(height: 15),

              // --- ข้อมูลเป้าหมาย (Target Info) ---
              Text(
                "TARGET ($scanType)",
                style: textDescription.copyWith(fontSize: 10),
              ),
              const SizedBox(height: 4),
              Text(
                targetName,
                style: textLabel.copyWith(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 15),

              // --- สถานะ & เวลา (Status & Time) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "STATUS",
                        style: textDescription.copyWith(fontSize: 10),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusText,
                        style: textLabel.copyWith(
                          fontSize: 12,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "SCANNED AT",
                        style: textDescription.copyWith(fontSize: 10),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: textLabel.copyWith(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 15),
              const Divider(color: Colors.grey),
              const SizedBox(height: 15),

              // --- รายละเอียด Vendor (Vendor Details) ---
              Text(
                "DETECTION SCORE",
                style: textDescription.copyWith(fontSize: 10),
              ),
              const SizedBox(height: 4),

              if (hasDetailedData) ...[
                Text(
                  "$maliciousCount / $totalEngines engines detected this file",
                  style: textLabel.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 15),

                // กล่องเลื่อนดู Vendor (จำกัดความสูงไว้จะได้ไม่ล้นจอ)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: vtCard,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _buildVendorList(vendorResults),
                ),
              ] else ...[
                // ถ้าไม่มีข้อมูลละเอียด (สแกนเก่าๆ)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: vtCard,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Detailed vendor reports are not available for legacy scans.",
                    style: textDescription.copyWith(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildVendorList(Map<String, dynamic> vendorResults) {
  // ดึงคีย์และจัดเรียงคล้ายๆ กับหน้า ResultScreen
  const Color vtGrey = Colors.grey;
  final vendorNames = vendorResults.keys.toList();

  // ฟังก์ชันย่อยสำหรับเรียงลำดับ
  int getPriority(String? category) {
    if (category == 'malicious' || category == 'suspicious') return 0;
    if (category == 'undetected' || category == 'harmless') return 1;
    return 2;
  }

  vendorNames.sort((a, b) {
    final pA = getPriority(vendorResults[a]['category']);
    final pB = getPriority(vendorResults[b]['category']);
    if (pA != pB) return pA.compareTo(pB);
    return a.compareTo(b);
  });

  return ListView.builder(
    padding: const EdgeInsets.all(8),
    shrinkWrap: true,
    itemCount: vendorNames.length,
    itemBuilder: (context, index) {
      final vendorName = vendorNames[index];
      final resultData = vendorResults[vendorName];
      final String category = resultData['category'] ?? 'unknown';

      Color vColor;
      IconData vIcon;

      if (category == 'malicious' || category == 'suspicious') {
        vColor = vtRed;
        vIcon = Icons.bug_report_outlined;
      } else if (category == 'undetected' || category == 'harmless') {
        vColor = vtGreen;
        vIcon = Icons.check_circle_outline;
      } else {
        vColor = vtGrey;
        vIcon = Icons.do_not_disturb_alt;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(vIcon, color: vColor, size: 14),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                vendorName,
                style: textLabel.copyWith(
                  fontSize: 11,
                  color: vColor == vtGrey ? Colors.grey : Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (category == 'malicious' && resultData['result'] != null)
              Expanded(
                child: Text(
                  resultData['result'],
                  style: textDescription.copyWith(color: vtRed, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
          ],
        ),
      );
    },
  );
}
