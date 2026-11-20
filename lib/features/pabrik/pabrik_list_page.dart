import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/pabrik.dart';
import 'pabrik_controller.dart';
import 'pabrik_form_modal.dart';

/// Halaman Master Data Pabrik (FR-8.1 & Bagian 11).
/// Mendukung pencarian, penambahan, pengubahan, dan soft delete (is_active).
class PabrikListPage extends ConsumerStatefulWidget {
  const PabrikListPage({super.key});

  @override
  ConsumerState<PabrikListPage> createState() => _PabrikListPageState();
}

class _PabrikListPageState extends ConsumerState<PabrikListPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleAddNew() async {
    final created = await PabrikFormModal.show(context);
    if (created != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pabrik "${created.nama}" berhasil disimpan.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleEdit(Pabrik pabrik) async {
    final updated = await PabrikFormModal.show(
      context,
      pabrikToEdit: pabrik,
    );
    if (updated != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data "${updated.nama}" berhasil diperbarui.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmToggleStatus(Pabrik pabrik) async {
    final willDeactivate = pabrik.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.canvas,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
        ),
        title: Text(
          willDeactivate ? 'Nonaktifkan Pabrik?' : 'Aktifkan Kembali Pabrik?',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: Text(
          willDeactivate
              ? 'Pabrik "${pabrik.nama}" tidak akan muncul dalam pilihan pengiriman baru, namun seluruh histori pengiriman sebelumnya tetap aman tersimpan.'
              : 'Aktifkan kembali pabrik "${pabrik.nama}" agar dapat dipilih dalam pengiriman baru?',
          style: const TextStyle(fontSize: 14, color: AppColors.inkMuted),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  willDeactivate ? AppColors.error : AppColors.success,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(willDeactivate ? 'Nonaktifkan' : 'Aktifkan'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(pabrikListProvider.notifier)
          .toggleStatus(pabrik.id, pabrik.isActive);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              willDeactivate
                  ? 'Pabrik "${pabrik.nama}" telah dinonaktifkan.'
                  : 'Pabrik "${pabrik.nama}" berhasil diaktifkan kembali.',
            ),
            backgroundColor: willDeactivate ? AppColors.ink : AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(pabrikFilterProvider);
    final pabrikAsync = ref.watch(pabrikListProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar: Judul dan Tombol Tambah
            // Top Bar: Judul dan Tombol Tambah
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 600;
                final titleWidget = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Master Data Pabrik (PKS)',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Kelola daftar pabrik kelapa sawit tujuan pengiriman penjualan TBS.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                );

                final addButton = ElevatedButton.icon(
                  key: const Key('tambah_pabrik_btn'),
                  onPressed: _handleAddNew,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah Pabrik Baru'),
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      titleWidget,
                      const SizedBox(height: 12),
                      addButton,
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: titleWidget),
                    addButton,
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Bar Pencarian & Filter
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 450;
                final searchField = TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari pabrik (nama, alamat, kontak)...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(pabrikFilterProvider.notifier)
                                  .setSearchQuery('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  onChanged: (value) {
                    ref
                        .read(pabrikFilterProvider.notifier)
                        .setSearchQuery(value);
                  },
                );

                final checkboxWidget = InkWell(
                  onTap: () {
                    ref
                        .read(pabrikFilterProvider.notifier)
                        .toggleIncludeInactive();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: filter.includeInactive,
                        onChanged: (val) {
                          ref
                              .read(pabrikFilterProvider.notifier)
                              .toggleIncludeInactive();
                        },
                      ),
                      const Text(
                        'Tampilkan Nonaktif',
                        style: TextStyle(fontSize: 12, color: AppColors.ink),
                      ),
                    ],
                  ),
                );

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface1,
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: isCompact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            searchField,
                            const SizedBox(height: 8),
                            checkboxWidget,
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: searchField),
                            const SizedBox(width: 12),
                            checkboxWidget,
                          ],
                        ),
                );
              },
            ),
            const SizedBox(height: 16),

            // List Pabrik
            Expanded(
              child: pabrikAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 36,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Terjadi kesalahan saat memuat data pabrik:\n$err',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () =>
                            ref.read(pabrikListProvider.notifier).refresh(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
                data: (list) {
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.factory_outlined,
                            size: 48,
                            color: AppColors.inkSubtle.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tidak ada data pabrik yang sesuai.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.inkMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Silakan tambah data pabrik baru atau sesuaikan kata kunci pencarian.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.inkSubtle,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return _PabrikCard(
                        pabrik: item,
                        onEdit: () => _handleEdit(item),
                        onToggleStatus: () => _confirmToggleStatus(item),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PabrikCard extends StatelessWidget {
  final Pabrik pabrik;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;

  const _PabrikCard({
    required this.pabrik,
    required this.onEdit,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: pabrik.isActive ? AppColors.canvas : AppColors.surface2,
        border: Border.all(
          color: pabrik.isActive ? AppColors.hairline : AppColors.hairline,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon / Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: pabrik.isActive
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.surface2,
                border: Border.all(
                  color: pabrik.isActive ? AppColors.primary : AppColors.inkSubtle,
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.factory,
                  size: 20,
                  color: pabrik.isActive ? AppColors.primary : AppColors.inkSubtle,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Info Pabrik
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pabrik.nama,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: pabrik.isActive
                                ? AppColors.ink
                                : AppColors.inkMuted,
                          ),
                        ),
                      ),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: pabrik.isActive
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.surface2,
                          border: Border.all(
                            color: pabrik.isActive
                                ? AppColors.success
                                : AppColors.inkSubtle,
                          ),
                        ),
                        child: Text(
                          pabrik.isActive ? 'AKTIF' : 'NONAKTIF',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: pabrik.isActive
                                ? AppColors.success
                                : AppColors.inkMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  if (pabrik.kontak != null && pabrik.kontak!.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined,
                            size: 14, color: AppColors.inkMuted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            pabrik.kontak!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],

                  if (pabrik.alamat != null && pabrik.alamat!.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.inkMuted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            pabrik.alamat!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Action Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Ubah Data Pabrik',
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  color: AppColors.primary,
                  onPressed: onEdit,
                ),
                IconButton(
                  tooltip: pabrik.isActive
                      ? 'Nonaktifkan Pabrik'
                      : 'Aktifkan Kembali Pabrik',
                  icon: Icon(
                    pabrik.isActive
                        ? Icons.block_outlined
                        : Icons.check_circle_outline,
                    size: 18,
                  ),
                  color:
                      pabrik.isActive ? AppColors.error : AppColors.success,
                  onPressed: onToggleStatus,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
