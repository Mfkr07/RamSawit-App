import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaksi_sawit_app/models/saldo_ringkasan.dart';
import 'package:transaksi_sawit_app/models/transaksi.dart';
import 'package:transaksi_sawit_app/models/transaksi_non_tunai_harian.dart';
import 'package:transaksi_sawit_app/features/transaksi/transaksi_filter_state.dart';
import 'package:transaksi_sawit_app/features/transaksi/transaksi_form_state.dart';
import 'package:transaksi_sawit_app/features/saldo/saldo_controller.dart';

void main() {
  group('Bagian 24: Model Transaksi & TransaksiRingkasan (Jenis Pembayaran)', () {
    test('Transaksi model defaults to tunai and exposes isTunai / isNonTunai', () {
      final trx = Transaksi(
        id: 'trx-1',
        kodeTransaksi: 'TRX-20260923-0001',
        penjualId: 'penjual-1',
        tanggalTransaksi: DateTime(2026, 9, 23),
        createdAt: DateTime(2026, 9, 23),
        updatedAt: DateTime(2026, 9, 23),
      );

      expect(trx.jenisPembayaran, 'tunai');
      expect(trx.isTunai, isTrue);
      expect(trx.isNonTunai, isFalse);

      final trxNonTunai = trx.copyWith(jenisPembayaran: 'non_tunai');
      expect(trxNonTunai.jenisPembayaran, 'non_tunai');
      expect(trxNonTunai.isTunai, isFalse);
      expect(trxNonTunai.isNonTunai, isTrue);
    });

    test('TransaksiRingkasan fromJson parses jenis_pembayaran and toJson serializes it', () {
      final jsonMap = {
        'id': 'trx-ringkas-1',
        'kode_transaksi': 'TRX-20260923-0002',
        'tanggal_transaksi': '2026-09-23',
        'status': 'selesai',
        'jenis_pembayaran': 'non_tunai',
        'penjual_id': 'p-1',
        'nama_penjual': 'Pak Slamet',
        'total_berat_kotor_kg': '1500.00',
        'total_berat_bersih_kg': '1450.00',
        'total_potongan_rp': '125000.00',
        'total_nilai': '3625000.00',
        'created_at': '2026-09-23T10:00:00.000Z',
      };

      final ringkasan = TransaksiRingkasan.fromJson(jsonMap);
      expect(ringkasan.jenisPembayaran, 'non_tunai');
      expect(ringkasan.isNonTunai, isTrue);
      expect(ringkasan.isTunai, isFalse);

      final serialized = ringkasan.toJson();
      expect(serialized['jenis_pembayaran'], 'non_tunai');
    });

    test('TransaksiRingkasan defaults to tunai if null in json (backward-compatibility)', () {
      final jsonMap = {
        'id': 'trx-ringkas-old',
        'kode_transaksi': 'TRX-20260920-0001',
        'tanggal_transaksi': '2026-09-20',
        'status': 'selesai',
        'penjual_id': 'p-old',
        'nama_penjual': 'Petani Lama',
        'total_berat_kotor_kg': '1000.00',
        'total_berat_bersih_kg': '1000.00',
        'total_potongan_rp': '0',
        'total_nilai': '2500000.00',
        'created_at': '2026-09-20T10:00:00.000Z',
      };

      final ringkasan = TransaksiRingkasan.fromJson(jsonMap);
      expect(ringkasan.jenisPembayaran, 'tunai');
      expect(ringkasan.isTunai, isTrue);
      expect(ringkasan.isNonTunai, isFalse);
    });
  });

  group('Bagian 24: Model TransaksiNonTunaiHarian', () {
    test('parses from v_transaksi_non_tunai_harian view format', () {
      final json = {
        'tanggal': '2026-09-23',
        'jumlah_transaksi': 4,
        'total_nilai': '12500000.00',
      };

      final model = TransaksiNonTunaiHarian.fromJson(json);
      expect(model.tanggal.year, 2026);
      expect(model.tanggal.month, 9);
      expect(model.tanggal.day, 23);
      expect(model.jumlahTransaksi, 4);
      expect(model.totalNilai, Decimal.parse('12500000.00'));
    });
  });

  group('Bagian 24: TransaksiFormState', () {
    test('defaults to tunai and toggles correctly', () {
      final formState = TransaksiFormState(
        tanggalTransaksi: DateTime(2026, 9, 23),
        itemRows: [],
      );

      expect(formState.jenisPembayaran, 'tunai');
      expect(formState.isTunai, isTrue);
      expect(formState.isNonTunai, isFalse);

      final updatedState = formState.copyWith(jenisPembayaran: 'non_tunai');
      expect(updatedState.jenisPembayaran, 'non_tunai');
      expect(updatedState.isTunai, isFalse);
      expect(updatedState.isNonTunai, isTrue);
    });
  });

  group('Bagian 24: TransaksiFilterState & Notifier', () {
    test('supports filtering by jenisPembayaran (semua, tunai, non_tunai)', () {
      final notifier = TransaksiFilterNotifier();
      expect(notifier.state.jenisPembayaran, 'semua');
      expect(notifier.state.hasActiveFilter, isFalse);

      notifier.setJenisPembayaran('tunai');
      expect(notifier.state.jenisPembayaran, 'tunai');
      expect(notifier.state.hasActiveFilter, isTrue);
      expect(notifier.state.activeFilterCount, 1);

      notifier.setJenisPembayaran('non_tunai');
      expect(notifier.state.jenisPembayaran, 'non_tunai');
      expect(notifier.state.hasActiveFilter, isTrue);

      notifier.reset();
      expect(notifier.state.jenisPembayaran, 'semua');
      expect(notifier.state.hasActiveFilter, isFalse);
    });
  });

  group('Bagian 24: SaldoState Non Tunai Integration', () {
    test('calculates totalNilaiNonTunai correctly across nonTunaiHarianList', () {
      final state = SaldoState(
        ringkasan: SaldoRingkasan.zero(),
        topupList: const [],
        nonTunaiHarianList: [
          TransaksiNonTunaiHarian(
            tanggal: DateTime(2026, 9, 22),
            jumlahTransaksi: 2,
            totalNilai: Decimal.parse('5000000'),
          ),
          TransaksiNonTunaiHarian(
            tanggal: DateTime(2026, 9, 23),
            jumlahTransaksi: 3,
            totalNilai: Decimal.parse('8500000'),
          ),
        ],
      );

      expect(state.totalNilaiNonTunai, Decimal.parse('13500000'));
      expect(state.nonTunaiHarianList.length, 2);
    });
  });
}
