import 'dart:typed_data';
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/percentage_formatter.dart';
import '../../../core/utils/weight_formatter.dart';
import '../../../models/laporan_export_item.dart';

/// Generator laporan riwayat transaksi pembelian dalam format dokumen PDF (.pdf)
/// Menghasilkan 1 baris per jenis buah per transaksi dengan 11 kolom dan baris total di akhir (FR-7.2, FR-7.3, Tugas Bagian 14).
class LaporanPdfGenerator {
  /// Menghasilkan nama file standar PDF dengan rentang tanggal
  static String generateFileName({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    String rangePart;

    if (startDate != null && endDate != null) {
      final s = dateFormat.format(startDate);
      final e = dateFormat.format(endDate);
      rangePart = (s == e) ? s : '$s-sd-$e';
    } else if (startDate != null) {
      rangePart = 'sejak-${dateFormat.format(startDate)}';
    } else if (endDate != null) {
      rangePart = 'hingga-${dateFormat.format(endDate)}';
    } else {
      rangePart = 'Semua-Periode';
    }

    return 'Laporan-Transaksi-$rangePart.pdf';
  }

  /// Membuat byte array dokumen PDF dari daftar item detail pembelian
  static Future<Uint8List> generate({
    required List<LaporanPembelianItem> items,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = pw.Document();

    // Hitung total akumulasi angka
    var totalBeratKotor = Decimal.zero;
    var totalPotonganKg = Decimal.zero;
    var totalBeratBersih = Decimal.zero;
    var totalSubtotal = Decimal.zero;

    for (final item in items) {
      totalBeratKotor += item.beratKotorKg;
      totalPotonganKg += item.potonganKg;
      totalBeratBersih += item.beratBersihKg;
      totalSubtotal += item.subtotal;
    }

    final dateRangeStr = (startDate != null && endDate != null)
        ? '${DateFormat('d MMM yyyy', 'id_ID').format(startDate)} s/d ${DateFormat('d MMM yyyy', 'id_ID').format(endDate)}'
        : 'Semua Periode Tanggal';

    // 12 Kolom sesuai FR-7.2 & FR-3.8
    final tableHeaders = [
      'No',
      'Kode Trx',
      'Tanggal',
      'Nama Penjual',
      'Bayar',
      'Jenis Buah',
      'Harga/kg',
      'Berat Kotor',
      'Potongan',
      'Pot. (kg)',
      'Berat Bersih',
      'Subtotal',
    ];

    final tableData = <List<String>>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final bayarLabel = item.jenisPembayaranLabel;
      tableData.add([
        (i + 1).toString(),
        item.kodeTransaksi,
        DateFormat('dd/MM/yy').format(item.tanggalTransaksi),
        item.namaPenjual,
        bayarLabel,
        item.jenisBuah,
        CurrencyFormatter.format(item.hargaPerKg),
        WeightFormatter.format(item.beratKotorKg),
        PercentageFormatter.format(item.persentasePotongan),
        WeightFormatter.format(item.potonganKg),
        WeightFormatter.format(item.beratBersihKg),
        CurrencyFormatter.format(item.subtotal),
      ]);
    }

    final columnWidths = <int, pw.TableColumnWidth>{
      0: const pw.FixedColumnWidth(22), // No
      1: const pw.FlexColumnWidth(1.4), // Kode Trx
      2: const pw.FlexColumnWidth(0.9), // Tanggal
      3: const pw.FlexColumnWidth(1.9), // Nama Penjual
      4: const pw.FlexColumnWidth(1.0), // Bayar (Tunai/Non Tunai)
      5: const pw.FlexColumnWidth(1.3), // Jenis Buah
      6: const pw.FlexColumnWidth(1.1), // Harga/kg
      7: const pw.FlexColumnWidth(1.2), // Berat Kotor
      8: const pw.FlexColumnWidth(0.8), // Potongan %
      9: const pw.FlexColumnWidth(1.1), // Potongan kg
      10: const pw.FlexColumnWidth(1.2), // Berat Bersih
      11: const pw.FlexColumnWidth(1.6), // Subtotal
    };

    final cellAlignments = <int, pw.Alignment>{
      0: pw.Alignment.center,
      1: pw.Alignment.centerLeft,
      2: pw.Alignment.center,
      3: pw.Alignment.centerLeft,
      4: pw.Alignment.center,
      5: pw.Alignment.centerLeft,
      6: pw.Alignment.centerRight,
      7: pw.Alignment.centerRight,
      8: pw.Alignment.centerRight,
      9: pw.Alignment.centerRight,
      10: pw.Alignment.centerRight,
      11: pw.Alignment.centerRight,
    };

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        maxPages: 1000,
        header: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 10),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'LAPORAN DETAIL TRANSAKSI PEMBELIAN TBS SAWIT',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('0F62FE'), // IBM Blue
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Rincian per jenis buah per transaksi dengan kalkulasi potongan dan berat bersih',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Periode: $dateRangeStr',
                      style: pw.TextStyle(
                        fontSize: 9.5,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Total Baris: ${items.length} item',
                      style: const pw.TextStyle(
                        fontSize: 8.5,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      'Dicetak: ${DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(DateTime.now())} WIB',
                      style: const pw.TextStyle(
                        fontSize: 8.5,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        footer: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Aplikasi Transaksi TBS Sawit | Dokumen Resmi',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ],
            ),
          );
        },
        build: (context) => [
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: tableHeaders,
            data: tableData,
            columnWidths: columnWidths,
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            headerStyle: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(
              color: PdfColor.fromHex('0F62FE'),
            ),
            cellStyle: const pw.TextStyle(fontSize: 7.5),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: cellAlignments,
            headerAlignments: cellAlignments,
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3.5),
            rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
            oddRowDecoration: pw.BoxDecoration(color: PdfColor.fromHex('F4F4F4')),
          ),
          // Baris Total Keseluruhan (Tabel Total dengan lebar kolom identik)
          pw.Table(
            columnWidths: columnWidths,
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.7),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('E0E0E0'),
                ),
                children: [
                  // Col 0 s/d 6: Label TOTAL
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text(
                      'TOTAL',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Container(),
                  pw.Container(),
                  pw.Container(),
                  pw.Container(),
                  pw.Container(),
                  pw.Container(),
                  // Col 7: Total Berat Kotor
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      WeightFormatter.format(totalBeratKotor),
                      style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  // Col 8: Potongan % (dash)
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                    alignment: pw.Alignment.center,
                    child: pw.Text('-', style: const pw.TextStyle(fontSize: 7.5)),
                  ),
                  // Col 9: Total Potongan (kg)
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      WeightFormatter.format(totalPotonganKg),
                      style: pw.TextStyle(
                        fontSize: 7.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red700,
                      ),
                    ),
                  ),
                  // Col 10: Total Berat Bersih
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      WeightFormatter.format(totalBeratBersih),
                      style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  // Col 11: Total Subtotal
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      CurrencyFormatter.format(totalSubtotal),
                      style: pw.TextStyle(
                        fontSize: 7.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('0F62FE'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
