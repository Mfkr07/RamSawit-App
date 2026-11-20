# Laporan Pelaksanaan Tugas Bagian 17: Dashboard Role dan Filter

**Branch**: `fitur/dashboard-role-dan-filter`  
**Target Dokumen**: `doc/PRD-Aplikasi-Transaksi-Sawit.md` (FR-5.11, FR-5.12, FR-4.1)  
**Tanggal**: 16 September 2026  
**Status**: SELESAI (100% Lulus Verifikasi Otomatis & Visual Browser)

---

## 1. Ringkasan Pekerjaan

Tugas Bagian 17 mengimplementasikan penyempurnaan dashboard, kontrol akses berbasis peran (RBAC) antara Admin dan Kasir, serta standarisasi filter periode tanpa migration database:

1. **Opsi "Hari Ini" pada Filter Periode Reusable**:
   - Ditambahkan sebagai preset pertama (`DashboardPeriodePreset.hariIni`) sebelum opsi "1 Minggu" pada bilah filter dashboard analitik.
   - Menghitung rentang waktu 24 jam kalender hari ini (00:00:00 hingga 23:59:59).

2. **Pembatasan Role Kasir di Dashboard Analitik (FR-5.11)**:
   - **Penyembunyian Tab Margin**: Tab "Margin Keuntungan" disembunyikan sepenuhnya untuk role Kasir (`profiles.role == 'kasir'`). Jika kasir sebelumnya berada di tab margin, otomatis dikembalikan ke tab Pembelian.
   - **Penyembunyian Seluruh Grafik Tren**: Tiga grafik tren (*Tren Nilai Pembelian vs Penjualan*, *Tren Berat Pembelian Petani*, *Tren Berat Penjualan Pabrik*) disembunyikan sepenuhnya untuk Kasir. Halaman Kasir hanya menampilkan kartu ringkasan, pie chart proporsi volume jenis buah & pabrik tujuan, serta daftar transaksi terakhir.
   - **Pembatasan Opsi Periode Kasir**: Preset filter periode dibatasi maksimal sampai "1 Bulan" (`Hari Ini`, `1 Minggu`, `2 Minggu`, `1 Bulan`). Opsi `3 Bulan`, `6 Bulan`, `1 Tahun`, dan tombol `Pilih Tanggal Manual...` (custom date picker) disembunyikan dari UI.
   - **Defense in Depth di Layer Repository**: `DashboardRepository` memvalidasi hak akses: query data margin atau rentang waktu > 31 hari oleh role Kasir langsung ditolak dengan `AppException`.
   - **Role Admin Tetap Utuh**: Role Admin memiliki akses penuh ke seluruh tab, seluruh grafik tren, preset hingga 1 tahun, dan custom date picker.

3. **Filter Khusus Kartu "Bulan Ini" (FR-5.12)**:
   - Khusus role Admin, kartu ke-3 ("Bulan Ini") memiliki tombol filter/tune di pojok kanan atas kartu.
   - Mendukung 4 mode filter:
     - **Bulan Berjalan (Default)**: Mengikuti kalender bulan saat ini.
     - **Pilih Bulan Tertentu**: Memilih bulan & tahun spesifik (contoh: Agustus 2026).
     - **Satu Tahun Penuh**: Akumulasi 12 bulan dalam tahun kalender (contoh: Tahun 2026).
     - **Rentang Bulan Kustom**: Memilih rentang awal (Bulan & Tahun) hingga akhir (Bulan & Tahun).
   - Filter ini diisolasi khusus kartu ke-3 dan tidak mempengaruhi kartu lain maupun grafik analitik lainnya.
   - Untuk role Kasir, kartu tetap terkunci pada bulan berjalan tanpa kontrol filter.

4. **Standarisasi Filter Periode Riwayat 8 Opsi (FR-4.1)**:
   - Diterapkan pada **Riwayat Transaksi** (`transaksi_list_page.dart`) dan **Riwayat Pengiriman ke Pabrik** (`pengiriman_pabrik_list_page.dart`).
   - 8 Preset terstandarisasi: `Semua`, `Hari Ini`, `1 Minggu`, `2 Minggu`, `1 Bulan`, `3 Bulan`, `6 Bulan`, `1 Tahun`.
   - Tombol *Pilih Tanggal Manual / Custom Date Picker* ditiadakan pada kedua halaman riwayat sesuai mandat FR-4.1.
   - Terintegrasi dengan paginasi: memilih atau berpindah filter periode otomatis me-reset nomor halaman kembali ke halaman 1 (`currentPage = 1`).

