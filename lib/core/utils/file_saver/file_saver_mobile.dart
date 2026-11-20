import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> saveOrShareFilePlatform({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
}) async {
  if (Platform.isWindows) {
    // Pada Windows Desktop, simpan langsung ke Downloads / Documents pengguna
    Directory? saveDir;
    try {
      saveDir = await getDownloadsDirectory();
    } catch (_) {}
    try {
      saveDir ??= await getApplicationDocumentsDirectory();
    } catch (_) {}

    final dirPath = saveDir?.path ?? Directory.current.path;
    final filePath = '$dirPath/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    // Buka File Explorer dan sorot file yang baru disimpan
    try {
      await Process.run('explorer.exe', ['/select,', filePath.replaceAll('/', '\\')]);
    } catch (_) {}
    return;
  }

  final tempDir = await getTemporaryDirectory();
  final filePath = '${tempDir.path}/$fileName';
  final file = File(filePath);
  await file.writeAsBytes(bytes, flush: true);

  final xFile = XFile(filePath, mimeType: mimeType, name: fileName);
  await Share.shareXFiles(
    [xFile],
    text: 'Laporan Transaksi TBS Sawit: $fileName',
    subject: fileName,
  );
}
