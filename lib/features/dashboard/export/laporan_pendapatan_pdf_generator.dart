import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/utils/currency_formatter.dart';
import '../../../models/laporan_pendapatan.dart';

/// Generator dokumen PDF (.pdf) untuk Laporan Pendapatan & Laba Bersih (FR-7.8 & Bagian 21)
class LaporanPendapatanPdfGenerator {
  static String generateFileName({
    required CakupanLaporanPendapatan cakupan,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final dateFormat = DateFormat('yyyyMMdd');
    final s = dateFormat.format(startDate);
    final e = dateFormat.format(endDate);
    final rangePart = (s == e) ? s : '${s}_$e';
    final cakupanStr = cakupan.name;

    return 'Laporan-Pendapatan-$cakupanStr-$rangePart.pdf';
  }

  static Future<Uint8List> generate({
    required LaporanPendapatanData data,
  }) async {
    final pdf = pw.Document();

    final dateRangeStr =
        '${DateFormat('d MMMM yyyy', 'id_ID').format(data.startDate)} s/d ${DateFormat('d MMMM yyyy', 'id_ID').format(data.endDate)}';
    final printTimeStr =
        '${DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(DateTime.now())} WIB';

    final tableHeaders = [
      'No',
      'Periode',
      'Total Beli (Rp)',
      'Total Jual (Rp)',
      'Margin (Rp)',
      'Pengeluaran (Rp)',
      'Laba Bersih (Rp)',
    ];

    final tableData = <List<String>>[];
    for (var i = 0; i < data.rows.length; i++) {
      final r = data.rows[i];
      tableData.add([
        '${i + 1}',
        r.periodeLabel,
        CurrencyFormatter.format(r.totalPembelian),
        CurrencyFormatter.format(r.totalPenjualan),
        CurrencyFormatter.format(r.margin),
        CurrencyFormatter.format(r.totalPengeluaran),
        CurrencyFormatter.format(r.labaBersih),
      ]);
    }

    final columnWidths = {
      0: const pw.FixedColumnWidth(25),
      1: const pw.FlexColumnWidth(2.2),
      2: const pw.FlexColumnWidth(1.6),
      3: const pw.FlexColumnWidth(1.6),
      4: const pw.FlexColumnWidth(1.5),
      5: const pw.FlexColumnWidth(1.6),
      6: const pw.FlexColumnWidth(1.6),
    };

    final cellAlignments = {
      0: pw.Alignment.center,
      1: pw.Alignment.centerLeft,
      2: pw.Alignment.centerRight,
      3: pw.Alignment.centerRight,
      4: pw.Alignment.centerRight,
      5: pw.Alignment.centerRight,
      6: pw.Alignment.centerRight,
    };

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        maxPages: 1000,
        header: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'LAPORAN PENDAPATAN & LABA BERSIH',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('161616'),
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Aplikasi Transaksi TBS Sawit Enterprise',
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColor.fromHex('525252'),
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('0F62FE'),
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(2),
                      ),
                    ),
                    child: pw.Text(
                      'CAKUPAN: ${data.cakupan.label.toUpperCase()}',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('F4F4F4'),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(2),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Detail Periode: ${data.judulCakupan}',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Rentang Tanggal: $dateRangeStr',
                            style: const pw.TextStyle(fontSize: 8.5),
                          ),
                        ],
                      ),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Waktu Cetak: $printTimeStr',
                          style: const pw.TextStyle(
                            fontSize: 8.5,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          data.cakupan.deskripsiPengelompokan,
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontStyle: pw.FontStyle.italic,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
            ],
          );
        },
        footer: (context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 12),
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
                  'Dokumen Resmi Keuangan | Transaksi TBS Sawit',
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
          pw.TableHelper.fromTextArray(
            headers: tableHeaders,
            data: tableData,
            columnWidths: columnWidths,
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            headerStyle: pw.TextStyle(
              fontSize: 8.0,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(
              color: PdfColor.fromHex('0F62FE'),
            ),
            cellStyle: const pw.TextStyle(fontSize: 7.5),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: cellAlignments,
            headerAlignments: {
              0: pw.Alignment.center,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.centerRight,
              6: pw.Alignment.centerRight,
            },
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
            rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
            oddRowDecoration: pw.BoxDecoration(color: PdfColor.fromHex('F8F9FA')),
          ),
          // Baris Total Keseluruhan
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
                    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    alignment: pw.Alignment.center,
                    child: pw.Text('-', style: const pw.TextStyle(fontSize: 7.5)),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text(
                      'TOTAL',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('161616'),
                      ),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      CurrencyFormatter.format(data.grandTotalPembelian),
                      style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      CurrencyFormatter.format(data.grandTotalPenjualan),
                      style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      CurrencyFormatter.format(data.grandTotalMargin),
                      style: pw.TextStyle(
                        fontSize: 7.5,
                        fontWeight: pw.FontWeight.bold,
                        color: data.isSurplus
                            ? PdfColor.fromHex('0F62FE')
                            : PdfColors.red700,
                      ),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      CurrencyFormatter.format(data.grandTotalPengeluaran),
                      style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      CurrencyFormatter.format(data.grandTotalLabaBersih),
                      style: pw.TextStyle(
                        fontSize: 7.5,
                        fontWeight: pw.FontWeight.bold,
                        color: data.isLabaBersihSurplus
                            ? PdfColor.fromHex('198038')
                            : PdfColors.red700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          // Catatan audit / ringkasan bawah
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Catatan: Margin = Penjualan - Pembelian | Laba Bersih = Margin - Pengeluaran',
                  style: pw.TextStyle(
                    fontSize: 7.5,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.Text(
                  'Status Laba Bersih: ${data.isLabaBersihSurplus ? "SURPLUS / PROFIT" : "DEFISIT"}',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: data.isLabaBersihSurplus
                        ? PdfColor.fromHex('198038')
                        : PdfColors.red700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
