import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../core/supabase_client.dart';
import '../../core/sync/sync_engine.dart';
import '../../core/tenant_config_service.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_repository.dart';

/// Notifier untuk mengelola state konfigurasi tenant / organisasi.
class TenantConfigNotifier extends StateNotifier<AsyncValue<TenantConfig>> {
  TenantConfigNotifier() : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final config = await TenantConfigService.loadConfig();
      state = AsyncValue.data(config);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> save({
    required String namaOrganisasi,
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    state = const AsyncValue.loading();
    try {
      await TenantConfigService.saveConfig(
        namaOrganisasi: namaOrganisasi,
        supabaseUrl: supabaseUrl,
        supabaseAnonKey: supabaseAnonKey,
      );
      final newConfig = await TenantConfigService.loadConfig();
      state = AsyncValue.data(newConfig);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> reset() async {
    state = const AsyncValue.loading();
    try {
      await TenantConfigService.resetToDefault();
      final defaultConfig = await TenantConfigService.loadConfig();
      state = AsyncValue.data(defaultConfig);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final tenantConfigProvider =
    StateNotifierProvider<TenantConfigNotifier, AsyncValue<TenantConfig>>((ref) {
  return TenantConfigNotifier();
});

/// Halaman Setup Organisasi & Konfigurasi Supabase Multi-Tenant.
class SetupOrganisasiPage extends ConsumerStatefulWidget {
  const SetupOrganisasiPage({super.key});

  @override
  ConsumerState<SetupOrganisasiPage> createState() =>
      _SetupOrganisasiPageState();
}

class _SetupOrganisasiPageState extends ConsumerState<SetupOrganisasiPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _urlController = TextEditingController();
  final _keyController = TextEditingController();
  bool _obscureKey = true;
  bool _isSaving = false;
  bool _isTesting = false;
  String? _testResultText;
  bool? _testResultSuccess;

  @override
  void dispose() {
    _namaController.dispose();
    _urlController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  void _populateData(TenantConfig config) {
    if (_namaController.text.isEmpty && _urlController.text.isEmpty) {
      _namaController.text = config.namaOrganisasi;
      _urlController.text = config.supabaseUrl;
      _keyController.text = config.supabaseAnonKey;
    }
  }

  Future<void> _testConnection() async {
    final url = _urlController.text.trim();
    final key = _keyController.text.trim();

    if (url.isEmpty || key.isEmpty) {
      setState(() {
        _testResultSuccess = false;
        _testResultText = 'Supabase Project URL dan Anon Key tidak boleh kosong.';
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _testResultText = null;
      _testResultSuccess = null;
    });

    final stopwatch = Stopwatch()..start();
    try {
      final cleanUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
      // Gunakan /auth/v1/settings atau /auth/v1/health yang dapat diakses oleh anon key untuk validasi kredensial
      var endpoint = Uri.parse('$cleanUrl/auth/v1/settings');

      var response = await http.get(
        endpoint,
        headers: {
          'apikey': key,
          'Authorization': 'Bearer $key',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        endpoint = Uri.parse('$cleanUrl/auth/v1/health');
        response = await http.get(
          endpoint,
          headers: {
            'apikey': key,
            'Authorization': 'Bearer $key',
          },
        ).timeout(const Duration(seconds: 10));
      }

      stopwatch.stop();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          _testResultSuccess = true;
          _testResultText = 'Koneksi ke Supabase berhasil! (${stopwatch.elapsedMilliseconds} ms)\nDatabase Cloud siap digunakan.';
        });
      } else {
        setState(() {
          _testResultSuccess = false;
          _testResultText = 'Gagal terhubung (HTTP ${response.statusCode}): Pastikan Anon Key sesuai dengan project Supabase Anda.';
        });
      }
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _testResultSuccess = false;
        _testResultText = 'Koneksi gagal: Tidak dapat menjangkau server Supabase ($e).';
      });
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(tenantConfigProvider.notifier).save(
            namaOrganisasi: _namaController.text,
            supabaseUrl: _urlController.text,
            supabaseAnonKey: _keyController.text,
          );

      // Re-initialize Supabase client immediately
      final initialized = await SupabaseConfig.initialize();

      // Refresh seluruh provider Riverpod terkait database dan autentikasi
      ref.read(supabaseClientRefreshTriggerProvider.notifier).state++;
      ref.invalidate(authRepositoryProvider);
      ref.invalidate(authControllerProvider);
      ref.invalidate(syncEngineProvider);

      if (mounted) {
        if (initialized) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Konfigurasi organisasi berhasil disimpan dan terhubung ke Supabase Cloud.',
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Konfigurasi tersimpan, namun gagal inisialisasi Supabase. Periksa kembali URL dan Anon Key.',
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan konfigurasi: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Konfigurasi?'),
        content: const Text(
          'Aplikasi akan kembali menggunakan akun database bawaan (default).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reset ke Default'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isSaving = true);
      await ref.read(tenantConfigProvider.notifier).reset();
      await SupabaseConfig.initialize();

      ref.read(supabaseClientRefreshTriggerProvider.notifier).state++;
      ref.invalidate(authRepositoryProvider);
      ref.invalidate(authControllerProvider);
      ref.invalidate(syncEngineProvider);

      final fresh = await TenantConfigService.loadConfig();
      _namaController.text = fresh.namaOrganisasi;
      _urlController.text = fresh.supabaseUrl;
      _keyController.text = fresh.supabaseAnonKey;
      setState(() {
        _isSaving = false;
        _testResultText = null;
        _testResultSuccess = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konfigurasi dikembalikan ke default.'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final configState = ref.watch(tenantConfigProvider);

    return Scaffold(
      backgroundColor: AppColors.surface1,
      appBar: AppBar(
        title: const Text(
          'Setup Organisasi & Database',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
        elevation: 0.5,
      ),
      body: configState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (config) {
          _populateData(config);

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: AppColors.surface2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.business_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Konfigurasi Supabase Usaha',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  Text(
                                    config.isCustom
                                        ? 'Status: Akun Khusus Aktif'
                                        : 'Status: Akun Bawaan (Default)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: config.isCustom
                                          ? AppColors.success
                                          : AppColors.inkMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface1,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.surface2),
                          ),
                          child: const Text(
                            'Setiap organisasi/bisnis dapat menggunakan proyek Supabase mandiri. Masukkan URL dan Project Anon Key dari dashboard Supabase Anda.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.inkMuted,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _namaController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Organisasi / Usaha',
                            hintText: 'Contoh: UD Sawit Makmur Jaya',
                            prefixIcon: Icon(Icons.storefront_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Nama organisasi tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _urlController,
                          decoration: const InputDecoration(
                            labelText: 'Supabase Project URL',
                            hintText: 'https://xxxxxxxxxxxx.supabase.co',
                            prefixIcon: Icon(Icons.link_rounded),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Supabase URL wajib diisi';
                            }
                            if (!v.trim().startsWith('http://') &&
                                !v.trim().startsWith('https://')) {
                              return 'URL harus diawali http:// atau https://';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _keyController,
                          obscureText: _obscureKey,
                          maxLines: 1,
                          decoration: InputDecoration(
                            labelText: 'Supabase Anon / Public Key',
                            hintText: 'eyJhbGciOiJIUzI1NiIsIn...',
                            prefixIcon: const Icon(Icons.key_rounded),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureKey
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() => _obscureKey = !_obscureKey);
                              },
                            ),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Anon Key wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 14),

                        // Tombol Uji Koneksi
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.hairline),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onPressed: _isTesting ? null : _testConnection,
                          icon: _isTesting
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.network_check, size: 16),
                          label: Text(_isTesting ? 'Menguji Koneksi Supabase...' : 'Uji Koneksi Supabase'),
                        ),

                        if (_testResultText != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _testResultSuccess == true
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _testResultSuccess == true
                                    ? AppColors.success.withValues(alpha: 0.4)
                                    : AppColors.error.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  _testResultSuccess == true ? Icons.check_circle : Icons.error_outline,
                                  size: 18,
                                  color: _testResultSuccess == true ? AppColors.success : AppColors.error,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _testResultText!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _testResultSuccess == true ? AppColors.success : AppColors.error,
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: _isSaving ? null : _handleSave,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_rounded, color: Colors.white),
                          label: Text(
                            _isSaving ? 'Menyimpan...' : 'Simpan Konfigurasi',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (config.isCustom) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: _isSaving ? null : _handleReset,
                            icon: const Icon(Icons.restart_alt_rounded),
                            label: const Text('Reset ke Konfigurasi Bawaan'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
