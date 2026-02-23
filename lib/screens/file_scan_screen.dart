import 'package:flutter/material.dart';
import 'analysis_loading_screen.dart';
import '../const/my_const.dart';
import 'package:file_picker/file_picker.dart';

class FileScanScreen extends StatelessWidget {
  const FileScanScreen({super.key});

  Future<void> _pickFileAndScan(BuildContext context) async {
    // 1. ในแอปจริง คุณจะใช้โค้ดประมาณนี้เพื่อเปิดหน้าเลือกไฟล์ของระบบ:
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return; // ถ้าผู้ใช้กดยกเลิก ไม่เลือกไฟล์ ให้หยุดการทำงาน
    }
    String fileName = result.files.single.name;

    // 2. สำหรับตอนนี้ เราจะจำลองการหน่วงเวลา 1 วินาที (เหมือนผู้ใช้กำลังเลือกไฟล์)
    await Future.delayed(const Duration(seconds: 1));

    // สมมติว่านี่คือชื่อไฟล์ที่ผู้ใช้เลือกมา
    //String mockFileName = "unknown_installer.exe";

    // 3. เมื่อได้ไฟล์มาแล้ว ให้เปลี่ยนหน้าไปหน้า AnalyzingScreen อัตโนมัติ
    if (context.mounted) {
      // ใช้ pushReplacement เพื่อแทนที่หน้านี้ไปเลย
      // (เวลากด Back จากหน้าโหลด จะได้กลับไปที่หน้า Home ไม่ใช่เด้งกลับมาหน้าเลือกไฟล์อีก)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AnalyzingScreen(targetName: fileName),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vtBackground,
      appBar: AppBar(
        backgroundColor: vtBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // สีปุ่ม Back
        title: const Text(
          'FILE UPLOAD',
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
              "Select a suspicious file to analyze.",
              style: TextStyle(color: Colors.grey, fontFamily: 'Courier'),
            ),
            const SizedBox(height: 40),

            // Drop Zone Area
            Expanded(
              child: GestureDetector(
                onTap: () => _pickFileAndScan(context),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: vtCard,
                    borderRadius: BorderRadius.circular(20),
                    // ทำขอบเป็นสีฟ้า
                    border: Border.all(
                      color: vtAccent.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 80,
                        color: vtAccent.withOpacity(0.8),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "TAP TO BROWSE",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Max size: 650MB",
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Courier',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40), // เว้นที่ด้านล่างหน่อย
          ],
        ),
      ),
    );
  }
}
