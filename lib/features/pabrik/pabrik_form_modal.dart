import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/pabrik.dart';
import 'pabrik_controller.dart';

/// Modal dialog untuk Tambah / Edit data Pabrik tujuan pengiriman.
/// Dapat dipanggil dari halaman Daftar Pabrik maupun secara inline dari PabrikPicker.
class PabrikFormModal extends ConsumerStatefulWidget {
  final Pabrik? pabrikToEdit;

  const PabrikFormModal({
    super.key,
    this.pabrikToEdit,
  });

  /// Helper untuk menampilkan modal dialog
  static Future<Pabrik?> show(
    BuildContext context, {
    Pabrik? pabrikToEdit,
  }) {
    return showDialog<Pabrik>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PabrikFormModal(pabrikToEdit: pabrikToEdit),
    );
  }

  @override
  ConsumerState<PabrikFormModal> createState() => _PabrikFormModalState();
}

class _PabrikFormModalState extends ConsumerState<PabrikFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _alamatController;
  late final TextEditingController _kontakController;

  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEdit => widget.pabrikToEdit != null;

  @override
  void initState() {
    super.initState();
    _namaController =
        TextEditingController(text: widget.pabrikToEdit?.nama ?? '');
    _alamatController =
        TextEditingController(text: widget.pabrikToEdit?.alamat ?? '');
    _kontakController =
        TextEditingController(text: widget.pabrikToEdit?.kontak ?? '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _kontakController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      Pabrik result;
      if (_isEdit) {
        result = await ref.read(pabrikListProvider.notifier).updatePabrik(
              id: widget.pabrikToEdit!.id,
              nama: _namaController.text,
              alamat: _alamatController.text,
              kontak: _kontakController.text,
            );
      } else {
        result = await ref.read(pabrikListProvider.notifier).createPabrik(
              nama: _namaController.text,
              alamat: _alamatController.text,
              kontak: _kontakController.text,
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
                        _isEdit ? 'Ubah Data Pabrik' : 'Tambah Pabrik Baru',
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

                  // Field Nama Pabrik (Wajib)
                  const Text(
                    'Nama Pabrik / PKS *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    key: const Key('pabrik_nama_input'),
                    controller: _namaController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: PT Sawit Inti Riau / PKS Makmur Sentosa',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama pabrik wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Field Kontak
                  const Text(
                    'Kontak / Penanggung Jawab PKS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    key: const Key('pabrik_kontak_input'),
                    controller: _kontakController,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: 081234567890 (Bpk. Hendra - Bagian Timbangan)',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Field Alamat
                  const Text(
                    'Alamat Pabrik / Lokasi PKS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    key: const Key('pabrik_alamat_input'),
                    controller: _alamatController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Jl. Lintas Timur KM 45, Pelalawan',
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
                        key: const Key('pabrik_submit_btn'),
                        onPressed: _isSaving ? null : _submit,
                        child: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_isEdit ? 'Perbarui Data' : 'Simpan Pabrik'),
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
