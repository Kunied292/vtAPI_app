import 'dart:convert';
import 'package:http/http.dart' as http;

class VtApiService {
  final String _apiKey =
      '56e7f0c3dd77eb8dd56306994aa26d87e22aa5113ea62a49a34307eafd40907e';

  // ฟังก์ชันอัปโหลดไฟล์ไปยัง VirusTotal
  Future<String?> uploadFileForScan(String filePath) async {
    // 1. กำหนด URL
    final uri = Uri.parse('https://www.virustotal.com/api/v3/files');

    // 2. สร้าง MultipartRequest (ใช้สำหรับการส่งไฟล์)
    var request = http.MultipartRequest('POST', uri);

    // 3. แนบ Headers ตามที่ Docs ระบุ
    request.headers.addAll({'x-apikey': _apiKey, 'accept': 'application/json'});

    // 4. แนบไฟล์เข้าไปใน Request
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    try {
      // 5. สั่งยิง API
      var streamedResponse = await request.send();
      // แปลง stream กลับมาเป็น response ปกติให้อ่านง่าย
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // อัปโหลดสำเร็จ! แกะ JSON เพื่อเอา Analysis ID
        print('------------- Upload Success -------------');
        var jsonResponse = jsonDecode(response.body);
        String analysisId = jsonResponse['data']['id'];
        return analysisId;
      } else {
        // กรณี Error (เช่น ไฟล์ใหญ่ไป, API Key ผิด)
        print('VT API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getAnalysisReport(String analysisId) async {
    final uri = Uri.parse(
      'https://www.virustotal.com/api/v3/analyses/$analysisId',
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'x-apikey': _apiKey, // ใช้ API Key ตัวเดิม
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // คืนค่า JSON กลับไป
      } else {
        print('VT API Report Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Network Error: $e');
      return null;
    }
  }
}
