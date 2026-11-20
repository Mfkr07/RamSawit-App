import 'dart:typed_data';
import 'package:decimal/decimal.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '../../../models/pengiriman_pabrik.dart';

/// Generator laporan riwayat penjualan ke pabrik format Excel (.xlsx)
/// Hanya menyertakan status 'selesai' (FR-7.7, FR-8.9, Tugas Bagian 14).
class LaporanPengirimanExcelGenerator {
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

    return 'Laporan-Penjualan-Pabrik-$rangePart.$extension';
  }

  static Uint8List generate({
    required List<PengirimanPabrik> items,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    // Filter ketat: Hanya menyertakan status 'selesai' (FR-8.9)
    final filteredItems = items.where((item) => item.isSelesai).toList();

    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
    excel.rename(defaultSheet, 'Laporan Penjualan Pabrik');
    final sheet = excel['Laporan Penjualan Pabrik'];

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

    // 1. Judul & Metadata
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      ..value = TextCellValue('LAPORAN PENJUALAN TBS KE PABRIK KELAPA SAWIT (PKS)')
      ..cellStyle = titleStyle;

    final dateRangeStr = (startDate != null && endDate != null)
        ? '${DateFormat('d MMMM yyyy', 'id_ID').format(startDate)} s/d ${DateFormat('d MMMM yyyy', 'id_ID').format(endDate)}'
        : 'Semua Periode Tanggal';

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).value =
        TextCellValue('Periode: $dateRangeStr (Hanya Status Selesai)');

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).value =
        TextCellValue(
            'Waktu Cetak: ${DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(DateTime.now())} WIB');

    // 2. Baris Header (FR-7.7, FR-8.8 & Bagian 23)
    final headers = [
      'No',
      'Kode Pengiriman',
      'Tanggal',
      'Pabrik Tujuan',
      'Plat Nomor',
      'Sopir',
      'Berat Dikirim (kg)',
      'Berat Sampai (kg)',
      'Berat Ditolak (kg)',
      'Berat Diterima (kg)',
      'Potongan (%)',
      'Berat Bersih (kg)',
      'Susut Buah (kg)',
      'Harga Jual / kg (Rp)',
      'Potongan Lainnya (Rp)',
      'Potongan Sortasi / kg (Rp)',
      'Nilai Potongan Sortasi (Rp)',
      'Total Nilai Jual (Rp)',
    ];

    for (var col = 0; col < headers.length; col++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 4))
        ..value = TextCellValue(headers[col])
        ..cellStyle = headerStyle;
    }

    // 3. Baris Data
    var totalDikirim = Decimal.zero;
    var totalSampai = Decimal.zero;
    var totalDitolak = Decimal.zero;
    var totalDiterima = Decimal.zero;
    var totalBersih = Decimal.zero;
    var totalSusut = Decimal.zero;
    var totalPotonganLainnya = Decimal.zero;
    var totalNilaiSortasi = Decimal.zero;
    var totalNilaiJual = Decimal.zero;

    var currentRow = 5;
    for (var i = 0; i < filteredItems.length; i++) {
      final item = filteredItems[i];

      totalDikirim += item.beratDikirimKg;
      totalSampai += item.beratSampaiKg ?? Decimal.zero;
      totalDitolak += item.beratDitolakKg ?? Decimal.zero;
      totalDiterima += item.beratDiterimaKg ?? Decimal.zero;
      totalBersih += item.beratBersihKg ?? Decimal.zero;
      totalSusut += item.susutBuahKg ?? Decimal.zero;
      totalPotonganLainnya += item.potonganLainnyaRp ?? Decimal.zero;
      totalNilaiSortasi += item.nilaiPotonganSortasiRp ?? Decimal.zero;
      totalNilaiJual += item.totalNilaiJual ?? Decimal.zero;

      final rowValues = [
        IntCellValue(i + 1),
        TextCellValue(item.kodePengiriman),
        TextCellValue(DateFormat('yyyy-MM-dd').format(item.tanggalKirim)),
        TextCellValue(item.pabrik?.nama ?? '-'),
        TextCellValue(item.platNomor),
        TextCellValue(item.namaSopir),
        DoubleCellValue(double.tryParse(item.beratDikirimKg.toString()) ?? 0.0),
        DoubleCellValue(double.tryParse((item.beratSampaiKg ?? Decimal.zero).toString()) ?? 0.0),
        DoubleCellValue(double.tryParse((item.beratDitolakKg ?? Decimal.zero).toString()) ?? 0.0),
        DoubleCellValue(double.tryParse((item.beratDiterimaKg ?? Decimal.zero).toString()) ?? 0.0),
        DoubleCellValue(double.tryParse((item.persentasePotonganPabrik ?? Decimal.zero).toString()) ?? 0.0),
        DoubleCellValue(double.tryParse((item.beratBersihKg ?? Decimal.zero).toString()) ?? 0.0),
        DoubleCellValue(double.tryParse((item.susutBuahKg ?? Decimal.zero).toString()) ?? 0.0),
        DoubleCellValue(double.tryParse((item.hargaJualPerKg ?? Decimal.zero).toString()) ?? 0.0),
        DoubleCellValue(double.tryParse((item.potonganLainnyaRp ?? Decimal.zero).toString()) ?? 0.0),
        DoubleCellValue(double.tryParse((item.potonganSortasiPerKg ?? Decimal.zero).toString()) ?? 0.0),
        DoubleCellValue(double.tryParse((item.nilaiPotonganSortasiRp ?? Decimal.zero).toString()) ?? 0.0),
        DoubleCellValue(double.tryParse((item.totalNilaiJual ?? Decimal.zero).toString()) ?? 0.0),
      ];

      for (var col = 0; col < rowValues.length; col++) {
        sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: col, rowIndex: currentRow))
          .value = rowValues[col];
      }
      currentRow++;
    }

    // 4. Baris Total Keseluruhan
    final totalRowCells = [
      TextCellValue('TOTAL KESELURUHAN'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      DoubleCellValue(double.tryParse(totalDikirim.toString()) ?? 0.0),
      DoubleCellValue(double.tryParse(totalSampai.toString()) ?? 0.0),
      DoubleCellValue(double.tryParse(totalDitolak.toString()) ?? 0.0),
      DoubleCellValue(double.tryParse(totalDiterima.toString()) ?? 0.0),
      TextCellValue('-'),
      DoubleCellValue(double.tryParse(totalBersih.toString()) ?? 0.0),
      DoubleCellValue(double.tryParse(totalSusut.toString()) ?? 0.0),
      TextCellValue('-'),
      DoubleCellValue(double.tryParse(totalPotonganLainnya.toString()) ?? 0.0),
      TextCellValue('-'),
      DoubleCellValue(double.tryParse(totalNilaiSortasi.toString()) ?? 0.0),
      DoubleCellValue(double.tryParse(totalNilaiJual.toString()) ?? 0.0),
    ];

    for (var col = 0; col < totalRowCells.length; col++) {
      sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: currentRow))
        ..value = totalRowCells[col]
        ..cellStyle = totalStyle;
    }

    sheet.setColumnWidth(0, 6.0);
    sheet.setColumnWidth(1, 20.0);
    sheet.setColumnWidth(2, 13.0);
    sheet.setColumnWidth(3, 24.0);
    sheet.setColumnWidth(4, 14.0);
    sheet.setColumnWidth(5, 16.0);
    sheet.setColumnWidth(6, 17.0);
    sheet.setColumnWidth(7, 17.0);
    sheet.setColumnWidth(8, 17.0);
    sheet.setColumnWidth(9, 17.0);
    sheet.setColumnWidth(10, 14.0);
    sheet.setColumnWidth(11, 17.0);
    sheet.setColumnWidth(12, 16.0);
    sheet.setColumnWidth(13, 18.0);
    sheet.setColumnWidth(14, 18.0);
    sheet.setColumnWidth(15, 20.0);
    sheet.setColumnWidth(16, 20.0);
    sheet.setColumnWidth(17, 22.0);

    final bytes = excel.encode();
    return Uint8List.fromList(bytes ?? []);
  }
}
