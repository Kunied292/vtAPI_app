import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <--- เพิ่มสำหรับ MethodChannel
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../services/vt_api.dart';
import 'analysis_loading_screen.dart';
import '../const/my_const.dart';
import '../widgets/custom_app_bar_widget.dart';

class DeviceScanScreen extends StatefulWidget {
  const DeviceScanScreen({super.key});

  @override
  State<DeviceScanScreen> createState() => _DeviceScanScreenState();
}

class _DeviceScanScreenState extends State<DeviceScanScreen> {
  // 1. เชื่อมต่อท่อส่งข้อมูลที่ตั้งชื่อไว้ใน Kotlin
  static const platform = MethodChannel('com.vtscanner/apk_path');

  List<AppInfo> _apps = [];
  bool _isLoadingApps = true;
  String? _scanningPackageName;

  @override
  void initState() {
    super.initState();
    _loadInstalledApps();
  }

  Future<void> _loadInstalledApps() async {
    // ใช้แพ็กเกจใหม่ ดึงแอป (excludeSystemApps: true, withIcon: true)
    List<AppInfo> apps = await InstalledApps.getInstalledApps(
      excludeSystemApps: false,
      withIcon: true,
    );

    // เรียงตามตัวอักษร A-Z
    apps.sort(
      (a, b) => (a.name).toLowerCase().compareTo((b.name).toLowerCase()),
    );

    if (mounted) {
      setState(() {
        _apps = apps;
        _isLoadingApps = false;
      });
    }
  }

  Future<void> _scanApp(AppInfo app) async {
    setState(() => _scanningPackageName = app.packageName);

    try {
      // 2. เรียกใช้คำสั่ง getApkPath ผ่าน Native Android!
      final String apkPath = await platform.invokeMethod('getApkPath', {
        'packageName': app.packageName,
      });

      // 3. ได้ APK Path มาแล้ว โยนขึ้น VirusTotal เลย!
      final apiService = VtApiService();
      final resultOrFailure = await apiService.uploadFileForScan(apkPath);

      if (mounted) {
        setState(() => _scanningPackageName = null);

        resultOrFailure.fold(
          (failure) {
            _showError("Failed to upload app: ${failure.message}");
          },
          (analysisId) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AnalyzingScreen(
                  targetName: "${app.name}.apk",
                  analysisId: analysisId,
                ),
              ),
            );
          },
        );
      }
    } on PlatformException catch (e) {
      // ดักจับ Error กรณีที่ Kotlin หาไฟล์ไม่เจอ
      setState(() => _scanningPackageName = null);
      _showError("Failed to extract APK: '${e.message}'.");
    } catch (e) {
      setState(() => _scanningPackageName = null);
      _showError("An unexpected error occurred.");
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'DEVICE APPS SCAN'),
      body: _isLoadingApps
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: vtAccent),
                  const SizedBox(height: 16),
                  Text("Scanning installed apps...", style: textLabel),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "FOUND ${_apps.length} APPLICATIONS",
                    style: textLabel.copyWith(color: vtGreen),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _apps.length,
                      itemBuilder: (context, index) {
                        final app = _apps[index];
                        final bool isScanningThis =
                            _scanningPackageName == app.packageName;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            // แพ็กเกจใหม่ส่งรูปมาเป็น Uint8List (bytes)
                            leading: app.icon != null
                                ? Image.memory(
                                    app.icon as Uint8List,
                                    width: 40,
                                    height: 40,
                                  )
                                : const Icon(
                                    Icons.android,
                                    color: Colors.green,
                                    size: 40,
                                  ),
                            title: Text(app.name, style: textLabel),
                            subtitle: Text(
                              "v${app.versionName}",
                              style: textDescription.copyWith(fontSize: 12),
                            ),
                            trailing: isScanningThis
                                ? SizedBox(
                                    width: 64,
                                    height: 40,
                                    child: Center(
                                      child:
                                          LoadingAnimationWidget.progressiveDots(
                                            color: vtAccent,
                                            size: 30,
                                          ),
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: _scanningPackageName != null
                                        ? null
                                        : () => _scanApp(app),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: vtAccent.withValues(
                                        alpha: 0.2,
                                      ),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      "SCAN",
                                      style: textLabel.copyWith(
                                        color: vtAccent,
                                      ),
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
