import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaksi_sawit_app/models/pengiriman_pabrik.dart';
import 'package:transaksi_sawit_app/features/pengiriman_pabrik/pengiriman_pabrik_controller.dart';
import 'package:transaksi_sawit_app/features/pengiriman_pabrik/pengiriman_pabrik_repository.dart';

void main() {
  group('Tugas Bagian 20: Model & Rumus Koreksi Alur Penjualan ke Pabrik', () {
    test('Kalkulasi spesifikasi Tugas Bagian 20 menghasilkan angka yang presisi', () {
      final dikirim = Decimal.parse('1000');
      final sampai = Decimal.parse('980');
      final ditolak = Decimal.parse('30');
      final persenPotongan = Decimal.parse('2'); // 2%
      final hargaJual = Decimal.parse('2200');

      // 1. Susut Buah = Dikirim - Sampai
      final susut = dikirim - sampai;
      expect(susut, equals(Decimal.parse('20')));

      // 2. Diterima = Sampai - Ditolak
      final diterima = sampai - ditolak;
      expect(diterima, equals(Decimal.parse('950')));

      // 3. Bersih = Diterima * (1 - Potongan%)
      final factor = ((Decimal.fromInt(100) - persenPotongan) / Decimal.fromInt(100))
          .toDecimal(scaleOnInfinitePrecision: 4);
      final bersih = (diterima * factor);
      expect(bersih, equals(Decimal.parse('931')));

      // 4. Total Nilai Jual = Harga * Bersih
      final totalJual = hargaJual * bersih;
      expect(totalJual, equals(Decimal.parse('2048200')));
    });

    test('PengirimanPabrik model parsing json baru', () {
      final json = {
        'id': 'test-uuid-123',
        'kode_pengiriman': 'KRM-20260917-0001',
        'pabrik_id': 'pabrik-1',
        'plat_nomor': 'BK 1234 AB',
        'nama_sopir': 'Budi',
        'tanggal_kirim': '2026-09-17',
        'berat_dikirim_kg': 1000.0,
        'berat_sampai_kg': 980.0,
        'berat_ditolak_kg': 30.0,
        'berat_diterima_kg': 950.0,
        'persentase_potongan_pabrik': 2.0,
        'berat_bersih_kg': 931.0,
        'susut_buah_kg': 20.0,
        'harga_jual_per_kg': 2200.0,
        'nilai_potongan_rp': 41800.0,
        'total_nilai_jual': 2048200.0,
        'status': 'selesai',
        'catatan': 'Pengujian Bagian 20',
      };

      final model = PengirimanPabrik.fromJson(json);

      expect(model.beratDikirimKg, equals(Decimal.parse('1000')));
      expect(model.beratSampaiKg, equals(Decimal.parse('980')));
      expect(model.beratDitolakKg, equals(Decimal.parse('30')));
      expect(model.beratDiterimaKg, equals(Decimal.parse('950')));
      expect(model.persentasePotonganPabrik, equals(Decimal.parse('2')));
      expect(model.beratBersihKg, equals(Decimal.parse('931')));
      expect(model.susutBuahKg, equals(Decimal.parse('20')));
      expect(model.hargaJualPerKg, equals(Decimal.parse('2200')));
      expect(model.totalNilaiJual, equals(Decimal.parse('2048200')));
      expect(model.isSelesai, isTrue);

      // Pastikan getter alias beratKotorKg tetap bekerja
      expect(model.beratKotorKg, equals(Decimal.parse('1000')));
    });

    test('PengirimanPabrik toInsertMap hanya mengirim berat_dikirim_kg (Fase 1)', () {
      final model = PengirimanPabrik(
        id: 'new-id',
        kodePengiriman: 'KRM-20260917-0002',
        pabrikId: 'pabrik-1',
        platNomor: 'BK 9999 XX',
        namaSopir: 'Sopir A',
        tanggalKirim: DateTime(2026, 9, 17),
        beratDikirimKg: Decimal.parse('1000'),
        status: 'berangkat',
      );

      final insertMap = model.toInsertMap();
      expect(insertMap['berat_dikirim_kg'], equals(1000.0));
      expect(insertMap.containsKey('berat_kotor_kg'), isFalse);
      expect(insertMap['status'], equals('berangkat'));
      expect(insertMap.containsKey('berat_sampai_kg'), isFalse);
    });

    test('PengirimanPabrik toSelesaikanMap menyertakan berat_sampai_kg dan bukan berat_diterima_kg', () {
      final model = PengirimanPabrik(
        id: 'selesai-id',
        kodePengiriman: 'KRM-20260917-0003',
        pabrikId: 'pabrik-1',
        platNomor: 'BK 8888 YY',
        namaSopir: 'Sopir B',
        tanggalKirim: DateTime(2026, 9, 17),
        beratDikirimKg: Decimal.parse('1000'),
        beratSampaiKg: Decimal.parse('980'),
        beratDitolakKg: Decimal.parse('30'),
        persentasePotonganPabrik: Decimal.parse('2'),
        hargaJualPerKg: Decimal.parse('2200'),
        status: 'selesai',
      );

      final selesaikanMap = model.toSelesaikanMap();
      expect(selesaikanMap['berat_sampai_kg'], equals(980.0));
      expect(selesaikanMap['berat_ditolak_kg'], equals(30.0));
      expect(selesaikanMap['persentase_potongan_pabrik'], equals(2.0));
      expect(selesaikanMap['harga_jual_per_kg'], equals(2200.0));
      expect(selesaikanMap['status'], equals('selesai'));
      // berat_diterima_kg adalah generated column, tidak boleh ada di payload update
      expect(selesaikanMap.containsKey('berat_diterima_kg'), isFalse);
      expect(selesaikanMap.containsKey('susut_buah_kg'), isFalse);
    });
  });

  group('Tugas Bagian 20: Validasi SelesaikanFormState & Live Preview', () {
    test('Live preview kalkulasi SelesaikanFormState menghasilkan nilai turunan yang benar', () {
      final state = SelesaikanFormState(
        beratDikirim: Decimal.parse('1000'),
        beratSampai: Decimal.parse('980'),
        beratDitolak: Decimal.parse('30'),
        persentasePotongan: Decimal.parse('2'),
        hargaJualPerKg: Decimal.parse('2200'),
      );

      expect(state.susutBuah, equals(Decimal.parse('20')));
      expect(state.beratDiterima, equals(Decimal.parse('950')));
      expect(state.beratBersih, equals(Decimal.parse('931')));
      expect(state.totalNilaiJual, equals(Decimal.parse('2048200')));
      expect(state.isValid, isTrue);
    });

    test('Validasi gagal jika berat ditolak melebihi berat sampai (bukan berat dikirim)', () {
      final state = SelesaikanFormState(
        beratDikirim: Decimal.parse('1000'),
        beratSampai: Decimal.parse('980'),
        beratDitolak: Decimal.parse('985'), // Lebih besar dari 980 meskipun < 1000
        persentasePotongan: Decimal.parse('2'),
        hargaJualPerKg: Decimal.parse('2200'),
      );

      expect(state.isValid, isFalse);
    });

    test('Validasi gagal jika berat sampai bernilai 0 atau negatif', () {
      final stateZero = SelesaikanFormState(
        beratDikirim: Decimal.parse('1000'),
        beratSampai: Decimal.zero,
        beratDitolak: Decimal.zero,
        persentasePotongan: Decimal.parse('2'),
        hargaJualPerKg: Decimal.parse('2200'),
      );
      expect(stateZero.isValid, isFalse);

      final stateNull = SelesaikanFormState(
        beratDikirim: Decimal.parse('1000'),
        beratSampai: null,
        beratDitolak: Decimal.zero,
        persentasePotongan: Decimal.parse('2'),
        hargaJualPerKg: Decimal.parse('2200'),
      );
      expect(stateNull.isValid, isFalse);
    });

    test('Repository selesaikanPengirimanFase2 melempar exception jika ditolak > sampai', () {
      final repo = PengirimanPabrikRepository(null);

      expect(
        () => repo.selesaikanPengirimanFase2(
          id: 'test-krm',
          beratSampaiKg: Decimal.parse('900'),
          beratDitolakKg: Decimal.parse('950'), // > 900
          persentasePotonganPabrik: Decimal.parse('2'),
          hargaJualPerKg: Decimal.parse('2200'),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
