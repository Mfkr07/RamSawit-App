# Laporan Tugas Bagian 13: Dashboard Lengkap & Multi-Modul

**Tanggal Pelaksanaan**: 10 September 2026  
**Branch Git**: `fitur/dashboard-lengkap` (Commit: `9afc18f`)  
**Status**: **SELESAI (100% PASS, 39/39 Tests Passed, Browser Verified)**  
**Target Platform**: Android, iOS, Web (Responsive Single Codebase)  
**Referensi**: [PRD.md §7.5 (FR-5.1 s/d FR-5.10)](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/PRD-Aplikasi-Transaksi-Sawit.md#L89), [Database.md §8.1](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/Database-Aplikasi-Transaksi-Sawit.md#L679), [AGENTS.md](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/AGENTS.md)

---

## 1. Ringkasan Eksekutif

Tugas Bagian 13 merupakan penyatuan menyeluruh (*holistic unification*) analitik bisnis pada **Aplikasi Transaksi Jual Beli Buah Kelapa Sawit (TBS)**. Sebelum pembaruan ini, dashboard aplikasi hanya berfokus pada data Pembelian dari Petani/Pengepul. Pada Bagian 13 ini, seluruh data dari **Modul Pembelian Petani (§7.3)** dan **Modul Penjualan ke Pabrik (§7.8)** diintegrasikan secara elegan ke dalam satu dashboard analitik interaktif yang menyajikan:
1. **Analisis Margin Keuntungan** ($\text{Total Penjualan Pabrik} - \text{Total Pembelian Petani}$).
2. **Monitoring Tonase Fisik** (perbandingan Berat Kotor vs Berat Bersih pada kedua sisi transaksi).
3. **Filter Periode Terpusat & Reusable** yang mengendalikan seluruh grafik secara simultan.

### Prinsip Penting yang Dipenuhi:
- **Proteksi Branch Produksi**: Karena aplikasi sudah berada di tahap produksi dan aktif digunakan kasir, seluruh pengerjaan diisolasi di branch git `fitur/dashboard-lengkap` tanpa menyentuh branch `main`.
- **Single Source of Truth Database**: Mengoptimalkan view SQL yang sudah ada (`v_transaksi_harian`, `v_pengiriman_harian`, `v_margin_harian`) tanpa komputasi manual yang tercecer di client. Hanya ada 1 view SQL baru yang ditambahkan: `v_breakdown_pabrik` (Database.md §8.1).
- **Presisi Finansial Anti-Floating Point**: Seluruh akumulasi keuangan menggunakan tipe data `Decimal` / `BigInt`, tanpa tipe `double` primitif.
- **Konsistensi Desain IBM Carbon**: Antarmuka flat-square corner (0–2px), aksen IBM Blue (`#0F62FE`), Charcoal Ink (`#161616`), dan tipografi IBM Plex Sans dalam Bahasa Indonesia baku.

---

## 2. Rincian Perubahan Database & View Baru

Sesuai Database.md §8.1, view baru disiapkan untuk menghitung distribusi pengiriman TBS per pabrik tujuan berstatus `'selesai'`:

### A. Skrip SQL Migrasi: `v_breakdown_pabrik`
- **File**: `supabase/migrations/20260907_breakdown_pabrik.sql`

```sql
create view public.v_breakdown_pabrik as
select
    pb.nama as nama_pabrik,
    date_trunc('day', pp.tanggal_kirim) as tanggal,
    sum(pp.berat_kotor_kg) as total_berat_kotor_kg,
    sum(pp.berat_bersih_kg) as total_berat_bersih_kg,
    sum(pp.total_nilai_jual) as total_nilai_jual
from public.pengiriman_pabrik pp
join public.pabrik pb on pb.id = pp.pabrik_id
where pp.status = 'selesai'
group by pb.nama, date_trunc('day', pp.tanggal_kirim);
```

### B. Optimalisasi View Eksisting
- View `v_transaksi_harian`: Menyediakan `total_berat_kotor_kg`, `total_berat_bersih_kg`, dan `total_nilai`.
- View `v_pengiriman_harian`: Menyediakan agregasi pengiriman pabrik status `'selesai'`.
- View `v_margin_harian`: Menggabungkan secara otomatis `total_pembelian`, `total_penjualan`, dan selisih `margin` per tanggal.

---

## 3. Rincian Implementasi Client & Komponen Baru

### A. Komponen Reusable Filter Periode (`DashboardPeriodeBar`)
- **Berkas**: [`lib/features/dashboard/widgets/dashboard_periode_bar.dart`](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/dashboard/widgets/dashboard_periode_bar.dart)
- **Model & State**: `DashboardPeriodePreset` (Enum) & `DashboardPeriodeState` pada [`lib/models/dashboard_analytics.dart`](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/models/dashboard_analytics.dart).
- **Fitur Utama**:
  - Pilihan cepat preset: **1 Minggu**, **2 Minggu**, **1 Bulan** (default), **3 Bulan**, **6 Bulan**, **1 Tahun**.
  - Opsi kustom: Tombol **Pilih Rentang** membuka dialog kalender interaktif (`showDateRangePicker`).
  - Dikelola via Riverpod StateNotifier (`dashboardPeriodeProvider`) yang terhubung secara reaktif ke semua data provider grafik.
  - Tampilan responsif dengan proteksi layout overflow (`Wrap`).

### B. Kartu Ringkasan Multi-Modul (3 Modul Terpadu)
- **Berkas**: [`lib/features/dashboard/widgets/kartu_ringkasan.dart`](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/dashboard/widgets/kartu_ringkasan.dart)
- **Struktur Tiga Tab**:
  1. **Pembelian Petani**: Menampilkan metrik Hari Ini, Minggu Ini, Bulan Ini:
     - **Berat Kotor (kg)**
     - **Berat Bersih (kg)**
     - **Total Pembelian (Rp)** (nilai eksisting dan formula dipertahankan 100% presisi).
  2. **Penjualan ke Pabrik**: Menampilkan metrik Hari Ini, Minggu Ini, Bulan Ini khusus pengiriman berstatus `selesai`:
     - **Berat Kotor (kg)**
     - **Berat Bersih (kg)**
     - **Total Penjualan (Rp)**
  3. **Margin Keuntungan**: Menampilkan metrik Hari Ini, Minggu Ini, Bulan Ini dari `v_margin_harian`:
     - **Total Pembelian (Rp)**
     - **Total Penjualan (Rp)**
     - **Margin Bersih (Rp)** disertai indikator warna dinamis (hijau untuk laba, merah jika terjadi defisit).

### C. Visualisasi Grafik Komprehensif (`fl_chart`)
1. **Grafik Tren Nilai Transaksi (2 Garis)**:
   - Berkas: [`lib/features/dashboard/widgets/chart_tren.dart`](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/dashboard/widgets/chart_tren.dart)
   - Garis Biru: Total Pembelian Petani (Rp).
   - Garis Cyan/Teal: Total Penjualan ke Pabrik (Rp).
   - Mengikuti filter rentang tanggal aktif.
2. **Grafik Tren Berat Pembelian Petani (2 Garis)**:
   - Berkas: [`lib/features/dashboard/widgets/chart_tren_berat_pembelian.dart`](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/dashboard/widgets/chart_tren_berat_pembelian.dart)
   - Garis Biru Tua: Berat Kotor (kg).
   - Garis Hijau: Berat Bersih (kg) setelah potongan grading petani.
3. **Grafik Tren Berat Penjualan ke Pabrik (2 Garis)**:
   - Berkas: [`lib/features/dashboard/widgets/chart_tren_berat_penjualan.dart`](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/dashboard/widgets/chart_tren_berat_penjualan.dart)
   - Garis Oranye/Amber: Berat Kotor Pabrik (kg).
   - Garis Ungu: Berat Bersih Pabrik (kg) setelah potongan sortasi & retur.
4. **Breakdown Komposisi Jenis Buah (Pie Chart Terfilter)**:
   - Berkas: [`lib/features/dashboard/widgets/chart_breakdown.dart`](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/dashboard/widgets/chart_breakdown.dart)
   - Diperbarui agar dinamis mengikuti rentang tanggal filter periode aktif (tidak lagi terkunci pada bulan berjalan).
5. **Breakdown Penjualan per Pabrik Tujuan (Donut Chart Baru)**:
   - Berkas: [`lib/features/dashboard/widgets/chart_breakdown_pabrik.dart`](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/dashboard/widgets/chart_breakdown_pabrik.dart)
   - Menampilkan proporsi tonase bersih dan nilai penjualan rupiah yang terdistribusi ke masing-masing mitra pabrik kelapa sawit (PKS).

### D. Tab Aktivitas Transaksi & Pengiriman Terakhir
- **Berkas**: [`lib/features/dashboard/widgets/list_transaksi_terakhir.dart`](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/dashboard/widgets/list_transaksi_terakhir.dart)
- Tab 1: **10 Transaksi Pembelian Petani Terakhir** (kode `TRX-...`, nama petani, tanggal, tonase, dan total rupiah).
- Tab 2: **10 Pengiriman Pabrik Terakhir** (kode `KRM-...`, nama pabrik tujuan, armada/plat nomor, tonase bersih, dan total nilai jual).
- Masing-masing item dapat diklik (*tap-to-detail*) untuk navigasi ke riwayat detail.

---

## 4. Matriks Kriteria Penerimaan (Acceptance Criteria Bagian 13)

| ID Kriteria | Uraian Kriteria Penerimaan | Status | Bukti Implementasi & Verifikasi |
|---|---|:---:|---|
| **AC-13.1** | View SQL `v_breakdown_pabrik` tersedia dan menghitung agregasi pengiriman selesai | **PASS** | File `supabase/migrations/20260907_breakdown_pabrik.sql` |
| **AC-13.2** | Komponen filter periode reusable mendukung 6 preset dan custom range picker | **PASS** | `DashboardPeriodeBar` dengan integrasi `showDateRangePicker` |
| **AC-13.3** | Kartu Pembelian menampilkan Berat Kotor, Bersih, dan Total Nilai tanpa merubah nilai lama | **PASS** | `KartuRingkasan` tab Pembelian tervalidasi dengan data eksisting |
| **AC-13.4** | Kartu Penjualan menampilkan metrik pengiriman selesai (Kotor, Bersih, Nilai Jual) | **PASS** | `KartuRingkasan` tab Penjualan membaca view `v_pengiriman_harian` |
| **AC-13.5** | Kartu Margin menampilkan perbandingan penjualan vs pembelian dan laba bersih | **PASS** | `KartuRingkasan` tab Margin bersumber dari view `v_margin_harian` |
| **AC-13.6** | Grafik Tren Nilai menampilkan 2 garis (Pembelian vs Penjualan) secara sinkron | **PASS** | `ChartTren` dengan dua garis `LineChartBarData` |
| **AC-13.7** | Grafik Tren Berat Pembelian menampilkan Kotor vs Bersih Petani | **PASS** | `ChartTrenBeratPembelian` terhubung ke provider periode |
| **AC-13.8** | Grafik Tren Berat Penjualan menampilkan Kotor vs Bersih Pabrik | **PASS** | `ChartTrenBeratPenjualan` terpisah rapi dari grafik pembelian |
| **AC-13.9** | Grafik Komposisi Buah dan Donut Pabrik terhubung ke filter periode yang sama | **PASS** | `ChartBreakdown` dan `ChartBreakdownPabrik` reaktif terhadap filter |
| **AC-13.10**| Daftar aktivitas menyajikan 10 transaksi dan 10 pengiriman terakhir secara tabbed | **PASS** | `ListTransaksiTerakhir` dengan tab Pembelian dan Pengiriman |

---

## 5. Hasil Pengujian & Verifikasi

### A. Pengujian Otomatis Unit & Widget Test (`flutter test`)
Pengujian dilakukan menggunakan seluruh rangkaian pengujian, termasuk test suite khusus [`test/dashboard_lengkap_test.dart`](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/test/dashboard_lengkap_test.dart):

```text
00:00 +0: Tugas Bagian 13: Dashboard Multi-Modul & Filter Periode Tests DashboardPeriodeState calculates date ranges accurately
00:00 +1: Tugas Bagian 13: Dashboard Multi-Modul & Filter Periode Tests Model deserialization for multi-module dashboard
00:00 +2: Tugas Bagian 13: Dashboard Multi-Modul & Filter Periode Tests DashboardRepository Demo Mode returns rich data for all views
00:01 +3: Tugas Bagian 13: Dashboard Multi-Modul & Filter Periode Tests DashboardPeriodeBar renders all presets and switches active preset
00:02 +4: Tugas Bagian 13: Dashboard Multi-Modul & Filter Periode Tests Chart sections render without throwing exception
...
00:05 +39: All tests passed!
```
**Hasil: 39 dari 39 tests LULUS 100% (0 gagal).**

### B. Pengujian Statis Kode (`flutter analyze`)
Hasil verifikasi analisis statis Dart/Flutter: **0 Issues / Errors**.

### C. Verifikasi Interaktif Browser Subagent (Google Chrome Web Server)
Verifikasi visual dan fungsional dilakukan pada lingkungan browser Chrome:
1. **Default State (1 Bulan)**: Seluruh kartu ringkasan, 3 chart tren garis, 2 chart donat/pie, serta tab aktivitas terakhir terisi data lengkap tanpa error runtime.
2. **Switching Preset Periode (1 Minggu & 3 Bulan)**: Komponen `DashboardPeriodeBar` merespons klik dengan cepat, seluruh grafik garis dan donat ter-update secara serentak tanpa lag.
3. **Switching Tab Modul**: Kartu ringkasan berhasil beralih antara Pembelian Petani, Penjualan Pabrik, dan Margin Keuntungan dengan format mata uang dan tonase yang rapi.
4. **Artefak Verifikasi**:
   - Screenshot 1 (Default 1 Bulan): `dashboard_verified_1_bulan_1789011792891.png`
   - Screenshot 2 (Filter 1 Minggu): `dashboard_verified_1_minggu_1789011935491.png`
   - Screenshot 3 (Tab Penjualan Pabrik): `dashboard_verified_pabrik_1789011991117.png`
   - Rekaman Sesi WebP: `dashboard_final_tour_1789011767322.webp`

---

## 6. Status Git & Komitmen Produksi

- **Branch Pengerjaan**: `fitur/dashboard-lengkap`
- **Commit SHA**: `9afc18f` (`1.5.1 feat: making complete version for dashboard, including all data from modul penjualan and pembelian sawit`)
- **Remote Push**: Berhasil di-push ke branch remote `origin/fitur/dashboard-lengkap`.
- **Status Branch `main`**: Aman dan tidak terdampak. Penggabungan ke `main` disarankan melalui mekanisme Pull Request setelah review tim pengembang selesai.
