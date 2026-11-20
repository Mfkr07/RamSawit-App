import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/penjual.dart';
import 'penjual_controller.dart';

/// Modal dialog untuk Tambah / Edit data Penjual.
/// Dapat dipanggil dari halaman Daftar Penjual maupun inline dari PenjualPicker.
class PenjualFormModal extends ConsumerStatefulWidget {
  final Penjual? penjualToEdit;

  const PenjualFormModal({
    super.key,
    this.penjualToEdit,
  });

  /// Helper untuk menampilkan modal
  static Future<Penjual?> show(
    BuildContext context, {
    Penjual? penjualToEdit,
  }) {
    return showDialog<Penjual>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PenjualFormModal(penjualToEdit: penjualToEdit),
    );
  }

  @override
  ConsumerState<PenjualFormModal> createState() => _PenjualFormModalState();
}

class _PenjualFormModalState extends ConsumerState<PenjualFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _teleponController;
  late final TextEditingController _alamatController;
  late final TextEditingController _catatanController;

  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEdit => widget.penjualToEdit != null;

  @override
  void initState() {
    super.initState();
    _namaController =
        TextEditingController(text: widget.penjualToEdit?.nama ?? '');
    _teleponController =
        TextEditingController(text: widget.penjualToEdit?.noTelepon ?? '');
    _alamatController =
        TextEditingController(text: widget.penjualToEdit?.alamat ?? '');
    _catatanController =
        TextEditingController(text: widget.penjualToEdit?.catatan ?? '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      Penjual result;
      if (_isEdit) {
        result = await ref.read(penjualListProvider.notifier).updatePenjual(
              id: widget.penjualToEdit!.id,
              nama: _namaController.text,
              noTelepon: _teleponController.text,
              alamat: _alamatController.text,
              catatan: _catatanController.text,
            );
      } else {
        result = await ref.read(penjualListProvider.notifier).createPenjual(
              nama: _namaController.text,
              noTelepon: _teleponController.text,
              alamat: _alamatController.text,
              catatan: _catatanController.text,
            );
      }

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isEdit ? 'Ubah Data Penjual' : 'Tambah Penjual Baru',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.hairline, height: 24),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      color: AppColors.error.withValues(alpha: 0.1),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Field Nama (Wajib)
                  const Text(
                    'Nama Penjual / Petani *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    key: const Key('penjual_nama_input'),
                    controller: _namaController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Haji Sukirman / Kelompok Tani Barokah',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama penjual wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Field Nomor Telepon
                  const Text(
                    'Nomor Telepon / WhatsApp',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    key: const Key('penjual_telepon_input'),
                    controller: _teleponController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: '081234567890',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Field Alamat
                  const Text(
                    'Alamat Kebun / Domisili',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    key: const Key('penjual_alamat_input'),
                    controller: _alamatController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Desa, Dusun, atau KM Kebun Sawit',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Field Catatan
                  const Text(
                    'Catatan Tambahan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    key: const Key('penjual_catatan_input'),
                    controller: _catatanController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Petani plasma, bibit Marihat, dsb.',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Batal'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        key: const Key('penjual_submit_button'),
                        onPressed: _isSaving ? null : _submit,
                        child: _isSaving
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Menyimpan...'),
                                ],
                              )
                            : Text(_isEdit ? 'Simpan Perubahan' : 'Simpan Penjual'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
