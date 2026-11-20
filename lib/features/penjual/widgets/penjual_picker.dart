import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_list_tile.dart';
import '../../../models/penjual.dart';
import '../penjual_controller.dart';
import '../penjual_form_modal.dart';

/// Komponen Reusable Picker / Autocomplete Penjual.
/// Memenuhi FR-2.3, FR-3.1, dan PRD §6 poin 2:
/// - Pencarian cepat nama penjual
/// - Fitur tambah penjual baru secara inline langsung dari dalam picker
class PenjualPicker extends ConsumerStatefulWidget {
  final Penjual? selectedPenjual;
  final ValueChanged<Penjual?> onChanged;
  final FormFieldValidator<Penjual>? validator;
  final bool enabled;

  const PenjualPicker({
    super.key,
    required this.selectedPenjual,
    required this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  ConsumerState<PenjualPicker> createState() => _PenjualPickerState();
}

class _PenjualPickerState extends ConsumerState<PenjualPicker> {
  Future<void> _openPickerModal() async {
    if (!widget.enabled) return;

    final selected = await showDialog<Penjual>(
      context: context,
      builder: (context) => const _PenjualSelectionDialog(),
    );

    if (selected != null) {
      widget.onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<Penjual>(
      initialValue: widget.selectedPenjual,
      validator: widget.validator,
      builder: (formFieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _openPickerModal,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.enabled ? AppColors.surface1 : AppColors.surface2,
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
                      Icons.person_outline,
                      color: AppColors.inkMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: widget.selectedPenjual != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.selectedPenjual!.nama,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                                if (widget.selectedPenjual!.noTelepon != null)
                                  Text(
                                    widget.selectedPenjual!.noTelepon!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.inkMuted,
                                    ),
                                  ),
                              ],
                            )
                          : const Text(
                              'Pilih atau cari penjual / petani sawit...',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.inkSubtle,
                              ),
                            ),
                    ),
                    if (widget.selectedPenjual != null && widget.enabled)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => widget.onChanged(null),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
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

/// Dialog pencarian penjual dengan tombol inline '+ Tambah Penjual Baru'
class _PenjualSelectionDialog extends ConsumerStatefulWidget {
  const _PenjualSelectionDialog();

  @override
  ConsumerState<_PenjualSelectionDialog> createState() =>
      _PenjualSelectionDialogState();
}

class _PenjualSelectionDialogState
    extends ConsumerState<_PenjualSelectionDialog> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleAddNewPenjual() async {
    final newPenjual = await PenjualFormModal.show(context);
    if (newPenjual != null && mounted) {
      // Langsung kembalikan penjual baru agar otomatis terpilih
      Navigator.of(context).pop(newPenjual);
    }
  }

  @override
  Widget build(BuildContext context) {
    final penjualAsync = ref.watch(penjualListProvider);

    return Dialog(
      backgroundColor: AppColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
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
                    'Pilih Penjual Sawit',
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

              // Kotak Pencarian
              TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Cari nama atau no. telepon...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                ),
                onChanged: (val) => setState(() => _query = val.trim().toLowerCase()),
              ),
              const SizedBox(height: 12),

              // Tombol Tambah Penjual Baru Inline (User Flow PRD §6 poin 2)
              InkWell(
                key: const Key('picker_add_new_penjual_button'),
                onTap: _handleAddNewPenjual,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    border: Border.all(color: AppColors.primary, width: 1.0),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '+ Tambah Penjual Baru',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.hairline),

              // Daftar Hasil
              Expanded(
                child: penjualAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (err, _) => Center(
                    child: Text(
                      'Gagal memuat: $err',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                  data: (allPenjual) {
                    // Filter aktif & sesuai pencarian
                    final filtered = allPenjual.where((p) {
                      if (!p.isActive) return false;
                      if (_query.isEmpty) return true;
                      return p.nama.toLowerCase().contains(_query) ||
                          (p.noTelepon != null && p.noTelepon!.contains(_query));
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 40,
                              color: AppColors.inkSubtle,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Penjual tidak ditemukan.',
                              style: TextStyle(color: AppColors.inkMuted),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _handleAddNewPenjual,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Buat Baru Sekarang'),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: AppColors.hairline),
                      itemBuilder: (context, index) {
                        final penjual = filtered[index];
                        return AppListTile(
                          tileColor: AppColors.canvas,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          title: Text(
                            penjual.nama,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                          subtitle: Text(
                            [
                              if (penjual.noTelepon != null) penjual.noTelepon,
                              if (penjual.alamat != null) penjual.alamat,
                            ].join(' • '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.inkMuted,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.inkSubtle,
                            size: 18,
                          ),
                          onTap: () => Navigator.of(context).pop(penjual),
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
