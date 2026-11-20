import 'package:flutter_test/flutter_test.dart';
import 'package:transaksi_sawit_app/core/services/app_update_service.dart';

void main() {
  group('AppUpdateInfo Tests', () {
    test('fromJson parses correctly and detects newer version', () {
      final json = {
        'latest_version': '2.5.4',
        'version_code': 254,
        'min_supported_version': '2.0.0',
        'release_date': '2026-11-20',
        'release_notes': {
          'id': 'Catatan rilis bahasa Indonesia',
        },
        'changelog': [
          'Fitur A',
          'Perbaikan B',
        ],
        'downloads': {
          'android': {'url': 'downloads/app.apk'},
          'windows': {'url': 'downloads/app.zip'},
        },
      };

      // Current version 2.4.6 is older than 2.5.4 -> hasUpdate should be true
      final info = AppUpdateInfo.fromJson(json, '2.4.6');
      expect(info.latestVersion, equals('2.5.4'));
      expect(info.versionCode, equals(254));
      expect(info.hasUpdate, isTrue);
      expect(info.releaseNotes, equals('Catatan rilis bahasa Indonesia'));
      expect(info.changelog.length, equals(2));
      expect(info.downloadApkUrl, equals('downloads/app.apk'));
      expect(info.downloadWindowsUrl, equals('downloads/app.zip'));
    });

    test('fromJson correctly identifies same or older version as hasUpdate false', () {
      final json = {
        'latest_version': '2.5.4',
        'version_code': 254,
      };

      // When running on 2.5.4, same version -> hasUpdate should be false
      final infoSame = AppUpdateInfo.fromJson(json, '2.5.4');
      expect(infoSame.hasUpdate, isFalse);

      // When running on 2.6.0, newer than server -> hasUpdate should be false
      final infoNewer = AppUpdateInfo.fromJson(json, '2.6.0');
      expect(infoNewer.hasUpdate, isFalse);
    });

    test('semver comparison handles patch, minor, and major correctly', () {
      final jsonHigherPatch = {'latest_version': '2.5.5'};
      expect(AppUpdateInfo.fromJson(jsonHigherPatch, '2.5.4').hasUpdate, isTrue);

      final jsonHigherMinor = {'latest_version': '2.6.0'};
      expect(AppUpdateInfo.fromJson(jsonHigherMinor, '2.5.4').hasUpdate, isTrue);

      final jsonHigherMajor = {'latest_version': '3.0.0'};
      expect(AppUpdateInfo.fromJson(jsonHigherMajor, '2.5.4').hasUpdate, isTrue);

      final jsonLower = {'latest_version': '2.4.9'};
      expect(AppUpdateInfo.fromJson(jsonLower, '2.5.4').hasUpdate, isFalse);
    });
  });
}
