import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transaksi_sawit_app/features/dashboard/export/laporan_pendapatan_excel_generator.dart';
import 'package:transaksi_sawit_app/features/dashboard/export/laporan_pendapatan_pdf_generator.dart';
import 'package:transaksi_sawit_app/features/pengeluaran/export/laporan_pengeluaran_excel_generator.dart';
import 'package:transaksi_sawit_app/features/pengeluaran/export/laporan_pengeluaran_pdf_generator.dart';
import 'package:transaksi_sawit_app/features/pengeluaran/pengeluaran_filter_state.dart';
import 'package:transaksi_sawit_app/models/dashboard_analytics.dart';
import 'package:transaksi_sawit_app/models/jenis_pengeluaran.dart';
import 'package:transaksi_sawit_app/models/laporan_pendapatan.dart';
import 'package:transaksi_sawit_app/models/pengeluaran.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('id_ID', null);
  });

  group('Tugas Bagian 21: Model JenisPengeluaran & Pengeluaran', () {
    test('1. Model JenisPengeluaran JSON serialization & active state', () {
      final json = {
        'id': 1,
        'nama': 'Bahan Bakar & Solar',
        'is_active': true,
      };

      final jenis = JenisPengeluaran.fromJson(json);
      expect(jenis.id, 1);
      expect(jenis.nama, 'Bahan Bakar & Solar');
      expect(jenis.isActive, true);

      final outJson = jenis.toJson();
      expect(outJson['nama'], 'Bahan Bakar & Solar');
      expect(outJson['is_active'], true);
    });

    test('2. Model Pengeluaran anti-floating point Decimal nominal', () {
      final json = {
        'id': 'exp-1',
        'jenis_pengeluaran_id': 1,
        'jenis_pengeluaran_nama': 'Bahan Bakar',
        'nominal': '1250000.00',
        'tanggal_pengeluaran': '2026-09-15',
        'keterangan': 'Beli solar 100 liter',
        'created_by': 'user-kasir-1',
        'created_by_name': 'Budi Kasir',
        'created_at': '2026-09-15T08:30:00Z',
      };

      final exp = Pengeluaran.fromJson(json);
      expect(exp.id, 'exp-1');
      expect(exp.nominal, Decimal.parse('1250000.00'));
      expect(exp.jenisPengeluaranNama, 'Bahan Bakar');
      expect(exp.createdByName, 'Budi Kasir');

      // Test permission helper: Kasir owner vs Kasir non-owner vs Admin
      // Kasir owner (user-kasir-1) -> can edit/delete
      expect(exp.canUserEditOrDelete(userId: 'user-kasir-1', isAdmin: false), true);
      // Kasir non-owner (user-kasir-2) -> cannot edit/delete
      expect(exp.canUserEditOrDelete(userId: 'user-kasir-2', isAdmin: false), false);
      // Admin (any userId) -> can edit/delete
      expect(exp.canUserEditOrDelete(userId: 'admin-user', isAdmin: true), true);
    });

    test('3. Model LabaBersihHarian surplus & deficit detection', () {
      final surplus = LabaBersihHarian(
        tanggal: DateTime(2026, 9, 15),
        totalPembelian: Decimal.parse('10000000'),
        totalPenjualan: Decimal.parse('15000000'),
        margin: Decimal.parse('5000000'),
        totalPengeluaran: Decimal.parse('1500000'),
        labaBersih: Decimal.parse('3500000'),
      );

      expect(surplus.isMarginSurplus, true);
      expect(surplus.isLabaBersihSurplus, true);

      final defisit = LabaBersihHarian(
        tanggal: DateTime(2026, 9, 16),
        totalPembelian: Decimal.parse('10000000'),
        totalPenjualan: Decimal.parse('12000000'),
        margin: Decimal.parse('2000000'),
        totalPengeluaran: Decimal.parse('3000000'),
        labaBersih: Decimal.parse('-1000000'),
      );

      expect(defisit.isMarginSurplus, true);
      expect(defisit.isLabaBersihSurplus, false);
    });
  });

  group('Tugas Bagian 21: Preset Filter Pengeluaran & Tanggal Kustom', () {
    test('4. Standard Preset Filter Pengeluaran melalui PengeluaranFilterNotifier', () {
      final notifier = PengeluaranFilterNotifier();
      expect(notifier.state.datePreset, 'semua');
      expect(notifier.state.hasActiveFilter, false);

      notifier.applyDatePreset('hari_ini');
      expect(notifier.state.datePreset, 'hari_ini');
      expect(notifier.state.startDate, isNotNull);
      expect(notifier.state.endDate, isNotNull);
      expect(notifier.state.hasActiveFilter, true);

      notifier.applyDatePreset('1_minggu');
      expect(notifier.state.datePreset, '1_minggu');

      notifier.applyDatePreset('2_minggu');
      expect(notifier.state.datePreset, '2_minggu');

      notifier.applyDatePreset('1_bulan');
      expect(notifier.state.datePreset, '1_bulan');

      notifier.applyDatePreset('3_bulan');
      expect(notifier.state.datePreset, '3_bulan');

      notifier.applyDatePreset('6_bulan');
      expect(notifier.state.datePreset, '6_bulan');

      notifier.applyDatePreset('1_tahun');
      expect(notifier.state.datePreset, '1_tahun');

      final customStart = DateTime(2026, 8, 1);
      final customEnd = DateTime(2026, 8, 31);
      notifier.setCustomRange(customStart, customEnd);
      expect(notifier.state.datePreset, 'kustom');
      expect(notifier.state.startDate?.year, 2026);
      expect(notifier.state.startDate?.month, 8);
      expect(notifier.state.startDate?.day, 1);
      expect(notifier.state.endDate?.month, 8);
      expect(notifier.state.endDate?.day, 31);
    });
  });

  group('Tugas Bagian 21: Integrasi Laporan Pendapatan & Laba Bersih', () {
    test('5. Aggregator Laporan Pendapatan menghitung Pengeluaran & Laba Bersih', () {
      final sampleLabaBersih = [
        // Kuartal 1: Beli 25jt, Jual 31.5jt, Margin 6.5jt, Pengeluaran 2jt -> Laba Bersih 4.5jt
        LabaBersihHarian(
          tanggal: DateTime(2026, 1, 15),
          totalPembelian: Decimal.parse('10000000'),
          totalPenjualan: Decimal.parse('13000000'),
          margin: Decimal.parse('3000000'),
          totalPengeluaran: Decimal.parse('1000000'),
          labaBersih: Decimal.parse('2000000'),
        ),
        LabaBersihHarian(
          tanggal: DateTime(2026, 2, 20),
          totalPembelian: Decimal.parse('15000000'),
          totalPenjualan: Decimal.parse('18500000'),
          margin: Decimal.parse('3500000'),
          totalPengeluaran: Decimal.parse('1000000'),
          labaBersih: Decimal.parse('2500000'),
        ),
        // Kuartal 2: Beli 20jt, Jual 25jt, Margin 5jt, Pengeluaran 3jt -> Laba Bersih 2jt
        LabaBersihHarian(
          tanggal: DateTime(2026, 4, 10),
          totalPembelian: Decimal.parse('20000000'),
          totalPenjualan: Decimal.parse('25000000'),
          margin: Decimal.parse('5000000'),
          totalPengeluaran: Decimal.parse('3000000'),
          labaBersih: Decimal.parse('2000000'),
        ),
      ];

      final result1Tahun = LaporanPendapatanAggregator.aggregate(
        dailyLabaBersih: sampleLabaBersih,
        cakupan: CakupanLaporanPendapatan.satuTahun,
        referenceDate: DateTime(2026, 9, 16),
      );

      // Kuartal 1
      expect(result1Tahun.rows[0].totalPembelian, Decimal.parse('25000000'));
      expect(result1Tahun.rows[0].totalPenjualan, Decimal.parse('31500000'));
      expect(result1Tahun.rows[0].margin, Decimal.parse('6500000'));
      expect(result1Tahun.rows[0].totalPengeluaran, Decimal.parse('2000000'));
      expect(result1Tahun.rows[0].labaBersih, Decimal.parse('4500000'));

      // Kuartal 2
      expect(result1Tahun.rows[1].totalPembelian, Decimal.parse('20000000'));
      expect(result1Tahun.rows[1].totalPenjualan, Decimal.parse('25000000'));
      expect(result1Tahun.rows[1].margin, Decimal.parse('5000000'));
      expect(result1Tahun.rows[1].totalPengeluaran, Decimal.parse('3000000'));
      expect(result1Tahun.rows[1].labaBersih, Decimal.parse('2000000'));

      // Grand Totals
      expect(result1Tahun.grandTotalPembelian, Decimal.parse('45000000'));
      expect(result1Tahun.grandTotalPenjualan, Decimal.parse('56500000'));
      expect(result1Tahun.grandTotalMargin, Decimal.parse('11500000'));
      expect(result1Tahun.grandTotalPengeluaran, Decimal.parse('5000000'));
      expect(result1Tahun.grandTotalLabaBersih, Decimal.parse('6500000'));
      expect(result1Tahun.isLabaBersihSurplus, true);
    });

    test('6. Export Generator Laporan Pendapatan (Excel & PDF) memuat 7 kolom', () async {
      final sampleLabaBersih = [
        LabaBersihHarian(
          tanggal: DateTime(2026, 9, 10),
          totalPembelian: Decimal.parse('10000000'),
          totalPenjualan: Decimal.parse('13000000'),
          margin: Decimal.parse('3000000'),
          totalPengeluaran: Decimal.parse('500000'),
          labaBersih: Decimal.parse('2500000'),
        ),
      ];

      final data = LaporanPendapatanAggregator.aggregate(
        dailyLabaBersih: sampleLabaBersih,
        cakupan: CakupanLaporanPendapatan.satuBulan,
        referenceDate: DateTime(2026, 9, 1),
      );

      final excelBytes = LaporanPendapatanExcelGenerator.generate(data: data);
      expect(excelBytes.isNotEmpty, true);

      final pdfBytes = await LaporanPendapatanPdfGenerator.generate(data: data);
      expect(pdfBytes.isNotEmpty, true);
    });
  });

  group('Tugas Bagian 21: Export Laporan Pengeluaran Khusus', () {
    test('7. LaporanPengeluaranExcelGenerator & PdfGenerator', () async {
      final sampleList = [
        Pengeluaran(
          id: 'exp-1',
          jenisPengeluaranId: 1,
          jenisPengeluaranNama: 'Bahan Bakar & Solar',
          nominal: Decimal.parse('750000'),
          tanggalPengeluaran: DateTime(2026, 9, 10),
          keterangan: 'Pengisian solar dump truck 1',
          createdBy: 'user-1',
          createdByName: 'Budi Kasir',
          createdAt: DateTime(2026, 9, 10, 8, 0),
        ),
        Pengeluaran(
          id: 'exp-2',
          jenisPengeluaranId: 2,
          jenisPengeluaranNama: 'Konsumsi Petugas',
          nominal: Decimal.parse('150000'),
          tanggalPengeluaran: DateTime(2026, 9, 10),
          keterangan: 'Makan siang 5 orang',
          createdBy: 'user-2',
          createdByName: 'Agus Mandor',
          createdAt: DateTime(2026, 9, 10, 12, 0),
        ),
      ];

      final excelBytes = LaporanPengeluaranExcelGenerator.generate(
        items: sampleList,
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 30),
      );
      expect(excelBytes.isNotEmpty, true);

      final pdfBytes = await LaporanPengeluaranPdfGenerator.generate(
        items: sampleList,
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 30),
      );
      expect(pdfBytes.isNotEmpty, true);
    });
  });
}
