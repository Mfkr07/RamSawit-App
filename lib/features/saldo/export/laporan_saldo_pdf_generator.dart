import 'dart:typed_data';
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/utils/currency_formatter.dart';
import '../../../models/saldo_ringkasan.dart';
import '../../../models/topup_saldo.dart';
import '../saldo_repository.dart';

/// Generator Laporan Saldo / Dana Modal format PDF (.pdf) (FR-10.9).
/// Memuat: (a) Ringkasan atas, (b) Rincian Top Up, (c) Rincian Transaksi Pembelian pengurang saldo.
class LaporanSaldoPdfGenerator {
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

    return 'Laporan-Saldo-Dana-Modal-$rangePart.pdf';
  }

  static Future<Uint8List> generate({
    required SaldoRingkasan ringkasan,
    required List<TopupSaldo> topupItems,
    required List<PembelianPengurangSaldo> pembelianItems,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = pw.Document();

    final dateRangeStr = (startDate != null && endDate != null)
        ? '${DateFormat('d MMM yyyy', 'id_ID').format(startDate)} s/d ${DateFormat('d MMM yyyy', 'id_ID').format(endDate)}'
        : 'Semua Periode Tanggal';

    final dateFormat = DateFormat('dd/MM/yyyy');

    var sumTopupPeriod = Decimal.zero;
    for (final t in topupItems) {
      sumTopupPeriod += t.nominal;
    }

    var sumPembelianPeriod = Decimal.zero;
    for (final p in pembelianItems) {
      sumPembelianPeriod += p.nominal;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        maxPages: 1000,
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'LAPORAN SALDO / DANA MODAL OPERASIONAL',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.Text(
                    'Aplikasi Kasir Sawit',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Periode: $dateRangeStr',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
              ),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 8),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Dicetak pada: ${DateFormat('d MMM yyyy HH:mm', 'id_ID').format(DateTime.now())} WIB',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
              pw.Text(
                'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            // 1. Kotak Ringkasan Saldo (Bagian a)
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'RINGKASAN SALDO & DANA MODAL',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Total Top Up Modal', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            CurrencyFormatter.format(ringkasan.totalTopup),
                            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Total Pemakaian (Pembelian Selesai)', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            CurrencyFormatter.format(ringkasan.totalPemakaian),
                            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Sisa Saldo Kas Modal', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            CurrencyFormatter.format(ringkasan.sisaSaldo),
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: ringkasan.isLowOrExhausted ? PdfColors.red800 : PdfColors.green800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // 2. Bagian (b): Rincian Top Up dalam Periode
            pw.Text(
              'Rincian Top Up Dana Modal (${topupItems.length} Catatan)',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
            ),
            pw.SizedBox(height: 6),
            topupItems.isEmpty
                ? pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 8),
                    child: pw.Text('Tidak ada top up pada periode ini.', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                  )
                : pw.TableHelper.fromTextArray(
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                    headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                    headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
                    cellStyle: const pw.TextStyle(fontSize: 8),
                    cellAlignment: pw.Alignment.centerLeft,
                    columnWidths: {
                      0: const pw.FixedColumnWidth(25),
                      1: const pw.FixedColumnWidth(65),
                      2: const pw.FixedColumnWidth(95),
                      3: const pw.FlexColumnWidth(),
                    },
                    headers: ['No', 'Tanggal', 'Nominal (Rp)', 'Keterangan'],
                    data: [
                      ...topupItems.asMap().entries.map((e) {
                        return [
                          '${e.key + 1}',
                          dateFormat.format(e.value.tanggal),
                          CurrencyFormatter.format(e.value.nominal),
                          e.value.keterangan ?? '-',
                        ];
                      }),
                      [
                        'TOTAL',
                        '',
                        CurrencyFormatter.format(sumTopupPeriod),
                        '',
                      ],
                    ],
                  ),
            pw.SizedBox(height: 16),

            // 3. Bagian (c): Rincian Transaksi Pembelian Pengurang Saldo
            pw.Text(
              'Rincian Transaksi Pembelian Pengurang Saldo (${pembelianItems.length} Transaksi)',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
            ),
            pw.SizedBox(height: 6),
            pembelianItems.isEmpty
                ? pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 8),
                    child: pw.Text('Tidak ada transaksi pembelian berstatus selesai pada periode ini.', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                  )
                : pw.TableHelper.fromTextArray(
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                    headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                    headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
                    cellStyle: const pw.TextStyle(fontSize: 8),
                    cellAlignment: pw.Alignment.centerLeft,
                    columnWidths: {
                      0: const pw.FixedColumnWidth(25),
                      1: const pw.FixedColumnWidth(60),
                      2: const pw.FixedColumnWidth(95),
                      3: const pw.FlexColumnWidth(),
                      4: const pw.FixedColumnWidth(95),
                    },
                    headers: ['No', 'Tanggal', 'Kode Transaksi', 'Petani / Penjual', 'Total Nilai (Rp)'],
                    data: [
                      ...pembelianItems.asMap().entries.map((e) {
                        return [
                          '${e.key + 1}',
                          dateFormat.format(e.value.tanggal),
                          e.value.kodeTransaksi,
                          e.value.namaPenjual,
                          CurrencyFormatter.format(e.value.nominal),
                        ];
                      }),
                      [
                        'TOTAL',
                        '',
                        '',
                        '',
                        CurrencyFormatter.format(sumPembelianPeriod),
                      ],
                    ],
                  ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}
