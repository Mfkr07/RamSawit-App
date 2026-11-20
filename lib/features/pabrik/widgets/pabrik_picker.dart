import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_list_tile.dart';
import '../../../models/pabrik.dart';
import '../pabrik_controller.dart';
import '../pabrik_form_modal.dart';

/// Komponen Reusable Picker / Autocomplete Pabrik (FR-8.1, FR-8.2, dan Bagian 11).
/// Mendukung:
/// - Pencarian cepat nama / alamat / kontak pabrik
/// - Fitur tambah pabrik baru secara inline langsung dari dalam picker
class PabrikPicker extends ConsumerStatefulWidget {
  final Pabrik? selectedPabrik;
  final ValueChanged<Pabrik?> onChanged;
  final FormFieldValidator<Pabrik>? validator;
  final bool enabled;

  const PabrikPicker({
    super.key,
    required this.selectedPabrik,
    required this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  ConsumerState<PabrikPicker> createState() => _PabrikPickerState();
}

class _PabrikPickerState extends ConsumerState<PabrikPicker> {
  Future<void> _openPickerModal() async {
    if (!widget.enabled) return;

    final selected = await showDialog<Pabrik>(
      context: context,
      builder: (context) => const _PabrikSelectionDialog(),
    );

    if (selected != null) {
      widget.onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<Pabrik>(
      initialValue: widget.selectedPabrik,
      validator: widget.validator,
      builder: (formFieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              key: const Key('pabrik_picker_trigger'),
              onTap: _openPickerModal,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color:
                      widget.enabled ? AppColors.surface1 : AppColors.surface2,
                  border: Border.all(
                    color: formFieldState.hasError
                        ? AppColors.error
                        : AppColors.hairline,
                    width: formFieldState.hasError ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.factory_outlined,
                      color: AppColors.inkMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: widget.selectedPabrik != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.selectedPabrik!.nama,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                                if (widget.selectedPabrik!.kontak != null)
                                  Text(
                                    widget.selectedPabrik!.kontak!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.inkMuted,
                                    ),
                                  ),
                              ],
                            )
                          : const Text(
                              'Pilih atau cari pabrik / PKS tujuan...',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.inkSubtle,
                              ),
                            ),
                    ),
                    if (widget.selectedPabrik != null && widget.enabled)
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        color: AppColors.inkMuted,
                        onPressed: () {
                          widget.onChanged(null);
                          formFieldState.didChange(null);
                        },
                      )
                    else
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.inkMuted,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
            if (formFieldState.hasError) ...[
              const SizedBox(height: 6),
              Text(
                formFieldState.errorText!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Dialog pilihan Pabrik dengan live search dan tambah pabrik inline
class _PabrikSelectionDialog extends ConsumerStatefulWidget {
  const _PabrikSelectionDialog();

  @override
  ConsumerState<_PabrikSelectionDialog> createState() =>
      _PabrikSelectionDialogState();
}

class _PabrikSelectionDialogState
    extends ConsumerState<_PabrikSelectionDialog> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleTambahPabrikInline() async {
    final created = await PabrikFormModal.show(context);
    if (created != null && mounted) {
      Navigator.of(context).pop(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pabrikAsync = ref.watch(pabrikListProvider);

    return Dialog(
      backgroundColor: AppColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Dialog
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih Pabrik / PKS Tujuan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Search Bar & Tombol Tambah Inline
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('pabrik_picker_search_input'),
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Ketik nama pabrik atau kontak...',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (val) {
                        setState(() => _searchQuery = val.trim().toLowerCase());
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    key: const Key('tambah_pabrik_inline_btn'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _handleTambahPabrikInline,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Baru', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.hairline, height: 1),

              // List of Pabrik
              Expanded(
                child: pabrikAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (err, _) => Center(
                    child: Text(
                      'Gagal memuat data pabrik:\n$err',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  data: (list) {
                    final filtered = list.where((p) {
                      if (!p.isActive) return false;
                      if (_searchQuery.isEmpty) return true;
                      return p.nama.toLowerCase().contains(_searchQuery) ||
                          (p.kontak != null &&
                              p.kontak!.toLowerCase().contains(_searchQuery)) ||
                          (p.alamat != null &&
                              p.alamat!.toLowerCase().contains(_searchQuery));
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.factory_outlined,
                              size: 40,
                              color: AppColors.inkSubtle,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Belum ada data pabrik aktif.'
                                  : 'Pabrik "$_searchQuery" tidak ditemukan.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.inkMuted,
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _handleTambahPabrikInline,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Tambah Pabrik Ini Sekarang'),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) =>
                          const Divider(color: AppColors.hairline, height: 1),
                      itemBuilder: (context, index) {
                        final pabrik = filtered[index];
                        return AppListTile(
                          tileColor: AppColors.canvas,
                          dense: true,
                          leading: const CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.surface2,
                            child: Icon(
                              Icons.factory,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(
                            pabrik.nama,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                          subtitle: pabrik.kontak != null ||
                                  pabrik.alamat != null
                              ? Text(
                                  [pabrik.kontak, pabrik.alamat]
                                      .where((s) => s != null && s.isNotEmpty)
                                      .join(' • '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.inkMuted,
                                  ),
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(pabrik),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
