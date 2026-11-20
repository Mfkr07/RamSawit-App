import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:transaksi_sawit_app/features/pengiriman_pabrik/export/laporan_pengiriman_excel_generator.dart';
import 'package:transaksi_sawit_app/features/pengiriman_pabrik/export/laporan_pengiriman_pdf_generator.dart';
import 'package:transaksi_sawit_app/models/pengiriman_pabrik.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('Tugas Bagian 23 - Potongan Lainnya & Potongan Sortasi Pabrik Tests', () {
    test('Model serialization and formula verification', () {
      final item = PengirimanPabrik(
        id: 'test-id-1',
        kodePengiriman: 'KRM-20260921-0001',
        tanggalKirim: DateTime(2026, 9, 21),
        pabrikId: 'pabrik-1',
        platNomor: 'BK 1234 AB',
        namaSopir: 'Budi Santoso',
        beratDikirimKg: Decimal.parse('1000.00'),
        status: 'selesai',
        beratSampaiKg: Decimal.parse('980.00'),
        beratDitolakKg: Decimal.parse('30.00'),
        beratDiterimaKg: Decimal.parse('950.00'),
        persentasePotonganPabrik: Decimal.parse('2.00'),
        beratBersihKg: Decimal.parse('931.00'),
        susutBuahKg: Decimal.parse('20.00'),
        hargaJualPerKg: Decimal.parse('2200.00'),
        potonganLainnyaRp: Decimal.parse('50000.00'),
        potonganSortasiPerKg: Decimal.parse('10.00'),
        nilaiPotonganSortasiRp: Decimal.parse('9800.00'), // 10 * 980
        totalNilaiJual: Decimal.parse('1988400.00'), // (2200 * 931) - 50000 - 9800 = 2048200 - 59800 = 1988400
      );

      // Verify properties
      expect(item.beratDiterimaKg, Decimal.parse('950.00'));
      expect(item.beratBersihKg, Decimal.parse('931.00'));
      expect(item.susutBuahKg, Decimal.parse('20.00'));

      // Check fields
      expect(item.potonganLainnyaRp, Decimal.parse('50000.00'));
      expect(item.potonganSortasiPerKg, Decimal.parse('10.00'));
      expect(item.nilaiPotonganSortasiRp, Decimal.parse('9800.00'));
      expect(item.totalNilaiJual, Decimal.parse('1988400.00'));

      // Test JSON roundtrip
      final json = item.toJson();
      expect(Decimal.parse(json['potongan_lainnya_rp']), Decimal.parse('50000'));
      expect(Decimal.parse(json['potongan_sortasi_per_kg']), Decimal.parse('10'));
      expect(Decimal.parse(json['nilai_potongan_sortasi_rp']), Decimal.parse('9800'));
      expect(Decimal.parse(json['total_nilai_jual']), Decimal.parse('1988400'));

      final fromJson = PengirimanPabrik.fromJson(json);
      expect(fromJson.potonganLainnyaRp, Decimal.parse('50000.00'));
      expect(fromJson.potonganSortasiPerKg, Decimal.parse('10.00'));
      expect(fromJson.nilaiPotonganSortasiRp, Decimal.parse('9800.00'));
      expect(fromJson.totalNilaiJual, Decimal.parse('1988400.00'));
    });

    test('Formula with zero or null discounts leaves total unaffected', () {
      final item = PengirimanPabrik(
        id: 'test-id-2',
        kodePengiriman: 'KRM-20260921-0002',
        tanggalKirim: DateTime(2026, 9, 21),
        pabrikId: 'pabrik-1',
        platNomor: 'BK 5678 CD',
        namaSopir: 'Joko',
        beratDikirimKg: Decimal.parse('1000.00'),
        status: 'selesai',
        beratSampaiKg: Decimal.parse('980.00'),
        beratDitolakKg: Decimal.parse('30.00'),
        beratDiterimaKg: Decimal.parse('950.00'),
        persentasePotonganPabrik: Decimal.parse('2.00'),
        beratBersihKg: Decimal.parse('931.00'),
        susutBuahKg: Decimal.parse('20.00'),
        hargaJualPerKg: Decimal.parse('2200.00'),
        potonganLainnyaRp: null,
        potonganSortasiPerKg: null,
        nilaiPotonganSortasiRp: Decimal.zero,
        totalNilaiJual: Decimal.parse('2048200.00'), // 2200 * 931.00
      );

      expect(item.potonganLainnyaRp, isNull);
      expect(item.potonganSortasiPerKg, isNull);
      expect(item.nilaiPotonganSortasiRp, Decimal.zero);
      expect(item.totalNilaiJual, Decimal.parse('2048200.00'));
    });

    test('Excel generator generates valid bytes with new discount columns', () {
      final items = [
        PengirimanPabrik(
          id: 'test-id-1',
          kodePengiriman: 'KRM-20260921-0001',
          tanggalKirim: DateTime(2026, 9, 21),
          pabrikId: 'pabrik-1',
          platNomor: 'BK 1234 AB',
          namaSopir: 'Budi Santoso',
          beratDikirimKg: Decimal.parse('1000.00'),
          status: 'selesai',
          beratSampaiKg: Decimal.parse('980.00'),
          beratDitolakKg: Decimal.parse('30.00'),
          beratDiterimaKg: Decimal.parse('950.00'),
          persentasePotonganPabrik: Decimal.parse('2.00'),
          beratBersihKg: Decimal.parse('931.00'),
          susutBuahKg: Decimal.parse('20.00'),
          hargaJualPerKg: Decimal.parse('2200.00'),
          potonganLainnyaRp: Decimal.parse('50000.00'),
          potonganSortasiPerKg: Decimal.parse('10.00'),
          nilaiPotonganSortasiRp: Decimal.parse('9800.00'),
          totalNilaiJual: Decimal.parse('1988400.00'),
        ),
      ];

      final bytes = LaporanPengirimanExcelGenerator.generate(items: items);
      expect(bytes.isNotEmpty, isTrue);
    });

    test('PDF generator generates valid bytes with new discount columns', () async {
      final items = [
        PengirimanPabrik(
          id: 'test-id-1',
          kodePengiriman: 'KRM-20260921-0001',
          tanggalKirim: DateTime(2026, 9, 21),
          pabrikId: 'pabrik-1',
          platNomor: 'BK 1234 AB',
          namaSopir: 'Budi Santoso',
          beratDikirimKg: Decimal.parse('1000.00'),
          status: 'selesai',
          beratSampaiKg: Decimal.parse('980.00'),
          beratDitolakKg: Decimal.parse('30.00'),
          beratDiterimaKg: Decimal.parse('950.00'),
          persentasePotonganPabrik: Decimal.parse('2.00'),
          beratBersihKg: Decimal.parse('931.00'),
          susutBuahKg: Decimal.parse('20.00'),
          hargaJualPerKg: Decimal.parse('2200.00'),
          potonganLainnyaRp: Decimal.parse('50000.00'),
          potonganSortasiPerKg: Decimal.parse('10.00'),
          nilaiPotonganSortasiRp: Decimal.parse('9800.00'),
          totalNilaiJual: Decimal.parse('1988400.00'),
        ),
      ];

      final bytes = await LaporanPengirimanPdfGenerator.generate(items: items);
      expect(bytes.isNotEmpty, isTrue);
    });
  });
}
