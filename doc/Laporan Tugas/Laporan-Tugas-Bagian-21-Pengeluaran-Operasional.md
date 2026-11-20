# LAPORAN IMPLEMENTASI TUGAS: BAGIAN 21
## Modul Pengeluaran Operasional & Integrasi Laporan Laba Bersih

---

### 1. Ringkasan Eksekutif
Tugas Bagian 21 bertujuan untuk mencatat seluruh beban operasional (misal: bensin truk, konsumsi pekerja timbangan, perawatan mesin timbangan) ke dalam sistem dan mengintegrasikannya secara langsung dengan Laporan Laba Bersih (Net Profit) pada dashboard admin dan modul laporan.

### 2. Skema Database
- **Tabel `public.jenis_pengeluaran`**:
  - Menyimpan kategori biaya (`id`, `nama`, `deskripsi`, `is_active`, timestamp).
- **Tabel `public.pengeluaran`**:
  - Menyimpan pencatatan transaksi biaya riil (`id`, `tanggal`, `jenis_pengeluaran_id`, `nominal`, `keterangan`, `created_by`, timestamp).
- **View Analitik**:
  - `v_pengeluaran_harian`: agregasi total nominal biaya per tanggal.
  - `v_laporan_pendapatan_harian`: mengintegrasikan Penjualan Pabrik, Pembelian Petani, dan Pengeluaran Operasional untuk menghasilkan Laba Kotor dan Laba Bersih secara otomatis.

### 3. Implementasi Dart & Flutter
- **Model**: `Pengeluaran`, `JenisPengeluaran`, `LaporanPendapatanHarianItem` (100% menggunakan tipe data `Decimal`).
- **Repository & State**: `PengeluaranRepository`, `PengeluaranController` dengan Riverpod.
- **UI**: Halaman manajemen pengeluaran, dialog form input pengeluaran, tab/kartu pada dashboard admin.
- **Fitur Ekspor**: `LaporanPengeluaranExcelGenerator` dan `LaporanPengeluaranPdfGenerator` untuk pelaporan audit operasional.

### 4. Hasil Verifikasi
- Pengujian menyeluruh pada file `test/bagian21_pengeluaran_test.dart` (kalkulasi laba bersih, ekspor file PDF/Excel 7 kolom) dinyatakan **LULUS (PASS)**.
