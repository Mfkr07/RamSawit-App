import 'package:decimal/decimal.dart';

/// Formatter utilitas untuk berat buah kelapa sawit (kg).
/// Mengikuti aturan AGENTS.md:
/// - Presisi 2 desimal
/// - Format Indonesia: koma (,) untuk desimal, titik (.) untuk ribuan
/// - Disertai suffix satuan ' kg' (contoh: 1.250,50 kg)
class WeightFormatter {

  /// Format Decimal, num, atau string ke format berat Indonesia (contoh: 1.250,50 kg)
  /// tanpa konversi ke tipe double untuk mencegah floating-point loss
  static String format(dynamic value, {bool includeUnit = true}) {
    if (value == null) return includeUnit ? '0,00 kg' : '0,00';
    Decimal? dec;

    if (value is Decimal) {
      dec = value;
    } else if (value is num) {
      dec = Decimal.tryParse(value.toString());
    } else if (value is String) {
      dec = Decimal.tryParse(value);
    }

    if (dec == null) return includeUnit ? '0,00 kg' : '0,00';

    final isNegative = dec < Decimal.zero;
    final absDec = dec.abs();
    final parts = absDec.toString().split('.');
    final intPart = parts[0];
    final fracPart =
        (parts.length > 1 ? parts[1] : '').padRight(2, '0').substring(0, 2);

    // Format ribuan pada bagian integer
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(intPart[i]);
    }

    final formattedInt = buffer.toString();
    final formatted = '$formattedInt,$fracPart';
    final sign = isNegative ? '-' : '';

    return includeUnit ? '$sign$formatted kg' : '$sign$formatted';
  }

  /// Parsing input berat dari UI (contoh: '1.250,50', '1250.50') menjadi Decimal
  static Decimal? parse(String input) {
    final cleanString = input
        .replaceAll('kg', '')
        .replaceAll('KG', '')
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .replaceAll(',', '.')
        .trim();
    if (cleanString.isEmpty) return null;
    return Decimal.tryParse(cleanString);
  }
}
