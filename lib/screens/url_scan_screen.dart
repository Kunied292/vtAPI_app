import 'package:flutter/material.dart';

import '../services/vt_api.dart';
import 'analysis_loading_screen.dart';
import '../const/my_const.dart';

class UrlScanScreen extends StatefulWidget {
  const UrlScanScreen({super.key});

  @override
  State<UrlScanScreen> createState() => _UrlScanScreenState();
}

class _UrlScanScreenState extends State<UrlScanScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;

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
        title: Text('URL ANALYSIS', style: textTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter a URL, IP address, or domain to scan.",
              style: textDescription,
            ),
            const SizedBox(height: 30),

            // ช่องกรอก URL
            TextField(
              controller: _urlController,
              style: textLabel.copyWith(color: Colors.white),
              decoration: InputDecoration(
                hintText: "https://...",
                hintStyle: textLabel.copyWith(color: Colors.grey, fontSize: 14),
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
                // 1. ถ้าระบบกำลังโหลดอยู่ ให้ปุ่มเป็น null (จะทำให้ปุ่มเป็นสีเทาและกดซ้ำไม่ได้)
                onPressed: _isLoading
                    ? null
                    : () async {
                        final url = _urlController.text.trim();

                        if (url.isNotEmpty) {
                          // 2. สั่งเปิดสถานะ Loading (ตัวหมุนจะโผล่ขึ้นมา)
                          setState(() {
                            _isLoading = true;
                          });

                          final apiService = VtApiService();
                          String? analysisId = await apiService.scanUrl(url);

                          if (context.mounted) {
                            // 3. พอ API ตอบกลับมา ก็สั่งปิด Loading
                            setState(() {
                              _isLoading = false;
                            });

                            if (analysisId != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AnalyzingScreen(
                                    targetName: url,
                                    analysisId: analysisId,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Failed to scan URL. Please check the format.",
                                  ),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  // ถ้าโหลดอยู่ เปลี่ยนสีปุ่มให้ดูทึบลงหน่อย
                  backgroundColor: _isLoading ? vtCard : vtAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                // 4. สลับ UI ระหว่างตัวหมุน กับ ข้อความ
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white, // ตัวหมุนสีขาว
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        "ANALYZE NOW",
                        style: textLabel.copyWith(
                          color: Colors.white,
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
