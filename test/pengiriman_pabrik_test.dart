import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaksi_sawit_app/core/utils/currency_formatter.dart';
import 'package:transaksi_sawit_app/core/utils/weight_formatter.dart';
import 'package:transaksi_sawit_app/features/pengiriman_pabrik/pengiriman_pabrik_controller.dart';
import 'package:transaksi_sawit_app/models/pabrik.dart';
import 'package:transaksi_sawit_app/models/pengiriman_pabrik.dart';

void main() {
  group('Modul Penjualan ke Pabrik - Unit Test Kalkulasi & Model', () {
    test('Verifikasi Kalkulasi Resmi: 1000kg - 50kg, 2%, Rp 2200/kg', () {
      final formState = SelesaikanFormState(
        beratDikirim: Decimal.parse('1000'),
        beratSampai: Decimal.parse('1000'),
        beratDitolak: Decimal.parse('50'),
        persentasePotongan: Decimal.parse('2'),
        hargaJualPerKg: Decimal.parse('2200'),
      );

      // 1. Berat Diterima = 1000 - 50 = 950 kg
      expect(formState.beratDiterima, Decimal.parse('950'));
      expect(WeightFormatter.format(formState.beratDiterima), '950,00 kg');

      // 2. Berat Bersih = 950 * (1 - 0.02) = 931 kg
      expect(formState.beratBersih, Decimal.parse('931'));
      expect(WeightFormatter.format(formState.beratBersih), '931,00 kg');

      // 3. Total Nilai Jual = 931 * 2200 = Rp 2.048.200
      expect(formState.totalNilaiJual, Decimal.parse('2048200'));
      expect(CurrencyFormatter.format(formState.totalNilaiJual), 'Rp 2.048.200');

      // Nilai Potongan = 2200 * 950 * 2% = Rp 41.800
      expect(formState.nilaiPotonganRp, Decimal.parse('41800'));
    });

    test('Pabrik Model JSON Serialization', () {
      final now = DateTime.now();
      final pabrik = Pabrik(
        id: 'pb-test-1',
        nama: 'PT Sawit Makmur',
        alamat: 'Jl. Sawit Raya',
        kontak: '08123456789',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final json = pabrik.toJson();
      expect(json['id'], 'pb-test-1');
      expect(json['nama'], 'PT Sawit Makmur');

      final deserialized = Pabrik.fromJson(json);
      expect(deserialized.id, pabrik.id);
      expect(deserialized.nama, pabrik.nama);
      expect(deserialized.isActive, true);
    });

    test('PengirimanPabrik Model JSON Serialization with Decimals', () {
      final now = DateTime.now();
      final pengiriman = PengirimanPabrik(
        id: 'krm-test-1',
        kodePengiriman: 'KRM-20260907-0001',
        pabrikId: 'pb-test-1',
        platNomor: 'BM 1234 AB',
        namaSopir: 'Pak Budi',
        tanggalKirim: now,
        beratKotorKg: Decimal.parse('1000'),
        beratDitolakKg: Decimal.parse('50'),
        beratDiterimaKg: Decimal.parse('950'),
        persentasePotonganPabrik: Decimal.parse('2'),
        beratBersihKg: Decimal.parse('931'),
        hargaJualPerKg: Decimal.parse('2200'),
        nilaiPotonganRp: Decimal.parse('41800'),
        totalNilaiJual: Decimal.parse('2048200'),
        status: 'selesai',
        createdAt: now,
        updatedAt: now,
      );

      final json = pengiriman.toJson();
      expect(json['kode_pengiriman'], 'KRM-20260907-0001');

      final deserialized = PengirimanPabrik.fromJson(json);
      expect(deserialized.kodePengiriman, 'KRM-20260907-0001');
      expect(deserialized.beratDiterimaKg, Decimal.parse('950'));
      expect(deserialized.beratBersihKg, Decimal.parse('931'));
      expect(deserialized.totalNilaiJual, Decimal.parse('2048200'));
    });
  });
}
