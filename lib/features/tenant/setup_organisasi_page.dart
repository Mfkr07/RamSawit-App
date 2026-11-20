import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/supabase_client.dart';
import '../../core/tenant_config_service.dart';
import '../../core/theme/app_theme.dart';

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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(tenantConfigProvider.notifier).save(
            namaOrganisasi: _namaController.text,
            supabaseUrl: _urlController.text,
            supabaseAnonKey: _keyController.text,
          );

      // Re-initialize Supabase client immediately so user does not need to restart app
      await SupabaseConfig.initialize();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Konfigurasi organisasi berhasil disimpan dan dihubungkan.',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
      final fresh = await TenantConfigService.loadConfig();
      _namaController.text = fresh.namaOrganisasi;
      _urlController.text = fresh.supabaseUrl;
      _keyController.text = fresh.supabaseAnonKey;
      setState(() => _isSaving = false);

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
                        const SizedBox(height: 24),
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
