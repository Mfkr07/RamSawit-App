import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../saldo_controller.dart';

/// Modal dialog untuk mencatat Top Up Saldo Dana Modal baru (FR-10.1)
class TopupFormModal extends ConsumerStatefulWidget {
  const TopupFormModal({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const TopupFormModal(),
    );
  }

  @override
  ConsumerState<TopupFormModal> createState() => _TopupFormModalState();
}

class _TopupFormModalState extends ConsumerState<TopupFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _nominalController = TextEditingController();
  final _keteranganController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nominalController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Decimal _parseNominal(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return Decimal.zero;
    return Decimal.parse(cleaned);
  }

  void _formatNominalInput(String value) {
    final decimal = _parseNominal(value);
    if (decimal == Decimal.zero) {
      _nominalController.value = TextEditingValue.empty;
      return;
    }

    final formatted = CurrencyFormatter.format(decimal);
    _nominalController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<void> _handleSubmit() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    final nominal = _parseNominal(_nominalController.text);
    if (nominal <= Decimal.zero) {
      setState(() {
        _errorMessage = 'Nominal top up harus lebih besar dari Rp 0.';
      });
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await ref.read(saldoControllerProvider.notifier).createTopup(
      tanggal: _selectedDate,
      nominal: nominal,
      keterangan: _keteranganController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Top Up Dana Modal berhasil dicatat.'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final state = ref.read(saldoControllerProvider);
      setState(() {
        _errorMessage = state.errorMessage ?? 'Gagal menyimpan catatan Top Up.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Top Up Dana Modal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F1),
                      border: Border.all(color: AppColors.error),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 18, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Field Tanggal Top Up
                const Text(
                  'Tanggal Top Up',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _isSubmitting ? null : _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.hairline),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateFormat.format(_selectedDate),
                          style: const TextStyle(fontSize: 13, color: AppColors.ink),
                        ),
                        const Icon(Icons.calendar_today, size: 16, color: AppColors.inkMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Field Nominal Top Up
                const Text(
                  'Nominal Top Up (Rp)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  key: const Key('nominal_topup_input'),
                  controller: _nominalController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Rp 0',
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined, size: 18),
                  ),
                  onChanged: _formatNominalInput,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nominal top up wajib diisi.';
                    }
                    final decimal = _parseNominal(value);
                    if (decimal <= Decimal.zero) {
                      return 'Nominal harus lebih besar dari Rp 0.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Field Keterangan Opsional
                const Text(
                  'Keterangan (Opsional)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  key: const Key('keterangan_topup_input'),
                  controller: _keteranganController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Modal kas awal operasional panen raya...',
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Submit
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      key: const Key('submit_topup_button'),
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check, size: 18),
                      label: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan Top Up'),
                      onPressed: _isSubmitting ? null : _handleSubmit,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
