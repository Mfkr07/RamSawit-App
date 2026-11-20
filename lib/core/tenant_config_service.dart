import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_client.dart';

/// Data class yang merepresentasikan konfigurasi Supabase per tenant/organisasi
class TenantConfig {
  final String namaOrganisasi;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final bool isCustom;

  const TenantConfig({
    required this.namaOrganisasi,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.isCustom = false,
  });

  bool get isValid => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  TenantConfig copyWith({
    String? namaOrganisasi,
    String? supabaseUrl,
    String? supabaseAnonKey,
    bool? isCustom,
  }) {
    return TenantConfig(
      namaOrganisasi: namaOrganisasi ?? this.namaOrganisasi,
      supabaseUrl: supabaseUrl ?? this.supabaseUrl,
      supabaseAnonKey: supabaseAnonKey ?? this.supabaseAnonKey,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}

/// Service untuk menyimpan dan membaca konfigurasi Supabase per organisasi
/// secara aman menggunakan flutter_secure_storage dengan fallback SharedPreferences.
class TenantConfigService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      resetOnError: true,
    ),
  );

  static const String _keyNamaOrganisasi = 'tenant_nama_organisasi';
  static const String _keySupabaseUrl = 'tenant_supabase_url';
  static const String _keySupabaseAnonKey = 'tenant_supabase_anon_key';
  static const String _keyIsCustom = 'tenant_is_custom';

  /// Membaca konfigurasi tenant saat ini.
  /// Jika belum ada yang disimpan secara custom, gunakan default bawaan dari SupabaseConfig.
  static Future<TenantConfig> loadConfig() async {
    // 1. Coba baca dari SharedPreferences terlebih dahulu (cepat dan stabil di test/desktop/mobile)
    try {
      final prefs = await SharedPreferences.getInstance();
      final isCustom = prefs.getBool(_keyIsCustom) ?? false;
      if (isCustom) {
        final nama = prefs.getString(_keyNamaOrganisasi);
        final url = prefs.getString(_keySupabaseUrl);
        final key = prefs.getString(_keySupabaseAnonKey);

        if (url != null && url.isNotEmpty && key != null && key.isNotEmpty) {
          return TenantConfig(
            namaOrganisasi: nama ?? 'Organisasi Saya',
            supabaseUrl: url.trim(),
            supabaseAnonKey: key.trim(),
            isCustom: true,
          );
        }
      }
    } catch (_) {}

    // 2. Coba baca dari flutter_secure_storage
    try {
      final isCustomStr = await _storage.read(key: _keyIsCustom);
      final isCustom = isCustomStr == 'true';

      if (isCustom) {
        final nama = await _storage.read(key: _keyNamaOrganisasi);
        final url = await _storage.read(key: _keySupabaseUrl);
        final key = await _storage.read(key: _keySupabaseAnonKey);

        if (url != null && url.isNotEmpty && key != null && key.isNotEmpty) {
          return TenantConfig(
            namaOrganisasi: nama ?? 'Organisasi Saya',
            supabaseUrl: url.trim(),
            supabaseAnonKey: key.trim(),
            isCustom: true,
          );
        }
      }
    } catch (_) {
      // Abaikan jika secure storage error di Windows/Linux/Web tertentu
    }

    return TenantConfig(
      namaOrganisasi: 'RAM Sawit Utama (Default)',
      supabaseUrl: SupabaseConfig.url,
      supabaseAnonKey: SupabaseConfig.anonKey,
      isCustom: false,
    );
  }

  /// Menyimpan konfigurasi baru organisasi ke secure storage & SharedPreferences.
  static Future<void> saveConfig({
    required String namaOrganisasi,
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    final cleanNama = namaOrganisasi.trim();
    final cleanUrl = supabaseUrl.trim();
    final cleanKey = supabaseAnonKey.trim();

    try {
      await _storage.write(key: _keyNamaOrganisasi, value: cleanNama);
      await _storage.write(key: _keySupabaseUrl, value: cleanUrl);
      await _storage.write(key: _keySupabaseAnonKey, value: cleanKey);
      await _storage.write(key: _keyIsCustom, value: 'true');
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyNamaOrganisasi, cleanNama);
      await prefs.setString(_keySupabaseUrl, cleanUrl);
      await prefs.setString(_keySupabaseAnonKey, cleanKey);
      await prefs.setBool(_keyIsCustom, true);
    } catch (_) {}
  }

  /// Menghapus konfigurasi custom dan mengembalikan ke default bawaan.
  static Future<void> resetToDefault() async {
    try {
      await _storage.delete(key: _keyNamaOrganisasi);
      await _storage.delete(key: _keySupabaseUrl);
      await _storage.delete(key: _keySupabaseAnonKey);
      await _storage.delete(key: _keyIsCustom);
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyNamaOrganisasi);
      await prefs.remove(_keySupabaseUrl);
      await prefs.remove(_keySupabaseAnonKey);
      await prefs.remove(_keyIsCustom);
    } catch (_) {}
  }
}
