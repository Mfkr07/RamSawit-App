import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tenant_config_service.dart';

/// Trigger provider untuk menyegarkan SupabaseClient di seluruh aplikasi
final supabaseClientRefreshTriggerProvider = StateProvider<int>((ref) => 0);

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
      if (!Supabase.instance.isInitialized) return false;
      final client = Supabase.instance.client;
      return client.rest.url.toString().isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Inisialisasi Supabase saat app bootstrap (di main.dart) atau saat tenant diperbarui.
  /// Membaca konfigurasi tenant aktif dari TenantConfigService.
  static Future<bool> initialize() async {
    final tenantConfig = await TenantConfigService.loadConfig();
    final targetUrl = tenantConfig.isValid ? tenantConfig.supabaseUrl : url;
    final targetAnonKey = tenantConfig.isValid ? tenantConfig.supabaseAnonKey : anonKey;

    if (targetUrl.isEmpty || targetAnonKey.isEmpty) {
      debugPrint('PERINGATAN: Supabase URL atau Anon Key belum disetel.');
      return false;
    }

    try {
      if (Supabase.instance.isInitialized) {
        await Supabase.instance.dispose();
      }
    } catch (_) {}

    try {
      // ignore: deprecated_member_use
      await Supabase.initialize(
        url: targetUrl,
        // ignore: deprecated_member_use
        anonKey: targetAnonKey,
      );
      return true;
    } catch (e) {
      debugPrint('Gagal inisialisasi Supabase: $e');
      return false;
    }
  }
}

/// Riverpod provider untuk SupabaseClient instance (aman jika belum diinisialisasi)
final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  ref.watch(supabaseClientRefreshTriggerProvider);
  try {
    if (Supabase.instance.isInitialized) {
      return Supabase.instance.client;
    }
    return null;
  } catch (_) {
    return null;
  }
});
