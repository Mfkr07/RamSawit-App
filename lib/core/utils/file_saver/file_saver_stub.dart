import 'dart:typed_data';

Future<void> saveOrShareFilePlatform({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
}) async {
  throw UnsupportedError('Platform ini tidak didukung untuk penyimpanan file.');
}