---

## 2. File yang Dibuat dan Dimodifikasi

| No | File | Status | Keterangan |
|---|---|---|---|
| 1 | `lib/models/dashboard_analytics.dart` | Diperbarui | Menambahkan preset `hariIni`, getter `isAllowedForKasir`, enum `KartuBulanIniMode`, model `KartuBulanIniFilterState`, dan `KartuBulanIniSummary`. |
| 2 | `lib/features/dashboard/dashboard_repository.dart` | Diperbarui | Implementasi `_validateAccess()` role-level guard dan query `getKartuBulanIniSummary()`. |
| 3 | `lib/features/dashboard/dashboard_controller.dart` | Diperbarui | Menambahkan guard role Kasir pada provider grafik tren, notifier & provider `kartuBulanIniFilterProvider`, dan `kartuBulanIniSummaryProvider`. |
| 4 | `lib/features/dashboard/widgets/dashboard_periode_bar.dart` | Diperbarui | Menampilkan opsi `Hari Ini` pertama, filter preset berdasarkan `isKasir`, dan menyembunyikan date picker kustom untuk Kasir. |
| 5 | `lib/features/dashboard/widgets/kartu_ringkasan.dart` | Diperbarui | Menyembunyikan tab Margin untuk Kasir, tombol filter kartu ke-3 untuk Admin, dan implementasi modal dialog `_DialogFilterBulanIni`. |
| 6 | `lib/features/dashboard/dashboard_page.dart` | Diperbarui | Menyembunyikan seluruh grafik tren dari tampilan Kasir. |
| 7 | `lib/features/transaksi/transaksi_filter_state.dart` | Diperbarui | Menambahkan preset `hari_ini` dan `semua`, meniadakan custom date range. |
| 8 | `lib/features/transaksi/transaksi_list_page.dart` | Diperbarui | Bilah filter 8 preset chip dengan reset halaman ke 1. |
| 9 | `lib/features/pengiriman_pabrik/pengiriman_pabrik_list_page.dart` | Diperbarui | Bilah filter 8 preset chip terstandarisasi dengan scroll horizontal dan reset halaman ke 1. |
| 10 | `lib/features/auth/auth_repository.dart` | Diperbarui | Sinkronisasi role `admin` otomatis untuk akun ber-email admin (`admin@sawit.com`). |
| 11 | `test/bagian17_dashboard_role_dan_filter_test.dart` | Baru | 10 unit test dan widget test komprehensif untuk seluruh requirement Bagian 17. |

---

## 3. Hasil Pengujian Otomatis

### A. Pengujian Unit & Widget Baru (`bagian17_dashboard_role_dan_filter_test.dart`)
```
00:00 +0: Tugas Bagian 17: Model & Preset Dashboard 1. DashboardPeriodePreset.hariIni menghitung rentang 24 jam hari ini dengan benar
00:00 +1: Tugas Bagian 17: Model & Preset Dashboard 2. isAllowedForKasir membatasi preset hanya sampai 1 Bulan
00:00 +2: Tugas Bagian 17: Model & Preset Dashboard 3. KartuBulanIniFilterState mengelola mode dan label dengan tepat
00:00 +3: Tugas Bagian 17: Repository-Level Defense in Depth (FR-5.11) 4. Role Kasir menolak metrik margin di tingkat repository
00:00 +4: Tugas Bagian 17: Repository-Level Defense in Depth (FR-5.11) 5. Role Kasir menolak query dengan rentang waktu > 31 hari
00:00 +5: Tugas Bagian 17: UI Role Kasir vs Admin di Dashboard 6. Role Kasir: Tab Margin & Grafik Tren Disembunyikan
00:00 +6: Tugas Bagian 17: UI Role Kasir vs Admin di Dashboard 7. Role Admin: Tab Margin, Grafik Tren, dan Filter Card Bulan Ini Tampil
00:01 +7: Tugas Bagian 17: UI Role Kasir vs Admin di Dashboard 8. Role Admin: Membuka Dialog Filter Kartu Bulan Ini dan Mengganti Filter
00:01 +8: Tugas Bagian 17: Standarisasi 8 Filter Periode Riwayat (FR-4.1) 9. Riwayat Transaksi: Menampilkan 8 Preset dan Tanpa Custom Date Picker
00:01 +9: Tugas Bagian 17: Standarisasi 8 Filter Periode Riwayat (FR-4.1) 10. Riwayat Pengiriman Pabrik: Menampilkan 8 Preset dan Reset Halaman ke 1
00:01 +10: All tests passed!
```

