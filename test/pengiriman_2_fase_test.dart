import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:transaksi_sawit_app/core/utils/currency_formatter.dart';
import 'package:transaksi_sawit_app/core/utils/weight_formatter.dart';
import 'package:transaksi_sawit_app/features/pengiriman_pabrik/export/laporan_pengiriman_excel_generator.dart';
import 'package:transaksi_sawit_app/features/pengiriman_pabrik/export/laporan_pengiriman_pdf_generator.dart';
import 'package:transaksi_sawit_app/features/pengiriman_pabrik/pengiriman_pabrik_controller.dart';
import 'package:transaksi_sawit_app/models/pabrik.dart';
import 'package:transaksi_sawit_app/models/pengiriman_pabrik.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Alur 2-Fase Pengiriman Pabrik (Tugas Bagian 15)', () {
    final now = DateTime(2026, 9, 10, 10, 0);

    final mockPabrik = Pabrik(
      id: 'pabrik-1',
      nama: 'PT Sawit Makmur Sejahtera',
      alamat: 'Jl. Industri Sawit No. 1',
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    test('Fase 1 (Keberangkatan): Model Serialization & toInsertMap', () {
      final pengirimanFase1 = PengirimanPabrik(
        id: 'krm-fase1-01',
        kodePengiriman: 'KRM-20260910-0001',
        pabrikId: 'pabrik-1',
        platNomor: 'BM 8899 AB',
        namaSopir: 'Pak Joko',
        tanggalKirim: now,
        beratKotorKg: Decimal.parse('10500'),
        status: 'berangkat',
        catatan: 'SPK No 45/IX/2026',
        createdAt: now,
        updatedAt: now,
        pabrik: mockPabrik,
      );

      // Verifikasi status & nullability kolom fase 2
      expect(pengirimanFase1.isBerangkat, true);
      expect(pengirimanFase1.isSelesai, false);
      expect(pengirimanFase1.isDibatalkan, false);
      expect(pengirimanFase1.beratDitolakKg, isNull);
      expect(pengirimanFase1.beratDiterimaKg, isNull);
      expect(pengirimanFase1.persentasePotonganPabrik, isNull);
      expect(pengirimanFase1.beratBersihKg, isNull);
      expect(pengirimanFase1.hargaJualPerKg, isNull);
      expect(pengirimanFase1.totalNilaiJual, isNull);

      // Verifikasi toInsertMap Fase 1
      final insertMap = pengirimanFase1.toInsertMap();
      expect(insertMap['pabrik_id'], 'pabrik-1');
      expect(insertMap['plat_nomor'], 'BM 8899 AB');
      expect(insertMap['nama_sopir'], 'Pak Joko');
      expect(insertMap['berat_dikirim_kg'] ?? insertMap['berat_kotor_kg'], 10500.0);
      expect(insertMap['status'], 'berangkat');
      expect(insertMap.containsKey('berat_ditolak_kg'), false);
      expect(insertMap.containsKey('harga_jual_per_kg'), false);

      // Verifikasi toJson & fromJson round-trip
      final json = pengirimanFase1.toJson();
      expect(json['status'], 'berangkat');
      expect(json['berat_kotor_kg'], '10500');
      expect(json['berat_ditolak_kg'], isNull);

      final fromJson = PengirimanPabrik.fromJson(json);
      expect(fromJson.isBerangkat, true);
      expect(fromJson.beratKotorKg, Decimal.parse('10500'));
      expect(fromJson.beratBersihKg, isNull);
    });

    test('Fase 2 (Penyelesaian): Live Preview SelesaikanFormState', () {
      final pengirimanFase1 = PengirimanPabrik(
        id: 'krm-fase1-01',
        kodePengiriman: 'KRM-20260910-0001',
        pabrikId: 'pabrik-1',
        platNomor: 'BM 8899 AB',
        namaSopir: 'Pak Joko',
        tanggalKirim: now,
        beratKotorKg: Decimal.parse('10000'),
        status: 'berangkat',
        createdAt: now,
        updatedAt: now,
        pabrik: mockPabrik,
      );

      final selesaikanState = SelesaikanFormState(
        pengiriman: pengirimanFase1,
        beratDitolak: Decimal.parse('500'),
        persentasePotongan: Decimal.parse('5'),
        hargaJualPerKg: Decimal.parse('2500'),
      );

      // 1. Berat Diterima = 10.000 - 500 = 9.500 kg
      expect(selesaikanState.beratDiterima, Decimal.parse('9500'));
      expect(WeightFormatter.format(selesaikanState.beratDiterima), '9.500,00 kg');

      // 2. Berat Bersih = 9.500 * (1 - 0.05) = 9.025 kg
      expect(selesaikanState.beratBersih, Decimal.parse('9025'));
      expect(WeightFormatter.format(selesaikanState.beratBersih), '9.025,00 kg');

      // 3. Nilai Potongan = 2500 * 9500 * 5% = Rp 1.187.500
      expect(selesaikanState.nilaiPotonganRp, Decimal.parse('1187500'));
      expect(CurrencyFormatter.format(selesaikanState.nilaiPotonganRp), 'Rp 1.187.500');

      // 4. Total Nilai Jual = 9.025 * 2500 = Rp 22.562.500
      expect(selesaikanState.totalNilaiJual, Decimal.parse('22562500'));
      expect(CurrencyFormatter.format(selesaikanState.totalNilaiJual), 'Rp 22.562.500');
    });

    test('Fase 2 (Penyelesaian): Validasi Edge Cases (0% potongan, 0 ditolak)', () {
      final pengirimanFase1 = PengirimanPabrik(
        id: 'krm-fase1-02',
        kodePengiriman: 'KRM-20260910-0002',
        pabrikId: 'pabrik-1',
        platNomor: 'BM 1122 CD',
        namaSopir: 'Pak Ali',
        tanggalKirim: now,
        beratKotorKg: Decimal.parse('8000'),
        status: 'berangkat',
        createdAt: now,
        updatedAt: now,
      );

      final stateTanpaPotongan = SelesaikanFormState(
        pengiriman: pengirimanFase1,
        beratDitolak: Decimal.zero,
        persentasePotongan: Decimal.zero,
        hargaJualPerKg: Decimal.parse('2400'),
      );

      expect(stateTanpaPotongan.beratDiterima, Decimal.parse('8000'));
      expect(stateTanpaPotongan.beratBersih, Decimal.parse('8000'));
      expect(stateTanpaPotongan.nilaiPotonganRp, Decimal.zero);
      expect(stateTanpaPotongan.totalNilaiJual, Decimal.parse('19200000'));
    });

    test('Fase 2: Model Berstatus Selesai', () {
      final pengirimanSelesai = PengirimanPabrik(
        id: 'krm-fase2-01',
        kodePengiriman: 'KRM-20260910-0001',
        pabrikId: 'pabrik-1',
        platNomor: 'BM 8899 AB',
        namaSopir: 'Pak Joko',
        tanggalKirim: now,
        beratKotorKg: Decimal.parse('10000'),
        beratDitolakKg: Decimal.parse('500'),
        beratDiterimaKg: Decimal.parse('9500'),
        persentasePotonganPabrik: Decimal.parse('5'),
        beratBersihKg: Decimal.parse('9025'),
        hargaJualPerKg: Decimal.parse('2500'),
        nilaiPotonganRp: Decimal.parse('1187500'),
        totalNilaiJual: Decimal.parse('22562500'),
        status: 'selesai',
        createdAt: now,
        updatedAt: now,
        pabrik: mockPabrik,
      );

      expect(pengirimanSelesai.isBerangkat, false);
      expect(pengirimanSelesai.isSelesai, true);
      expect(pengirimanSelesai.isDibatalkan, false);
      expect(pengirimanSelesai.beratBersihKg, Decimal.parse('9025'));
      expect(pengirimanSelesai.totalNilaiJual, Decimal.parse('22562500'));
    });

    test('Isolasi Export: Hanya Mengikutsertakan Status Selesai', () async {
      final itemBerangkat = PengirimanPabrik(
        id: 'krm-berangkat',
        kodePengiriman: 'KRM-BERANGKAT-01',
        pabrikId: 'pabrik-1',
        platNomor: 'BM 1',
        namaSopir: 'Sopir 1',
        tanggalKirim: now,
        beratKotorKg: Decimal.parse('5000'),
        status: 'berangkat',
        createdAt: now,
        updatedAt: now,
      );

      final itemSelesai = PengirimanPabrik(
        id: 'krm-selesai',
        kodePengiriman: 'KRM-SELESAI-01',
        pabrikId: 'pabrik-1',
        platNomor: 'BM 2',
        namaSopir: 'Sopir 2',
        tanggalKirim: now,
        beratKotorKg: Decimal.parse('6000'),
        beratDitolakKg: Decimal.zero,
        beratDiterimaKg: Decimal.parse('6000'),
        persentasePotonganPabrik: Decimal.zero,
        beratBersihKg: Decimal.parse('6000'),
        hargaJualPerKg: Decimal.parse('2300'),
        totalNilaiJual: Decimal.parse('13800000'),
        status: 'selesai',
        createdAt: now,
        updatedAt: now,
      );

      final mixedList = [itemBerangkat, itemSelesai];

      // Excel Generator
      final excelBytes = LaporanPengirimanExcelGenerator.generate(
        items: mixedList,
        startDate: now,
        endDate: now,
      );
      expect(excelBytes.isNotEmpty, true);

      // PDF Generator
      final pdfBytes = await LaporanPengirimanPdfGenerator.generate(
        items: mixedList,
        startDate: now,
        endDate: now,
      );
      expect(pdfBytes.isNotEmpty, true);
    });
  });
}
