import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/jenis_pengeluaran.dart';
import '../../../models/pengeluaran.dart';
import '../jenis_pengeluaran_controller.dart';
import '../pengeluaran_controller.dart';

/// Modal dialog untuk Tambah / Edit Catatan Pengeluaran Operasional (FR-9.1, FR-9.3).
class PengeluaranFormModal extends ConsumerStatefulWidget {
  final Pengeluaran? initialPengeluaran;

  const PengeluaranFormModal({
    super.key,
    this.initialPengeluaran,
  });

  static Future<bool?> show(
    BuildContext context, {
    Pengeluaran? initialPengeluaran,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          PengeluaranFormModal(initialPengeluaran: initialPengeluaran),
    );
  }

  @override
  ConsumerState<PengeluaranFormModal> createState() =>
      _PengeluaranFormModalState();
}

class _PengeluaranFormModalState extends ConsumerState<PengeluaranFormModal> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  int? _selectedJenisId;
  String? _selectedJenisNama;
  late String _metodePembayaran;
  late final TextEditingController _keteranganController;
  late final TextEditingController _nominalController;

  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEdit => widget.initialPengeluaran != null;

  @override
  void initState() {
    super.initState();
    final p = widget.initialPengeluaran;
    _selectedDate = p?.tanggalPengeluaran ?? DateTime.now();
    _selectedJenisId = p?.jenisPengeluaranId;
    _selectedJenisNama = p?.jenisPengeluaranNama;
    _metodePembayaran = p?.metodePembayaran ?? 'tunai';
    _keteranganController = TextEditingController(text: p?.keterangan ?? '');

    final initialNominal = p != null
        ? NumberFormat('#,###', 'id_ID').format(
            double.parse(p.nominal.toString()),
          )
        : '';
    _nominalController = TextEditingController(text: initialNominal);
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  Decimal _parseNominal(String text) {
    final clean = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return Decimal.zero;
    return Decimal.parse(clean);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.ink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedJenisId == null) {
      setState(() => _errorMessage = 'Pilih jenis pengeluaran.');
      return;
    }

    final nominal = _parseNominal(_nominalController.text);
    if (nominal <= Decimal.zero) {
      setState(() => _errorMessage = 'Nominal harus lebih besar dari Rp 0.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final controller = ref.read(pengeluaranControllerProvider.notifier);
    bool success;

    if (_isEdit) {
      success = await controller.updatePengeluaran(
        widget.initialPengeluaran!.id,
        tanggal: _selectedDate,
        jenisPengeluaranId: _selectedJenisId!,
        keterangan: _keteranganController.text.trim(),
        nominal: nominal,
        jenisPengeluaranNama: _selectedJenisNama,
        metodePembayaran: _metodePembayaran,
      );
    } else {
      success = await controller.createPengeluaran(
        tanggal: _selectedDate,
        jenisPengeluaranId: _selectedJenisId!,
        keterangan: _keteranganController.text.trim(),
        nominal: nominal,
        jenisPengeluaranNama: _selectedJenisNama,
        metodePembayaran: _metodePembayaran,
      );
    }

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit
                ? 'Catatan pengeluaran berhasil diperbarui.'
                : 'Pengeluaran berhasil dicatat.',
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final errorState = ref.read(pengeluaranControllerProvider);
      setState(() {
        _isSaving = false;
        _errorMessage = errorState.error?.toString() ?? 'Gagal menyimpan data.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final jenisAsync = ref.watch(jenisPengeluaranActiveListProvider);
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');

    return Dialog(
      backgroundColor: AppColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Modal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEdit
                        ? 'Edit Catatan Pengeluaran'
                        : 'Catat Pengeluaran Baru',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppColors.inkMuted),
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.hairline, height: 1),
              const SizedBox(height: 16),

              // Error Banner jika ada
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    border: Border.all(color: AppColors.error),
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                              color: AppColors.error, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Field 1: Tanggal Pengeluaran
              const Text(
                'TANGGAL PENGELUARAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _isSaving ? null : _pickDate,
                borderRadius: const BorderRadius.all(Radius.circular(2)),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface1,
                    border: Border.all(color: AppColors.hairline),
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateFormat.format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Field 2: Jenis Pengeluaran Dropdown
              const Text(
                'JENIS PENGELUARAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(height: 6),
              jenisAsync.when(
                loading: () => const LinearProgressIndicator(minHeight: 2),
                error: (err, _) => Text(
                  'Gagal memuat kategori: $err',
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
                data: (jenisList) {
                  // Jika jenis pengeluaran sebelumnya ada tapi nonaktif, tetap masukkan ke list agar bisa tampil saat edit
                  final items = List<JenisPengeluaran>.from(jenisList);
                  if (_selectedJenisId != null &&
                      !items.any((j) => j.id == _selectedJenisId)) {
                    items.add(
                      JenisPengeluaran(
                        id: _selectedJenisId!,
                        nama: _selectedJenisNama ?? 'Kategori ($_selectedJenisId)',
                        isActive: false,
                      ),
                    );
                  }

                  return DropdownButtonFormField<int>(
                    initialValue: _selectedJenisId,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: AppColors.surface1,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                        borderSide: BorderSide(color: AppColors.hairline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                        borderSide: BorderSide(color: AppColors.hairline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    hint: const Text('Pilih Kategori Pengeluaran',
                        style: TextStyle(fontSize: 13, color: AppColors.inkSubtle)),
                    items: items.map((j) {
                      return DropdownMenuItem<int>(
                        value: j.id,
                        child: Text(
                          j.nama + (!j.isActive ? ' (Nonaktif)' : ''),
                          style: TextStyle(
                            fontSize: 13,
                            color: j.isActive ? AppColors.ink : AppColors.inkMuted,
                          ),
                        ),
                      );
                    }).toList(),
                    validator: (val) =>
                        val == null ? 'Kategori wajib dipilih.' : null,
                    onChanged: _isSaving
                        ? null
                        : (val) {
                            setState(() {
                              _selectedJenisId = val;
                              _selectedJenisNama = items
                                  .firstWhere((j) => j.id == val)
                                  .nama;
                            });
                          },
                  );
                },
              ),
              const SizedBox(height: 14),

              // Field 3: Nominal (Rupiah)
              const Text(
                'NOMINAL PENGELUARAN (RP)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nominalController,
                keyboardType: TextInputType.number,
                enabled: !_isSaving,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CurrencyInputFormatter(),
                ],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
                decoration: const InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  filled: true,
                  fillColor: AppColors.surface1,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                    borderSide: BorderSide(color: AppColors.hairline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                    borderSide: BorderSide(color: AppColors.hairline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  hintText: '0',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nominal wajib diisi.';
                  }
                  final dec = _parseNominal(val);
                  if (dec <= Decimal.zero) {
                    return 'Nominal harus lebih dari Rp 0.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Field 4: Metode Pembayaran (Tunai vs Non Tunai)
              const Text(
                'METODE PEMBAYARAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      key: const Key('radio_pengeluaran_tunai'),
                      onTap: _isSaving
                          ? null
                          : () => setState(() => _metodePembayaran = 'tunai'),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(2)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: _metodePembayaran == 'tunai'
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : AppColors.surface1,
                          border: Border.all(
                            color: _metodePembayaran == 'tunai'
                                ? AppColors.primary
                                : AppColors.hairline,
                            width: _metodePembayaran == 'tunai' ? 1.5 : 1.0,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(2)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _metodePembayaran == 'tunai'
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              size: 16,
                              color: _metodePembayaran == 'tunai'
                                  ? AppColors.primary
                                  : AppColors.inkSubtle,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tunai (Kas Ramp)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: _metodePembayaran == 'tunai'
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: _metodePembayaran == 'tunai'
                                          ? AppColors.primary
                                          : AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  const Text(
                                    'Uang fisik kas timbangan',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.inkSubtle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      key: const Key('radio_pengeluaran_non_tunai'),
                      onTap: _isSaving
                          ? null
                          : () => setState(() => _metodePembayaran = 'non_tunai'),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(2)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: _metodePembayaran == 'non_tunai'
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : AppColors.surface1,
                          border: Border.all(
                            color: _metodePembayaran == 'non_tunai'
                                ? AppColors.primary
                                : AppColors.hairline,
                            width:
                                _metodePembayaran == 'non_tunai' ? 1.5 : 1.0,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(2)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _metodePembayaran == 'non_tunai'
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              size: 16,
                              color: _metodePembayaran == 'non_tunai'
                                  ? AppColors.primary
                                  : AppColors.inkSubtle,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Non Tunai (Transfer)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight:
                                          _metodePembayaran == 'non_tunai'
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                      color: _metodePembayaran == 'non_tunai'
                                          ? AppColors.primary
                                          : AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  const Text(
                                    'Transfer rekening bank',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.inkSubtle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Field 5: Keterangan (Opsional)
              const Text(
                'KETERANGAN / CATATAN (OPSIONAL)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _keteranganController,
                maxLines: 2,
                enabled: !_isSaving,
                style: const TextStyle(fontSize: 13, color: AppColors.ink),
                decoration: const InputDecoration(
                  hintText: 'Contoh: Beli solar truk 50 liter, operasional ramp, dsb.',
                  hintStyle: TextStyle(fontSize: 12, color: AppColors.inkSubtle),
                  filled: true,
                  fillColor: AppColors.surface1,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                    borderSide: BorderSide(color: AppColors.hairline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                    borderSide: BorderSide(color: AppColors.hairline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.hairline),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                    ),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(_isEdit ? Icons.save : Icons.add, size: 16),
                    label: Text(_isSaving
                        ? 'Menyimpan...'
                        : (_isEdit ? 'Perbarui' : 'Simpan Pengeluaran')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Formatter otomatis pemisah ribuan saat mengetik nominal Rupiah
class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final clean = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final number = int.tryParse(clean) ?? 0;
    final formatted = NumberFormat('#,###', 'id_ID').format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
