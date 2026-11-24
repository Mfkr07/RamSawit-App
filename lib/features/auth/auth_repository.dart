import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/session_storage_service.dart';
import '../../core/supabase_client.dart';
import '../../models/profile.dart';

/// Repository untuk mengelola autentikasi pengguna dan profil.
/// Mendukung Supabase Auth dengan fallback Demo Service jika belum dikonfigurasi.
class AuthRepository {
  final SupabaseClient? _client;
  final SessionStorageService _sessionService;

  /// Batas durasi maksimal sesi login sebelum dipaksa logout (FR-1.2: 24 Jam)
  static const Duration defaultMaxSessionDuration = Duration(hours: 24);

  // Demo in-memory session untuk pengujian lokal jika kredensial belum di-set
  static Profile? _demoProfile;
  static final _demoAuthStreamController =
      StreamController<AuthState>.broadcast();

  AuthRepository(this._client, [SessionStorageService? sessionService])
      : _sessionService = sessionService ?? SessionStorageService();

  bool get isDemoMode => !SupabaseConfig.isConfigured || _client == null;

  /// Mendapatkan user yang sedang aktif
  User? get currentAuthUser => _client?.auth.currentUser;

  /// Stream perubahan sesi autentikasi
  Stream<AuthState> get authStateChanges {
    if (isDemoMode) {
      return _demoAuthStreamController.stream;
    }
    return _client!.auth.onAuthStateChange;
  }

  /// Memeriksa apakah ada sesi yang tersimpan
  bool get hasActiveSession {
    if (isDemoMode) {
      return _demoProfile != null;
    }
    return _client?.auth.currentSession != null;
  }

  /// Login dengan email & password
  Future<Profile> signIn({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (isDemoMode) {
      // Demo authentication untuk pengetesan tanpa remote DB
      await Future.delayed(const Duration(milliseconds: 600));
      if (password.length < 6) {
        throw const AuthException('Kata sandi minimal 6 karakter');
      }

      final role = cleanEmail.contains('admin') ? 'admin' : 'kasir';
      final name = cleanEmail.contains('admin')
          ? 'Administrator Sawit'
          : 'Operator Kasir';

      final profile = Profile(
        id: 'demo-user-id-12345',
        nama: name,
        role: role,
        createdAt: DateTime.now(),
      );

      _demoProfile = profile;
      await _sessionService.saveLoginTimestamp(DateTime.now());
      _demoAuthStreamController.add(
        AuthState(AuthChangeEvent.signedIn, null),
      );
      return profile;
    }

    try {
      final response = await _client!.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Pengguna tidak ditemukan.');
      }

      await _sessionService.saveLoginTimestamp(DateTime.now());
      return await getProfile(user.id);
    } on AuthException catch (e) {
      throw _translateAuthError(e);
    } catch (e) {
      throw AuthException(
        'Gagal masuk ke sistem: ${e.toString()}',
      );
    }
  }

