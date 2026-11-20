# Laporan Implementasi Tugas Bagian 5: Dashboard Analitik & Visualisasi Grafik

**Aplikasi Transaksi Jual Beli TBS Kelapa Sawit**  
**Tanggal Eksekusi**: 4 September 2026  
**Status**: **SELESAI (100% Verified)**  
**Referensi PRD**: Bagian 7 (FR-5.1, FR-5.2, FR-5.3, FR-5.4), Bagian 8.4 (`v_transaksi_harian`, `v_breakdown_jenis_buah`, `v_transaksi_ringkasan`), dan `AGENTS.md`

---

## 1. Ringkasan Objektif & Ruang Lingkup

Tugas Bagian 5 berfokus pada penyajian ringkasan operasional bisnis, intelijen data, dan grafik visualisasi interaktif berbasis paket `fl_chart` dengan tema korporat **IBM Carbon Design System**:

1. **Kartu Ringkasan KPI (FR-5.1)**:
   - Menampilkan total transaksi, total berat (kg), dan total nilai penjualan (Rp) untuk 3 periode waktu:
     - **Hari Ini**
     - **Minggu Ini** (7 hari terakhir)
     - **Bulan Ini** (bulan kalender berjalan)
   - Sumber data: diambil dari database view `public.v_transaksi_harian` dan dijumlahkan di sisi client Flutter menggunakan tipe presisi tinggi `Decimal` (anti floating-point error).
2. **Grafik Tren Harian 30 Hari Terakhir (FR-5.2)**:
   - Line Chart dinamis menggunakan package `fl_chart` dengan kurva nilai transaksi (Rp).
   - Dilengkapi area gradien halus IBM Blue, grid line putus-putus, label sumbu X (`dd/MM`), label sumbu Y ringkas (`Jt`/`Rb`), serta *touch tooltip* interaktif berformat Rupiah lokal Indonesia.
   - Sumber data: view `public.v_transaksi_harian`.
3. **Grafik Proporsi Volume per Jenis Buah (FR-5.3)**:
   - Donut Chart (`fl_chart` `PieChart`) yang menyajikan persentase (%) dan volume total (kg) panen untuk bulan berjalan:
     - Tandan Besar (IBM Blue `#0F62FE`)
     - Tandan Kecil (IBM Teal/Cyan `#0072C3`)
     - Berondolan (IBM Purple `#6929C4`)
   - Dilengkapi daftar legenda interaktif di samping/bawah grafik.
   - Sumber data: view `public.v_breakdown_jenis_buah`.
4. **Daftar 10 Transaksi Terakhir (FR-5.4)**:
   - Menampilkan 10 data transaksi terbaru dari view `public.v_transaksi_ringkasan` (`order by created_at desc limit 10`).
   - Informasi lengkap: kode transaksi, status badge, nama penjual, tanggal, total berat, dan total harga.
   - Aksi **tap-to-detail**: menavigasi pengguna langsung ke halaman faktur lengkap `TransaksiDetailPage` yang dibuat pada Bagian 4.
5. **Dashboard sebagai Landing Page**:
   - Menjadikan `DashboardPage` sebagai tampilan utama (Index 0) setelah user melakukan autentikasi login.

---

## 2. Rincian Perubahan File & Arsitektur Kode

### A. Berkas Baru yang Ditambahkan

1. **`lib/models/dashboard_analytics.dart`**:
   - Model `TransaksiHarian`: memetakan baris view `public.v_transaksi_harian` (`tanggalTransaksi`, `jumlahTransaksi`, `totalBeratKg`, `totalNilai`).
   - Model `BreakdownJenisBuah`: memetakan baris view `public.v_breakdown_jenis_buah` (`jenisBuah`, `tanggal`, `totalBeratKg`, `totalNilai`).
   - Model `RingkasanPeriodik` & `DashboardSummary`: struktur data pembungkus 3 kartu metrik dengan operator penjumlahan `+`.
