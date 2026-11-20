# Laporan Pelaksanaan Tugas Bagian 19: Export Laporan Pendapatan

**Branch**: `fitur/laporan-pendapatan`  
**Target Dokumen**: `doc/PRD-Aplikasi-Transaksi-Sawit.md` (FR-7.8)  
**Tanggal**: 16 September 2026  
**Status**: SELESAI (100% Lulus Verifikasi Otomatis, Unit Test & Browser E2E)

---

## 1. Ringkasan Pekerjaan

Tugas Bagian 19 mengimplementasikan fitur ekspor baru **Laporan Pendapatan** (FR-7.8), melengkapi ekspor laporan operasional pembelian dan penjualan pabrik yang telah ada. Fitur ini dirancang khusus untuk ringkasan eksekutif dan evaluasi profitabilitas usaha bagi pemilik (Admin).

Fitur ini berjalan murni di sisi Flutter (client-side aggregation) dengan mengambil data harian dari database view `v_margin_harian` yang sudah ada, tanpa memerlukan migrasi database baru.

### Poin Utama Implementasi:
1. **Opsi Ekspor Laporan Pendapatan (FR-7.8)**:
   - Terpisah dari ekspor laporan pembelian detail dan pengiriman pabrik.
   - Pilihan cakupan periode:
     - **1 Tahun**: Dikelompokkan per kuartal (Kuartal 1: Jan–Mar, Kuartal 2: Apr–Jun, Kuartal 3: Jul–Sep, Kuartal 4: Okt–Des) $\rightarrow$ 4 baris data kuartalan.
     - **3 Bulan**: Dikelompokkan per 1 bulan (3 baris data bulanan untuk kuartal/tiga bulan yang dipilih).
     - **1 Bulan**: Dikelompokkan per minggu (Minggu 1: tgl 1–7, Minggu 2: tgl 8–14, Minggu 3: tgl 15–21, Minggu 4: tgl 22–28, Minggu 5: tgl 29–30/31) $\rightarrow$ 5 baris data mingguan.
2. **Kolom & Penghitungan Akurat**:
   - Kolom: `Periode`, `Total Pembelian (Rp)`, `Total Penjualan (Rp)`, `Margin (Rp)`.
   - Baris **Total Keseluruhan** di paling bawah yang menjumlahkan seluruh baris periode secara presisi menggunakan tipe data `Decimal` (anti-floating point error).
   - Indikator visual surplus/defisit: Margin positif berwarna biru/hijau dan surplus, margin negatif berwarna merah dengan tanda minus.
3. **Format Dokumen**:
   - **Microsoft Excel (.xlsx)**: Styling enterprise IBM Carbon, header aksen biru `#0F62FE`, pemisah ribuan Rupiah, baris total tebal, dan auto-fit lebar kolom.
   - **Dokumen PDF (.pdf)**: Format Portrait A4 formal, kop/header resmi Aplikasi Kasir TBS Sawit, metadata filter & tanggal cetak, tabel data, dan baris total berbingkai ganda.
4. **Role-Based Access Control (RBAC)**:
   - Fitur hanya dapat diakses oleh role **Admin**.
   - Role **Kasir** disembunyikan dari tombol header Dashboard, bilah navigasi drawer/sidebar, dan dilindungi guard otorisasi di layer repository.

---

## 2. File yang Dibuat dan Dimodifikasi

| No | File | Status | Keterangan |
|---|---|---|---|
| 1 | `lib/models/laporan_pendapatan.dart` | Baru | Model `CakupanLaporanPendapatan`, `LaporanPendapatanRow`, `LaporanPendapatanData`, dan algoritma `LaporanPendapatanAggregator` untuk pengelompokan 1 Tahun, 3 Bulan, dan 1 Bulan. |
| 2 | `lib/features/dashboard/export/laporan_pendapatan_excel_generator.dart` | Baru | Generator file Excel `.xlsx` dengan styling IBM Carbon, font formal, currency formatting, dan baris total. |
| 3 | `lib/features/dashboard/export/laporan_pendapatan_pdf_generator.dart` | Baru | Generator dokumen PDF `.pdf` ukuran A4 portrait dengan header profesional, tabel terstruktur, dan grand total. |
| 4 | `lib/features/dashboard/export/export_laporan_pendapatan_dialog.dart` | Baru | Modal dialog interaktif dengan pemilih cakupan (1 Tahun / 3 Bulan / 1 Bulan), pemilih tahun/kuartal/bulan, pratinjau tabel dinamis (*live preview*), pemilih format (Excel / PDF), dan tombol unduh. |
| 5 | `lib/core/widgets/main_layout_page.dart` | Diperbarui | Menambahkan menu "Laporan Pendapatan" pada sidebar dan drawer mobile di bawah kategori `LAPORAN & KEUANGAN`, terisolasi khusus role `Admin`. |
| 6 | `lib/features/dashboard/dashboard_page.dart` | Diperbarui | Menambahkan tombol aksi cepat "Laporan Pendapatan" di header dashboard bersebelahan dengan tombol aksi utama, khusus role `Admin`. |
| 7 | `test/bagian19_laporan_pendapatan_test.dart` | Baru | 10 unit test dan widget test komprehensif menguji grouping ketiga cakupan, penjumlahan grand total, generator Excel, generator PDF, RBAC repository guard, dan UI permission rendering. |

---

## 3. Hasil Pengujian & Verifikasi

