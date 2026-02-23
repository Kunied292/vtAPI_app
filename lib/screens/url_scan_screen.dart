import 'package:flutter/material.dart';

import 'analysis_loading_screen.dart';
import '../const/my_const.dart';

class UrlScanScreen extends StatefulWidget {
  const UrlScanScreen({super.key});

  @override
  State<UrlScanScreen> createState() => _UrlScanScreenState();
}

class _UrlScanScreenState extends State<UrlScanScreen> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vtBackground,
      // บังคับไม่ให้คีย์บอร์ดดันหน้าจอเละ
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: vtBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'URL ANALYSIS',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter a URL, IP address, or domain to scan.",
              style: TextStyle(color: Colors.grey, fontFamily: 'Courier'),
            ),
            const SizedBox(height: 30),

            // ช่องกรอก URL
            TextField(
              controller: _urlController,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Courier',
              ),
              decoration: InputDecoration(
                hintText: "https://...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: vtCard,
                prefixIcon: const Icon(Icons.link, color: Colors.grey),
                // ขอบตอนไม่ได้กด
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                // ขอบตอนกดพิมพ์ (เรืองแสงสีฟ้า)
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: vtAccent, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
              ),
            ),

            const Spacer(),

            // ปุ่มเริ่มสแกน (อยู่ล่างสุด)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: นำ URL ไปเช็คกับ API
                  final url = _urlController.text.trim();
                  if (url.isNotEmpty) {
                    // สั่งให้วิ่งไปหน้า Loading Animation พร้อมส่งค่า URL ไปให้ด้วย
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnalyzingScreen(targetName: url),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: vtAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "ANALYZE NOW",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // เผื่อขอบจอด้านล่าง
          ],
        ),
      ),
    );
  }
}