### B. Pengujian Regresi Keseluruhan (`flutter test`)
- **Total Pengujian**: 73 pengujian
- **Status**: **100% Passed (73 passed, 0 failed)**
- **Cakupan Pengujian**:
  - `widget_test.dart` (Bagian 1 - 10)
  - `dashboard_lengkap_test.dart` (Bagian 13)
  - `bagian16_responsif_performa_test.dart` (Bagian 16)
  - `bagian17_dashboard_role_dan_filter_test.dart` (Bagian 17)

### C. Analisis Statis Kode (`flutter analyze`)
- **Hasil**: 0 errors, 0 warnings. Kode bersih sesuai standar Flutter & Riverpod.

---

## 4. Hasil Verifikasi Visual Browser (Admin vs Kasir)

Pengujian interaktif dilakukan menggunakan browser subagent pada target Web App (`http://localhost:8080`) dengan akun `admin@sawit.com` dan `kasir@sawit.com`:

| Fitur | Tampilan Admin (`admin@sawit.com`) | Tampilan Kasir (`kasir@sawit.com`) | Bukti Screenshot |
|---|---|---|---|
| **Tab Margin Keuntungan** | Ditampilkan & dapat diakses aktif | **Disembunyikan sepenuhnya** (hanya Pembelian & Penjualan) | `admin_dashboard_full_1789527554351.png` vs `kasir_dashboard_restricted_1789527686446.png` |
| **Filter Kartu Bulan Ini** | Tombol Filter (`tune`) aktif di pojok kartu, membuka modal dialog 4 mode | **Disembunyikan**, kartu terkunci ke bulan berjalan | `admin_dialog_filter_1789527568524.png` vs `kasir_dashboard_restricted_1789527686446.png` |
| **Bilah Preset Periode** | 8 Preset (`Hari Ini` s/d `1 Tahun`) + Tombol `Pilih Tanggal Manual...` | **Hanya 4 Preset** (`Hari Ini`, `1 Minggu`, `2 Minggu`, `1 Bulan`). Opsi > 1 Bulan & tombol manual disembunyikan | `admin_dashboard_full_1789527554351.png` vs `kasir_dashboard_restricted_1789527686446.png` |
| **Grafik Tren Bisnis** | Ditampilkan lengkap (*Tren Nilai*, *Tren Berat Pembelian*, *Tren Berat Penjualan*) | **Disembunyikan sepenuhnya** (hanya pie chart breakdown volume dan list transaksi) | `admin_trend_charts_1789527589963.png` vs `kasir_dashboard_restricted_1789527686446.png` |
| **Filter Riwayat Transaksi** | 8 Preset Chip (`Semua`, `Hari Ini`, `1 Minggu`, `2 Minggu`, `1 Bulan`, `3 Bulan`, `6 Bulan`, `1 Tahun`), tanpa manual picker | Sama (8 Preset Chip terstandarisasi untuk operasional kasir) | `admin_riwayat_transaksi_1789527606480.png` & `kasir_riwayat_transaksi_1789527707614.png` |
| **Filter Riwayat Pengiriman** | 8 Preset Chip terstandarisasi dengan scroll horizontal responsif | Sama | `admin_riwayat_pengiriman_1789527625707.png` |

---

## 5. Kesimpulan

Seluruh mandat tugas Bagian 17 telah diselesaikan dengan akurat dan sesuai prinsip single source of truth, tanpa merusak atau mengubah skema database, serta telah terverifikasi secara visual di browser dan lulus seluruh unit/widget test.