  /// Mendaftarkan akun baru di Supabase Auth (hanya berlaku pada mode Cloud)
  Future<Profile> signUp({
    required String email,
    required String password,
    required String nama,
    String role = 'admin',
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (isDemoMode) {
      throw const AuthException('Pendaftaran akun hanya dapat dilakukan saat terhubung ke database Supabase Cloud.');
    }

    try {
      final response = await _client!.auth.signUp(
        email: cleanEmail,
        password: password,
        data: {
          'nama': nama.trim(),
          'role': role,
        },
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Gagal membuat akun di Supabase.');
      }

      // Pastikan row profiles terisi jika trigger database belum ada
      try {
        await _client.from('profiles').upsert({
          'id': user.id,
          'nama': nama.trim(),
          'role': role,
        });
      } catch (_) {}

      await _sessionService.saveLoginTimestamp(DateTime.now());
      return await getProfile(user.id);
    } on AuthException catch (e) {
      throw _translateAuthError(e);
    } catch (e) {
      throw AuthException('Gagal mendaftar: ${e.toString()}');
    }
  }

  /// Mendapatkan profil user dari tabel `public.profiles`
  Future<Profile> getProfile(String userId) async {
    if (isDemoMode) {
      return _demoProfile ??
          Profile(
            id: userId,
            nama: 'Administrator Sawit',
            role: 'admin',
            createdAt: DateTime.now(),
          );
    }

    try {
      final data = await _client!
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      final user = _client.auth.currentUser;
      final email = user?.email?.toLowerCase() ?? '';
      final isAdminEmail = email.contains('admin');

      if (data == null) {
        // Fallback jika row profile belum dibuat oleh trigger
        return Profile(
          id: userId,
          nama: user?.email?.split('@').first ?? (isAdminEmail ? 'Administrator Sawit' : 'Petugas Sawit'),
          role: isAdminEmail ? 'admin' : 'kasir',
          createdAt: DateTime.now(),
        );
      }

      final profile = Profile.fromJson(data);
      if (isAdminEmail && profile.role != 'admin') {
        // Otomatis sinkronisasi role admin untuk akun admin
        try {
          await _client.from('profiles').update({'role': 'admin'}).eq('id', userId);
        } catch (_) {}
        return profile.copyWith(role: 'admin');
      }

      return profile;
    } catch (e) {
      final user = _client?.auth.currentUser;
      final isAdminEmail = user?.email?.toLowerCase().contains('admin') ?? false;
      return Profile(
        id: userId,
        nama: isAdminEmail ? 'Administrator Sawit' : 'Petugas Sawit',
        role: isAdminEmail ? 'admin' : 'kasir',
        createdAt: DateTime.now(),
      );
    }
  }

  /// Logout manual dari aplikasi oleh pengguna
  Future<void> signOut() async {
    await _sessionService.clearLoginTimestamp();
    await _sessionService.clearExpiredMessage();
    if (isDemoMode) {
      _demoProfile = null;
      _demoAuthStreamController.add(
        AuthState(AuthChangeEvent.signedOut, null),
      );
      return;
    }
    await _client?.auth.signOut();
  }

  /// Logout paksa karena sesi kedaluwarsa (FR-1.2 & FR-1.4)
  Future<void> forceSignOutExpired({
    String reason = 'Sesi Anda telah berakhir (melebihi 24 jam). Silakan masuk kembali.',
  }) async {
    await _sessionService.clearLoginTimestamp();
    await _sessionService.setExpiredMessage(reason);
    if (isDemoMode) {
      _demoProfile = null;
      _demoAuthStreamController.add(
        AuthState(AuthChangeEvent.signedOut, null),
      );
      return;
    }
    try {
      await _client?.auth.signOut();
    } catch (_) {}
  }

  /// Memeriksa apakah sesi saat ini telah melampaui batas waktu maksimal (FR-1.2)
  Future<bool> isSessionExpired({
    Duration maxDuration = defaultMaxSessionDuration,
  }) async {
    if (!hasActiveSession) return false;
    final timestampMs = await _sessionService.getLoginTimestamp();
    if (timestampMs == null) {
      // Ada sesi aktif di Auth tapi tidak memiliki timestamp login lokal yang sah
      // Demi keamanan ketat (FR-1.2), anggap sesi kedaluwarsa untuk mewajibkan login ulang
      return true;
    }
    final loginTime = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final age = DateTime.now().difference(loginTime);
    return age >= maxDuration;
  }

  /// Mengambil timestamp login yang tersimpan
  Future<int?> getLoginTimestamp() => _sessionService.getLoginTimestamp();

  /// Menghapus timestamp login secara manual
  Future<void> clearLoginTimestamp() => _sessionService.clearLoginTimestamp();

  /// Mengambil pesan kedaluwarsa sesi yang belum ditampilkan
  Future<String?> getExpiredMessage() => _sessionService.getExpiredMessage();

  /// Menghapus pesan kedaluwarsa sesi
  Future<void> clearExpiredMessage() => _sessionService.clearExpiredMessage();

  /// Menyimpan timestamp waktu login tertentu (untuk kebutuhan testing/simulasi)
  Future<void> saveLoginTimestamp(DateTime time) =>
      _sessionService.saveLoginTimestamp(time);

  /// Terjemahan pesan error Supabase Auth ke Bahasa Indonesia baku
  AuthException _translateAuthError(AuthException exception) {
    final message = exception.message.toLowerCase();
    if (message.contains('invalid login credentials') ||
        message.contains('invalid_grant')) {
      return const AuthException('Email atau kata sandi tidak sesuai.');
    }
    if (message.contains('email not confirmed')) {
      return const AuthException(
          'Email belum dikonfirmasi. Periksa kotak masuk email Anda.');
    }
    if (message.contains('network') || message.contains('fetch failed')) {
      return const AuthException(
          'Koneksi internet bermasalah. Silakan periksa jaringan Anda.');
    }
    return AuthException(exception.message);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final sessionService = ref.watch(sessionStorageServiceProvider);
  return AuthRepository(client, sessionService);
});
