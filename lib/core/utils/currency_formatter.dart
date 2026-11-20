import 'package:decimal/decimal.dart';

/// Formatter utilitas untuk mata uang Rupiah (IDR).
/// Mengikuti aturan AGENTS.md:
/// - Pemisah ribuan titik (.) dengan prefix 'Rp ' (contoh: Rp 2.450.000)
/// - Menggunakan Decimal/BigInt untuk mencegah floating-point error
class CurrencyFormatter {

  /// Format Decimal, BigInt, num, atau string ke Rupiah tanpa konversi ke double
  /// (contoh: Rp 2.450.000, Rp 15.000.000.000)
  static String format(dynamic value) {
    if (value == null) return 'Rp 0';
    Decimal? dec;
    if (value is Decimal) {
      dec = value;
    } else if (value is BigInt) {
      dec = Decimal.fromBigInt(value);
    } else if (value is int) {
      dec = Decimal.fromInt(value);
    } else if (value is num) {
      dec = Decimal.tryParse(value.toInt().toString());
    } else if (value is String) {
      dec = Decimal.tryParse(value);
    }

    if (dec == null) return 'Rp 0';

    final isNegative = dec < Decimal.zero;
    final absBigInt = dec.abs().toBigInt();
    final str = absBigInt.toString();

    // Sisipkan pemisah ribuan titik (.)
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }

    final formatted = buffer.toString();
    return isNegative ? '-Rp $formatted' : 'Rp $formatted';
  }

  /// Parsing teks input Rupiah menjadi Decimal
  /// Toleran terhadap format 'Rp 2.450.000', '2.450.000', dsb.
  static Decimal? parse(String input) {
    final cleanString = input
        .replaceAll('Rp', '')
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .replaceAll(',', '.')
        .trim();
    if (cleanString.isEmpty) return null;
    return Decimal.tryParse(cleanString);
  }
}