2. **`lib/features/dashboard/dashboard_repository.dart`**:
   - `getTransaksiHarian30Hari()`: mengeksekusi query Supabase `v_transaksi_harian` 30 hari terakhir.
   - `getBreakdownJenisBuahBulanIni()`: mengeksekusi query Supabase `v_breakdown_jenis_buah` untuk bulan berjalan.
   - `getRecentTransactions({int limit = 10})`: mengeksekusi query `v_transaksi_ringkasan` dengan batas 10 data terbaru.
   - Generator data demo fallback yang terintegrasi secara otomatis dengan transaksi di `TransaksiRepository`.
3. **`lib/features/dashboard/dashboard_controller.dart`**:
   - `transaksiHarianProvider`: future provider tren harian 30 hari.
   - `dashboardSummaryProvider`: provider kalkulasi agregasi client untuk Hari Ini, Minggu Ini, dan Bulan Ini.
   - `breakdownJenisBuahProvider`: future provider proporsi volume per jenis buah.
   - `recentTransactionsProvider`: future provider 10 transaksi terakhir.
   - Helper `refreshDashboard(ref)` untuk menyegarkan seluruh modul analitik sekaligus.
4. **`lib/features/dashboard/widgets/kartu_ringkasan.dart`**:
   - Widget presentasi kartu metrik enterprise IBM Carbon dengan bar aksen warna atas, tipografi hierarki jelas, dan badge jumlah transaksi.
5. **`lib/features/dashboard/widgets/chart_tren.dart`**:
   - Widget grafik garis tren 30 hari berbasis `fl_chart` `LineChart`.
6. **`lib/features/dashboard/widgets/chart_breakdown.dart`**:
   - Widget grafik donat proporsi panen jenis buah berbasis `fl_chart` `PieChart`.
7. **`lib/features/dashboard/widgets/list_transaksi_terakhir.dart`**:
   - Widget daftar 10 transaksi terakhir dengan visual tap-to-detail dan pintasan ke riwayat penuh.
8. **`lib/features/dashboard/dashboard_page.dart`**:
   - Layar dashboard analitik utama yang merangkum seluruh widget di atas dalam grid responsif (Web Desktop 2 kolom, Mobile tumpukan vertikal) disertai tombol Segarkan data.

### B. Berkas yang Diperbarui

1. **`lib/features/transaksi/transaksi_repository.dart`**:
   - Menambahkan getter publik `static List<TransaksiRingkasan> get demoRingkasanList` agar repository analitik dapat membaca transaksi yang sedang aktif secara konsisten.
2. **`lib/core/widgets/main_layout_page.dart`**:
   - Menetapkan `DashboardPage` pada **Index 0 (Landing Page)**.
   - Menata ulang menu navigasi (Dashboard, Transaksi Baru, Riwayat Transaksi, Data Penjual, Uji Picker) pada Sidebar Desktop dan Bottom Bar Mobile.
3. **`test/widget_test.dart`**:
   - Menambahkan suite pengujian unit: model serialisasi `TransaksiHarian` dan `BreakdownJenisBuah`, serta pemanggilan query repository analitik.

---

## 3. Verifikasi Analisis Statis & Unit Tests

### A. Hasil `flutter analyze`
```bash
$ flutter analyze
Analyzing Aplikasi Transaksi TBS sawit...                       
No issues found! (ran in 7.7s)
```

