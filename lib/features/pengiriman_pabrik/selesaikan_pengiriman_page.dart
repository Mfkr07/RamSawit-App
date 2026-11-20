import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/weight_formatter.dart';
import '../../core/widgets/responsive_form_row.dart';
import '../../models/pengiriman_pabrik.dart';
import 'pengiriman_pabrik_controller.dart';

/// Halaman Fase 2: Penyelesaian Pengiriman ke Pabrik (FR-8.3, FR-8.4).
/// Menginput Berat Sampai (kg), Berat Ditolak (kg), Potongan Pabrik (%), dan Harga Jual/kg dari slip timbang PKS.
/// Menyimpan dengan status 'selesai'.
class SelesaikanPengirimanPage extends ConsumerStatefulWidget {
  final PengirimanPabrik pengiriman;

  const SelesaikanPengirimanPage({
    super.key,
    required this.pengiriman,
  });

  @override
  ConsumerState<SelesaikanPengirimanPage> createState() =>
      _SelesaikanPengirimanPageState();
}

class _SelesaikanPengirimanPageState
    extends ConsumerState<SelesaikanPengirimanPage> {
  final _formKey = GlobalKey<FormState>();
  final _beratSampaiController = TextEditingController();
  final _beratDitolakController = TextEditingController(text: '0');
  final _potonganController = TextEditingController(text: '0');
  final _hargaJualController = TextEditingController();
  final _potonganLainnyaController = TextEditingController();
  final _potonganSortasiController = TextEditingController();
  final _catatanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inisialisasi catatan jika sudah ada sebelumnya
    if (widget.pengiriman.catatan != null &&
        widget.pengiriman.catatan!.isNotEmpty) {
      _catatanController.text = widget.pengiriman.catatan!;
    }
  }

  @override
  void dispose() {
    _beratSampaiController.dispose();
    _beratDitolakController.dispose();
    _potonganController.dispose();
    _hargaJualController.dispose();
    _potonganLainnyaController.dispose();
    _potonganSortasiController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _handleSelesaikan() async {
    if (!_formKey.currentState!.validate()) return;

    final formNotifier =
        ref.read(selesaikanFormProvider(widget.pengiriman).notifier);
    formNotifier.setCatatan(_catatanController.text);

    final completed = await formNotifier.submit();
    if (completed != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pengiriman ${completed.kodePengiriman} berhasil diselesaikan. Status: SELESAI.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(completed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(selesaikanFormProvider(widget.pengiriman));
    final formNotifier =
        ref.read(selesaikanFormProvider(widget.pengiriman).notifier);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Selesaikan Pengiriman Pabrik (Fase 2)'),
        backgroundColor: AppColors.surface1,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width < 500 ? 12.0 : 24.0,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Info
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Penyelesaian Pengiriman: ${widget.pengiriman.kodePengiriman}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Input hasil timbangan pabrik dan kesepakatan harga dari slip timbang PKS untuk menyelesaikan transaksi.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Text(
                          'STATUS SAAT INI: BERANGKAT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

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
                          const SizedBox(width: 10),
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

                  // Kartu Ringkasan Data Awal Keberangkatan (Fase 1)
                  _buildPengirimanSummaryCard(widget.pengiriman),
                  const SizedBox(height: 20),

                  // Layout Dua Kolom untuk Desktop / Vertikal untuk Mobile
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildInputCard(formState, formNotifier),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: _buildLiveCalculationCard(formState),
                        ),
                      ],
                    )
                  else ...[
                    _buildInputCard(formState, formNotifier),
                    const SizedBox(height: 20),
                    _buildLiveCalculationCard(formState),
                  ],

                  const SizedBox(height: 24),

                  // Tombol Simpan & Batal
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OutlinedButton(
                        onPressed: formState.isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(2.0)),
                          ),
                        ),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton.icon(
                        key: const Key('simpan_penyelesaian_button'),
                        onPressed:
                            formState.isSubmitting ? null : _handleSelesaikan,
                        icon: formState.isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline, size: 20),
                        label: Text(
                          formState.isSubmitting
                              ? 'Menyimpan...'
                              : 'Selesaikan & Kunci Transaksi',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(2.0)),
                          ),
                        ),
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

  /// Kartu Informasi Keberangkatan (Fase 1)
  Widget _buildPengirimanSummaryCard(PengirimanPabrik p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        border: Border.all(color: AppColors.hairline),
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
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 250),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.local_shipping_outlined,
                        size: 16, color: AppColors.inkSubtle),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'KEBERANGKATAN (FASE 1)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkSubtle,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Tanggal: ${DateFormat('d MMM yyyy', 'id_ID').format(p.tanggalKirim)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.inkMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.hairline, height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              final items = [
                _buildInfoItem(
                  'PABRIK TUJUAN',
                  p.pabrik?.nama ?? 'Pabrik ID: ${p.pabrikId}',
                  isBold: true,
                ),
                _buildInfoItem(
                  'ARMADA / PLAT NOMOR',
                  p.platNomor,
                ),
                _buildInfoItem(
                  'SOPIR / PENANGGUNG JAWAB',
                  p.namaSopir,
                ),
                _buildInfoItem(
                  'BERAT DIKIRIM (AWAL)',
                  WeightFormatter.format(p.beratDikirimKg),
                  isBold: true,
                  color: AppColors.primary,
                ),
              ];

              if (isWide) {
                return Row(
                  children: items.map((w) => Expanded(child: w)).toList(),
                );
              }

              return Wrap(
                spacing: 16,
                runSpacing: 12,
                children: items
                    .map((w) => SizedBox(
                          width: constraints.maxWidth < 300
                              ? double.infinity
                              : (constraints.maxWidth - 16) / 2,
                          child: w,
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value,
      {bool isBold = false, Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.inkSubtle,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color ?? AppColors.ink,
          ),
        ),
      ],
    );
  }

  /// Kartu Input Formulir Fase 2
  Widget _buildInputCard(
    SelesaikanFormState formState,
    SelesaikanFormNotifier formNotifier,
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
            'INPUT HASIL PENERIMAAN PABRIK (SLIP TIMBANG & SORTASI)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),

          // Field 1: Berat Sampai di Pabrik (kg) - WAJIB > 0
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Berat Sampai di Pabrik (kg) *',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                key: const Key('selesaikan_berat_sampai_input'),
                controller: _beratSampaiController,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                decoration: const InputDecoration(
                  hintText: 'Hasil timbang bruto pabrik (kg)',
                  helperText: 'Timbangan kotor saat tiba di pabrik (wajib diisi)',
                  suffixText: 'kg',
                  prefixIcon: Icon(Icons.scale, size: 18),
                ),
                onChanged: (val) {
                  final parsed = WeightFormatter.parse(val);
                  formNotifier.setBeratSampai(parsed);
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Berat sampai di pabrik wajib diisi';
                  }
                  final parsed = WeightFormatter.parse(val);
                  if (parsed == null || parsed <= Decimal.zero) {
                    return 'Berat sampai harus > 0 kg';
                  }
                  return null;
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Baris Berat Ditolak & Potongan Pabrik (Adaptif Responsif)
          ResponsiveFormRow(
            breakpoint: 540,
            spacing: 16,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Berat Ditolak Pabrik (kg)',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    key: const Key('selesaikan_berat_ditolak_input'),
                    controller: _beratDitolakController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(
                      hintText: '0',
                      helperText: 'Buah yang dibawa pulang / afkir',
                      suffixText: 'kg',
                    ),
                    onChanged: (val) {
                      final parsed =
                          WeightFormatter.parse(val) ?? Decimal.zero;
                      formNotifier.setBeratDitolak(parsed);
                    },
                    validator: (val) {
                      if (val != null && val.trim().isNotEmpty) {
                        final parsed = WeightFormatter.parse(val);
                        if (parsed == null || parsed < Decimal.zero) {
                          return 'Berat ditolak >= 0 kg';
                        }
                        if (formState.beratSampai != null &&
                            parsed > formState.beratSampai!) {
                          return 'Tidak boleh > berat sampai';
                        }
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
                    'Potongan Sortasi Pabrik (%)',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    key: const Key('selesaikan_potongan_input'),
                    controller: _potonganController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(
                      hintText: '0',
                      helperText: 'Potongan air/sampah/tangkai panjang',
                      suffixText: '%',
                    ),
                    onChanged: (val) {
                      final parsed =
                          WeightFormatter.parse(val) ?? Decimal.zero;
                      formNotifier.setPersentasePotongan(parsed);
                    },
                    validator: (val) {
                      if (val != null && val.trim().isNotEmpty) {
                        final parsed = WeightFormatter.parse(val);
                        if (parsed == null ||
                            parsed < Decimal.zero ||
                            parsed > Decimal.fromInt(100)) {
                          return 'Rentang 0 - 100%';
                        }
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Harga Jual / kg
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Harga Jual Kesepakatan / kg (Rp) *',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                key: const Key('selesaikan_harga_jual_input'),
                controller: _hargaJualController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'Contoh: 2200',
                  prefixText: 'Rp ',
                ),
                onChanged: (val) {
                  final parsed = CurrencyFormatter.parse(val);
                  formNotifier.setHargaJualPerKg(parsed);
                },
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Harga jual wajib diisi';
                  }
                  final parsed = CurrencyFormatter.parse(val);
                  if (parsed == null || parsed <= Decimal.zero) {
                    return 'Harga jual harus > Rp 0';
                  }
                  return null;
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Baris Potongan Lainnya (Rp) & Potongan Sortasi (Rp/kg) (FR-8.3 Diperbarui)
          ResponsiveFormRow(
            breakpoint: 540,
            spacing: 16,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Potongan Lainnya (Rp)',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    key: const Key('selesaikan_potongan_lainnya_input'),
                    controller: _potonganLainnyaController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(
                      hintText: '0 (Opsional)',
                      helperText: 'Nominal tetap langsung mengurangi total',
                      prefixText: 'Rp ',
                    ),
                    onChanged: (val) {
                      final parsed = CurrencyFormatter.parse(val);
                      formNotifier.setPotonganLainnya(parsed);
                    },
                    validator: (val) {
                      if (val != null && val.trim().isNotEmpty) {
                        final parsed = CurrencyFormatter.parse(val);
                        if (parsed == null || parsed < Decimal.zero) {
                          return 'Nominal >= Rp 0';
                        }
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
                    'Potongan Sortasi (Rp/kg)',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    key: const Key('selesaikan_potongan_sortasi_input'),
                    controller: _potonganSortasiController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    decoration: const InputDecoration(
                      hintText: '0 (Opsional)',
                      helperText: 'Tarif / kg dikalikan Berat Sampai',
                      prefixText: 'Rp ',
                      suffixText: '/ kg',
                    ),
                    onChanged: (val) {
                      final parsed = CurrencyFormatter.parse(val);
                      formNotifier.setPotonganSortasiPerKg(parsed);
                    },
                    validator: (val) {
                      if (val != null && val.trim().isNotEmpty) {
                        final parsed = CurrencyFormatter.parse(val);
                        if (parsed == null || parsed < Decimal.zero) {
                          return 'Tarif >= Rp 0';
                        }
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Catatan Penyelesaian
          const Text(
            'Catatan Tambahan / No. Slip PKS',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextFormField(
            key: const Key('selesaikan_catatan_input'),
            controller: _catatanController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Contoh: No Slip Timbang PKS-9821, sortasi sampah normal',
            ),
          ),
        ],
      ),
    );
  }

  /// Kartu Real-Time Live Calculation Fase 2
  Widget _buildLiveCalculationCard(SelesaikanFormState formState) {
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
                  'PREVIEW KALKULASI PENJUALAN',
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

          // 1. Susut Buah (kg)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              border: Border.all(color: AppColors.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    const Text(
                      '1. SUSUT BUAH (TRANSPORTASI)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkSubtle,
                      ),
                    ),
                    Text(
                      'Berat Dikirim − Berat Sampai',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.inkSubtle.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SelectableText(
                  WeightFormatter.format(formState.susutBuah),
                  key: const Key('selesaikan_live_susut_buah'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: formState.susutBuah > Decimal.zero
                        ? Colors.orange.shade800
                        : AppColors.ink,
                  ),
                ),
                Text(
                  formState.beratSampai != null
                      ? '${WeightFormatter.format(widget.pengiriman.beratDikirimKg)} − ${WeightFormatter.format(formState.safeBeratSampai)}'
                      : 'Isi Berat Sampai untuk melihat susut',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 2. Berat Diterima
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              border: Border.all(color: AppColors.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    const Text(
                      '2. BERAT DITERIMA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkSubtle,
                      ),
                    ),
                    Text(
                      'Berat Sampai − Ditolak',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.inkSubtle.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SelectableText(
                  WeightFormatter.format(formState.beratDiterima),
                  key: const Key('selesaikan_live_berat_diterima'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  formState.beratSampai != null
                      ? '${WeightFormatter.format(formState.safeBeratSampai)} − ${WeightFormatter.format(formState.safeBeratDitolak)}'
                      : 'Isi Berat Sampai untuk melihat hasil',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 3. Berat Bersih
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              border: Border.all(color: AppColors.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    const Text(
                      '3. BERAT BERSIH (NETTO)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkSubtle,
                      ),
                    ),
                    Text(
                      'Diterima × (1 − ${formState.safePersentasePotongan}%)',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.inkSubtle.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SelectableText(
                  WeightFormatter.format(formState.beratBersih),
                  key: const Key('selesaikan_live_berat_bersih'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  formState.safePersentasePotongan > Decimal.zero
                      ? 'Potongan ${formState.safePersentasePotongan}% (−${WeightFormatter.format(formState.beratDiterima - formState.beratBersih)})'
                      : 'Tanpa potongan sortasi (0%)',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 4. Nilai Potongan Sortasi (Rp) (FR-8.3 Diperbarui)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              border: Border.all(color: AppColors.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    const Text(
                      '4. NILAI POTONGAN SORTASI (RP)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkSubtle,
                      ),
                    ),
                    Text(
                      'Sortasi (Rp/kg) × Berat Sampai',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.inkSubtle.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SelectableText(
                  CurrencyFormatter.format(formState.nilaiPotonganSortasi),
                  key: const Key('selesaikan_live_nilai_potongan_sortasi'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: formState.nilaiPotonganSortasi > Decimal.zero
                        ? AppColors.error
                        : AppColors.ink,
                  ),
                ),
                Text(
                  formState.safePotonganSortasiPerKg > Decimal.zero
                      ? '${CurrencyFormatter.format(formState.safePotonganSortasiPerKg)}/kg × ${WeightFormatter.format(formState.safeBeratSampai)}'
                      : 'Tidak ada potongan sortasi Rp/kg',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 5. Total Nilai Jual
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    Text(
                      '5. TOTAL NILAI JUAL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Icon(
                      Icons.monetization_on_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SelectableText(
                  CurrencyFormatter.format(formState.totalNilaiJual),
                  key: const Key('selesaikan_live_total_nilai_jual'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formState.hargaJualPerKg != null
                      ? (formState.safePotonganLainnya > Decimal.zero ||
                              formState.nilaiPotonganSortasi > Decimal.zero)
                          ? '${CurrencyFormatter.format(formState.hargaJualPerKg! * formState.beratBersih)} − ${CurrencyFormatter.format(formState.safePotonganLainnya)} (Lainnya) − ${CurrencyFormatter.format(formState.nilaiPotonganSortasi)} (Sortasi)'
                          : '${WeightFormatter.format(formState.beratBersih)} × ${CurrencyFormatter.format(formState.hargaJualPerKg)}/kg'
                      : 'Masukkan harga jual/kg untuk melihat total',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.inkMuted,
                  ),
                ),
                if (formState.nilaiPotonganRp > Decimal.zero) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Potongan berat pabrik: ${CurrencyFormatter.format(formState.nilaiPotonganRp)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
