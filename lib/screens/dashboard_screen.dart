import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/firestore_service.dart';
import '../const/my_const.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
              stream: FirestoreService().getUserHistoryStream(),
              builder: (context, snapshot) {
                // 1. ระหว่างรอโหลด
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. ถ้ามี Error หรือไม่ได้ล็อกอิน
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No scan history found.\nSign in and start scanning!",
                      textAlign: TextAlign.center,
                      style: textDescription,
                    ),
                  );
                }

                // 3. ดึงข้อมูลสำเร็จ! นำมาคำนวณสถิติ
                final docs = snapshot.data!.docs;
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
                    Text(
                      "RECENT ACTIVITY",
                      style: textDescription.copyWith(
                        fontSize: 14,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // --- รายการประวัติ (History List) ---
                    Expanded(
                      child: ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;
                          final targetName = data['targetName'] ?? 'Unknown';
                          final isSafe = data['isSafe'] ?? false;
                          final statusText = isSafe ? 'CLEAN' : 'MALICIOUS';

                          return _buildHistoryItem(
                            targetName,
                            statusText,
                            isSafe,
                          );
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

  Widget _buildHistoryItem(String name, String status, bool isSafe) {
    final color = isSafe ? vtGreen : vtRed;
    return Container(
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
    );
  }
}
