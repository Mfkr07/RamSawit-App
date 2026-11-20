import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:transaksi_sawit_app/core/utils/app_exception_helper.dart';
import 'package:transaksi_sawit_app/core/utils/currency_formatter.dart';
import 'package:transaksi_sawit_app/core/utils/percentage_formatter.dart';
import 'package:transaksi_sawit_app/core/utils/weight_formatter.dart';
import 'package:transaksi_sawit_app/main.dart';
import 'package:transaksi_sawit_app/models/jenis_buah.dart';
import 'package:transaksi_sawit_app/models/penjual.dart';
import 'package:transaksi_sawit_app/models/profile.dart';
import 'package:transaksi_sawit_app/models/transaksi.dart';
import 'package:transaksi_sawit_app/features/dashboard/dashboard_repository.dart';
import 'package:transaksi_sawit_app/features/transaksi/transaksi_filter_state.dart';
import 'package:transaksi_sawit_app/features/transaksi/transaksi_form_state.dart';
import 'package:transaksi_sawit_app/features/transaksi/transaksi_repository.dart';
import 'package:transaksi_sawit_app/models/dashboard_analytics.dart';
import 'package:transaksi_sawit_app/models/transaksi_item.dart';

import 'package:transaksi_sawit_app/features/auth/auth_repository.dart';
import 'package:transaksi_sawit_app/features/transaksi/transaksi_form_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transaksi_sawit_app/features/transaksi/export/laporan_excel_generator.dart';
import 'package:transaksi_sawit_app/features/transaksi/export/laporan_pdf_generator.dart';
import 'package:transaksi_sawit_app/models/laporan_export_item.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
    TransaksiRepository.seedDemoDataForTesting();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(AuthRepository(null)),
        ],
        child: const TransaksiSawitApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Masuk ke Sistem'), findsNWidgets(2));
    expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
    expect(find.text('Alamat Email'), findsOneWidget);
  });

  testWidgets('TransaksiFormPage opens date picker without throwing exception', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('id', 'ID'),
          supportedLocales: [
            Locale('id', 'ID'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(body: TransaksiFormPage()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find and tap the date field by key
    final datePickerField = find.byKey(const Key('transaksi_date_picker_field'));
    expect(datePickerField, findsOneWidget);
    await tester.tap(datePickerField);
    await tester.pumpAndSettle();

    // Verify DatePickerDialog is rendered successfully without any exception
    expect(find.byType(DatePickerDialog), findsOneWidget);
    expect(find.byType(TextButton), findsWidgets);
  });

  group('Formatter Tests', () {
    test('CurrencyFormatter formats and parses IDR properly', () {
      final formatted = CurrencyFormatter.format(2450000);
      expect(formatted.contains('2.450.000'), isTrue);

      final parsed = CurrencyFormatter.parse('Rp 2.450.000');
      expect(parsed, equals(Decimal.parse('2450000')));
    });

    test('CurrencyFormatter formats extreme large values without double overflow', () {
      final largeVal = Decimal.parse('15000000000'); // 15 Miliar
      final formatted = CurrencyFormatter.format(largeVal);
      expect(formatted, equals('Rp 15.000.000.000'));

      final parsed = CurrencyFormatter.parse('Rp 15.000.000.000');
      expect(parsed, equals(largeVal));
    });

    test('WeightFormatter formats and parses weight properly', () {
      final weight = Decimal.parse('1250.50');
      final formatted = WeightFormatter.format(weight);
      expect(formatted.contains('1.250,50 kg'), isTrue);

      final parsed = WeightFormatter.parse('1.250,50 kg');
      expect(parsed, equals(Decimal.parse('1250.50')));
    });

    test('WeightFormatter formats large weight with precision', () {
      final weight = Decimal.parse('15000000.75'); // 15 juta kg
      final formatted = WeightFormatter.format(weight);
      expect(formatted, equals('15.000.000,75 kg'));
    });
  });

  group('Model Serialization Tests', () {
    test('Profile model parses and serializes correctly', () {
      final now = DateTime.now().toUtc();
      final json = {
        'id': '11111111-1111-1111-1111-111111111111',
        'nama': 'Pak Mandor',
        'role': 'admin',
        'created_at': now.toIso8601String(),
      };
      final profile = Profile.fromJson(json);
      expect(profile.isAdmin, isTrue);
      expect(profile.nama, 'Pak Mandor');
    });

    test('Penjual model parses and serializes correctly', () {
      final now = DateTime.now().toUtc();
      final json = {
        'id': '22222222-2222-2222-2222-222222222222',
        'nama': 'Petani Sawit Sejahtera',
        'no_telepon': '081234567890',
        'alamat': 'Desa Sawit Makmur',
        'catatan': 'Kebun blok A',
        'is_active': true,
        'created_by': '11111111-1111-1111-1111-111111111111',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      final penjual = Penjual.fromJson(json);
      expect(penjual.nama, 'Petani Sawit Sejahtera');
      expect(penjual.isActive, isTrue);
    });

    test('JenisBuah model parses correctly', () {
      final json = {
        'id': 1,
        'kode': 'TB',
        'nama': 'Tandan Besar',
        'is_active': true,
      };
      final jb = JenisBuah.fromJson(json);
      expect(jb.kode, 'TB');
      expect(jb.nama, 'Tandan Besar');
    });

    test('Transaksi and TransaksiItem models parse with Decimal correctly', () {
      final now = DateTime.now().toUtc();
      final itemJson = {
        'id': '33333333-3333-3333-3333-333333333333',
        'transaksi_id': '44444444-4444-4444-4444-444444444444',
        'jenis_buah_id': 1,
        'harga_per_kg': '2500.00',
        'berat_kg': '1500.50',
        'subtotal': '3751250.00',
        'created_at': now.toIso8601String(),
      };
      final item = TransaksiItem.fromJson(itemJson);
      expect(item.hargaPerKg, equals(Decimal.parse('2500.00')));
      expect(item.beratKg, equals(Decimal.parse('1500.50')));
      expect(item.subtotal, equals(Decimal.parse('3751250.00')));

      final ringkasanJson = {
        'id': '44444444-4444-4444-4444-444444444444',
        'kode_transaksi': 'TRX-20260904-0001',
        'tanggal_transaksi': '2026-09-04',
        'status': 'selesai',
        'penjual_id': '22222222-2222-2222-2222-222222222222',
        'nama_penjual': 'Petani Sawit Sejahtera',
        'total_berat_kg': '1500.50',
        'total_harga': '3751250.00',
        'created_at': now.toIso8601String(),
      };
      final ringkasan = TransaksiRingkasan.fromJson(ringkasanJson);
      expect(ringkasan.totalHarga, equals(Decimal.parse('3751250.00')));
      expect(ringkasan.totalBeratKg, equals(Decimal.parse('1500.50')));
      expect(ringkasan.isSelesai, isTrue);
    });
  });

  group('Transaksi Multi-Item Form & Calculation Tests', () {
    test('Calculates subtotal and total accurately using Decimal', () {
      final tb = const JenisBuah(id: 1, kode: 'TB', nama: 'Tandan Besar');
      final br = const JenisBuah(id: 3, kode: 'BR', nama: 'Berondolan');

      final row1 = TransaksiItemRowState(
        keyId: 'r1',
        selectedJenisBuah: tb,
        hargaController: TextEditingController(text: '2500'),
        beratController: TextEditingController(text: '1000'),
      );

      final row2 = TransaksiItemRowState(
        keyId: 'r2',
        selectedJenisBuah: br,
        hargaController: TextEditingController(text: '2800'),
        beratController: TextEditingController(text: '500'),
      );

      // Verify row subtotals
      expect(row1.subtotal, equals(Decimal.parse('2500000')));
      expect(row2.subtotal, equals(Decimal.parse('1400000')));

      final form = TransaksiFormState(
        tanggalTransaksi: DateTime.now(),
        itemRows: [row1, row2],
      );

      // Verify aggregated totals
      expect(form.totalBeratKg, equals(Decimal.parse('1500')));
      expect(form.totalHarga, equals(Decimal.parse('3900000')));
      expect(form.hasDuplicateFruit, isFalse);
      expect(form.canAddRow, isTrue); // 2 rows < 3
    });

    test('Prevents duplicate fruit types and detects max 3 rows limit', () {
      final tb = const JenisBuah(id: 1, kode: 'TB', nama: 'Tandan Besar');
      final row1 = TransaksiItemRowState(keyId: 'r1', selectedJenisBuah: tb);
      final row2 = TransaksiItemRowState(keyId: 'r2', selectedJenisBuah: tb); // duplicate!
      final row3 = TransaksiItemRowState(keyId: 'r3');

      final form = TransaksiFormState(
        tanggalTransaksi: DateTime.now(),
        itemRows: [row1, row2, row3],
      );

      expect(form.hasDuplicateFruit, isTrue);
      expect(form.canAddRow, isFalse); // reached 3 rows
    });
  });

  group('Transaksi Bagian 4: Riwayat & Pembatalan Tests', () {
    test('TransaksiFilterState calculates date ranges and active filter counts', () {
      final defaultFilter = TransaksiFilterState();
      expect(defaultFilter.hasActiveFilters, isFalse);
      expect(defaultFilter.activeFilterCount, equals(0));

      // Test preset 'hari_ini' via notifier
      final notifier = TransaksiFilterNotifier();
      notifier.applyDatePreset('hari_ini');
      expect(notifier.state.hasActiveFilters, isTrue);
      expect(notifier.state.startDate, isNotNull);
      expect(notifier.state.endDate, isNotNull);
      expect(notifier.state.startDate!.day, equals(DateTime.now().day));

      // Test status filter
      final statusFilter = defaultFilter.copyWith(status: 'dibatalkan');
      expect(statusFilter.hasActiveFilters, isTrue);
      expect(statusFilter.activeFilterCount, equals(1));
    });

    test('TransaksiRepository queries demo ringkasan and respects status filter', () async {
      final repo = TransaksiRepository();
      final allTrx = await repo.getFilteredRingkasanList();
      expect(allTrx.isNotEmpty, isTrue);
      expect(allTrx.any((t) => t.kodeTransaksi == 'TRX-20260904-0001'), isTrue);

      final cancelledTrx = await repo.getFilteredRingkasanList(status: 'dibatalkan');
      // Initially none are cancelled
      expect(cancelledTrx.isEmpty, isTrue);
    });

    test('TransaksiRepository cancelTransaksi performs soft delete with reason', () async {
      final repo = TransaksiRepository();
      const trxId = 'TRX-20260904-0001';

      // Detail before cancel
      final detailBefore = await repo.getTransaksiDetail(trxId);
      expect(detailBefore.status, equals('selesai'));
      expect(detailBefore.alasanPembatalan, isNull);

      // Perform cancellation
      await repo.cancelTransaksi(trxId, 'Salah timbangan kotor');

      // Detail after cancel: status must be dibatalkan and reason preserved
      final detailAfter = await repo.getTransaksiDetail(trxId);
      expect(detailAfter.status, equals('dibatalkan'));
      expect(detailAfter.alasanPembatalan, equals('Salah timbangan kotor'));

      // Ensure it still exists in the ringkasan list (soft delete, not deleted)
      final allAfter = await repo.getFilteredRingkasanList();
      final target = allAfter.firstWhere((t) => t.kodeTransaksi == trxId);
      expect(target.status, equals('dibatalkan'));
    });
  });

  group('Dashboard Bagian 5: Analitik & fl_chart Tests', () {
    test('TransaksiHarian and BreakdownJenisBuah models parse JSON correctly', () {
      final harianJson = {
        'tanggal_transaksi': '2026-09-04',
        'jumlah_transaksi': 5,
        'total_berat_kg': '7500.50',
        'total_nilai': '18751250.00',
      };
      final harian = TransaksiHarian.fromJson(harianJson);
      expect(harian.jumlahTransaksi, equals(5));
      expect(harian.totalBeratKg, equals(Decimal.parse('7500.50')));
      expect(harian.totalNilai, equals(Decimal.parse('18751250.00')));

      final breakdownJson = {
        'jenis_buah': 'Tandan Besar',
        'tanggal': '2026-09-01T00:00:00Z',
        'total_berat_kg': '12500.00',
        'total_nilai': '31250000.00',
      };
      final breakdown = BreakdownJenisBuah.fromJson(breakdownJson);
      expect(breakdown.jenisBuah, equals('Tandan Besar'));
      expect(breakdown.totalBeratKg, equals(Decimal.parse('12500.00')));
    });

    test('DashboardRepository fetches 30-day trends, breakdown, and recent transactions', () async {
      final repo = DashboardRepository();

      // 1. Tren 30 hari
      final tren = await repo.getTransaksiHarian30Hari();
      expect(tren.isNotEmpty, isTrue);
      expect(tren.every((t) => t.totalNilai >= Decimal.zero), isTrue);

      // 2. Breakdown jenis buah bulan ini
      final breakdown = await repo.getBreakdownJenisBuahBulanIni();
      expect(breakdown.isNotEmpty, isTrue);
      expect(breakdown.any((b) => b.jenisBuah == 'Tandan Besar'), isTrue);

      // 3. 10 Transaksi terakhir
      final recent = await repo.getRecentTransactions(limit: 10);
      expect(recent.length, lessThanOrEqualTo(10));
      expect(recent.isNotEmpty, isTrue);
    });
  });

  group('AppExceptionHelper Tests (Bagian 6 Error Handling)', () {
    test('Translates AuthException correctly', () {
      const authErr1 = AuthException('Invalid login credentials');
      expect(AppExceptionHelper.toUserFriendlyMessage(authErr1),
          equals('Email atau kata sandi tidak cocok. Silakan periksa kembali.'));

      const authErr2 = AuthException('User already registered');
      expect(AppExceptionHelper.toUserFriendlyMessage(authErr2),
          equals('Alamat email ini sudah terdaftar di sistem.'));
    });

    test('Translates PostgrestException correctly into Indonesian', () {
      const duplicateErr = PostgrestException(
        message: 'duplicate key value violates unique constraint',
        code: '23505',
      );
      expect(AppExceptionHelper.toUserFriendlyMessage(duplicateErr),
          equals('Data yang Anda masukkan sudah terdaftar sebelumnya di sistem.'));

      const notFoundErr = PostgrestException(
        message: 'JSON object requested, multiple (or no) rows returned',
        code: 'PGRST116',
      );
      expect(AppExceptionHelper.toUserFriendlyMessage(notFoundErr),
          equals('Data yang diminta tidak ditemukan di database.'));

      const checkErr = PostgrestException(
        message: 'check constraint violation',
        code: '23514',
      );
      expect(AppExceptionHelper.toUserFriendlyMessage(checkErr),
          equals('Nilai input tidak sesuai aturan validasi (misal berat harus lebih dari 0 kg).'));
    });

    test('Translates network or generic errors', () {
      final netErr = Exception('SocketException: Connection refused (OS Error: Connection refused, errno = 111)');
      expect(AppExceptionHelper.toUserFriendlyMessage(netErr),
          equals('Tidak dapat terhubung ke server database. Periksa koneksi internet Anda.'));
    });
    test('Translates timeoutErr correctly', () {
      final timeoutErr = Exception('TimeoutException after 0:00:30.000000: Task timed out');
      expect(AppExceptionHelper.toUserFriendlyMessage(timeoutErr),
          equals('Waktu koneksi habis. Server memerlukan waktu terlalu lama untuk merespons.'));
    });
  });

  group('Tugas Bagian 10: Potongan Level Berat per Jenis Buah Tests', () {
    test('TransaksiItemRowState calculates berat bersih, nilai potongan, and subtotal with Decimal', () {
      final tb = const JenisBuah(id: 1, kode: 'TB', nama: 'Tandan Besar');

      // 100 kg kotor @ Rp 2.500 dengan potongan 3%
      final row1 = TransaksiItemRowState(
        keyId: 'row-tb',
        selectedJenisBuah: tb,
        hargaController: TextEditingController(text: '2500'),
        beratController: TextEditingController(text: '100'),
        potonganController: TextEditingController(text: '3'),
      );

      // Berat Kotor = 100 kg
      expect(row1.beratKotorKg, equals(Decimal.parse('100')));
      // Potongan = 3%
      expect(row1.persentasePotongan, equals(Decimal.parse('3')));
      // Berat Bersih = 100 * (1 - 0.03) = 97 kg
      expect(row1.beratBersihKg, equals(Decimal.parse('97.00')));
      // Nilai Potongan = 2500 * 100 * 0.03 = Rp 7.500
      expect(row1.nilaiPotonganRp, equals(Decimal.parse('7500.00')));
      // Subtotal = 2500 * 97 = Rp 242.500
      expect(row1.subtotal, equals(Decimal.parse('242500.00')));
      expect(row1.isValid, isTrue);
      expect(row1.isPotonganValid, isTrue);

      // Baris kedua: Berondolan 50 kg kotor @ Rp 2.800 tanpa potongan (0%)
      final br = const JenisBuah(id: 3, kode: 'BR', nama: 'Berondolan');
      final row2 = TransaksiItemRowState(
        keyId: 'row-br',
        selectedJenisBuah: br,
        hargaController: TextEditingController(text: '2800'),
        beratController: TextEditingController(text: '50'),
        potonganController: TextEditingController(text: '0'),
      );

      expect(row2.beratKotorKg, equals(Decimal.parse('50')));
      expect(row2.persentasePotongan, equals(Decimal.zero));
      expect(row2.beratBersihKg, equals(Decimal.parse('50.00')));
      expect(row2.nilaiPotonganRp, equals(Decimal.zero));
      expect(row2.subtotal, equals(Decimal.parse('140000.00')));

      // Form Aggregation
      final formState = TransaksiFormState(
        tanggalTransaksi: DateTime.now(),
        itemRows: [row1, row2],
      );

      // Total Berat Kotor = 100 + 50 = 150 kg
      expect(formState.totalBeratKotorKg, equals(Decimal.parse('150')));
      // Total Berat Bersih = 97 + 50 = 147 kg
      expect(formState.totalBeratBersihKg, equals(Decimal.parse('147.00')));
      // Total Potongan Rp = 7500 + 0 = Rp 7.500
      expect(formState.totalPotonganRp, equals(Decimal.parse('7500.00')));
      // Total Nilai Transaksi = 242.500 + 140.000 = Rp 382.500
      expect(formState.totalNilai, equals(Decimal.parse('382500.00')));

      // Formatter Verifications
      expect(WeightFormatter.format(formState.totalBeratKotorKg), equals('150,00 kg'));
      expect(WeightFormatter.format(formState.totalBeratBersihKg), equals('147,00 kg'));
      expect(CurrencyFormatter.format(formState.totalPotonganRp), equals('Rp 7.500'));
      expect(CurrencyFormatter.format(formState.totalNilai), equals('Rp 382.500'));
    });

    test('TransaksiItemRowState validates potongan percentage range (0 - 100%)', () {
      final rowValid = TransaksiItemRowState(
        keyId: 'valid',
        potonganController: TextEditingController(text: '15.5'),
      );
      expect(rowValid.isPotonganValid, isTrue);

      final rowNegative = TransaksiItemRowState(
        keyId: 'neg',
        potonganController: TextEditingController(text: '-5'),
      );
      expect(rowNegative.isPotonganValid, isFalse);

      final rowOver100 = TransaksiItemRowState(
        keyId: 'over',
        potonganController: TextEditingController(text: '105'),
      );
      expect(rowOver100.isPotonganValid, isFalse);

      final rowBlank = TransaksiItemRowState(
        keyId: 'blank',
        potonganController: TextEditingController(text: ''),
      );
      // Blank defaults to 0% so it is valid
      expect(rowBlank.persentasePotongan, equals(Decimal.zero));
      expect(rowBlank.isPotonganValid, isTrue);
    });

    test('Transaksi and TransaksiItem models serialize and deserialize weight discount columns', () {
      final itemJson = {
        'id': 'item-101',
        'transaksi_id': 'trx-101',
        'jenis_buah_id': 1,
        'harga_per_kg': '2500.00',
        'berat_kotor_kg': '100.00',
        'persentase_potongan': '3.00',
        'berat_bersih_kg': '97.00',
        'nilai_potongan_rp': '7500.00',
        'subtotal': '242500.00',
        'created_at': '2026-09-06T08:00:00Z',
      };

      final item = TransaksiItem.fromJson(itemJson);
      expect(item.beratKotorKg, equals(Decimal.parse('100.00')));
      expect(item.persentasePotongan, equals(Decimal.parse('3.00')));
      expect(item.beratBersihKg, equals(Decimal.parse('97.00')));
      expect(item.nilaiPotonganRp, equals(Decimal.parse('7500.00')));
      expect(item.subtotal, equals(Decimal.parse('242500.00')));

      final ringkasanJson = {
        'id': 'trx-101',
        'kode_transaksi': 'TRX-20260906-0001',
        'tanggal_transaksi': '2026-09-06',
        'status': 'selesai',
        'penjual_id': 'p-01',
        'nama_penjual': 'Pak Tani Sawit',
        'total_berat_kotor_kg': '150.00',
        'total_berat_bersih_kg': '147.00',
        'total_potongan_rp': '7500.00',
        'total_nilai': '382500.00',
        'created_at': '2026-09-06T08:30:00Z',
      };

      final ringkasan = TransaksiRingkasan.fromJson(ringkasanJson);
      expect(ringkasan.totalBeratKotorKg, equals(Decimal.parse('150.00')));
      expect(ringkasan.totalBeratBersihKg, equals(Decimal.parse('147.00')));
      expect(ringkasan.totalPotonganRp, equals(Decimal.parse('7500.00')));
      expect(ringkasan.totalNilai, equals(Decimal.parse('382500.00')));
      // Compatibility getters
      expect(ringkasan.totalBeratKg, equals(Decimal.parse('147.00')));
      expect(ringkasan.totalHarga, equals(Decimal.parse('382500.00')));
      expect(ringkasan.totalBersih, equals(Decimal.parse('382500.00')));
    });

    test('TransaksiRepository createTransaksi produces item-level weight discount in demo mode', () async {
      final repo = TransaksiRepository();
      final result = await repo.createTransaksi(
        penjualId: 'p-001',
        namaPenjual: 'Haji Sukirman',
        tanggalTransaksi: DateTime.now(),
        items: [
          TransaksiItemDraft(
            jenisBuahId: 1,
            jenisBuahNama: 'Tandan Besar',
            hargaPerKg: Decimal.parse('2500'),
            beratKotorKg: Decimal.parse('100'),
            persentasePotongan: Decimal.parse('3'),
          ),
          TransaksiItemDraft(
            jenisBuahId: 3,
            jenisBuahNama: 'Berondolan',
            hargaPerKg: Decimal.parse('2800'),
            beratKotorKg: Decimal.parse('50'),
            persentasePotongan: Decimal.zero,
          ),
        ],
      );

      expect(result.totalBeratKotorKg, equals(Decimal.parse('150')));
      expect(result.totalBeratBersihKg, equals(Decimal.parse('147.00')));
      expect(result.totalPotonganRp, equals(Decimal.parse('7500.00')));
      expect(result.totalNilai, equals(Decimal.parse('382500.00')));
    });

    test('PercentageFormatter formats whole and decimal percentages cleanly', () {
      expect(PercentageFormatter.format(Decimal.parse('5.00')), equals('5%'));
      expect(PercentageFormatter.format(Decimal.parse('5')), equals('5%'));
      expect(PercentageFormatter.format(Decimal.parse('3.5')), equals('3.5%'));
      expect(PercentageFormatter.format(Decimal.parse('0')), equals('0%'));
      expect(PercentageFormatter.format(null), equals('0%'));
    });
  });

  group('Tugas Bagian 8: Export Laporan Excel & PDF Tests', () {
    final List<LaporanPembelianItem> sampleItems = [
      LaporanPembelianItem(
        kodeTransaksi: 'TRX-20260901-0001',
        tanggalTransaksi: DateTime(2026, 9, 1),
        namaPenjual: 'Budi Santoso',
        jenisBuah: 'Tandan Besar',
        hargaPerKg: Decimal.parse('2500'),
        beratKotorKg: Decimal.parse('400.00'),
        persentasePotongan: Decimal.parse('5.00'),
        potonganKg: Decimal.parse('20.00'),
        beratBersihKg: Decimal.parse('380.00'),
        subtotal: Decimal.parse('950000.00'),
        status: 'selesai',
      ),
      LaporanPembelianItem(
        kodeTransaksi: 'TRX-20260902-0002',
        tanggalTransaksi: DateTime(2026, 9, 2),
        namaPenjual: 'Haji Sukirman',
        jenisBuah: 'Berondolan',
        hargaPerKg: Decimal.parse('2500'),
        beratKotorKg: Decimal.parse('600.00'),
        persentasePotongan: Decimal.parse('5.00'),
        potonganKg: Decimal.parse('30.00'),
        beratBersihKg: Decimal.parse('570.00'),
        subtotal: Decimal.parse('1425000.00'),
        status: 'selesai',
      ),
    ];

    test('LaporanExcelGenerator generates proper file name with date range', () {
      final name1 = LaporanExcelGenerator.generateFileName(
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 30),
      );
      expect(name1, equals('Laporan-Transaksi-2026-09-01-sd-2026-09-30.xlsx'));

      final name2 = LaporanExcelGenerator.generateFileName(
        startDate: DateTime(2026, 9, 5),
        endDate: DateTime(2026, 9, 5),
      );
      expect(name2, equals('Laporan-Transaksi-2026-09-05.xlsx'));

      final name3 = LaporanExcelGenerator.generateFileName();
      expect(name3, equals('Laporan-Transaksi-Semua-Periode.xlsx'));
    });

    test('LaporanPdfGenerator generates proper file name with date range', () {
      final name1 = LaporanPdfGenerator.generateFileName(
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 30),
      );
      expect(name1, equals('Laporan-Transaksi-2026-09-01-sd-2026-09-30.pdf'));
    });

    test('LaporanExcelGenerator generates non-empty byte buffer with data and totals', () {
      final bytes = LaporanExcelGenerator.generate(
        items: sampleItems,
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 30),
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(100));
    });

    test('LaporanPdfGenerator generates non-empty PDF byte buffer', () async {
      final bytes = await LaporanPdfGenerator.generate(
        items: sampleItems,
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 30),
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(500));
    });
  });
}

