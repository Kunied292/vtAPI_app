import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/firestore_service.dart';
import '../const/my_const.dart';
import '../widgets/scan_details_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isDescending =
      true; // true = ใหม่สุดไปเก่าสุด, false = เก่าสุดไปใหม่สุด
  List<QueryDocumentSnapshot>? _cachedDocs; // 🌟 เก็บข้อมูลชั่วคราวกันจอกระพริบ

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SECURITY OVERVIEW",
            style: textLabel.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),

          // 💡 ใช้ StreamBuilder ดึงข้อมูลจาก Firestore แบบ Real-time
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreService().getUserHistoryStream(
                descending: _isDescending,
              ),
              builder: (context, snapshot) {
                // อัปเดต Cache ทุกครั้งที่มีข้อมูลใหม่เข้ามา
                if (snapshot.hasData) {
                  _cachedDocs = snapshot.data!.docs;
                }

                // ใช้ข้อมูลจาก Cache แทนถ้ามี (เพื่อกันจอกระพริบตอนสลับ Sort)
                // หรือถ้าไม่มี Cache ค่อยใช้จาก snapshot.data
                final docs = _cachedDocs;

                // 1. ระหว่างรอโหลด (และยังไม่มี Cache)
                if (docs == null) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading history."));
                  }
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. ถ้าไม่มีข้อมูลประวัติเลย
                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No scan history found.\nSign in and start scanning!",
                      textAlign: TextAlign.center,
                      style: textDescription,
                    ),
                  );
                }

                // 3. นำมาคำนวณสถิติ
                int totalScans = docs.length;
                int cleanCount = 0;
                int threatCount = 0;

                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data['isSafe'] == true) {
                    cleanCount++;
                  } else {
                    threatCount++;
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- สรุปสถิติ (Stats Row) ---
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "SCANNED",
                            totalScans.toString(),
                            vtAccent,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildStatCard(
                            "CLEAN",
                            cleanCount.toString(),
                            vtGreen,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildStatCard(
                            "THREATS",
                            threatCount.toString(),
                            vtRed,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "ACTIVITY HISTORY",
                          style: textDescription.copyWith(
                            fontSize: 14,
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _isDescending = !_isDescending;
                            });
                          },
                          icon: Icon(
                            _isDescending
                                ? FontAwesomeIcons.arrowDownShortWide
                                : FontAwesomeIcons.arrowUpWideShort,
                            color: vtAccent,
                            size: 14,
                          ),
                          label: Text(
                            _isDescending ? "NEWEST" : "OLDEST",
                            style: textDescription.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: vtAccent,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // --- รายการประวัติ (History List) ---
                    Expanded(
                      child: ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;

                          return _buildHistoryItem(context, data);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // (Widget ย่อยด้านล่างนี้เหมือนเดิมเป๊ะครับ)
  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: vtCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: textLabel.copyWith(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: textDescription.copyWith(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, Map<String, dynamic> data) {
    final name = data['targetName'] ?? 'Unknown';
    final isSafe = data['isSafe'] ?? false;
    final status = isSafe ? 'CLEAN' : 'MALICIOUS';
    final color = isSafe ? vtGreen : vtRed;

    return InkWell(
      onTap: () => showScanDetailsDialog(context, data),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: vtCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSafe ? FontAwesomeIcons.shield : FontAwesomeIcons.shieldHalved,
              color: color,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: textLabel.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: textDescription.copyWith(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
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
