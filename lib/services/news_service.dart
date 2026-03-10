import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/failure.dart';

class NewsService {
  // Singleton pattern
  static final NewsService _instance = NewsService._internal();
  factory NewsService() => _instance;
  NewsService._internal();

  // ดึง API Key จากไฟล์ .env ผ่าน flutter_dotenv
  final String _apiKey = dotenv.env['NEWS_API_KEY'] ?? '';

  Future<Either<Failure, List<dynamic>>> getCyberNews() async {
    // ป้องกันกรณีไม่ได้ตั้งค่า API Key
    if (_apiKey.isEmpty) {
      return Left(Failure("NEWS API Key is missing in .env file"));
    }

    // ค้นหาคำว่า cybersecurity หรือ malware เรียงจากข่าวใหม่ล่าสุด
    final url = Uri.parse(
      'https://newsapi.org/v2/everything?q=cybersecurity OR malware OR ransomware&language=en&sortBy=publishedAt&apiKey=$_apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // แปลงข้อความ JSON ให้กลายเป็น Map ใน Dart
        final Map<String, dynamic> data = jsonDecode(response.body);

        // ส่งคืนเฉพาะก้อน 'articles' (ซึ่งเป็น List ของข่าวทั้งหมด)
        return Right(data['articles']);
      } else {
        return Left(Failure("News API Error: ${response.statusCode}"));
      }
    } catch (e) {
      return Left(Failure("Network Error: $e"));
    }
  }
}
