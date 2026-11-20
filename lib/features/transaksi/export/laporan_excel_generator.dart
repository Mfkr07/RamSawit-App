import 'dart:typed_data';
import 'package:decimal/decimal.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '../../../models/laporan_export_item.dart';

/// Generator laporan riwayat transaksi pembelian dalam format Microsoft Excel (.xlsx)
/// Menghasilkan 1 baris per jenis buah per transaksi dengan 11 kolom dan baris total di akhir (FR-7.2, FR-7.6, Tugas Bagian 14).
class LaporanExcelGenerator {
  /// Menghasilkan nama file standar dengan rentang tanggal
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

    return 'Laporan-Transaksi-$rangePart.$extension';
  }

  /// Membuat byte array dokumen Excel dari daftar item pembelian detail
  static Uint8List generate({
    required List<LaporanPembelianItem> items,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
    excel.rename(defaultSheet, 'Laporan Pembelian TBS');
    final sheet = excel['Laporan Pembelian TBS'];

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#0F62FE'), // IBM Blue
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

    // 1. Judul & Metadata Laporan
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      ..value = TextCellValue('LAPORAN DETAIL TRANSAKSI PEMBELIAN TBS SAWIT')
      ..cellStyle = titleStyle;

    final dateRangeStr = (startDate != null && endDate != null)
        ? '${DateFormat('d MMMM yyyy', 'id_ID').format(startDate)} s/d ${DateFormat('d MMMM yyyy', 'id_ID').format(endDate)}'
        : 'Semua Periode Tanggal';

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).value =
        TextCellValue('Periode: $dateRangeStr');

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).value =
        TextCellValue(
            'Waktu Cetak: ${DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(DateTime.now())} WIB');

    // 2. Baris Header Tabel (Row 4) - 12 Kolom sesuai FR-7.2 & FR-3.8
    final headers = [
      'No',
      'Kode Transaksi',
      'Tanggal',
      'Nama Penjual',
      'Jenis Pembayaran',
      'Jenis Buah',
      'Harga / kg (Rp)',
      'Berat Kotor (kg)',
      'Potongan (%)',
      'Potongan (kg)',
      'Berat Bersih (kg)',
      'Subtotal (Rp)',
    ];

    for (var col = 0; col < headers.length; col++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 4))
        ..value = TextCellValue(headers[col])
        ..cellStyle = headerStyle;
    }

    // 3. Baris Data Transaksi (Row 5 s/d N)
    var totalBeratKotor = Decimal.zero;
    var totalPotonganKg = Decimal.zero;
    var totalBeratBersih = Decimal.zero;
    var totalSubtotal = Decimal.zero;

    var currentRow = 5;
    for (var i = 0; i < items.length; i++) {
      final item = items[i];

      totalBeratKotor += item.beratKotorKg;
      totalPotonganKg += item.potonganKg;
      totalBeratBersih += item.beratBersihKg;
      totalSubtotal += item.subtotal;

      final jenisBayarLabel = item.jenisPembayaranLabel;

      final rowValues = [
        IntCellValue(i + 1),
        TextCellValue(item.kodeTransaksi),
        TextCellValue(DateFormat('yyyy-MM-dd').format(item.tanggalTransaksi)),
        TextCellValue(item.namaPenjual),
        TextCellValue(jenisBayarLabel),
        TextCellValue(item.jenisBuah),
        DoubleCellValue(double.tryParse(item.hargaPerKg.toString()) ?? 0.0),
        DoubleCellValue(double.tryParse(item.beratKotorKg.toString()) ?? 0.0),
        DoubleCellValue(double.tryParse(item.persentasePotongan.toString()) ?? 0.0),
        DoubleCellValue(double.tryParse(item.potonganKg.toString()) ?? 0.0),
        DoubleCellValue(double.tryParse(item.beratBersihKg.toString()) ?? 0.0),
        DoubleCellValue(double.tryParse(item.subtotal.toString()) ?? 0.0),
      ];

      for (var col = 0; col < rowValues.length; col++) {
        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: col, rowIndex: currentRow))
          .value = rowValues[col];
      }
      currentRow++;
    }

    // 4. Baris Total Keseluruhan (Row currentRow)
    // Kolom-kolom angka yang ditotalkan: Berat Kotor, Potongan (kg), Berat Bersih, Subtotal (Rp)
    // Indeks kolom:
    // 0: No, 1: Kode, 2: Tanggal, 3: Penjual, 4: Jenis Pembayaran, 5: Jenis Buah,
    // 6: Harga/kg, 7: Berat Kotor, 8: Potongan %, 9: Potongan kg, 10: Berat Bersih, 11: Subtotal
    final totalRowCells = [
      TextCellValue('TOTAL KESELURUHAN'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      DoubleCellValue(double.tryParse(totalBeratKotor.toString()) ?? 0.0),
      TextCellValue('-'),
      DoubleCellValue(double.tryParse(totalPotonganKg.toString()) ?? 0.0),
      DoubleCellValue(double.tryParse(totalBeratBersih.toString()) ?? 0.0),
      DoubleCellValue(double.tryParse(totalSubtotal.toString()) ?? 0.0),
    ];

    for (var col = 0; col < totalRowCells.length; col++) {
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: currentRow))
        ..value = totalRowCells[col]
        ..cellStyle = totalStyle;
    }

    // Atur perkiraan lebar kolom agar data rapi dan tidak terpotong
    sheet.setColumnWidth(0, 6.0);   // No
    sheet.setColumnWidth(1, 20.0);  // Kode
    sheet.setColumnWidth(2, 13.0);  // Tanggal
    sheet.setColumnWidth(3, 24.0);  // Penjual
    sheet.setColumnWidth(4, 18.0);  // Jenis Pembayaran
    sheet.setColumnWidth(5, 16.0);  // Jenis Buah
    sheet.setColumnWidth(6, 16.0);  // Harga / kg
    sheet.setColumnWidth(7, 17.0);  // Berat Kotor
    sheet.setColumnWidth(8, 14.0);  // Potongan %
    sheet.setColumnWidth(9, 16.0);  // Potongan kg
    sheet.setColumnWidth(10, 17.0); // Berat Bersih
    sheet.setColumnWidth(11, 22.0); // Subtotal

    final bytes = excel.encode();
    return Uint8List.fromList(bytes ?? []);
  }
}
