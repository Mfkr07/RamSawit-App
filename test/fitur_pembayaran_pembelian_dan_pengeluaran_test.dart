import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaksi_sawit_app/features/dashboard/dashboard_repository.dart';
import 'package:transaksi_sawit_app/features/dashboard/widgets/chart_breakdown_pembayaran.dart';
import 'package:transaksi_sawit_app/features/pengeluaran/pengeluaran_repository.dart';
import 'package:transaksi_sawit_app/models/dashboard_analytics.dart';
import 'package:transaksi_sawit_app/models/pengeluaran.dart';

void main() {
  group('Fitur 1: Pie Chart Pembelian Tunai dan Non Tunai', () {
    test('Model BreakdownMetodePembayaran serialization & helpers', () {
      final json = {
        'metode': 'tunai',
        'jumlah_transaksi': 15,
        'total_nilai': '45000000',
        'total_berat_bersih_kg': '18000',
      };

      final model = BreakdownMetodePembayaran.fromJson(json);
      expect(model.metode, 'tunai');
      expect(model.isTunai, isTrue);
      expect(model.isNonTunai, isFalse);
      expect(model.jumlahTransaksi, 15);
      expect(model.totalNilai, Decimal.parse('45000000'));
      expect(model.totalBeratBersihKg, Decimal.parse('18000'));
      expect(model.label, 'Tunai (Cash)');

      final outJson = model.toJson();
      expect(outJson['metode'], 'tunai');
      expect(outJson['jumlah_transaksi'], 15);
      expect(outJson['total_nilai'], '45000000');
    });

    test('DashboardRepository.getBreakdownMetodePembayaran demo calculation', () async {
      final repo = DashboardRepository(null, 'admin');
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 30));

      final result = await repo.getBreakdownMetodePembayaran(start, now);
      expect(result.length, 2);

      final tunai = result.firstWhere((r) => r.isTunai);
      final nonTunai = result.firstWhere((r) => r.isNonTunai);

      expect(tunai.isTunai, isTrue);
      expect(nonTunai.isNonTunai, isTrue);
      expect(tunai.totalNilai >= Decimal.zero, isTrue);
      expect(nonTunai.totalNilai >= Decimal.zero, isTrue);
    });

    testWidgets('ChartBreakdownPembayaranSection renders legend and donut accurately', (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockData = [
        BreakdownMetodePembayaran(
          metode: 'tunai',
          jumlahTransaksi: 10,
          totalNilai: Decimal.parse('25000000'),
          totalBeratBersihKg: Decimal.parse('10000'),
        ),
        BreakdownMetodePembayaran(
          metode: 'non_tunai',
          jumlahTransaksi: 5,
          totalNilai: Decimal.parse('15000000'),
          totalBeratBersihKg: Decimal.parse('6000'),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ChartBreakdownPembayaranSection(data: mockData),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('METODE PEMBAYARAN PEMBELIAN'), findsOneWidget);
      expect(find.textContaining('Tunai (Cash)'), findsOneWidget);
      expect(find.textContaining('Non Tunai (Transfer)'), findsOneWidget);
      expect(find.textContaining('10 TRX'), findsOneWidget);
      expect(find.textContaining('5 TRX'), findsOneWidget);
    });
  });

  group('Fitur 2: Field Metode Pembayaran pada Modul Pengeluaran', () {
    test('Model Pengeluaran default to tunai and supports non_tunai', () {
      final pengeluaranTunai = Pengeluaran(
        id: 'exp-1',
        tanggalPengeluaran: DateTime.now(),
        jenisPengeluaranId: 1,
        nominal: Decimal.parse('100000'),
      );
      expect(pengeluaranTunai.metodePembayaran, 'tunai');
      expect(pengeluaranTunai.isTunai, isTrue);
      expect(pengeluaranTunai.isNonTunai, isFalse);

      final pengeluaranNonTunai = pengeluaranTunai.copyWith(
        metodePembayaran: 'non_tunai',
      );
      expect(pengeluaranNonTunai.metodePembayaran, 'non_tunai');
      expect(pengeluaranNonTunai.isNonTunai, isTrue);
      expect(pengeluaranNonTunai.isTunai, isFalse);

      final json = pengeluaranNonTunai.toJson();
      expect(json['metode_pembayaran'], 'non_tunai');

      final parsed = Pengeluaran.fromJson(json);
      expect(parsed.metodePembayaran, 'non_tunai');
      expect(parsed.isNonTunai, isTrue);
    });

    test('PengeluaranRepository creates and updates with metodePembayaran', () async {
      final repo = PengeluaranRepository(null);

      // 1. Create pengeluaran non_tunai
      final created = await repo.createPengeluaran(
        tanggal: DateTime.now(),
        jenisPengeluaranId: 1,
        nominal: Decimal.parse('500000'),
        keterangan: 'Beli solar via transfer Mandiri',
        metodePembayaran: 'non_tunai',
      );

      expect(created.metodePembayaran, 'non_tunai');
      expect(created.isNonTunai, isTrue);

      // 2. Update to tunai
      final updated = await repo.updatePengeluaran(
        created.id,
        tanggal: created.tanggalPengeluaran,
        jenisPengeluaranId: created.jenisPengeluaranId,
        nominal: created.nominal,
        keterangan: 'Diubah jadi bayar tunai',
        metodePembayaran: 'tunai',
      );

      expect(updated.metodePembayaran, 'tunai');
      expect(updated.isTunai, isTrue);
    });
  });
}
