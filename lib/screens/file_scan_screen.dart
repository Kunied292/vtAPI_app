import 'package:flutter/material.dart';
import 'package:vtscanner/services/vt_api.dart';
import 'analysis_loading_screen.dart';
import '../const/my_const.dart';
import 'package:file_picker/file_picker.dart';

class FileScanScreen extends StatelessWidget {
  const FileScanScreen({super.key});

  Future<void> _pickFileAndScan(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null) {
      return;
    }
    String fileName = result.files.single.name;
    String filePath = result.files.single.path!;

    final apiService = VtApiService();
    String? analysisId = await apiService.uploadFileForScan(filePath);

    if (context.mounted) {
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
              'Failed to upload file',
              style: TextStyle(color: Colors.white),
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
