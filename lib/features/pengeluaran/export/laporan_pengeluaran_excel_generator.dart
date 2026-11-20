import 'dart:typed_data';
import 'package:decimal/decimal.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '../../../models/pengeluaran.dart';

/// Generator laporan riwayat pengeluaran operasional format Excel (.xlsx) (FR-9.6).
class LaporanPengeluaranExcelGenerator {
  static String generateFileName({
    DateTime? startDate,
    DateTime? endDate,
    String extension = 'xlsx',
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

    return 'Laporan-Pengeluaran-$rangePart.$extension';
  }

  static Uint8List generate({
    required List<Pengeluaran> items,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
    excel.rename(defaultSheet, 'Laporan Pengeluaran');
    final sheet = excel['Laporan Pengeluaran'];

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

    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // 1. Judul & Metadata Periode
    sheet.cell(CellIndex.indexByString('A1'))
      ..value = TextCellValue('LAPORAN PENCATATAN PENGELUARAN OPERASIONAL')
      ..cellStyle = titleStyle;

    String periodeText;
    if (startDate != null && endDate != null) {
      periodeText =
          'Periode: ${dateFormat.format(startDate)} – ${dateFormat.format(endDate)}';
    } else if (startDate != null) {
      periodeText = 'Periode: Sejak ${dateFormat.format(startDate)}';
    } else if (endDate != null) {
      periodeText = 'Periode: Hingga ${dateFormat.format(endDate)}';
    } else {
      periodeText = 'Periode: Semua Riwayat Transaksi Pengeluaran';
    }

    sheet.cell(CellIndex.indexByString('A2')).value = TextCellValue(periodeText);
    sheet.cell(CellIndex.indexByString('A3')).value = TextCellValue(
      'Tanggal Cetak: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())} WIB',
    );

    // 2. Header Kolom
    final headers = [
      'No',
      'Tanggal',
      'Jenis Pengeluaran',
      'Keterangan',
      'Nominal (Rp)',
    ];

    for (var col = 0; col < headers.length; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 4),
      );
      cell.value = TextCellValue(headers[col]);
      cell.cellStyle = headerStyle;
    }

    // 3. Data Baris
    var rowIndex = 5;
    var totalNominal = Decimal.zero;

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      totalNominal += item.nominal;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        ..value = IntCellValue(i + 1)
        ..cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Center);

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        ..value = TextCellValue(dateFormat.format(item.tanggalPengeluaran))
        ..cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Center);

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        ..value = TextCellValue(item.jenisPengeluaranNama ?? '-')
        ..cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Left);

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
        ..value = TextCellValue(item.keterangan?.isNotEmpty == true ? item.keterangan! : '-')
        ..cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Left);

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
        ..value = TextCellValue(currencyFormat.format(double.parse(item.nominal.toString())))
        ..cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Right);

      rowIndex++;
    }

    // 4. Baris Total di Akhir (FR-9.6)
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
      ..value = TextCellValue('TOTAL')
      ..cellStyle = totalStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
      ..value = TextCellValue('')
      ..cellStyle = totalStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
      ..value = TextCellValue('')
      ..cellStyle = totalStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
      ..value = TextCellValue('${items.length} Transaksi')
      ..cellStyle = totalStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
      ..value = TextCellValue(currencyFormat.format(double.parse(totalNominal.toString())))
      ..cellStyle = totalStyle;

    return Uint8List.fromList(excel.encode()!);
  }
}
