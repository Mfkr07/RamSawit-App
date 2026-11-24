import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/profile.dart';
import 'auth_repository.dart';

/// State status autentikasi aplikasi
class AppAuthState {
  final Profile? profile;
  final bool isLoading;
  final String? errorMessage;
  final bool isInitialized;

  const AppAuthState({
    this.profile,
    this.isLoading = false,
    this.errorMessage,
    this.isInitialized = false,
  });

  bool get isAuthenticated => profile != null;

  AppAuthState copyWith({
    Profile? profile,
    bool? isLoading,
    String? errorMessage,
    bool? isInitialized,
    bool clearProfile = false,
    bool clearError = false,
  }) {
    return AppAuthState(
      profile: clearProfile ? null : (profile ?? this.profile),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// Controller Riverpod untuk autentikasi dan status sesi
class AuthController extends StateNotifier<AppAuthState> {
  final AuthRepository _repository;
  final Duration maxSessionDuration;
  final Duration checkInterval;
  final bool enablePeriodicCheck;

  StreamSubscription? _authSubscription;
  Timer? _sessionAgeTimer;

  AuthController(
    this._repository, {
    this.maxSessionDuration = AuthRepository.defaultMaxSessionDuration,
    this.checkInterval = const Duration(minutes: 1),
    bool? enablePeriodicCheck,
  })  : enablePeriodicCheck = enablePeriodicCheck ??
            !WidgetsBinding.instance.runtimeType.toString().contains('Test'),
        super(const AppAuthState()) {
    _init();
  }

  Future<void> _init() async {
    // Ambil pesan kedaluwarsa sesi jika ada dari penyimpanan lokal
    final savedExpiredMessage = await _repository.getExpiredMessage();
    if (!mounted) return;

    // Periksa sesi yang tersimpan
    if (_repository.hasActiveSession) {
      // Pengecekan Titik A: Saat aplikasi dibuka / di-refresh (FR-1.2 & FR-1.4)
      final isExpired = await _repository.isSessionExpired(
        maxDuration: maxSessionDuration,
      );
      if (!mounted) return;

      if (isExpired) {
        await _repository.forceSignOutExpired(
          reason: 'Sesi Anda telah berakhir (melebihi 24 jam). Silakan masuk kembali.',
        );
        if (!mounted) return;
        state = state.copyWith(
          clearProfile: true,
          isInitialized: true,
          errorMessage: 'Sesi Anda telah berakhir (melebihi 24 jam). Silakan masuk kembali.',
        );
        return;
      }

      // Sesi masih valid dalam 24 jam
      final user = _repository.currentAuthUser;
      if (user != null) {
        try {
          final profile = await _repository.getProfile(user.id);
          if (!mounted) return;
          state = state.copyWith(
            profile: profile,
            isInitialized: true,
            clearError: true,
          );
          _startSessionAgeTimer();
        } catch (_) {
          if (!mounted) return;
          state = state.copyWith(isInitialized: true);
        }
      } else if (_repository.isDemoMode) {
        final profile = await _repository.getProfile('demo-user-id-12345');
        if (!mounted) return;
        state = state.copyWith(
          profile: profile,
          isInitialized: true,
          clearError: true,
        );
        _startSessionAgeTimer();
      }
    } else {
      if (!mounted) return;
      state = state.copyWith(
        isInitialized: true,
        errorMessage: savedExpiredMessage,
      );
      if (savedExpiredMessage != null) {
        await _repository.clearExpiredMessage();
      }
    }

    // Dengarkan perubahan sesi
    _authSubscription = _repository.authStateChanges.listen((event) async {
      if (!mounted) return;
      final user = _repository.currentAuthUser;
      if (user != null) {
        final profile = await _repository.getProfile(user.id);
        if (!mounted) return;
        state = state.copyWith(profile: profile);
        _startSessionAgeTimer();
      } else if (!_repository.isDemoMode) {
        _stopSessionAgeTimer();
        if (!mounted) return;
        state = state.copyWith(clearProfile: true);
      }
    });
  }

  /// Memulai timer periodik untuk memantau usia sesi (Titik B FR-1.4)
  void _startSessionAgeTimer() {
    _stopSessionAgeTimer();
    if (!enablePeriodicCheck) return;
    _sessionAgeTimer = Timer.periodic(checkInterval, (_) {
      checkSessionAge();
    });
  }

  /// Menghentikan timer usia sesi
  void _stopSessionAgeTimer() {
    _sessionAgeTimer?.cancel();
    _sessionAgeTimer = null;
  }

  /// Memeriksa usia sesi aktif saat ini
  Future<void> checkSessionAge() async {
    if (!mounted || !state.isAuthenticated) {
      _stopSessionAgeTimer();
      return;
    }

    final isExpired = await _repository.isSessionExpired(
      maxDuration: maxSessionDuration,
    );
    if (!mounted) return;

    if (isExpired) {
      await forceSignOutDueToExpiration();
    }
  }

  /// Melakukan logout paksa seketika karena sesi kedaluwarsa (FR-1.2 & FR-1.4)
  Future<void> forceSignOutDueToExpiration([
    String reason = 'Sesi Anda telah berakhir (melebihi 24 jam). Silakan masuk kembali.',
  ]) async {
    _stopSessionAgeTimer();
    await _repository.forceSignOutExpired(reason: reason);
    if (!mounted) return;
    state = state.copyWith(
      clearProfile: true,
      isLoading: false,
      errorMessage: reason,
    );
  }

  /// Bersihkan pesan error yang sedang tampil
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }

  /// Masuk dengan email & password
  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profile = await _repository.signIn(
        email: email,
        password: password,
      );
      state = state.copyWith(
        profile: profile,
        isLoading: false,
        clearError: true,
      );
      _startSessionAgeTimer();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', ''),
      );
      return false;
    }
  }

  /// Mendaftarkan akun baru di Supabase Auth
  Future<bool> signUp({
    required String email,
    required String password,
    required String nama,
    String role = 'admin',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profile = await _repository.signUp(
        email: email,
        password: password,
        nama: nama,
        role: role,
      );
      state = state.copyWith(
        profile: profile,
        isLoading: false,
        clearError: true,
      );
      _startSessionAgeTimer();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', ''),
      );
      return false;
    }
  }

  /// Keluar dari sesi aplikasi secara manual oleh pengguna
  Future<void> signOut() async {
    _stopSessionAgeTimer();
    state = state.copyWith(isLoading: true);
    try {
      await _repository.signOut();
      state = state.copyWith(
        clearProfile: true,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal keluar sesi: ${e.toString()}',
      );
    }
  }

  @override
  void dispose() {
    _stopSessionAgeTimer();
    _authSubscription?.cancel();
    super.dispose();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AppAuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});