### 3.1. Pengujian Otomatis (Unit & Widget Tests)
Seluruh pengujian unit dan widget pada `test/bagian19_laporan_pendapatan_test.dart` serta seluruh test suite proyek berjalan dengan sukses tanpa error:

```bash
flutter test
# Result: 00:09 +93: All tests passed! (93/93 Passed)
```

Ringkasan cakupan pengujian Bagian 19:
- **Test 1**: Pengelompokan 1 Tahun menghasilkan tepat 4 kuartal dengan agregasi pembelian, penjualan, dan margin yang akurat.
- **Test 2**: Pengelompokan 3 Bulan menghasilkan 3 baris bulanan berurutan.
- **Test 3**: Pengelompokan 1 Bulan menghasilkan 5 baris mingguan dengan pembagian tanggal 1–7, 8–14, 15–21, 22–28, dan 29–akhir bulan.
- **Test 4**: Verifikasi baris Total Keseluruhan menjumlahkan seluruh baris tanpa deviasi floating point.
- **Test 5**: Generator Excel menghasilkan byte buffer valid yang berisi data dan metadata laporan.
- **Test 6**: Generator PDF menghasilkan dokumen PDF valid yang berisi tabel dan grand total.
- **Test 7**: Repository guard menolak eksekusi ekspor pendapatan jika dipanggil oleh pengguna dengan role Kasir.
- **Test 8**: Tombol Laporan Pendapatan muncul di Dashboard untuk Admin.
- **Test 9**: Tombol Laporan Pendapatan tersembunyi di Dashboard untuk Kasir.
- **Test 10**: Dialog Ekspor merender 3 cakupan periode, live preview table, dan opsi format dokumen.

### 3.2. Verifikasi Visual Antarmuka (Browser E2E)

Pengujian langsung dilakukan menggunakan browser web subagent pada `http://localhost:8080/`:

1. **Cakupan 1 Bulan (Per Minggu)**:
   - Periode: September 2026
   - Tabel menampilkan 5 baris mingguan:
     - Minggu 1 (1 - 7 Sep 2026): Total Beli Rp 51.919.401, Total Jual Rp 219.841.236, Margin +Rp 167.921.834
     - Minggu 2 (8 - 14 Sep 2026): Total Beli Rp 294.205.215, Total Jual Rp 235.644.929, Margin -Rp 58.560.285
     - Minggu 3 (15 - 21 Sep 2026): Total Beli Rp 31.604.035, Total Jual Rp 0, Margin -Rp 31.604.035
     - Minggu 4 (22 - 28 Sep 2026): Rp 0, Rp 0, Rp 0
     - Minggu 5 (29 - 30 Sep 2026): Rp 0, Rp 0, Rp 0
   - Baris Total Keseluruhan:
     - Total Pembelian: **Rp 377.728.652**
     - Total Penjualan: **Rp 455.486.166**
     - Margin Bersih: **Rp 77.757.513** (Surplus)
   - Bukti screenshot: `laporan_pendapatan_1_bulan_1789534020422.png`

2. **Cakupan 3 Bulan (Per Bulan)**:
   - Periode: Kuartal 3 (Jul - Sep) 2026
   - Tabel menampilkan 3 baris bulanan:
     - Juli 2026: Rp 0 / Rp 0 / Rp 0
     - Agustus 2026: Rp 0 / Rp 0 / Rp 0
     - September 2026: Total Beli Rp 377.728.652, Total Jual Rp 455.486.166, Margin Rp 77.757.513
   - Baris Total Keseluruhan:
     - Total Pembelian: **Rp 377.728.652**
     - Total Penjualan: **Rp 455.486.166**
     - Margin Bersih: **Rp 77.757.513**
   - Bukti screenshot: `laporan_pendapatan_3_bulan_1789534275452.png`

3. **Cakupan 1 Tahun (Per Kuartal)**:
   - Periode: Tahun 2026
   - Tabel menampilkan 4 baris kuartal:
     - Kuartal 1 (Jan - Mar 2026): Rp 0 / Rp 0 / Rp 0
     - Kuartal 2 (Apr - Jun 2026): Rp 0 / Rp 0 / Rp 0
     - Kuartal 3 (Jul - Sep 2026): Total Beli Rp 377.728.652, Total Jual Rp 455.486.166, Margin Rp 77.757.513
     - Kuartal 4 (Okt - Des 2026): Rp 0 / Rp 0 / Rp 0
   - Baris Total Keseluruhan:
     - Total Pembelian: **Rp 377.728.652**
     - Total Penjualan: **Rp 455.486.166**
     - Margin Bersih: **Rp 77.757.513**
   - Bukti screenshot: `laporan_pendapatan_1_tahun_1789534296111.png`

4. **Verifikasi RBAC Role Kasir**:
   - Login sebagai `kasir@sawit.com`.
   - Tombol "Laporan Pendapatan" pada header Dashboard **tidak muncul**.
   - Bagian "LAPORAN & KEUANGAN" pada menu bilah samping (sidebar & drawer) **tidak ada**.
   - Bukti screenshot: `kasir_no_laporan_pendapatan_1789534385899.png`

---

## 4. Kesimpulan

Seluruh kebutuhan **Tugas Bagian 19 (FR-7.8)** telah berhasil diselesaikan dengan tingkat akurasi matematis yang tinggi, antarmuka enterprise bergaya IBM Carbon, generator ekspor ganda (Excel & PDF), dan perlindungan hak akses yang ketat. Branch `fitur/laporan-pendapatan` siap untuk ditinjau dan digabungkan ke branch utama.
