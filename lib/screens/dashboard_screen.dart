import 'package:flutter/material.dart';
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
          const Text(
            "SECURITY OVERVIEW",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Courier',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),

          // สรุปสถิติ (Stats Row)
          Row(
            children: [
              Expanded(child: _buildStatCard("SCANNED", "128", vtAccent)),
              const SizedBox(width: 15),
              Expanded(child: _buildStatCard("CLEAN", "120", vtGreen)),
              const SizedBox(width: 15),
              Expanded(child: _buildStatCard("THREATS", "8", vtRed)),
            ],
          ),

          const SizedBox(height: 40),
          const Text(
            "RECENT ACTIVITY",
            style: TextStyle(
              color: Colors.grey,
              fontFamily: 'Courier',
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 15),

          // รายการประวัติการสแกนล่าสุด
          Expanded(
            child: ListView(
              children: [
                _buildHistoryItem("system_update.apk", "Safe", true),
                _buildHistoryItem("http://free-movies.xyz", "Malicious", false),
                _buildHistoryItem("invoice_document.pdf", "Safe", true),
                _buildHistoryItem("crack_wifi.exe", "Malicious", false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget สร้างกล่องสถิติ
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
            style: TextStyle(
              color: color,
              fontFamily: 'Courier',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontFamily: 'Courier',
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Widget สร้างรายการประวัติ
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
            isSafe ? Icons.check_circle : Icons.warning,
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Courier',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontFamily: 'Courier',
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
        ],
      ),
    );
  }
}
