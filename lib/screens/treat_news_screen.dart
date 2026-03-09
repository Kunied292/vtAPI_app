import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart' hide State;
import '../core/failure.dart';
import '../services/news_service.dart';
import '../const/my_const.dart';
import '../widgets/vt_primary_button_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ThreatIntelScreen extends StatefulWidget {
  const ThreatIntelScreen({super.key});

  @override
  State<ThreatIntelScreen> createState() => _ThreatIntelScreenState();
}

class _ThreatIntelScreenState extends State<ThreatIntelScreen> {
  // เปลี่ยนมารอรับค่าเป็น Either<Failure, List<dynamic>>
  late Future<Either<Failure, List<dynamic>>> _newsFuture;
  final NewsService _newsService = NewsService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // ถ้าไม่ได้ล็อกอิน ไม่ต้องดึงข่าว
    if (_auth.currentUser != null) {
      _newsFuture = _newsService.getCyberNews();
    } else {
      // คืนค่า List ว่างๆ ทันที
      _newsFuture = Future.value(const Right([]));
    }
  }

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the article.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 24.0,
        left: 24.0,
        right: 24.0,
        bottom: 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "GLOBAL THREAT FEED",
            style: textLabel.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Latest cybersecurity news (Powered by NewsAPI)",
            style: textDescription.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: FutureBuilder<Either<Failure, List<dynamic>>>(
              future: _newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return _buildErrorState(
                    "Failed to load news.\nPlease check your connection.",
                  );
                }

                return snapshot.data!.fold(
                  (failure) => _buildErrorState(failure.message),
                  (items) {
                    if (items.isEmpty) {
                      // เช็คว่าเป็น Guest หรือเปล่า
                      if (_auth.currentUser == null) {
                        return Center(
                          child: Text(
                            "Sign in to access the Global Threat Feed\nand stay updated on the latest cybersecurity news.",
                            textAlign: TextAlign.center,
                            style: textDescription,
                          ),
                        );
                      }
                      return _buildErrorState("No news found.");
                    }

                    return RefreshIndicator(
                      color: vtAccent,
                      backgroundColor: Theme.of(context).cardColor,
                      onRefresh: () async {
                        setState(() {
                          _newsFuture = _newsService.getCyberNews();
                        });
                      },
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final article = items[index];

                          // คำนวณเวลา delay ให้การ์ดที่โหลดขึ้นมาตอนแรกค่อยๆ โผล่ไล่กัน
                          // แต่การ์ดที่เพิ่งโผล่มาตอนเลื่อนหน้าจอไม่ต้องรอ delay นาน
                          final delayMs = (index < 6 ? index * 100 : 0).ms;

                          // ดึงข้อมูลแต่ละส่วนออกมาจาก JSON
                          final String title = article['title'] ?? "No Title";
                          final String description =
                              article['description'] ??
                              "No description available.";
                          final String? imageUrl = article['urlToImage'];
                          final String articleUrl = article['url'] ?? "";
                          final String sourceName =
                              article['source']['name'] ?? "Unknown Source";

                          // จัดรูปแบบวันที่ (ตัดเอาเฉพาะ YYYY-MM-DD)
                          String pubDate = "Unknown Date";
                          if (article['publishedAt'] != null) {
                            pubDate = article['publishedAt']
                                .toString()
                                .split('T')
                                .first;
                          }

                          final bool isCritical =
                              title.toLowerCase().contains('vulnerability') ||
                              title.toLowerCase().contains('breach');

                          return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isCritical
                                        ? vtRed.withValues(alpha: 0.5)
                                        : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                // คลิปขอบให้มนเพื่อไม่ให้รูปภาพทะลุกรอบออกมา
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () => _launchUrl(articleUrl),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // --- ส่วนรูปภาพหน้าปก ---
                                      if (imageUrl != null &&
                                          imageUrl.isNotEmpty)
                                        Image.network(
                                          imageUrl,
                                          height: 180,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          // ถ้าโหลดรูปไม่ขึ้น (เช่น ลิงก์ตาย) ให้โชว์กล่องสีเทาแทน
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  height: 180,
                                                  width: double.infinity,
                                                  color: Colors.black26,
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey,
                                                    size: 50,
                                                  ),
                                                );
                                              },
                                        ),

                                      // --- ส่วนเนื้อหาข่าว ---
                                      Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: isCritical
                                                        ? vtRed.withValues(
                                                            alpha: 0.2,
                                                          )
                                                        : vtAccent.withValues(
                                                            alpha: 0.2,
                                                          ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    isCritical
                                                        ? "CRITICAL"
                                                        : "NEWS",
                                                    style: textLabel.copyWith(
                                                      color: isCritical
                                                          ? vtRed
                                                          : vtAccent,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.access_time,
                                                      color: Colors.grey,
                                                      size: 12,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      pubDate,
                                                      style: textDescription
                                                          .copyWith(
                                                            fontSize: 10,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              title,
                                              style: textLabel.copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              description,
                                              style: textDescription.copyWith(
                                                fontSize: 12,
                                                height: 1.5,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 12),
                                            const Divider(
                                              color: Colors.black26,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.language,
                                                  color: Colors.grey,
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 6),
                                                // โชว์ชื่อแหล่งข่าวจริงๆ ที่ดึงมาได้
                                                Expanded(
                                                  child: Text(
                                                    "Source: $sourceName",
                                                    style: textDescription
                                                        .copyWith(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.arrow_forward,
                                                  color: Colors.grey,
                                                  size: 14,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .animate()
                              .fade(duration: 400.ms, delay: delayMs)
                              .slideY(
                                begin: 0.1,
                                duration: 400.ms,
                                curve: Curves.easeOut,
                                delay: delayMs,
                              );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: Colors.grey, size: 40),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textLabel.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: VTPrimaryButton(
              text: "RETRY",
              onPressed: () =>
                  setState(() => _newsFuture = _newsService.getCyberNews()),
            ),
          ),
        ],
      ),
    );
  }
}
