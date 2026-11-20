import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk menyimpan dan mengelola metadata sesi login lokal secara persisten.
/// Bekerja konsisten di Web (localStorage) dan Mobile (SharedPreferences / NSUserDefaults).
class SessionStorageService {
  static const String _keyLoginTimestamp = 'auth_login_timestamp_ms';
  static const String _keyExpiredMessage = 'auth_session_expired_message';

  final SharedPreferences? _prefs;

  SessionStorageService([this._prefs]);

  /// Inisialisasi SharedPreferences instance jika belum disediakan (aman dari hang)
  Future<SharedPreferences?> _getPrefs() async {
    if (_prefs != null) return _prefs;
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  /// Menyimpan waktu login dalam milidetik sejak epoch (DateTime.millisecondsSinceEpoch)
  Future<void> saveLoginTimestamp(DateTime loginTime) async {
    try {
      final prefs = await _getPrefs();
      await prefs?.setInt(_keyLoginTimestamp, loginTime.millisecondsSinceEpoch);
      // Hapus pesan kedaluwarsa sesi sebelumnya saat login baru berhasil
      await prefs?.remove(_keyExpiredMessage);
    } catch (_) {}
  }

  /// Mengambil timestamp waktu login yang tersimpan
  Future<int?> getLoginTimestamp() async {
    try {
      final prefs = await _getPrefs();
      return prefs?.getInt(_keyLoginTimestamp);
    } catch (_) {
      return null;
    }
  }

  /// Menghapus timestamp login (dipanggil saat logout manual atau forced logout)
  Future<void> clearLoginTimestamp() async {
    try {
      final prefs = await _getPrefs();
      await prefs?.remove(_keyLoginTimestamp);
    } catch (_) {}
  }

  /// Menyimpan pesan kedaluwarsa sesi untuk ditampilkan di halaman login
  Future<void> setExpiredMessage(String message) async {
    try {
      final prefs = await _getPrefs();
      await prefs?.setString(_keyExpiredMessage, message);
    } catch (_) {}
  }

  /// Mengambil pesan kedaluwarsa sesi yang tersimpan
  Future<String?> getExpiredMessage() async {
    try {
      final prefs = await _getPrefs();
      return prefs?.getString(_keyExpiredMessage);
    } catch (_) {
      return null;
    }
  }

  /// Menghapus pesan kedaluwarsa sesi
  Future<void> clearExpiredMessage() async {
    try {
      final prefs = await _getPrefs();
      await prefs?.remove(_keyExpiredMessage);
    } catch (_) {}
  }
}

/// Provider untuk SessionStorageService
final sessionStorageServiceProvider = Provider<SessionStorageService>((ref) {
  return SessionStorageService();
});
