import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '../../../models/laporan_pendapatan.dart';

/// Generator file Excel (.xlsx) untuk Laporan Pendapatan & Laba Bersih (FR-7.8 & Bagian 21)
class LaporanPendapatanExcelGenerator {
  static String generateFileName({
    required CakupanLaporanPendapatan cakupan,
    required DateTime startDate,
    required DateTime endDate,
    String extension = 'xlsx',
  }) {
    final dateFormat = DateFormat('yyyyMMdd');
    final s = dateFormat.format(startDate);
    final e = dateFormat.format(endDate);
    final rangePart = (s == e) ? s : '${s}_$e';
    final cakupanStr = cakupan.name;

    return 'Laporan-Pendapatan-$cakupanStr-$rangePart.$extension';
  }

  static Uint8List generate({
    required LaporanPendapatanData data,
  }) {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
    excel.rename(defaultSheet, 'Laporan Pendapatan');
    final sheet = excel['Laporan Pendapatan'];

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#0F62FE'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final titleStyle = CellStyle(
      bold: true,
      fontSize: 14,
      fontColorHex: ExcelColor.fromHexString('#161616'),
    );

    final totalStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#E0E0E0'),
      fontColorHex: ExcelColor.fromHexString('#161616'),
    );

    // 1. Header Judul & Metadata
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      ..value = TextCellValue('LAPORAN PENDAPATAN & LABA BERSIH')
      ..cellStyle = titleStyle;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).value =
        TextCellValue('Cakupan Periode: ${data.cakupan.label} (${data.judulCakupan})');

    final dateRangeStr =
        '${DateFormat('d MMMM yyyy', 'id_ID').format(data.startDate)} s/d ${DateFormat('d MMMM yyyy', 'id_ID').format(data.endDate)}';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).value =
        TextCellValue('Rentang Tanggal: $dateRangeStr');

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3)).value =
        TextCellValue(
            'Waktu Cetak: ${DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(DateTime.now())} WIB');

    // 2. Baris Header Tabel (Row 5)
    final headers = [
      'No',
      'Periode',
      'Total Pembelian (Rp)',
      'Total Penjualan (Rp)',
      'Margin (Rp)',
      'Total Pengeluaran (Rp)',
      'Laba Bersih (Rp)',
    ];

    for (var col = 0; col < headers.length; col++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 5))
        ..value = TextCellValue(headers[col])
        ..cellStyle = headerStyle;
    }

    // 3. Baris Data (Row 6 s/d N)
    var currentRow = 6;
    for (var i = 0; i < data.rows.length; i++) {
      final row = data.rows[i];
      final beli = double.tryParse(row.totalPembelian.toString()) ?? 0.0;
      final jual = double.tryParse(row.totalPenjualan.toString()) ?? 0.0;
      final margin = double.tryParse(row.margin.toString()) ?? 0.0;
      final pengeluaran =
          double.tryParse(row.totalPengeluaran.toString()) ?? 0.0;
      final labaBersih = double.tryParse(row.labaBersih.toString()) ?? 0.0;

      final rowValues = [
        IntCellValue(i + 1),
        TextCellValue(row.periodeLabel),
        DoubleCellValue(beli),
        DoubleCellValue(jual),
        DoubleCellValue(margin),
        DoubleCellValue(pengeluaran),
        DoubleCellValue(labaBersih),
      ];

      for (var col = 0; col < rowValues.length; col++) {
        sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: currentRow,
        )).value = rowValues[col];
      }
      currentRow++;
    }

    // 4. Baris Total Keseluruhan
    final grandBeli =
        double.tryParse(data.grandTotalPembelian.toString()) ?? 0.0;
    final grandJual =
        double.tryParse(data.grandTotalPenjualan.toString()) ?? 0.0;
    final grandMargin =
        double.tryParse(data.grandTotalMargin.toString()) ?? 0.0;
    final grandPengeluaran =
        double.tryParse(data.grandTotalPengeluaran.toString()) ?? 0.0;
    final grandLabaBersih =
        double.tryParse(data.grandTotalLabaBersih.toString()) ?? 0.0;

    final totalValues = [
      TextCellValue(''),
      TextCellValue('Total Keseluruhan'),
      DoubleCellValue(grandBeli),
      DoubleCellValue(grandJual),
      DoubleCellValue(grandMargin),
      DoubleCellValue(grandPengeluaran),
      DoubleCellValue(grandLabaBersih),
    ];

    for (var col = 0; col < totalValues.length; col++) {
      sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: col,
        rowIndex: currentRow,
      ))
        ..value = totalValues[col]
        ..cellStyle = totalStyle;
    }

    // Atur lebar kolom
    sheet.setColumnWidth(0, 8.0);
    sheet.setColumnWidth(1, 30.0);
    sheet.setColumnWidth(2, 22.0);
    sheet.setColumnWidth(3, 22.0);
    sheet.setColumnWidth(4, 20.0);
    sheet.setColumnWidth(5, 22.0);
    sheet.setColumnWidth(6, 22.0);

    final fileBytes = excel.encode();
    return Uint8List.fromList(fileBytes ?? []);
  }
}
