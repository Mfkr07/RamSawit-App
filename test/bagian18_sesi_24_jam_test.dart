import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transaksi_sawit_app/core/services/session_storage_service.dart';
import 'package:transaksi_sawit_app/features/auth/auth_controller.dart';
import 'package:transaksi_sawit_app/features/auth/auth_repository.dart';
import 'package:transaksi_sawit_app/features/auth/login_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Tugas Bagian 18: SessionStorageService & Timestamp Storage', () {
    test('1. Menyimpan, mengambil, dan menghapus timestamp login', () async {
      // ignore: avoid_print
      print('DEBUG BINDING: ${WidgetsBinding.instance.runtimeType.toString()}');
      SharedPreferences.setMockInitialValues({});
      final service = SessionStorageService();

      expect(await service.getLoginTimestamp(), isNull);

      final testTime = DateTime(2026, 9, 16, 10, 0, 0);
      await service.saveLoginTimestamp(testTime);

      final savedMs = await service.getLoginTimestamp();
      expect(savedMs, testTime.millisecondsSinceEpoch);

      await service.clearLoginTimestamp();
      expect(await service.getLoginTimestamp(), isNull);
    });

    test('2. Mengelola pesan kedaluwarsa sesi', () async {
      SharedPreferences.setMockInitialValues({});
      final service = SessionStorageService();

      expect(await service.getExpiredMessage(), isNull);

      const message = 'Sesi Anda telah berakhir (melebihi 24 jam). Silakan masuk kembali.';
      await service.setExpiredMessage(message);

      expect(await service.getExpiredMessage(), message);

      await service.clearExpiredMessage();
      expect(await service.getExpiredMessage(), isNull);
    });
  });

  group('Tugas Bagian 18: Pengecekan Usia Sesi di AuthRepository (FR-1.2)', () {
    test('3. isSessionExpired mengembalikan false jika tidak ada sesi aktif', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = AuthRepository(null);

      expect(await repo.isSessionExpired(), isFalse);
    });

    test('4. isSessionExpired mengembalikan true jika sesi aktif tapi timestamp tidak ada', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = AuthRepository(null);

      // Login untuk membuat sesi demo aktif
      await repo.signIn(email: 'admin@sawit.com', password: 'password123');
      expect(repo.hasActiveSession, isTrue);

      // Hapus timestamp lokal untuk simulasi sesi tanpa timestamp
      await repo.clearLoginTimestamp();

      expect(await repo.isSessionExpired(), isTrue);
    });

    test('5. isSessionExpired membedakan sesi < 24 jam (valid) dan >= 24 jam (kedaluwarsa)', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = AuthRepository(null);

      await repo.signIn(email: 'admin@sawit.com', password: 'password123');

      final now = DateTime.now();

      // Kasus A: Login 5 jam lalu (masih valid)
      await repo.saveLoginTimestamp(now.subtract(const Duration(hours: 5)));
      expect(await repo.isSessionExpired(), isFalse);

      // Kasus B: Login 23 jam 50 menit lalu (masih valid)
      await repo.saveLoginTimestamp(now.subtract(const Duration(hours: 23, minutes: 50)));
      expect(await repo.isSessionExpired(), isFalse);

      // Kasus C: Login 24 jam 1 menit lalu (kedaluwarsa)
      await repo.saveLoginTimestamp(now.subtract(const Duration(hours: 24, minutes: 1)));
      expect(await repo.isSessionExpired(), isTrue);

      // Kasus D: Login 48 jam lalu (kedaluwarsa)
      await repo.saveLoginTimestamp(now.subtract(const Duration(hours: 48)));
      expect(await repo.isSessionExpired(), isTrue);
    });

    test('6. forceSignOutExpired membersihkan sesi dan menyimpan pesan', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = AuthRepository(null);

      await repo.signIn(email: 'admin@sawit.com', password: 'password123');
      expect(repo.hasActiveSession, isTrue);
      expect(await repo.getLoginTimestamp(), isNotNull);

      await repo.forceSignOutExpired(reason: 'Sesi berakhir');
      expect(repo.hasActiveSession, isFalse);
      expect(await repo.getLoginTimestamp(), isNull);
      expect(await repo.getExpiredMessage(), 'Sesi berakhir');
    });
  });

  group('Tugas Bagian 18: Pengecekan Titik A & B pada AuthController (FR-1.4)', () {
    test('7. Titik A: Inisialisasi dengan sesi > 24 jam memicu forced logout otomatis', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = AuthRepository(null);

      // Buat sesi aktif demo
      await repo.signIn(email: 'admin@sawit.com', password: 'password123');
      // Set timestamp login 25 jam yang lalu
      await repo.saveLoginTimestamp(DateTime.now().subtract(const Duration(hours: 25)));

      // Buat controller baru (simulasi app startup / refresh halaman)
      final controller = AuthController(repo);

      // Beri sedikit waktu untuk eksekusi _init() asynchronous
      await Future.delayed(const Duration(milliseconds: 50));

      expect(controller.state.isAuthenticated, isFalse);
      expect(controller.state.profile, isNull);
      expect(controller.state.errorMessage, contains('Sesi Anda telah berakhir'));
      expect(repo.hasActiveSession, isFalse);

      controller.dispose();
    });

    test('8. Titik A: Inisialisasi dengan sesi valid (< 24 jam) memuat profil normal', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = AuthRepository(null);

      await repo.signIn(email: 'admin@sawit.com', password: 'password123');
      // Set timestamp login 2 jam yang lalu
      await repo.saveLoginTimestamp(DateTime.now().subtract(const Duration(hours: 2)));

      final controller = AuthController(repo);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(controller.state.isAuthenticated, isTrue);
      expect(controller.state.profile?.nama, contains('Admin'));
      expect(controller.state.errorMessage, isNull);

      controller.dispose();
    });

    test('9. Titik B: Timer periodik mendeteksi sesi kedaluwarsa saat aplikasi terbuka', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = AuthRepository(null);

      // Gunakan simulasi durasi pendek untuk testing timer
      const testMaxDuration = Duration(milliseconds: 200);
      const testCheckInterval = Duration(milliseconds: 50);

      final controller = AuthController(
        repo,
        maxSessionDuration: testMaxDuration,
        checkInterval: testCheckInterval,
        enablePeriodicCheck: true,
      );

      // Login berhasil
      final success = await controller.signIn('kasir@sawit.com', 'password123');
      expect(success, isTrue);
      expect(controller.state.isAuthenticated, isTrue);

      // Tunggu hingga timer melewati testMaxDuration
      await Future.delayed(const Duration(milliseconds: 300));

      // Sesi harus otomatis dipaksa keluar oleh timer tanpa refresh manual
      expect(controller.state.isAuthenticated, isFalse);
      expect(controller.state.profile, isNull);
      expect(controller.state.errorMessage, contains('Sesi Anda telah berakhir'));

      controller.dispose();
    });
  });

  group('Tugas Bagian 18: UI Banner Pesan Kedaluwarsa di LoginPage', () {
    testWidgets('10. Pesan kedaluwarsa sesi ditampilkan dalam banner alert di LoginPage', (WidgetTester tester) async {
      final repo = AuthRepository(null);
      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith((ref) => AuthController(repo)),
        ],
      );
      addTearDown(container.dispose);

      // Set pesan kedaluwarsa pada controller
      container.read(authControllerProvider.notifier).forceSignOutDueToExpiration(
        'Sesi Anda telah berakhir (melebihi 24 jam). Silakan masuk kembali.',
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: LoginPage(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi banner pesan kesalahan tampil
      expect(find.byKey(const Key('login_error_banner')), findsOneWidget);
      expect(
        find.text('Sesi Anda telah berakhir (melebihi 24 jam). Silakan masuk kembali.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
