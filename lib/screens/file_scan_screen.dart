import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/vt_api.dart';
import 'analysis_loading_screen.dart';
import '../const/my_const.dart';

// 1. เปลี่ยนจาก StatelessWidget เป็น StatefulWidget
class FileScanScreen extends StatefulWidget {
  const FileScanScreen({super.key});

  @override
  State<FileScanScreen> createState() => _FileScanScreenState();
}

class _FileScanScreenState extends State<FileScanScreen> {
  // 2. ประกาศตัวแปร _isLoading
  bool _isLoading = false;

  Future<void> _pickFileAndScan(BuildContext context) async {
    // เปิดหน้าเลือกไฟล์ (ขั้นตอนนี้ยังไม่ต้องโชว์ตัวหมุน ให้ผู้ใช้เลือกไฟล์ตามสบาย)
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    // ถ้าผู้ใช้กดยกเลิก
    if (result == null || result.files.single.path == null) {
      return;
    }

    // 3. พอได้ไฟล์มาแล้ว เราจะเริ่มอัปโหลด -> สั่งเปิด Loading ตรงนี้เลย!
    setState(() {
      _isLoading = true;
    });

    String filePath = result.files.single.path!;
    String fileName = result.files.single.name;

    final apiService = VtApiService();
    String? analysisId = await apiService.uploadFileForScan(filePath);

    if (mounted) {
      // 4. ไม่ว่าจะสำเร็จหรือพัง ก็ต้องสั่งปิด Loading
      setState(() {
        _isLoading = false;
      });

      if (analysisId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AnalyzingScreen(targetName: fileName, analysisId: analysisId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Upload failed. File might be too large or API error.",
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: vtBackground,
      appBar: AppBar(
        backgroundColor: vtBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('FILE UPLOAD', style: textTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select a suspicious file to analyze.",
              style: textDescription,
            ),
            const SizedBox(height: 40),

            Expanded(
              child: GestureDetector(
                // 5. ป้องกันการกดซ้ำซ้อน: ถ้าโหลดอยู่ ให้ onTap เป็น null (กดไม่ได้)
                onTap: _isLoading ? null : () => _pickFileAndScan(context),

                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: vtCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isLoading
                          ? vtAccent
                          : vtAccent.withOpacity(
                              0.5,
                            ), // ถ้าโหลดอยู่ขอบจะสว่างขึ้น
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // 6. สลับหน้าตากล่อง Drop Zone
                    children: _isLoading
                        ? [
                            // หน้าตาตอน "กำลังโหลด"
                            const CircularProgressIndicator(
                              color: Color(0xFF3B82F6),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "UPLOADING FILE...",
                              style: textLabel.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Please do not close the app",
                              style: textDescription,
                            ),
                          ]
                        : [
                            // หน้าตาตอน "ปกติ" (เหมือนเดิม)
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 80,
                              color: vtAccent.withOpacity(0.8),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "TAP TO BROWSE",
                              style: textLabel.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text("Max size: 650MB", style: textDescription),
                          ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
