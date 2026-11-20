import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/weight_formatter.dart';
import '../../core/widgets/responsive_form_row.dart';
import '../../models/jenis_buah.dart';
import '../../models/transaksi.dart';
import '../penjual/widgets/penjual_picker.dart';
import 'jenis_buah_repository.dart';
import 'transaksi_form_controller.dart';
import 'transaksi_form_state.dart';

/// Halaman Input Transaksi Baru Multi-Item (FR-3.x & Bagian 10: Potongan Berat per Item).
/// Mengimplementasikan kalkulasi otomatis Berat Bersih = Berat Kotor x (1 - Potongan%),
/// Subtotal = Harga/kg x Berat Bersih, dan akumulasi total transaksi.
class TransaksiFormPage extends ConsumerStatefulWidget {
  const TransaksiFormPage({super.key});

  @override
  ConsumerState<TransaksiFormPage> createState() => _TransaksiFormPageState();
}

class _TransaksiFormPageState extends ConsumerState<TransaksiFormPage> {
  final _catatanController = TextEditingController();

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final formState = ref.read(transaksiFormProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: formState.tanggalTransaksi,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      ref.read(transaksiFormProvider.notifier).setTanggal(picked);
    }
  }

  Future<void> _handleSave() async {
    final formNotifier = ref.read(transaksiFormProvider.notifier);
    final result = await formNotifier.submitTransaksi(
      catatan: _catatanController.text,
    );

    if (result != null && mounted) {
      _showSuccessDialog(result);
    }
  }

  void _showSuccessDialog(TransaksiRingkasan ringkasan) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.canvas,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: AppColors.success, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Transaksi Berhasil Disimpan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Kode transaksi resmi telah dibuat otomatis oleh database:',
              style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
            ),
            const SizedBox(height: 12),

            // Box Kode Transaksi Otomatis
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface1,
                border: Border.all(color: AppColors.hairline),
              ),
              child: Column(
                children: [
                  const Text(
                    'KODE TRANSAKSI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkSubtle,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    ringkasan.kodeTransaksi,
                    key: const Key('created_kode_transaksi_text'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Rincian Singkat Nota Transaksi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Penjual:', style: TextStyle(fontSize: 13)),
                Text(
                  ringkasan.namaPenjual,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Jenis Pembayaran:', style: TextStyle(fontSize: 13)),
                Text(
                  ringkasan.isTunai ? 'Tunai (Kas)' : 'Non Tunai',
                  key: const Key('created_jenis_pembayaran_text'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ringkasan.isTunai ? AppColors.success : AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Berat Kotor:', style: TextStyle(fontSize: 13)),
                Text(
                  WeightFormatter.format(ringkasan.totalBeratKotorKg),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Berat Bersih:', style: TextStyle(fontSize: 13)),
                Text(
                  WeightFormatter.format(ringkasan.totalBeratBersihKg),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Potongan (Rp):',
                  style: TextStyle(fontSize: 13, color: AppColors.error),
                ),
                Text(
                  '- ${CurrencyFormatter.format(ringkasan.totalPotonganRp)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: AppColors.hairline, height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Nilai Transaksi:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(ringkasan.totalNilai),
                  key: const Key('created_transaksi_total_bersih_text'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            key: const Key('transaksi_sukses_ok_button'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _catatanController.clear();
              ref.read(transaksiFormProvider.notifier).resetForm();
            },
            child: const Text('Input Transaksi Baru'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return DateFormat('yyyy-MM-dd').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(transaksiFormProvider);
    final formNotifier = ref.read(transaksiFormProvider.notifier);
    final fruitsAsync = ref.watch(activeJenisBuahProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Transaksi Baru'),
        actions: [
          TextButton.icon(
            onPressed: formState.isSaving ? null : () => formNotifier.resetForm(),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reset Form'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pesan Error jika submit gagal
            if (formState.errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  border: const Border(
                    left: BorderSide(color: AppColors.error, width: 4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        formState.errorMessage!,
                        key: const Key('form_error_banner'),
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // SEKSI 1: Informasi Dasar (Penjual & Tanggal)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1. INFORMASI TRANSAKSI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ResponsiveFormRow(
                      breakpoint: 600,
                      flexes: const [3, 2],
                      children: [
                        PenjualPicker(
                          selectedPenjual: formState.selectedPenjual,
                          onChanged: (p) => formNotifier.setPenjual(p),
                        ),
                        InkWell(
                          key: const Key('transaksi_date_picker_field'),
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            key: const Key('tanggal_transaksi_picker_button'),
                            decoration: const InputDecoration(
                              labelText: 'Tanggal Transaksi *',
                              suffixIcon: Icon(Icons.calendar_today, size: 20),
                            ),
                            child: Text(
                              _formatDate(formState.tanggalTransaksi),
                              key: const Key('tanggal_transaksi_text'),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Input Pilihan Jenis Pembayaran (Tunai / Non Tunai) (PRD §7.3 FR-3.8)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jenis Pembayaran *',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (context, box) {
                            final isNarrow = box.maxWidth < 500;
                            final tunaiOption = InkWell(
                              key: const Key('radio_jenis_pembayaran_tunai'),
                              onTap: () => formNotifier.setJenisPembayaran('tunai'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: formState.isTunai
                                      ? AppColors.primary.withValues(alpha: 0.08)
                                      : AppColors.canvas,
                                  border: Border.all(
                                    color: formState.isTunai ? AppColors.primary : AppColors.hairline,
                                    width: formState.isTunai ? 1.5 : 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      formState.isTunai ? Icons.radio_button_checked : Icons.radio_button_off,
                                      size: 18,
                                      color: formState.isTunai ? AppColors.primary : AppColors.inkSubtle,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Tunai (Cash)',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: formState.isTunai ? FontWeight.bold : FontWeight.w500,
                                              color: formState.isTunai ? AppColors.primary : AppColors.ink,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );

                            final nonTunaiOption = InkWell(
                              key: const Key('radio_jenis_pembayaran_non_tunai'),
                              onTap: () => formNotifier.setJenisPembayaran('non_tunai'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: formState.isNonTunai
                                      ? AppColors.primary.withValues(alpha: 0.08)
                                      : AppColors.canvas,
                                  border: Border.all(
                                    color: formState.isNonTunai ? AppColors.primary : AppColors.hairline,
                                    width: formState.isNonTunai ? 1.5 : 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      formState.isNonTunai ? Icons.radio_button_checked : Icons.radio_button_off,
                                      size: 18,
                                      color: formState.isNonTunai ? AppColors.primary : AppColors.inkSubtle,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Non Tunai (Transfer / Tunda)',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: formState.isNonTunai ? FontWeight.bold : FontWeight.w500,
                                              color: formState.isNonTunai ? AppColors.primary : AppColors.ink,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );

                            if (isNarrow) {
                              return Column(
                                children: [
                                  tunaiOption,
                                  const SizedBox(height: 8),
                                  nonTunaiOption,
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(child: tunaiOption),
                                const SizedBox(width: 12),
                                Expanded(child: nonTunaiOption),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // SEKSI 2: Rincian Berat & Potongan per Jenis Buah
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            '2. RINCIAN BERAT & POTONGAN PER JENIS BUAH',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.inkMuted,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${formState.itemRows.length} dari 3 Jenis Buah',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.inkSubtle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Daftar Baris Item
                    fruitsAsync.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (err, _) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Gagal memuat jenis buah: $err',
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                      data: (availableFruits) {
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: formState.itemRows.length,
                          separatorBuilder: (ctx, idx) =>
                              const SizedBox(height: 12),
                          itemBuilder: (ctx, idx) {
                            final row = formState.itemRows[idx];
                            final usedOtherIds = formState.itemRows
                                .asMap()
                                .entries
                                .where((e) => e.key != idx)
                                .map((e) => e.value.selectedJenisBuah?.id)
                                .whereType<int>()
                                .toSet();

                            return _TransaksiItemRowWidget(
                              key: ValueKey(row.keyId),
                              index: idx,
                              rowState: row,
                              availableFruits: availableFruits,
                              usedFruitIdsInOtherRows: usedOtherIds,
                              canRemove: formState.itemRows.length > 1,
                              onFruitChanged: (fruit) {
                                formNotifier.setRowJenisBuah(idx, fruit);
                              },
                              onRemove: () {
                                formNotifier.removeRow(idx);
                              },
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tombol Tambah Baris Baru
                    OutlinedButton.icon(
                      key: const Key('tambah_jenis_buah_button'),
                      onPressed: formState.canAddRow
                          ? () => formNotifier.addRow()
                          : null,
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(
                        formState.canAddRow
                            ? 'Tambah Jenis Buah'
                            : 'Maksimal 3 Jenis Buah Tercapai',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // SEKSI 3: Catatan Transaksi (Opsional)
            TextField(
              controller: _catatanController,
              decoration: const InputDecoration(
                labelText: 'Catatan Transaksi (Opsional)',
                hintText: 'Contoh: Plat armada BM 1234 XX / catatan kualitas buah',
              ),
            ),
            const SizedBox(height: 32),

            // SEKSI 4: Ringkasan Total Real-Time (Bottom Sticky Summary)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface1,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 960;

                  final summaryItems = [
                    // Kolom Total Berat Kotor
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL BERAT KOTOR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          WeightFormatter.format(formState.totalBeratKotorKg),
                          key: const Key('summary_total_berat_kotor_text'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),

                    // Kolom Total Berat Bersih
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL BERAT BERSIH',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          WeightFormatter.format(formState.totalBeratBersihKg),
                          key: const Key('summary_total_berat_text'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),

                    // Kolom Total Potongan (Rp)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL POTONGAN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '- ${CurrencyFormatter.format(formState.totalPotonganRp)}',
                          key: const Key('summary_potongan_text'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),

                    // Kolom Total Nilai Transaksi
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL NILAI TRANSAKSI',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(formState.totalNilai),
                          key: const Key('summary_total_bersih_text'),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ];

                  final saveButton = ElevatedButton(
                    key: const Key('simpan_transaksi_button'),
                    onPressed: formState.isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                    ),
                    child: formState.isSaving
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('Menyimpan Transaksi...'),
                            ],
                          )
                        : const Text(
                            'Simpan Transaksi',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );

                  if (isWide) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 28,
                            runSpacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: summaryItems,
                          ),
                        ),
                        const SizedBox(width: 16),
                        saveButton,
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 24,
                        runSpacing: 16,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        children: summaryItems,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: saveButton,
                      ),
                    ],
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

/// Widget baris item transaksi dengan potongan berat per jenis buah
class _TransaksiItemRowWidget extends StatelessWidget {
  final int index;
  final TransaksiItemRowState rowState;
  final List<JenisBuah> availableFruits;
  final Set<int> usedFruitIdsInOtherRows;
  final bool canRemove;
  final ValueChanged<JenisBuah?> onFruitChanged;
  final VoidCallback onRemove;

  const _TransaksiItemRowWidget({
    super.key,
    required this.index,
    required this.rowState,
    required this.availableFruits,
    required this.usedFruitIdsInOtherRows,
    required this.canRemove,
    required this.onFruitChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // Saring opsi buah agar tidak ada duplikasi
    final selectableFruits = availableFruits.where((f) {
      if (rowState.selectedJenisBuah?.id == f.id) return true;
      return !usedFruitIdsInOtherRows.contains(f.id);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Baris
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    color: AppColors.primary,
                    child: Text(
                      'ITEM ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (rowState.selectedJenisBuah != null)
                    Text(
                      rowState.selectedJenisBuah!.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.ink,
                      ),
                    ),
                ],
              ),
              if (canRemove)
                IconButton(
                  tooltip: 'Hapus baris item ini',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                  onPressed: onRemove,
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Fields Input: Jenis Buah, Harga/kg, Berat Kotor kg, Potongan %, Berat Bersih, Subtotal
          LayoutBuilder(
            builder: (context, constraints) {
              final fruitDropdown = DropdownButtonFormField<JenisBuah>(
                key: Key('item_${index}_fruit_dropdown'),
                initialValue: rowState.selectedJenisBuah,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Jenis Buah *',
                  hintText: 'Pilih jenis buah',
                ),
                items: selectableFruits.map((fruit) {
                  return DropdownMenuItem<JenisBuah>(
                    value: fruit,
                    child: Text('${fruit.nama} (${fruit.kode})'),
                  );
                }).toList(),
                onChanged: onFruitChanged,
              );

              final hargaInput = TextFormField(
                key: Key('item_${index}_harga_input'),
                controller: rowState.hargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga / kg *',
                  hintText: 'Contoh: 2500',
                  prefixText: 'Rp ',
                ),
              );

              final beratKotorInput = TextFormField(
                key: Key('item_${index}_berat_input'),
                controller: rowState.beratController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Berat Kotor (kg) *',
                  hintText: 'Contoh: 100',
                  suffixText: 'kg',
                ),
              );

              final potonganInput = TextFormField(
                key: Key('item_${index}_potongan_input'),
                controller: rowState.potonganController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Potongan (%)',
                  hintText: '0',
                  suffixText: '%',
                  errorText: !rowState.isPotonganValid ? '0-100%' : null,
                ),
              );

              final beratBersihDisplay = Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Berat Bersih:',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      WeightFormatter.format(rowState.beratBersihKg),
                      key: Key('item_${index}_berat_bersih_text'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              );

              final subtotalDisplay = Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Subtotal (Otomatis):',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(rowState.subtotal),
                      key: Key('item_${index}_subtotal_text'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );

              final isDesktop = constraints.maxWidth > 920;
              final isTablet = constraints.maxWidth >= 580;

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: fruitDropdown),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: hargaInput),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: beratKotorInput),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: potonganInput),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: beratBersihDisplay),
                    const SizedBox(width: 8),
                    Expanded(flex: 3, child: subtotalDisplay),
                  ],
                );
              }

              if (isTablet) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    fruitDropdown,
                    const SizedBox(height: 12),
                    ResponsiveFormRow(
                      breakpoint: 500,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        hargaInput,
                        beratKotorInput,
                      ],
                    ),
                    const SizedBox(height: 12),
                    ResponsiveFormRow(
                      breakpoint: 500,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        potonganInput,
                        beratBersihDisplay,
                      ],
                    ),
                    const SizedBox(height: 12),
                    subtotalDisplay,
                  ],
                );
              }

              // Layar Mobile (< 580px): Setiap field membentang penuh (Full Width)
              // Menghilangkan desakan kolom 140px dan overflow RenderFlex
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  fruitDropdown,
                  const SizedBox(height: 12),
                  hargaInput,
                  const SizedBox(height: 12),
                  beratKotorInput,
                  const SizedBox(height: 12),
                  potonganInput,
                  const SizedBox(height: 12),
                  beratBersihDisplay,
                  const SizedBox(height: 12),
                  subtotalDisplay,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
