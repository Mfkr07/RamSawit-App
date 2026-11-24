import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/supabase_client.dart';
import '../../core/theme/app_theme.dart';
import '../tenant/setup_organisasi_page.dart';
import 'auth_controller.dart';
import 'auth_repository.dart';

/// Halaman Login aplikasi transaksi TBS kelapa sawit.
/// Mengadopsi IBM Carbon enterprise layout & styling (doc/DESIGN.md).
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@sawit.com');
  final _passwordController = TextEditingController(text: 'password123');
  final _namaController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSignUpMode = false;
  String _selectedRole = 'admin';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).signIn(
          _emailController.text,
          _passwordController.text,
        );

    if (success && mounted) {
      final isDemo = ref.read(authRepositoryProvider).isDemoMode;
      if (isDemo) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Masuk dalam Mode Demo: Data disimpan secara lokal di perangkat dan tidak terhubung ke server cloud.',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFFD97706),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil masuk ke sistem transaksi.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).signUp(
          email: _emailController.text,
          password: _passwordController.text,
          nama: _namaController.text,
          role: _selectedRole,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Akun baru berhasil didaftarkan dan terhubung ke Supabase Cloud.',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final tenantConfigAsync = ref.watch(tenantConfigProvider);
    final tenantConfig = tenantConfigAsync.asData?.value;
    final isCloudConfigured = SupabaseConfig.isConfigured;

    return Scaffold(
      backgroundColor: AppColors.surface1,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.canvas,
                border: Border.all(color: AppColors.hairline, width: 1.0),
              ),
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Brand
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 32,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TRANSAKSI TBS SAWIT',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                'Sistem Pembelian Kelapa Sawit',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Setup Organisasi & Database',
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: AppColors.inkMuted,
                            size: 22,
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SetupOrganisasiPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Banner Status Koneksi Cloud vs Mode Demo
                    if (isCloudConfigured)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFDEFBE6),
                          border: Border(
                            left: BorderSide(
                              color: Color(0xFF24A148),
                              width: 3.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cloud_done,
                              color: Color(0xFF24A148),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Terhubung ke Supabase Cloud',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF198038),
                                    ),
                                  ),
                                  Text(
                                    tenantConfig?.namaOrganisasi.isNotEmpty ==
                                            true
                                        ? tenantConfig!.namaOrganisasi
                                        : 'Cloud Database Aktif',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.ink,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(44, 24),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SetupOrganisasiPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Ubah',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEF3D6),
                          border: Border(
                            left: BorderSide(
                              color: Color(0xFFD97706),
                              width: 3.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cloud_off,
                              color: Color(0xFFD97706),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mode Demo / Offline Aktif',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFB45309),
                                    ),
                                  ),
                                  Text(
                                    'Belum terhubung ke Supabase Cloud.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(44, 24),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SetupOrganisasiPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Setup',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Judul Form
                    Text(
                      _isSignUpMode
                          ? 'Daftar Akun Baru (Cloud)'
                          : 'Masuk ke Sistem',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isSignUpMode
                          ? 'Buat akun login baru untuk database Supabase Anda.'
                          : 'Gunakan akun terdaftar Anda untuk melanjutkan.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Banner Error jika ada
                    if (authState.errorMessage != null) ...[
                      Container(
                        key: const Key('login_error_banner'),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          border: const Border(
                            left: BorderSide(
                              color: AppColors.error,
                              width: 3.5,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authState.errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Input Khusus Mode Pendaftaran: Nama Lengkap & Role
                    if (_isSignUpMode) ...[
                      const Text(
                        'Nama Lengkap',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _namaController,
                        decoration: const InputDecoration(
                          hintText: 'Contoh: Budi Santoso',
                          prefixIcon: Icon(Icons.person_outline, size: 20),
                        ),
                        validator: (value) {
                          if (_isSignUpMode &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Nama lengkap wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Hak Akses (Role)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedRole,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.badge_outlined, size: 20),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin (Pemilik RAM / Akses Penuh)'),
                          ),
                          DropdownMenuItem(
                            value: 'kasir',
                            child: Text('Kasir (Operator Timbangan)'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedRole = val);
                          }
                        },
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Input Email
                    const Text(
                      'Alamat Email',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      key: const Key('login_email_input'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'nama@sawit.com',
                        prefixIcon: Icon(Icons.email_outlined, size: 20),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email wajib diisi';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Input Kata Sandi
                    const Text(
                      'Kata Sandi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      key: const Key('login_password_input'),
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Masukkan kata sandi',
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kata sandi wajib diisi';
                        }
                        if (value.length < 6) {
                          return 'Kata sandi minimal 6 karakter';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) =>
                          _isSignUpMode ? _handleSignUp() : _handleLogin(),
                    ),
                    const SizedBox(height: 28),

                    // Tombol Submit (Masuk / Daftar)
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        key: const Key('login_submit_button'),
                        onPressed: authState.isLoading
                            ? null
                            : (_isSignUpMode ? _handleSignUp : _handleLogin),
                        child: authState.isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _isSignUpMode
                                        ? 'Mendaftarkan Akun...'
                                        : 'Memproses Masuk...',
                                  ),
                                ],
                              )
                            : Text(
                                _isSignUpMode
                                    ? 'Daftar Akun Baru'
                                    : 'Masuk ke Sistem',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Toggle Antara Masuk dan Daftar
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _isSignUpMode = !_isSignUpMode;
                          });
                        },
                        child: Text(
                          _isSignUpMode
                              ? 'Sudah punya akun? Masuk ke Sistem'
                              : (isCloudConfigured
                                  ? 'Belum punya akun di Supabase ini? Daftar Akun Baru'
                                  : 'Daftar Akun Baru (Mode Cloud)'),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info Bantuan & Demo Akun
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface1,
                        border: Border.all(color: AppColors.hairline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCloudConfigured
                                ? 'Informasi Akses Cepat (Demo Offline):'
                                : 'Informasi Akses Cepat:',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.inkMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Admin: admin@sawit.com',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.ink,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  _emailController.text = 'admin@sawit.com';
                                  _passwordController.text = 'password123';
                                },
                                child: const Text(
                                  'Gunakan',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Kasir: kasir@sawit.com',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.ink,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  _emailController.text = 'kasir@sawit.com';
                                  _passwordController.text = 'password123';
                                },
                                child: const Text(
                                  'Gunakan',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (isCloudConfigured) ...[
                            const SizedBox(height: 6),
                            const Text(
                              'Catatan: Kredensial di atas untuk demo offline. Untuk database cloud, gunakan akun yang didaftarkan di Supabase Auth.',
                              style: TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tombol Konfigurasi Database Organisasi (Multi-Tenant)
                    Center(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.inkMuted,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SetupOrganisasiPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings_outlined, size: 16),
                        label: const Text(
                          'Setup Organisasi & Database',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
