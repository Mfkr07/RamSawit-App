import 'dart:typed_data';
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/percentage_formatter.dart';
import '../../../core/utils/weight_formatter.dart';
import '../../../models/pengiriman_pabrik.dart';

/// Generator laporan riwayat penjualan ke pabrik format PDF (.pdf)
/// Hanya menyertakan status 'selesai' (FR-7.7, FR-8.9, Tugas Bagian 14).
class LaporanPengirimanPdfGenerator {
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

    return 'Laporan-Penjualan-Pabrik-$rangePart.pdf';
  }

  static Future<Uint8List> generate({
    required List<PengirimanPabrik> items,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final filteredItems = items.where((item) => item.isSelesai).toList();

    final pdf = pw.Document();

    var totalDikirim = Decimal.zero;
    var totalSampai = Decimal.zero;
    var totalDitolak = Decimal.zero;
    var totalDiterima = Decimal.zero;
    var totalBersih = Decimal.zero;
    var totalSusut = Decimal.zero;
    var totalPotonganLainnya = Decimal.zero;
    var totalNilaiSortasi = Decimal.zero;
    var totalNilaiJual = Decimal.zero;

    for (final item in filteredItems) {
      totalDikirim += item.beratDikirimKg;
      totalSampai += item.beratSampaiKg ?? Decimal.zero;
      totalDitolak += item.beratDitolakKg ?? Decimal.zero;
      totalDiterima += item.beratDiterimaKg ?? Decimal.zero;
      totalBersih += item.beratBersihKg ?? Decimal.zero;
      totalSusut += item.susutBuahKg ?? Decimal.zero;
      totalPotonganLainnya += item.potonganLainnyaRp ?? Decimal.zero;
      totalNilaiSortasi += item.nilaiPotonganSortasiRp ?? Decimal.zero;
      totalNilaiJual += item.totalNilaiJual ?? Decimal.zero;
    }

    final dateRangeStr = (startDate != null && endDate != null)
        ? '${DateFormat('d MMM yyyy', 'id_ID').format(startDate)} s/d ${DateFormat('d MMM yyyy', 'id_ID').format(endDate)}'
        : 'Semua Periode Tanggal';

    final headers = [
      'No',
      'Kode KRM',
      'Tanggal',
      'Pabrik Tujuan',
      'Plat Nomor',
      'Sopir',
      'Dikirim',
      'Sampai',
      'Ditolak',
      'Diterima',
      'Pot.%',
      'Netto',
      'Susut',
      'Harga/kg',
      'Pot. Lain',
      'Sortasi/kg',
      'Nilai Sortasi',
      'Total Jual',
    ];

    final tableData = <List<String>>[];
    for (var i = 0; i < filteredItems.length; i++) {
      final item = filteredItems[i];
      tableData.add([
        (i + 1).toString(),
        item.kodePengiriman,
        DateFormat('dd/MM/yy').format(item.tanggalKirim),
        item.pabrik?.nama ?? '-',
        item.platNomor,
        item.namaSopir,
        WeightFormatter.format(item.beratDikirimKg),
        WeightFormatter.format(item.beratSampaiKg),
        WeightFormatter.format(item.beratDitolakKg),
        WeightFormatter.format(item.beratDiterimaKg),
        PercentageFormatter.format(item.persentasePotonganPabrik),
        WeightFormatter.format(item.beratBersihKg),
        WeightFormatter.format(item.susutBuahKg),
        CurrencyFormatter.format(item.hargaJualPerKg),
        CurrencyFormatter.format(item.potonganLainnyaRp),
        CurrencyFormatter.format(item.potonganSortasiPerKg),
        CurrencyFormatter.format(item.nilaiPotonganSortasiRp),
        CurrencyFormatter.format(item.totalNilaiJual),
      ]);
    }

    final columnWidths = <int, pw.TableColumnWidth>{
      0: const pw.FixedColumnWidth(16),  // No
      1: const pw.FlexColumnWidth(1.2),  // Kode KRM
      2: const pw.FlexColumnWidth(0.8),  // Tanggal
      3: const pw.FlexColumnWidth(1.3),  // Pabrik
      4: const pw.FlexColumnWidth(0.9),  // Plat
      5: const pw.FlexColumnWidth(1.0),  // Sopir
      6: const pw.FlexColumnWidth(0.9),  // Dikirim
      7: const pw.FlexColumnWidth(0.9),  // Sampai
      8: const pw.FlexColumnWidth(0.8),  // Ditolak
      9: const pw.FlexColumnWidth(0.9),  // Diterima
      10: const pw.FlexColumnWidth(0.7), // Pot%
      11: const pw.FlexColumnWidth(0.9), // Netto
      12: const pw.FlexColumnWidth(0.8), // Susut
      13: const pw.FlexColumnWidth(1.0), // Harga/kg
      14: const pw.FlexColumnWidth(1.0), // Pot. Lain
      15: const pw.FlexColumnWidth(0.9), // Sortasi/kg
      16: const pw.FlexColumnWidth(1.0), // Nilai Sortasi
      17: const pw.FlexColumnWidth(1.3), // Total Jual
    };

    final cellAlignments = <int, pw.Alignment>{
      0: pw.Alignment.center,
      1: pw.Alignment.centerLeft,
      2: pw.Alignment.center,
      3: pw.Alignment.centerLeft,
      4: pw.Alignment.centerLeft,
      5: pw.Alignment.centerLeft,
      6: pw.Alignment.centerRight,
      7: pw.Alignment.centerRight,
      8: pw.Alignment.centerRight,
      9: pw.Alignment.centerRight,
      10: pw.Alignment.centerRight,
      11: pw.Alignment.centerRight,
      12: pw.Alignment.centerRight,
      13: pw.Alignment.centerRight,
      14: pw.Alignment.centerRight,
      15: pw.Alignment.centerRight,
      16: pw.Alignment.centerRight,
      17: pw.Alignment.centerRight,
    };

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 20),
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
                      'LAPORAN PENJUALAN TBS KE PABRIK KELAPA SAWIT (PKS)',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('0F62FE'),
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Rekapitulasi Pengiriman TBS Status Selesai ke Mitra Pabrik',
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
                      'Total: ${filteredItems.length} Pengiriman Selesai',
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
                  'Aplikasi Transaksi TBS Sawit | Modul Penjualan Pabrik',
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
            headers: headers,
            data: tableData,
            columnWidths: columnWidths,
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            headerStyle: pw.TextStyle(
              fontSize: 8,
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
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 2.5, vertical: 3),
            rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
            oddRowDecoration: pw.BoxDecoration(color: PdfColor.fromHex('F4F4F4')),
          ),
          pw.Table(
            columnWidths: columnWidths,
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.7),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('E0E0E0'),
                ),
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                    child: pw.Text('TOTAL', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Container(),
                  pw.Container(),
                  pw.Container(),
                  pw.Container(),
                  pw.Container(),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 2.5, vertical: 5),
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(WeightFormatter.format(totalDikirim), style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 2.5, vertical: 5),
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(WeightFormatter.format(totalSampai), style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 2.5, vertical: 5),
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(WeightFormatter.format(totalDitolak), style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.red700)),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 2.5, vertical: 5),
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(WeightFormatter.format(totalDiterima), style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 2.5, vertical: 5),
                    alignment: pw.Alignment.center,
                    child: pw.Text('-', style: const pw.TextStyle(fontSize: 7)),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 2.5, vertical: 5),
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(WeightFormatter.format(totalBersih), style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 2.5, vertical: 5),
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(WeightFormatter.format(totalSusut), style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                  ),
                  // 13: Harga/kg (dash)
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 2.5, vertical: 5),
                    alignment: pw.Alignment.center,
                    child: pw.Text('-', style: const pw.TextStyle(fontSize: 7)),
                  ),
                  // 14: Pot. Lain
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 2.5, vertical: 5),
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(CurrencyFormatter.format(totalPotonganLainnya), style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                  ),
                  // 15: Sortasi/kg (dash)
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 2.5, vertical: 5),
                    alignment: pw.Alignment.center,
                    child: pw.Text('-', style: const pw.TextStyle(fontSize: 7)),
                  ),
                  // 16: Nilai Sortasi
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 2.5, vertical: 5),
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(CurrencyFormatter.format(totalNilaiSortasi), style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                  ),
                  // 17: Total Jual
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 2.5, vertical: 5),
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(CurrencyFormatter.format(totalNilaiJual), style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('0F62FE'))),
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
