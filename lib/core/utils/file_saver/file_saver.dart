import 'dart:typed_data';
import 'file_saver_stub.dart'
    if (dart.library.html) 'file_saver_web.dart'
    if (dart.library.io) 'file_saver_mobile.dart';

/// Utilitas universal untuk menyimpan atau membagikan file (Web & Mobile)
class FileSaver {
  /// Menyimpan file di browser (Web) atau membuka native share sheet (Mobile)
  static Future<void> saveOrShareFile({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    await saveOrShareFilePlatform(
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
    );
  }
}
