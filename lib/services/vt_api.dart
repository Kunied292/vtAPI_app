import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class VtApiService {
  final String _apiKey =
      '56e7f0c3dd77eb8dd56306994aa26d87e22aa5113ea62a49a34307eafd40907e';

  // ฟังก์ชันอัปโหลดไฟล์ไปยัง VirusTotal
  Future<String?> uploadFileForScan(String filePath) async {
    // 1. อ่านขนาดไฟล์จากเครื่อง (หน่วยเป็น Bytes)
    final file = File(filePath);
    final int fileSizeInBytes = await file.length();

    // คำนวณขนาด (1 MB = 1024 * 1024 Bytes)
    final int limit32MB = 32 * 1024 * 1024;
    final int limit650MB = 650 * 1024 * 1024;

    // ถ้าไฟล์ใหญ่กว่า 650MB ไม่ต้องทำต่อ (เกินที่ VT กำหนด)
    if (fileSizeInBytes > limit650MB) {
      print('ERROR: File is larger than 650MB.');
      return null;
    }

    // กำหนด URL เริ่มต้นเป็นแบบปกติ (สำหรับไฟล์เล็ก)
    String uploadUrl = 'https://www.virustotal.com/api/v3/files';

    // 2. ถ้าไฟล์ใหญ่กว่า 32 MB ต้องไปขอ URL พิเศษมาก่อน
    if (fileSizeInBytes > limit32MB) {
      print('File is > 32MB. Requesting special upload URL...');
      try {
        final urlResponse = await http.get(
          Uri.parse('https://www.virustotal.com/api/v3/files/upload_url'),
          headers: {'x-apikey': _apiKey, 'accept': 'application/json'},
        );

        if (urlResponse.statusCode == 200) {
          final jsonUrlData = jsonDecode(urlResponse.body);
          uploadUrl = jsonUrlData['data']; // เอา URL ยาวๆ ที่ได้มาใช้แทน
          print('Got special URL! Ready to upload.');
        } else {
          print('Failed to get upload URL: ${urlResponse.statusCode}');
          return null;
        }
      } catch (e) {
        print('Error getting upload URL: $e');
        return null;
      }
    }

    // 3. เริ่มขั้นตอนอัปโหลด (ใช้ URL ไหนก็แล้วแต่เงื่อนไขด้านบน)
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.headers.addAll({'x-apikey': _apiKey, 'accept': 'application/json'});

    // แนบไฟล์
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return jsonResponse['data']['id']; // ส่ง Analysis ID กลับไป
      } else {
        print('VT API Upload Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network Error: $e');
      return null;
    }
  }

  Future<String?> scanUrl(String targetUrl) async {
    final uri = Uri.parse('https://www.virustotal.com/api/v3/urls');

    try {
      final response = await http.post(
        uri,
        headers: {
          'x-apikey': _apiKey,
          'accept': 'application/json',
          // 💡 สำคัญ: ต้องบอก VT ว่าเรากำลังส่งข้อมูลฟอร์มแบบ Text (URL) ไปให้
          'content-type': 'application/x-www-form-urlencoded',
        },
        body: {
          'url': targetUrl, // ส่ง URL เข้าไปใน Body
        },
      );

      if (response.statusCode == 200) {
        // สำเร็จ! แกะเอา Analysis ID ออกมาเหมือนตอนสแกนไฟล์เลย
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data']['id'];
      } else {
        print(
          'VT API URL Scan Error: ${response.statusCode} - ${response.body}',
        );
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
