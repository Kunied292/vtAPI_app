import 'package:flutter/material.dart';

import '../services/vt_api.dart';
import 'analysis_loading_screen.dart';
import '../const/my_const.dart';
import '../widgets/custom_app_bar_widget.dart';
import '../widgets/vt_primary_button_widget.dart';

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
      appBar: const CustomAppBar(title: 'URL ANALYSIS'),
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
            VTPrimaryButton(
              text: "ANALYZE NOW",
              isLoading: _isLoading,
              onPressed: () async {
                final url = _urlController.text.trim();

                if (url.isNotEmpty) {
                  // 2. สั่งเปิดสถานะ Loading (ตัวหมุนจะโผล่ขึ้นมา)
                  setState(() {
                    _isLoading = true;
                  });

                  final apiService = VtApiService();
                  final resultOrFailure = await apiService.scanUrl(url);

                  if (context.mounted) {
                    // 3. พอ API ตอบกลับมา ก็สั่งปิด Loading
                    setState(() {
                      _isLoading = false;
                    });

                    resultOrFailure.fold(
                      (failure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(failure.message),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      },
                      (analysisId) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnalyzingScreen(
                              targetName: url,
                              analysisId: analysisId,
                            ),
                          ),
                        );
                      },
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 20), // เผื่อขอบจอด้านล่าง
          ],
        ),
      ),
    );
  }
}
