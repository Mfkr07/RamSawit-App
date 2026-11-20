import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/weight_formatter.dart';
import '../../core/widgets/responsive_form_row.dart';
import '../../models/pengiriman_pabrik.dart';
import '../pabrik/widgets/pabrik_picker.dart';
import 'pengiriman_pabrik_controller.dart';

/// Halaman Formulir Input Pengiriman Penjualan TBS ke Pabrik - Fase 1: Keberangkatan (FR-8.1, FR-8.2).
/// Pada fase ini hanya dicatat: Pabrik tujuan, armada (plat nomor & sopir), tanggal kirim, dan berat kotor awal.
/// Data hasil pabrik (berat ditolak, potongan%, harga jual/kg) dicatat pada Fase 2 di menu Riwayat Pengiriman.
class PengirimanPabrikFormPage extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToRiwayat;

  const PengirimanPabrikFormPage({
    super.key,
    this.onNavigateToRiwayat,
  });

  @override
  ConsumerState<PengirimanPabrikFormPage> createState() =>
      _PengirimanPabrikFormPageState();
}

class _PengirimanPabrikFormPageState
    extends ConsumerState<PengirimanPabrikFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _platNomorController = TextEditingController();
  final _namaSopirController = TextEditingController();
  final _beratDikirimController = TextEditingController();
  final _catatanController = TextEditingController();

  @override
  void dispose() {
    _platNomorController.dispose();
    _namaSopirController.dispose();
    _beratDikirimController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _resetLocalControllers() {
    _platNomorController.clear();
    _namaSopirController.clear();
    _beratDikirimController.clear();
    _catatanController.clear();
    ref.read(pengirimanFormProvider.notifier).resetForm();
  }

  Future<void> _selectTanggal(BuildContext context) async {
    final formState = ref.read(pengirimanFormProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: formState.tanggalKirim,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      ref.read(pengirimanFormProvider.notifier).setTanggalKirim(picked);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final formNotifier = ref.read(pengirimanFormProvider.notifier);
    formNotifier.setPlatNomor(_platNomorController.text);
    formNotifier.setNamaSopir(_namaSopirController.text);
    formNotifier.setCatatan(_catatanController.text);

    final saved = await formNotifier.submit();
    if (saved != null && mounted) {
      _showSuccessDialog(saved);
    }
  }

  void _showSuccessDialog(PengirimanPabrik pengiriman) {
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
              child:
                  const Icon(Icons.check, color: AppColors.success, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Keberangkatan Truk Berhasil Dicatat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Truk telah dicatat dengan status BERANGKAT. Kode resmi telah dibuat oleh database:',
                style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
              ),
              const SizedBox(height: 12),

              // Kotak Kode Pengiriman Resmi
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface1,
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Column(
                  children: [
                    const Text(
                      'KODE PENGIRIMAN PABRIK',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkSubtle,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      pengiriman.kodePengiriman,
                      key: const Key('created_kode_pengiriman_text'),
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

              // Rincian Ringkas
              _buildDetailRow(
                'Pabrik Tujuan:',
                pengiriman.pabrik?.nama ?? 'Pabrik ID: ${pengiriman.pabrikId}',
                isBold: true,
              ),
              _buildDetailRow('Armada & Sopir:',
                  '${pengiriman.platNomor} (${pengiriman.namaSopir})'),
              _buildDetailRow(
                'Tanggal Kirim:',
                DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                    .format(pengiriman.tanggalKirim),
              ),
              const Divider(color: AppColors.hairline, height: 16),
              _buildDetailRow(
                'Berat Dikirim Awal:',
                WeightFormatter.format(pengiriman.beratDikirimKg),
                isBold: true,
                textColor: AppColors.primary,
              ),
              _buildDetailRow(
                'Status Pengiriman:',
                'BERANGKAT',
                isBold: true,
                textColor: Colors.orange.shade800,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.orange.shade800),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Setelah armada kembali dengan membawa slip timbang pabrik, silakan selesaikan (Fase 2) di menu Riwayat Pengiriman untuk melengkapi berat ditolak, potongan sortasi, dan harga jual/kg.',
                        style: TextStyle(fontSize: 11, color: AppColors.inkMuted, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            key: const Key('tutup_dialog_pengiriman_btn'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetLocalControllers();
            },
            child: const Text('Catat Truk Lain'),
          ),
          if (widget.onNavigateToRiwayat != null)
            ElevatedButton(
              key: const Key('ke_riwayat_pengiriman_btn'),
              onPressed: () {
                Navigator.of(ctx).pop();
                _resetLocalControllers();
                widget.onNavigateToRiwayat!();
              },
              child: const Text('Ke Riwayat Pengiriman'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 13,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: textColor ?? AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(pengirimanFormProvider);
    final formNotifier = ref.read(pengirimanFormProvider.notifier);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Judul Halaman
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 650),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Form Keberangkatan Pengiriman ke Pabrik (Fase 1)',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Pencatatan awal keberangkatan armada pengantar TBS ke PKS tujuan (status: berangkat).',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.onNavigateToRiwayat != null)
                        OutlinedButton.icon(
                          onPressed: widget.onNavigateToRiwayat,
                          icon: const Icon(Icons.history, size: 16),
                          label: const Text('Riwayat Pengiriman'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (formState.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              formState.errorMessage!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Layout: 2 Kolom di Desktop (Form Input Kiri, Panduan Alur Kanan)
                  isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: _buildInputCard(formState, formNotifier),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 4,
                              child: _buildFaseInfoCard(formState),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildInputCard(formState, formNotifier),
                            const SizedBox(height: 20),
                            _buildFaseInfoCard(formState),
                          ],
                        ),

                  const SizedBox(height: 28),

                  // Tombol Aksi Simpan
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: formState.isSubmitting
                            ? null
                            : _resetLocalControllers,
                        child: const Text('Reset Form'),
                      ),
                      ElevatedButton.icon(
                        key: const Key('pengiriman_submit_btn'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                        onPressed:
                            formState.isSubmitting ? null : _handleSave,
                        icon: formState.isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.local_shipping_outlined, size: 18),
                        label: Text(
                          formState.isSubmitting
                              ? 'Menyimpan ke Database...'
                              : 'Catat Keberangkatan Truk (Fase 1)',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Kartu Form Input Field Pengiriman Fase 1
  Widget _buildInputCard(
    PengirimanFormState formState,
    PengirimanFormNotifier formNotifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '1. INFORMASI TUJUAN & ARMADA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),

          // Picker Pabrik
          const Text(
            'Pabrik Kelapa Sawit (PKS) Tujuan *',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          PabrikPicker(
            selectedPabrik: formState.pabrik,
            onChanged: (p) => formNotifier.setPabrik(p),
            validator: (val) {
              if (val == null) return 'Pabrik tujuan wajib dipilih';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Baris Plat Nomor & Sopir (Adaptif Responsif)
          ResponsiveFormRow(
            breakpoint: 540,
            spacing: 16,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nomor Plat Truk *',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    key: const Key('pengiriman_plat_input'),
                    controller: _platNomorController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: BM 9123 AB',
                      prefixIcon: Icon(Icons.local_shipping_outlined, size: 18),
                    ),
                    onChanged: (val) => formNotifier.setPlatNomor(val),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Plat nomor truk wajib diisi';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nama Sopir / Penanggung Jawab *',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    key: const Key('pengiriman_sopir_input'),
                    controller: _namaSopirController,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Pak Budi',
                      prefixIcon: Icon(Icons.badge_outlined, size: 18),
                    ),
                    onChanged: (val) => formNotifier.setNamaSopir(val),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Nama sopir wajib diisi';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tanggal Kirim
          const Text(
            'Tanggal Kirim *',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          InkWell(
            key: const Key('pengiriman_tanggal_btn'),
            onTap: () => _selectTanggal(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                border: Border.all(color: AppColors.hairline),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 18, color: AppColors.inkMuted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                          .format(formState.tanggalKirim),
                      style: const TextStyle(fontSize: 14, color: AppColors.ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Ubah',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.hairline, height: 1),
          const SizedBox(height: 16),

          const Text(
            '2. TIMBANGAN AWAL (TIMBANG RAM / KEBUN)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),

          // Input Berat Dikirim
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Berat Dikirim Muatan TBS (kg) *',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                key: const Key('pengiriman_berat_kotor_input'),
                controller: _beratDikirimController,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                decoration: const InputDecoration(
                  hintText: 'Contoh: 10000',
                  helperText: 'Timbangan TBS sendiri sebelum truk berangkat',
                  suffixText: 'kg',
                  prefixIcon: Icon(Icons.scale_outlined, size: 18),
                ),
                onChanged: (val) {
                  final parsed = WeightFormatter.parse(val);
                  formNotifier.setBeratDikirim(parsed);
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Berat dikirim wajib diisi';
                  }
                  final parsed = WeightFormatter.parse(val);
                  if (parsed == null || parsed <= Decimal.zero) {
                    return 'Berat dikirim harus > 0 kg';
                  }
                  return null;
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Catatan Tambahan
          const Text(
            'Catatan Keberangkatan',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextFormField(
            key: const Key('pengiriman_catatan_input'),
            controller: _catatanController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Contoh: Muatan TBS panen blok A & B, SPK No. 12',
            ),
          ),
        ],
      ),
    );
  }

  /// Kartu Informasi Alur 2-Fase
  Widget _buildFaseInfoCard(PengirimanFormState formState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'ALUR PENGIRIMAN 2-FASE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Box Status Saat Ini (Fase 1)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Icon(Icons.local_shipping, size: 18, color: Colors.orange.shade800),
                        Text(
                          'FASE 1: KEBERANGKATAN',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade800,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Text(
                        'AKTIF',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Catat data truk dan timbangan awal muatan sebelum armada berangkat ke PKS. Pengiriman disimpan dengan status "berangkat".',
                  style: TextStyle(fontSize: 12, color: AppColors.ink, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Box Fase 2 (Penyelesaian)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              border: Border.all(color: AppColors.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: const [
                    Icon(Icons.receipt_long_outlined, size: 18, color: AppColors.inkMuted),
                    Text(
                      'FASE 2: PENYELESAIAN NOTA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Dilakukan di tab "Belum Selesai" pada menu Riwayat Pengiriman setelah truk kembali dengan membawa slip timbang pabrik (berat ditolak, potongan sortasi, dan harga jual/kg).',
                  style: TextStyle(fontSize: 12, color: AppColors.inkMuted, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Preview Timbangan Awal
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              border: Border.all(color: AppColors.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BERAT DIKIRIM TERINPUT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkSubtle,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  formState.beratDikirim != null
                      ? WeightFormatter.format(formState.beratDikirim!)
                      : '0 kg',
                  key: const Key('live_berat_kotor_preview'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Status saat disimpan: BERANGKAT',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
