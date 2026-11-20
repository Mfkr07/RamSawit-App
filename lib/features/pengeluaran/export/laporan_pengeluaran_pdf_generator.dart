import 'dart:typed_data';
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/utils/currency_formatter.dart';
import '../../../models/pengeluaran.dart';

/// Generator laporan riwayat pengeluaran operasional format PDF (.pdf) (FR-9.6).
class LaporanPengeluaranPdfGenerator {
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

    return 'Laporan-Pengeluaran-$rangePart.pdf';
  }

  static Future<Uint8List> generate({
    required List<Pengeluaran> items,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = pw.Document();

    var totalNominal = Decimal.zero;
    for (final item in items) {
      totalNominal += item.nominal;
    }

    final dateRangeStr = (startDate != null && endDate != null)
        ? '${DateFormat('d MMM yyyy', 'id_ID').format(startDate)} s/d ${DateFormat('d MMM yyyy', 'id_ID').format(endDate)}'
        : 'Semua Periode Tanggal';

    final headers = [
      'No',
      'Tanggal',
      'Jenis Pengeluaran',
      'Keterangan',
      'Nominal (Rp)',
    ];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        maxPages: 1000,
        header: (context) => _buildHeader(dateRangeStr),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildSummaryCards(items.length, totalNominal),
          pw.SizedBox(height: 14),
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: List.generate(items.length, (index) {
              final item = items[index];
              return [
                (index + 1).toString(),
                DateFormat('dd/MM/yyyy').format(item.tanggalPengeluaran),
                item.jenisPengeluaranNama ?? '-',
                item.keterangan?.isNotEmpty == true ? item.keterangan! : '-',
                CurrencyFormatter.format(item.nominal),
              ];
            }),
            border: pw.TableBorder.all(
              color: PdfColors.grey300,
              width: 0.5,
            ),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF0F62FE), // IBM Blue
            ),
            cellHeight: 22,
            cellStyle: const pw.TextStyle(fontSize: 8.5),
            cellAlignments: {
              0: pw.Alignment.center,
              1: pw.Alignment.center,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerLeft,
              4: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: 10),
          _buildTotalSummary(items.length, totalNominal),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(String dateRangeStr) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColor.fromInt(0xFF0F62FE), width: 2),
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
                'LAPORAN PENCATATAN PENGELUARAN',
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFF0F62FE),
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Sistem Operasional Ram Kelapa Sawit Enterprise',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Periode: $dateRangeStr',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey900,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Dicetak: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())} WIB',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryCards(int count, Decimal totalNominal) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              color: PdfColors.grey100,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'TOTAL TRANSAKSI',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  '$count Catatan',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: const PdfColor.fromInt(0xFF0F62FE)),
              color: const PdfColor.fromInt(0xFFEDF5FF),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'TOTAL PENGELUARAN',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColor.fromInt(0xFF0F62FE),
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  CurrencyFormatter.format(totalNominal),
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFF0F62FE),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTotalSummary(int count, Decimal totalNominal) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
        color: PdfColors.grey100,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'TOTAL KESELURUHAN ($count CATATAN):',
            style: pw.TextStyle(
              fontSize: 9.5,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            CurrencyFormatter.format(totalNominal),
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFFDA1E28), // IBM Red
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 14),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Dokumen ini dicetak otomatis oleh Aplikasi Transaksi TBS Sawit',
            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey500),
          ),
          pw.Text(
            'Halaman ${context.pageNumber} dari ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }
}
