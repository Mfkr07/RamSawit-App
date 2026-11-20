import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/jenis_pengeluaran.dart';
import '../auth/auth_controller.dart';
import 'jenis_pengeluaran_controller.dart';

/// Halaman Kelola Jenis Pengeluaran (Master Data Kategori) (FR-9.4).
/// KHUSUS ROLE ADMIN.
class JenisPengeluaranPage extends ConsumerStatefulWidget {
  const JenisPengeluaranPage({super.key});

  @override
  ConsumerState<JenisPengeluaranPage> createState() =>
      _JenisPengeluaranPageState();
}

class _JenisPengeluaranPageState extends ConsumerState<JenisPengeluaranPage> {
  final _addTextController = TextEditingController();
  bool _isAdding = false;
  String? _addErrorMessage;

  @override
  void dispose() {
    _addTextController.dispose();
    super.dispose();
  }

  Future<void> _handleAddCategory() async {
    final nama = _addTextController.text.trim();
    if (nama.isEmpty) {
      setState(() => _addErrorMessage = 'Nama kategori tidak boleh kosong.');
      return;
    }

    setState(() {
      _isAdding = true;
      _addErrorMessage = null;
    });

    final success = await ref
        .read(jenisPengeluaranControllerProvider.notifier)
        .createJenis(nama);

    if (mounted) {
      setState(() => _isAdding = false);
      if (success) {
        _addTextController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kategori pengeluaran baru berhasil ditambahkan.'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final err = ref.read(jenisPengeluaranControllerProvider).error;
        setState(() => _addErrorMessage = err?.toString() ?? 'Gagal menambahkan kategori.');
      }
    }
  }

  Future<void> _handleEditNama(JenisPengeluaran item) async {
    final editController = TextEditingController(text: item.nama);
    final confirmed = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.canvas,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        title: const Text(
          'Ubah Nama Kategori',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan nama baru untuk kategori pengeluaran ini:',
              style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: editController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.of(ctx).pop(editController.text.trim()),
            child: const Text('Simpan Perubahan'),
          ),
        ],
      ),
    );

    if (confirmed != null && confirmed.isNotEmpty && confirmed != item.nama && mounted) {
      final success = await ref
          .read(jenisPengeluaranControllerProvider.notifier)
          .updateNama(item.id, confirmed);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Nama kategori berhasil diubah menjadi "$confirmed".'
                  : 'Gagal mengubah nama kategori.',
            ),
            backgroundColor: success ? AppColors.primary : AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleToggleStatus(JenisPengeluaran item) async {
    final newStatus = !item.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.canvas,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        title: Text(
          newStatus ? 'Aktifkan Kategori?' : 'Nonaktifkan Kategori?',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Text(
          newStatus
              ? 'Kategori "${item.nama}" akan kembali muncul di dropdown pencatatan pengeluaran.'
              : 'Kategori "${item.nama}" akan disembunyikan dari pilihan pencatatan baru (data riwayat lama tetap aman).',
          style: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? AppColors.primary : AppColors.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(newStatus ? 'Aktifkan' : 'Nonaktifkan'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(jenisPengeluaranControllerProvider.notifier)
          .toggleStatus(item.id, item.isActive);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Status kategori "${item.nama}" berhasil diperbarui.'
                  : 'Gagal memperbarui status kategori.',
            ),
            backgroundColor: success ? AppColors.primary : AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(authControllerProvider).profile;
    final isAdmin = userProfile?.isAdmin == true;

    // Guard akses: Hanya Admin
    if (!isAdmin) {
      return Scaffold(
        backgroundColor: AppColors.surface1,
        body: Center(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              border: Border.all(color: AppColors.hairline),
              borderRadius: const BorderRadius.all(Radius.circular(2.0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.lock_outline, size: 48, color: AppColors.error),
                SizedBox(height: 16),
                Text(
                  'Akses Ditolak (Khusus Admin)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Halaman Kelola Jenis Pengeluaran hanya dapat diakses oleh akun dengan peran Admin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final categoriesAsync = ref.watch(jenisPengeluaranListProvider);

    return Scaffold(
      backgroundColor: AppColors.surface1,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KELOLA JENIS PENGELUARAN',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Master data kategori pengeluaran operasional (Khusus Administrator)',
                      style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Card Form Tambah Kategori Baru
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                border: Border.all(color: AppColors.hairline),
                borderRadius: const BorderRadius.all(Radius.circular(2.0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TAMBAH KATEGORI BARU',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_addErrorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: AppColors.error.withValues(alpha: 0.08),
                      child: Text(
                        _addErrorMessage!,
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _addTextController,
                          enabled: !_isAdding,
                          decoration: const InputDecoration(
                            hintText: 'Contoh: Listrik & Air Ramp, Keamanan, dsb.',
                            filled: true,
                            fillColor: AppColors.surface1,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(2)),
                              borderSide: BorderSide(color: AppColors.hairline),
                            ),
                          ),
                          onSubmitted: (_) => _handleAddCategory(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                        ),
                        onPressed: _isAdding ? null : _handleAddCategory,
                        icon: _isAdding
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.add, size: 16),
                        label: Text(_isAdding ? 'Menyimpan...' : 'Tambah Kategori'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // List Kategori Eksisting
            categoriesAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (err, _) => Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.error.withValues(alpha: 0.1),
                child: Text('Gagal memuat kategori: $err'),
              ),
              data: (categories) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    border: Border.all(color: AppColors.hairline),
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'DAFTAR KATEGORI (${categories.length})',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: AppColors.inkMuted,
                              ),
                            ),
                            const Text(
                              'Data dirujuk langsung oleh entri pengeluaran',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.inkSubtle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: AppColors.hairline, height: 1),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categories.length,
                        separatorBuilder: (_, _) =>
                            const Divider(color: AppColors.hairline, height: 1),
                        itemBuilder: (context, index) {
                          final item = categories[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            leading: CircleAvatar(
                              radius: 14,
                              backgroundColor: item.isActive
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : AppColors.surface2,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: item.isActive
                                      ? AppColors.primary
                                      : AppColors.inkMuted,
                                ),
                              ),
                            ),
                            title: Text(
                              item.nama,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: item.isActive
                                    ? AppColors.ink
                                    : AppColors.inkMuted,
                                decoration: item.isActive
                                    ? null
                                    : TextDecoration.lineThrough,
                              ),
                            ),
                            subtitle: Text(
                              item.isActive
                                  ? 'Tersedia di pilihan pencatatan'
                                  : 'Dinonaktifkan (arsip)',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.inkSubtle),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Badge Status
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: item.isActive
                                        ? const Color(0xFF198038)
                                            .withValues(alpha: 0.1)
                                        : AppColors.error.withValues(alpha: 0.1),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(2)),
                                  ),
                                  child: Text(
                                    item.isActive ? 'AKTIF' : 'NONAKTIF',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: item.isActive
                                          ? const Color(0xFF198038)
                                          : AppColors.error,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Aksi Edit Nama
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      size: 18, color: AppColors.primary),
                                  tooltip: 'Ubah Nama Kategori',
                                  onPressed: () => _handleEditNama(item),
                                ),

                                // Aksi Toggle Aktif/Nonaktif (Soft Delete)
                                IconButton(
                                  icon: Icon(
                                    item.isActive
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 18,
                                    color: item.isActive
                                        ? AppColors.error
                                        : const Color(0xFF198038),
                                  ),
                                  tooltip: item.isActive
                                      ? 'Nonaktifkan Kategori'
                                      : 'Aktifkan Kembali Kategori',
                                  onPressed: () => _handleToggleStatus(item),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
