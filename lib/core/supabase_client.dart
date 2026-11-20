import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tenant_config_service.dart';

/// Supabase environment configuration and client initialization.
/// Kredensial dibaca dari environment variables (--dart-define) atau TenantConfigService.
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Helper untuk memastikan konfigurasi telah disediakan
  static bool get isConfigured {
    if (url.isNotEmpty && anonKey.isNotEmpty) return true;
    try {
      final client = Supabase.instance.client;
      return client.rest.url.toString().isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Inisialisasi Supabase saat app bootstrap (di main.dart)
  /// Membaca konfigurasi tenant aktif dari TenantConfigService
  static Future<void> initialize() async {
    final tenantConfig = await TenantConfigService.loadConfig();
    final targetUrl = tenantConfig.isValid ? tenantConfig.supabaseUrl : url;
    final targetAnonKey = tenantConfig.isValid ? tenantConfig.supabaseAnonKey : anonKey;

    if (targetUrl.isEmpty || targetAnonKey.isEmpty) {
      // ignore: avoid_print
      print(
        'PERINGATAN: Supabase URL atau Anon Key belum disetel.',
      );
      return;
    }

    try {
      // ignore: deprecated_member_use
      await Supabase.initialize(
        url: targetUrl,
        // ignore: deprecated_member_use
        anonKey: targetAnonKey,
      );
    } catch (e) {
      // ignore: avoid_print
      print('Gagal inisialisasi Supabase: $e');
    }
  }
}

/// Riverpod provider untuk SupabaseClient instance (aman jika belum diinisialisasi)
final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
});
