import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Informasi rilis pembaruan aplikasi dari portal version.json
class AppUpdateInfo {
  final String latestVersion;
  final int versionCode;
  final String minSupportedVersion;
  final String releaseDate;
  final List<String> changelog;
  final String releaseNotes;
  final String? downloadApkUrl;
  final String? downloadWindowsUrl;
  final bool hasUpdate;

  const AppUpdateInfo({
    required this.latestVersion,
    required this.versionCode,
    required this.minSupportedVersion,
    required this.releaseDate,
    required this.changelog,
    required this.releaseNotes,
    this.downloadApkUrl,
    this.downloadWindowsUrl,
    required this.hasUpdate,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json, String currentVersion) {
    final latestVer = (json['latest_version'] as String?) ?? '2.5.4';
    final hasNewVersion = _compareVersions(latestVer, currentVersion) > 0;

    final downloads = json['downloads'] as Map<String, dynamic>? ?? {};
    final android = downloads['android'] as Map<String, dynamic>? ?? {};
    final windows = downloads['windows'] as Map<String, dynamic>? ?? {};

    final notes = json['release_notes'] as Map<String, dynamic>? ?? {};
    final noteId = (notes['id'] as String?) ?? '';

    final rawChangelog = json['changelog'];
    final changelogList = rawChangelog is List
        ? rawChangelog.map((e) => e.toString()).toList()
        : <String>[];

    return AppUpdateInfo(
      latestVersion: latestVer,
      versionCode: (json['version_code'] as num?)?.toInt() ?? 0,
      minSupportedVersion: (json['min_supported_version'] as String?) ?? '2.0.0',
      releaseDate: (json['release_date'] as String?) ?? '',
      changelog: changelogList,
      releaseNotes: noteId,
      downloadApkUrl: android['url'] as String?,
      downloadWindowsUrl: windows['url'] as String?,
      hasUpdate: hasNewVersion,
    );
  }

  /// Membandingkan semver vA vs vB
  /// return > 0 jika vA > vB, < 0 jika vA < vB, 0 jika sama
  static int _compareVersions(String vA, String vB) {
    try {
      final cleanA = vA.replaceAll(RegExp(r'[^0-9.]'), '');
      final cleanB = vB.replaceAll(RegExp(r'[^0-9.]'), '');
      final partsA = cleanA.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final partsB = cleanB.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      final maxLen = partsA.length > partsB.length ? partsA.length : partsB.length;
      for (var i = 0; i < maxLen; i++) {
        final a = i < partsA.length ? partsA[i] : 0;
        final b = i < partsB.length ? partsB[i] : 0;
        if (a > b) return 1;
        if (a < b) return -1;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }
}

/// Service untuk mengecek versi terbaru dari Portal Web RamSawit
class AppUpdateService {
  static const String currentAppVersion = '2.5.8';
  static const String _keyPortalUrl = 'ramsawit_portal_update_url';
  static const String defaultPortalUrl = 'https://ramsawit-portal.vercel.app';

  final SharedPreferences? _prefs;

  AppUpdateService([this._prefs]);

  /// Mendapatkan endpoint portal URL
  String getPortalUrl() {
    return _prefs?.getString(_keyPortalUrl)?.trim().isNotEmpty == true
        ? _prefs!.getString(_keyPortalUrl)!.trim()
        : defaultPortalUrl;
  }

  /// Menyimpan konfigurasi portal URL kustom
  Future<void> setPortalUrl(String url) async {
    if (_prefs != null) {
      await _prefs.setString(_keyPortalUrl, url.trim());
    }
  }

  /// Mengecek pembaruan aplikasi ke endpoint portal
  Future<AppUpdateInfo?> checkForUpdate({String? customUrl}) async {
    final base = customUrl ?? getPortalUrl();
    final cleanBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final url = Uri.parse('$cleanBase/version.json');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AppUpdateInfo.fromJson(data, currentAppVersion);
      }
    } catch (e) {
      debugPrint('[AppUpdateService] Cek pembaruan gagal atau offline: $e');
    }
    return null;
  }

  /// Menampilkan dialog notifikasi pembaruan jika tersedia
  static void showUpdateAvailableDialog(BuildContext context, AppUpdateInfo info) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F62FE).withAlpha(25),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.system_update_alt, color: Color(0xFF0F62FE), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pembaruan Tersedia',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Versi terbaru: v${info.latestVersion} (Saat ini: v$currentAppVersion)',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (info.releaseNotes.isNotEmpty) ...[
                    Text(
                      info.releaseNotes,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (info.changelog.isNotEmpty) ...[
                    const Text(
                      'Daftar Perubahan:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    ...info.changelog.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: Color(0xFF0F62FE), fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(fontSize: 12, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Text(
                      Platform.isAndroid
                          ? 'Paket APK Android siap diunduh melalui portal web rilis.'
                          : 'Paket rilis Windows siap diunduh melalui portal web rilis.',
                      style: TextStyle(fontSize: 11, color: Colors.blue.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Nanti Saja', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F62FE),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Silakan unduh pembaruan v${info.latestVersion} melalui browser portal unduh.',
                    ),
                    duration: const Duration(seconds: 4),
                  ),
                );
              },
              child: const Text('Unduh Pembaruan'),
            ),
          ],
        );
      },
    );
  }
}

/// Provider instance AppUpdateService
final appUpdateServiceProvider = Provider<AppUpdateService>((ref) {
  return AppUpdateService();
});