### B. Hasil `flutter test`
14 dari 14 unit tests berhasil dieksekusi dengan sukses:
```bash
$ flutter test
00:00 +0: App smoke test
00:00 +1: Formatter Tests CurrencyFormatter formats and parses IDR properly
00:00 +2: Formatter Tests WeightFormatter formats and parses weight properly
00:00 +3: Model Serialization Tests Profile model parses and serializes correctly
00:00 +4: Model Serialization Tests Penjual model parses and serializes correctly
00:00 +5: Model Serialization Tests JenisBuah model parses correctly
00:00 +6: Model Serialization Tests Transaksi and TransaksiItem models parse with Decimal correctly
00:00 +7: Transaksi Multi-Item Form & Calculation Tests Calculates subtotal and total accurately using Decimal
00:00 +8: Transaksi Multi-Item Form & Calculation Tests Prevents duplicate fruit types and detects max 3 rows limit
00:00 +9: Transaksi Bagian 4: Riwayat & Pembatalan Tests TransaksiFilterState calculates date ranges and active filter counts
00:00 +10: Transaksi Bagian 4: Riwayat & Pembatalan Tests TransaksiRepository queries demo ringkasan and respects status filter
00:01 +11: Transaksi Bagian 4: Riwayat & Pembatalan Tests TransaksiRepository cancelTransaksi performs soft delete with reason
00:02 +12: Dashboard Bagian 5: Analitik & fl_chart Tests TransaksiHarian and BreakdownJenisBuah models parse JSON correctly
00:02 +13: Dashboard Bagian 5: Analitik & fl_chart Tests DashboardRepository fetches 30-day trends, breakdown, and recent transactions
00:03 +14: All tests passed!
```

---

## 4. Hasil Pengujian Browser & Bukti Visual (End-to-End Test)

Pengujian interaktif otomatis dilakukan pada browser Chrome pada aplikasi web Flutter (`http://localhost:8080/`):

### 1. Landing Page Default & Kartu Ringkasan KPI
Setelah autentikasi, pengguna langsung mendarat pada **Dashboard Analitik** (Menu item 0 aktif di sidebar). Tiga kartu ringkasan KPI menampilkan data agregasi yang konsisten:
- **Hari Ini**: Rp 3.900.000 | 1.500,00 kg | 1 TRX
- **Minggu Ini**: Rp 21.026.250 | 8.350,50 kg | 7 TRX
- **Bulan Ini**: Rp 13.776.250 | 5.450,50 kg | 5 TRX

![Dashboard Overview & KPI](file:///C:/Users/lenov/.gemini/antigravity-ide/brain/1dade70d-b696-49f3-8ad3-f44f94891125/dashboard_overview_1788528805410.png)

### 2. Grafik Tren 30 Hari & Grafik Breakdown Jenis Buah (`fl_chart`)
Dua visualisasi grafik enterprise IBM Carbon tampil berdampingan dengan proporsi seimbang:
- **Line Chart Tren 30 Hari**: Fluktuasi nilai penjualan harian bersumber dari `v_transaksi_harian`.
- **Donut Chart Breakdown Volume**: Proporsi volume panen jenis buah bulan berjalan bersumber dari `v_breakdown_jenis_buah` (Tandan Besar 61.5%, Tandan Kecil 24.0%, Berondolan 14.5%).

![Dashboard Grafik Tren & Breakdown](file:///C:/Users/lenov/.gemini/antigravity-ide/brain/1dade70d-b696-49f3-8ad3-f44f94891125/dashboard_charts_1788528812137.png)

### 3. Daftar 10 Transaksi Terakhir & Navigasi Tap-to-Detail
Daftar transaksi terbaru menyajikan nomor transaksi, tanggal, penjual, berat, dan status. Mengetuk baris transaksi pertama (`TRX-20260904-0001` - Haji Sukirman) sukses membuka halaman **Detail Nota Transaksi**.
![Tap to Detail Nota Transaksi](file:///C:/Users/lenov/.gemini/antigravity-ide/brain/1dade70d-b696-49f3-8ad3-f44f94891125/dashboard_tap_to_detail_1788528826351.png)

---

## 5. Kesimpulan

Seluruh fungsionalitas dan kriteria penerimaan **Tugas Bagian 5 (FR-5.x)** telah selesai secara sempurna:
- Kartu ringkasan KPI menghitung nilai dari view `v_transaksi_harian` dengan presisi `Decimal`.
- Grafik tren nilai 30 hari terintegrasi menggunakan `fl_chart` LineChart.
- Grafik breakdown volume per jenis buah menyajikan Donut Chart interaktif beserta legenda.
- Daftar 10 transaksi terakhir terhubung langsung dengan alur tap-to-detail ke halaman faktur nota.
- Dashboard telah menjadi landing page utama aplikasi setelah proses login.
