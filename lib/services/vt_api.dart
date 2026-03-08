import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dartz/dartz.dart';
import '../core/failure.dart';

class VtApiService {
  final String _apiKey = dotenv.env['VT_API_KEY'] ?? '';

  // ฟังก์ชันอัปโหลดไฟล์ไปยัง VirusTotal
  Future<Either<Failure, String>> uploadFileForScan(String filePath) async {
    // 1. อ่านขนาดไฟล์จากเครื่อง (หน่วยเป็น Bytes)
    final file = File(filePath);
    final int fileSizeInBytes = await file.length();

    // คำนวณขนาด (1 MB = 1024 * 1024 Bytes)
    final int limit32MB = 32 * 1024 * 1024;
    final int limit650MB = 650 * 1024 * 1024;

    // ถ้าไฟล์ใหญ่กว่า 650MB ไม่ต้องทำต่อ (เกินที่ VT กำหนด)
    if (fileSizeInBytes > limit650MB) {
      return Left(Failure('File is larger than 650MB limit.'));
    }

    // กำหนด URL เริ่มต้นเป็นแบบปกติ (สำหรับไฟล์เล็ก)
    String uploadUrl = 'https://www.virustotal.com/api/v3/files';

    // 2. ถ้าไฟล์ใหญ่กว่า 32 MB ต้องไปขอ URL พิเศษมาก่อน
    if (fileSizeInBytes > limit32MB) {
      try {
        final urlResponse = await http.get(
          Uri.parse('https://www.virustotal.com/api/v3/files/upload_url'),
          headers: {'x-apikey': _apiKey, 'accept': 'application/json'},
        );

        if (urlResponse.statusCode == 200) {
          final jsonUrlData = jsonDecode(urlResponse.body);
          uploadUrl = jsonUrlData['data']; // เอา URL ยาวๆ ที่ได้มาใช้แทน
        } else {
          return Left(
            Failure('Failed to get upload URL: ${urlResponse.statusCode}'),
          );
        }
      } catch (e) {
        return Left(Failure('Error getting upload URL: $e'));
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
        return Right(jsonResponse['data']['id']); // ส่ง Analysis ID กลับไป
      } else {
        return Left(
          Failure(
            'VT API Upload Error: ${response.statusCode} - ${response.body}',
          ),
        );
      }
    } catch (e) {
      return Left(Failure('Network Error: $e'));
    }
  }

  Future<Either<Failure, String>> scanUrl(String targetUrl) async {
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
        return Right(jsonResponse['data']['id']);
      } else {
        return Left(
          Failure(
            'VT API URL Scan Error: ${response.statusCode} - ${response.body}',
          ),
        );
      }
    } catch (e) {
      return Left(Failure('Network Error: $e'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getAnalysisReport(
    String analysisId,
  ) async {
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
        return Right(jsonDecode(response.body)); // คืนค่า JSON กลับไป
      } else {
        return Left(Failure('VT API Report Error: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(Failure('Network Error: $e'));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getApiUsage() async {
    final uri = Uri.parse(
      'https://www.virustotal.com/api/v3/users/$_apiKey/api_usage',
    );

    try {
      final response = await http.get(
        uri,
        headers: {'x-apikey': _apiKey, 'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Right(jsonDecode(response.body));
      } else {
        return Left(
          Failure(
            'VT API Usage Error: ${response.statusCode} - ${response.body}',
          ),
        );
      }
    } catch (e) {
      return Left(Failure('Network Error: $e'));
    }
  }
}
