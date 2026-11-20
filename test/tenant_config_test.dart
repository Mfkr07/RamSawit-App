import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transaksi_sawit_app/core/tenant_config_service.dart';
import 'package:transaksi_sawit_app/features/tenant/setup_organisasi_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });

  group('Tugas Bagian 26: Multi-Tenant Config UI & Dynamic Client Tests', () {
    test('TenantConfig model validation & default values', () {
      const config = TenantConfig(
        namaOrganisasi: 'Sawit Berkah',
        supabaseUrl: 'https://test.supabase.co',
        supabaseAnonKey: 'anon-key-123',
      );

      expect(config.isValid, isTrue);
      expect(config.isCustom, isFalse);

      const invalidConfig = TenantConfig(
        namaOrganisasi: 'Sawit Berkah',
        supabaseUrl: '',
        supabaseAnonKey: '',
      );
      expect(invalidConfig.isValid, isFalse);
    });

    test('TenantConfigService saves and reads custom config', () async {
      final initial = await TenantConfigService.loadConfig();
      expect(initial.isCustom, isFalse);

      await TenantConfigService.saveConfig(
        namaOrganisasi: 'PT Sawit Makmur',
        supabaseUrl: 'https://makmur.supabase.co',
        supabaseAnonKey: 'anon-makmur-secret',
      );

      final saved = await TenantConfigService.loadConfig();
      expect(saved.isCustom, isTrue);
      expect(saved.namaOrganisasi, 'PT Sawit Makmur');
      expect(saved.supabaseUrl, 'https://makmur.supabase.co');
      expect(saved.supabaseAnonKey, 'anon-makmur-secret');

      await TenantConfigService.resetToDefault();
      final resetConfig = await TenantConfigService.loadConfig();
      expect(resetConfig.isCustom, isFalse);
    });

    testWidgets('SetupOrganisasiPage renders form fields and save button', (tester) async {
      const config = TenantConfig(
        namaOrganisasi: 'RAM Sawit Utama (Default)',
        supabaseUrl: '',
        supabaseAnonKey: '',
        isCustom: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tenantConfigProvider.overrideWith((ref) {
              final notifier = TenantConfigNotifier();
              notifier.state = const AsyncValue.data(config);
              return notifier;
            }),
          ],
          child: const MaterialApp(
            home: SetupOrganisasiPage(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Setup Organisasi & Database'), findsOneWidget);
      expect(find.text('Konfigurasi Supabase Usaha'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('Simpan Konfigurasi'), findsOneWidget);
    });
  });
}
