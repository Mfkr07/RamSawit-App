import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:transaksi_sawit_app/models/pemakaian_saldo_harian.dart';
import 'package:transaksi_sawit_app/models/saldo_ringkasan.dart';
import 'package:transaksi_sawit_app/models/topup_saldo.dart';
import 'package:transaksi_sawit_app/features/saldo/saldo_filter_state.dart';
import 'package:transaksi_sawit_app/features/saldo/saldo_repository.dart';
import 'package:transaksi_sawit_app/features/saldo/export/laporan_saldo_excel_generator.dart';
import 'package:transaksi_sawit_app/features/saldo/export/laporan_saldo_pdf_generator.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('id_ID', null);
    SaldoRepository.seedDemoDataForTesting();
  });

  group('Tugas Bagian 22: Model TopupSaldo & SaldoRingkasan', () {
    test('1. Model TopupSaldo serialisasi JSON dan Decimal nominal tanpa floating point error', () {
      final json = {
        'id': 'tp-101',
        'tanggal': '2026-09-20',
        'nominal': '25000000.5',
        'keterangan': 'Modal kas harian',
        'created_by': 'user-1',
        'created_at': '2026-09-20T08:00:00.000Z',
      };

      final topup = TopupSaldo.fromJson(json);
      expect(topup.id, 'tp-101');
      expect(topup.nominal, Decimal.parse('25000000.5'));
      expect(topup.keterangan, 'Modal kas harian');

      final serialized = topup.toJson();
      expect(serialized['nominal'], '25000000.5');
      expect(serialized['tanggal'], '2026-09-20');
    });

    test('2. Model SaldoRingkasan deteksi sisa saldo menipis/habis dan metrik periode', () {
      final saldoNormal = SaldoRingkasan(
        totalTopup: Decimal.parse('100000000'),
        totalPemakaian: Decimal.parse('75000000'),
        sisaSaldo: Decimal.parse('25000000'),
        totalTopupPeriode: Decimal.parse('15000000'),
        totalPemakaianPeriode: Decimal.parse('10000000'),
      );
      expect(saldoNormal.isLowOrExhausted, isFalse);
      expect(saldoNormal.effectiveTotalTopup, Decimal.parse('15000000'));
      expect(saldoNormal.effectiveTotalPemakaian, Decimal.parse('10000000'));

      final saldoHabis = SaldoRingkasan(
        totalTopup: Decimal.parse('50000000'),
        totalPemakaian: Decimal.parse('50000000'),
        sisaSaldo: Decimal.zero,
      );
      expect(saldoHabis.isLowOrExhausted, isTrue);

      final saldoMinus = SaldoRingkasan(
        totalTopup: Decimal.parse('50000000'),
        totalPemakaian: Decimal.parse('55000000'),
        sisaSaldo: Decimal.parse('-5000000'),
      );
      expect(saldoMinus.isLowOrExhausted, isTrue);
    });

    test('3. Model PemakaianSaldoHarian dan MutasiSaldoItem (+ Top Up & - Pemakaian)', () {
      final pemakaian = PemakaianSaldoHarian(
        tanggal: DateTime(2026, 9, 20),
        totalPemakaian: Decimal.parse('12500000'),
        jumlahTransaksi: 5,
      );
      expect(pemakaian.totalPemakaian, Decimal.parse('12500000'));
      expect(pemakaian.jumlahTransaksi, 5);

      final mutasiPemakaian = MutasiSaldoItem.pemakaian(pemakaian);
      expect(mutasiPemakaian.isPemakaian, isTrue);
      expect(mutasiPemakaian.isTopup, isFalse);
      expect(mutasiPemakaian.nominal, Decimal.parse('12500000'));

      final topup = TopupSaldo(
        id: 'tp-1',
        tanggal: DateTime(2026, 9, 20),
        nominal: Decimal.parse('20000000'),
        createdBy: 'admin',
        createdAt: DateTime.now(),
      );
      final mutasiTopup = MutasiSaldoItem.topup(topup);
      expect(mutasiTopup.isTopup, isTrue);
      expect(mutasiTopup.isPemakaian, isFalse);
      expect(mutasiTopup.nominal, Decimal.parse('20000000'));
    });
  });

  group('Tugas Bagian 22: Preset Filter Saldo (Default: Hari Ini)', () {
    test('4. Standard Preset Filter Saldo melalui SaldoFilterNotifier default ke hari_ini', () {
      final notifier = SaldoFilterNotifier();
      // Default awal adalah 'hari_ini' sesuai permintaan pengguna
      expect(notifier.state.datePreset, 'hari_ini');
      expect(notifier.state.startDate, isNotNull);
      expect(notifier.state.endDate, isNotNull);
      expect(notifier.state.hasActiveFilter, isFalse);

      notifier.applyDatePreset('1_minggu');
      expect(notifier.state.datePreset, '1_minggu');
      expect(notifier.state.hasActiveFilter, isTrue);

      notifier.applyDatePreset('1_bulan');
      expect(notifier.state.datePreset, '1_bulan');

      notifier.setCustomDateRange(DateTime(2026, 9, 1), DateTime(2026, 9, 15));
      expect(notifier.state.datePreset, 'kustom');
      expect(notifier.state.startDate, DateTime(2026, 9, 1));
      expect(notifier.state.endDate, DateTime(2026, 9, 15, 23, 59, 59));

      notifier.applyDatePreset('semua');
      expect(notifier.state.datePreset, 'semua');
      expect(notifier.state.startDate, isNull);
      expect(notifier.state.endDate, isNull);

      notifier.reset();
      expect(notifier.state.datePreset, 'hari_ini');
    });
  });

  group('Tugas Bagian 22: SaldoRepository & Operasi Data dengan Filter Periode & Pemakaian Harian', () {
    test('5. SaldoRepository getSaldoRingkasan dengan filter periode', () async {
      final repo = SaldoRepository(null); // demo mode

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final ringkasanHariIni = await repo.getSaldoRingkasan(
        startDate: todayStart,
        endDate: todayEnd,
      );
      expect(ringkasanHariIni.sisaSaldo, isNotNull);
      expect(ringkasanHariIni.totalTopupPeriode, isNotNull);
      expect(ringkasanHariIni.totalPemakaianPeriode, isNotNull);
      expect(ringkasanHariIni.effectiveTotalTopup, ringkasanHariIni.totalTopupPeriode);
    });

    test('6. SaldoRepository fetchPemakaianHarian dan fetchMutasiLinimasa', () async {
      final repo = SaldoRepository(null);

      final pemakaianHarian = await repo.fetchPemakaianHarian();
      expect(pemakaianHarian.isNotEmpty, isTrue);
      expect(pemakaianHarian.first.totalPemakaian > Decimal.zero, isTrue);

      final mutasiLinimasa = await repo.fetchMutasiLinimasa();
      expect(mutasiLinimasa.isNotEmpty, isTrue);
      expect(mutasiLinimasa.any((m) => m.isTopup), isTrue);
      expect(mutasiLinimasa.any((m) => m.isPemakaian), isTrue);
    });

    test('7. SaldoRepository createTopup & validasi nominal > 0', () async {
      final repo = SaldoRepository(null);

      final created = await repo.createTopup(
        tanggal: DateTime.now(),
        nominal: Decimal.parse('10000000'),
        keterangan: 'Top up test',
      );
      expect(created.nominal, Decimal.parse('10000000'));
      expect(created.keterangan, 'Top up test');

      expect(
        () => repo.createTopup(
          tanggal: DateTime.now(),
          nominal: Decimal.zero,
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('Tugas Bagian 22: Export Laporan Saldo / Dana Modal (Excel & PDF)', () {
    test('8. LaporanSaldoExcelGenerator memuat 3 bagian (Ringkasan, Topup, Pembelian)', () {
      final ringkasan = SaldoRingkasan(
        totalTopup: Decimal.parse('75000000'),
        totalPemakaian: Decimal.parse('42500000'),
        sisaSaldo: Decimal.parse('32500000'),
      );

      final topupItems = [
        TopupSaldo(
          id: 'tp-1',
          tanggal: DateTime(2026, 9, 1),
          nominal: Decimal.parse('50000000'),
          keterangan: 'Modal awal September',
          createdBy: 'admin-1',
          createdByName: 'Administrator',
          createdAt: DateTime(2026, 9, 1),
        ),
      ];

      final pembelianItems = [
        PembelianPengurangSaldo(
          id: 'trx-1',
          kodeTransaksi: 'TRX-20260901-001',
          tanggal: DateTime(2026, 9, 1),
          namaPenjual: 'Pak Budi Hartono',
          nominal: Decimal.fromInt(18500000),
        ),
      ];

      final bytes = LaporanSaldoExcelGenerator.generate(
        ringkasan: ringkasan,
        topupItems: topupItems,
        pembelianItems: pembelianItems,
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 20),
      );

      expect(bytes.isNotEmpty, isTrue);
      final filename = LaporanSaldoExcelGenerator.generateFileName(
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 20),
      );
      expect(filename, contains('Laporan-Saldo-Dana-Modal'));
      expect(filename.endsWith('.xlsx'), isTrue);
    });

    test('9. LaporanSaldoPdfGenerator menghasilkan dokumen PDF valid dengan header %PDF', () async {
      final ringkasan = SaldoRingkasan(
        totalTopup: Decimal.parse('75000000'),
        totalPemakaian: Decimal.parse('42500000'),
        sisaSaldo: Decimal.parse('32500000'),
      );

      final topupItems = [
        TopupSaldo(
          id: 'tp-1',
          tanggal: DateTime(2026, 9, 1),
          nominal: Decimal.parse('50000000'),
          keterangan: 'Modal awal September',
          createdBy: 'admin-1',
          createdByName: 'Administrator',
          createdAt: DateTime(2026, 9, 1),
        ),
      ];

      final pembelianItems = [
        PembelianPengurangSaldo(
          id: 'trx-1',
          kodeTransaksi: 'TRX-20260901-001',
          tanggal: DateTime(2026, 9, 1),
          namaPenjual: 'Pak Budi Hartono',
          nominal: Decimal.fromInt(18500000),
        ),
      ];

      final bytes = await LaporanSaldoPdfGenerator.generate(
        ringkasan: ringkasan,
        topupItems: topupItems,
        pembelianItems: pembelianItems,
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 20),
      );

      expect(bytes.isNotEmpty, isTrue);
      // Validasi magic number header PDF
      final header = utf8.decode(bytes.sublist(0, 4));
      expect(header, '%PDF');
    });
  });
}
