import 'package:decimal/decimal.dart';

/// Formatter utilitas untuk persentase potongan transaksi.
/// Mengikuti standar:
/// - Nilai bulat (misal 5.00 atau 5) ditampilkan sebagai "5%"
/// - Nilai desimal (misal 7.50 atau 7.25) ditampilkan sebagai "7.5%" / "7.25%"
/// - Nilai null / nol ditampilkan sebagai "0%"
class PercentageFormatter {
  /// Format Decimal atau num menjadi string persentase yang bersih
  static String format(dynamic value) {
    if (value == null) return '0%';
    Decimal? dec;
    if (value is Decimal) {
      dec = value;
    } else if (value is num) {
      dec = Decimal.tryParse(value.toString());
    } else if (value is String) {
      dec = Decimal.tryParse(value);
    }

    if (dec == null) return '0%';

    final str = dec.toString();
    if (str.contains('.')) {
      final clean = str.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      return '$clean%';
    }
    return '$str%';
  }
}
