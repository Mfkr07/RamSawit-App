import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_list_tile.dart';
import '../../models/penjual.dart';
import 'penjual_controller.dart';
import 'penjual_form_modal.dart';

/// Halaman Master Daftar Penjual (FR-2.1 & FR-2.2).
/// Mendukung pencarian, penambahan, pengubahan, dan soft delete (is_active).
class PenjualListPage extends ConsumerStatefulWidget {
  const PenjualListPage({super.key});

  @override
  ConsumerState<PenjualListPage> createState() => _PenjualListPageState();
}

class _PenjualListPageState extends ConsumerState<PenjualListPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleAddNew() async {
    final created = await PenjualFormModal.show(context);
    if (created != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Penjual "${created.nama}" berhasil disimpan.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleEdit(Penjual penjual) async {
    final updated = await PenjualFormModal.show(
      context,
      penjualToEdit: penjual,
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

  Future<void> _confirmToggleStatus(Penjual penjual) async {
    final willDeactivate = penjual.isActive;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.canvas,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
        ),
        title: Text(
          willDeactivate ? 'Nonaktifkan Penjual?' : 'Aktifkan Kembali Penjual?',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: Text(
          willDeactivate
              ? 'Penjual "${penjual.nama}" tidak akan muncul dalam pilihan transaksi baru, namun seluruh histori transaksi sebelumnya tetap aman tersimpan.'
              : 'Aktifkan kembali penjual "${penjual.nama}" agar dapat dipilih dalam transaksi baru?',
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
          .read(penjualListProvider.notifier)
          .toggleStatus(penjual.id, penjual.isActive);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              willDeactivate
                  ? 'Penjual "${penjual.nama}" telah dinonaktifkan.'
                  : 'Penjual "${penjual.nama}" berhasil diaktifkan kembali.',
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
    final filter = ref.watch(penjualFilterProvider);
    final penjualAsync = ref.watch(penjualListProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar: Judul dan Tombol Tambah
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 600;
                final titleWidget = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Data Penjual / Petani',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Kelola master data petani & pengepul kelapa sawit',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                );

                final addButton = ElevatedButton.icon(
                  key: const Key('tambah_penjual_button'),
                  onPressed: _handleAddNew,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah Penjual'),
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

            // Filter Bar: Input Search & Toggle Status
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 450;
                final searchField = TextField(
                  key: const Key('search_penjual_input'),
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau nomor telepon penjual...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: filter.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(penjualFilterProvider.notifier)
                                  .setSearchQuery('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  onChanged: (val) {
                    ref
                        .read(penjualFilterProvider.notifier)
                        .setSearchQuery(val);
                  },
                );

                final checkboxWidget = InkWell(
                  onTap: () {
                    ref
                        .read(penjualFilterProvider.notifier)
                        .toggleIncludeInactive();
                  },
                  child: Row(
                    key: const Key('toggle_show_inactive'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        key: const Key('checkbox_tampilkan_nonaktif'),
                        value: filter.includeInactive,
                        onChanged: (val) {
                          ref
                              .read(penjualFilterProvider.notifier)
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

            // List Penjual
            Expanded(
              child: penjualAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 40,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Terjadi kesalahan memuat data: $err',
                        style: const TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () =>
                            ref.read(penjualListProvider.notifier).refresh(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
                data: (penjualList) {
                  if (penjualList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person_off_outlined,
                            size: 48,
                            color: AppColors.inkSubtle,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum ada data penjual yang sesuai.',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.inkMuted,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _handleAddNew,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Tambah Penjual Pertama'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(penjualListProvider.notifier).refresh(),
                    child: ListView.builder(
                      itemCount: penjualList.length,
                      itemBuilder: (context, index) {
                        final p = penjualList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: p.isActive
                                  ? AppColors.hairline
                                  : AppColors.surface2,
                            ),
                          ),
                          child: AppListTile(
                            tileColor: AppColors.canvas,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: p.isActive
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : AppColors.surface2,
                              child: Icon(
                                Icons.person,
                                color: p.isActive
                                  ? AppColors.primary
                                  : AppColors.inkSubtle,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    p.nama,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: p.isActive
                                          ? AppColors.ink
                                          : AppColors.inkSubtle,
                                      decoration: p.isActive
                                          ? null
                                          : TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Badge Status
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: p.isActive
                                        ? AppColors.success.withValues(alpha: 0.1)
                                        : AppColors.inkSubtle.withValues(alpha: 0.1),
                                    border: Border.all(
                                      color: p.isActive
                                          ? AppColors.success
                                          : AppColors.inkSubtle,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    p.isActive ? 'Aktif' : 'Nonaktif',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: p.isActive
                                          ? AppColors.success
                                          : AppColors.inkSubtle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (p.noTelepon != null &&
                                          p.noTelepon!.isNotEmpty) ...[
                                        const Icon(
                                          Icons.phone_outlined,
                                          size: 14,
                                          color: AppColors.inkMuted,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          p.noTelepon!,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                      ],
                                      if (p.alamat != null &&
                                          p.alamat!.isNotEmpty) ...[
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 14,
                                          color: AppColors.inkMuted,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            p.alamat!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppColors.inkMuted,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (p.catatan != null &&
                                      p.catatan!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Catatan: ${p.catatan!}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: AppColors.inkSubtle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Ubah data penjual',
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: AppColors.inkMuted,
                                    size: 20,
                                  ),
                                  onPressed: () => _handleEdit(p),
                                ),
                                IconButton(
                                  tooltip: p.isActive
                                      ? 'Nonaktifkan penjual (soft delete)'
                                      : 'Aktifkan kembali penjual',
                                  icon: Icon(
                                    p.isActive
                                        ? Icons.block_outlined
                                        : Icons.check_circle_outline,
                                    color: p.isActive
                                        ? AppColors.error
                                        : AppColors.success,
                                    size: 20,
                                  ),
                                  onPressed: () => _confirmToggleStatus(p),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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
