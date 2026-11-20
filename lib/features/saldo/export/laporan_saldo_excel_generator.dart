import 'dart:typed_data';
import 'package:decimal/decimal.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '../../../models/saldo_ringkasan.dart';
import '../../../models/topup_saldo.dart';
import '../saldo_repository.dart';

/// Generator Laporan Saldo / Dana Modal format Excel (.xlsx) (FR-10.9).
/// Memuat: (a) Ringkasan atas, (b) Rincian Top Up, (c) Rincian Transaksi Pembelian pengurang saldo.
class LaporanSaldoExcelGenerator {
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

    return 'Laporan-Saldo-Dana-Modal-$rangePart.$extension';
  }

  static Uint8List generate({
    required SaldoRingkasan ringkasan,
    required List<TopupSaldo> topupItems,
    required List<PembelianPengurangSaldo> pembelianItems,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
    excel.rename(defaultSheet, 'Laporan Saldo Modal');
    final sheet = excel['Laporan Saldo Modal'];

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#0F62FE'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final subHeaderStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#393939'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      horizontalAlign: HorizontalAlign.Left,
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
      ..value = TextCellValue('LAPORAN SALDO / DANA MODAL OPERASIONAL')
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
      periodeText = 'Periode: Semua Riwayat Saldo & Transaksi';
    }

    sheet.cell(CellIndex.indexByString('A2')).value = TextCellValue(periodeText);
    sheet.cell(CellIndex.indexByString('A3')).value = TextCellValue(
      'Tanggal Cetak: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())} WIB',
    );

    // 2. Bagian (a): Ringkasan Saldo di bagian atas (FR-10.9)
    sheet.cell(CellIndex.indexByString('A5'))
      ..value = TextCellValue('A. RINGKASAN SALDO & MODAL')
      ..cellStyle = subHeaderStyle;

    sheet.cell(CellIndex.indexByString('A6')).value = TextCellValue('Total Top Up Dana Modal');
    sheet.cell(CellIndex.indexByString('B6'))
      ..value = TextCellValue(currencyFormat.format(double.tryParse(ringkasan.totalTopup.toString()) ?? 0))
      ..cellStyle = CellStyle(bold: true);

    sheet.cell(CellIndex.indexByString('A7')).value = TextCellValue('Total Pembelian Terpakai (Selesai)');
    sheet.cell(CellIndex.indexByString('B7'))
      ..value = TextCellValue(currencyFormat.format(double.tryParse(ringkasan.totalPemakaian.toString()) ?? 0))
      ..cellStyle = CellStyle(bold: true);

    sheet.cell(CellIndex.indexByString('A8')).value = TextCellValue('Sisa Saldo Kas Modal');
    sheet.cell(CellIndex.indexByString('B8'))
      ..value = TextCellValue(currencyFormat.format(double.tryParse(ringkasan.sisaSaldo.toString()) ?? 0))
      ..cellStyle = CellStyle(
        bold: true,
        fontColorHex: ringkasan.isLowOrExhausted
            ? ExcelColor.fromHexString('#DA1E28')
            : ExcelColor.fromHexString('#198038'),
      );

    // 3. Bagian (b): Rincian Top Up dalam periode (FR-10.9)
    var curRow = 10;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: curRow))
      ..value = TextCellValue('B. RINCIAN TOP UP DANA MODAL')
      ..cellStyle = subHeaderStyle;
    curRow++;

    final topupHeaders = ['No', 'Tanggal', 'Nominal (Rp)', 'Keterangan'];
    for (var col = 0; col < topupHeaders.length; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: curRow),
      );
      cell.value = TextCellValue(topupHeaders[col]);
      cell.cellStyle = headerStyle;
    }
    curRow++;

    var sumTopupPeriod = Decimal.zero;
    if (topupItems.isEmpty) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: curRow))
        ..value = TextCellValue('Tidak ada data top up pada periode ini.')
        ..cellStyle = CellStyle(italic: true);
      curRow++;
    } else {
      for (var i = 0; i < topupItems.length; i++) {
        final item = topupItems[i];
        sumTopupPeriod += item.nominal;

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: curRow))
          ..value = IntCellValue(i + 1)
          ..cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Center);

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: curRow))
          ..value = TextCellValue(dateFormat.format(item.tanggal))
          ..cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Center);

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: curRow))
          ..value = TextCellValue(currencyFormat.format(double.tryParse(item.nominal.toString()) ?? 0))
          ..cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Right);

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: curRow)).value =
            TextCellValue(item.keterangan ?? '-');

        curRow++;
      }

      // Baris Total Top Up Periode
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: curRow))
        ..value = TextCellValue('TOTAL TOP UP PERIODE')
        ..cellStyle = totalStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: curRow)).cellStyle =
          totalStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: curRow))
        ..value = TextCellValue(currencyFormat.format(double.tryParse(sumTopupPeriod.toString()) ?? 0))
        ..cellStyle = totalStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: curRow)).cellStyle =
          totalStyle;
      curRow += 2;
    }

    // 4. Bagian (c): Rincian Transaksi Pembelian yang Mengurangi Saldo (FR-10.9)
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: curRow))
      ..value = TextCellValue('C. RINCIAN TRANSAKSI PEMBELIAN PENGURANG SALDO')
      ..cellStyle = subHeaderStyle;
    curRow++;

    final pembelianHeaders = ['No', 'Tanggal', 'Kode Transaksi', 'Petani / Penjual', 'Total Nilai (Rp)'];
    for (var col = 0; col < pembelianHeaders.length; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: curRow),
      );
      cell.value = TextCellValue(pembelianHeaders[col]);
      cell.cellStyle = headerStyle;
    }
    curRow++;

    var sumPembelianPeriod = Decimal.zero;
    if (pembelianItems.isEmpty) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: curRow))
        ..value = TextCellValue('Tidak ada transaksi pembelian berstatus selesai pada periode ini.')
        ..cellStyle = CellStyle(italic: true);
      curRow++;
    } else {
      for (var i = 0; i < pembelianItems.length; i++) {
        final trx = pembelianItems[i];
        sumPembelianPeriod += trx.nominal;

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: curRow))
          ..value = IntCellValue(i + 1)
          ..cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Center);

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: curRow))
          ..value = TextCellValue(dateFormat.format(trx.tanggal))
          ..cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Center);

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: curRow)).value =
            TextCellValue(trx.kodeTransaksi);

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: curRow)).value =
            TextCellValue(trx.namaPenjual);

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: curRow))
          ..value = TextCellValue(currencyFormat.format(double.tryParse(trx.nominal.toString()) ?? 0))
          ..cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Right);

        curRow++;
      }

      // Baris Total Pembelian Periode
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: curRow))
        ..value = TextCellValue('TOTAL PEMBELIAN PERIODE')
        ..cellStyle = totalStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: curRow)).cellStyle =
          totalStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: curRow)).cellStyle =
          totalStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: curRow)).cellStyle =
          totalStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: curRow))
        ..value = TextCellValue(currencyFormat.format(double.tryParse(sumPembelianPeriod.toString()) ?? 0))
        ..cellStyle = totalStyle;
    }

    // Set Column widths
    sheet.setColumnWidth(0, 8);
    sheet.setColumnWidth(1, 15);
    sheet.setColumnWidth(2, 22);
    sheet.setColumnWidth(3, 30);
    sheet.setColumnWidth(4, 25);

    final bytes = excel.encode();
    return Uint8List.fromList(bytes ?? []);
  }
}
