# Laporan Tugas Bagian 8: Export Laporan Excel & PDF (PRD §FR-7.x)

**Tanggal Pelaksanaan**: 5 September 2026  
**Branch Git**: `fitur/potongan-dan-export`  
**Status**: **SELESAI (100% PASS)**  
**Target Platform**: Android, iOS, Web (Verified Production Web Build)  
**Referensi**: [PRD.md §7.7 (FR-7.1 s/d FR-7.6)](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/PRD-Aplikasi-Transaksi-Sawit.md#L102), [AGENTS.md](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/AGENTS.md)

---

## 1. Ringkasan Eksekutif

Tugas Bagian 8 mengimplementasikan fitur **Export Laporan Riwayat Transaksi** ke dalam format **Microsoft Excel (.xlsx)** dan **Dokumen PDF (.pdf)** pada sistem transaksi TBS Sawit.

Fitur ini memungkinkan pengelola/pemilik usaha untuk mengunduh rekapitulasi data transaksi berdasarkan rentang tanggal dan kriteria filter yang sedang aktif, lengkap dengan rincian berat, harga kotor, potongan biaya 5%, dan total pembayaran bersih.

Prinsip & kepatuhan utama yang dipenuhi:
1. **Single Source of Truth (FR-7.6)**: Data laporan diambil langsung dari view database `v_transaksi_ringkasan` (melalui model `TransaksiRingkasan`). Tidak ada komputasi potongan atau total harga yang dihitung ulang secara terpisah di kode export, sehingga angka laporan selalu konsisten 100% dengan tampilan di aplikasi.
2. **Multiplatform File Saver**:
   - **Web**: Menggunakan objek `Blob` dan `AnchorElement` (`dart:html`) untuk langsung memicu proses unduhan native browser.
   - **Mobile**: Menggunakan `path_provider` dan `share_plus` untuk menampilkan native Share Sheet sistem operasi (simpan ke Files, WhatsApp, Google Drive, cetak, dsb).
3. **Format Dokumen Profesional**:
   - **Excel**: Kop judul, periode, timestamp cetak, styling header warna biru IBM (`#0F62FE`) dengan teks putih, dan baris total di akhir (*sum* seluruh kolom numerik).
   - **PDF**: Format A4 Landscape siap cetak, kop judul, tabel rekapitulasi terpaginasi dengan zebra striping, baris total akumulasi, dan penomoran halaman otomatis (*Halaman X dari Y*).
4. **Penanganan Kondisi Kosong (Empty State)**: Jika filter menghasilkan 0 transaksi, aplikasi menampilkan peringatan komunikatif dan menonaktifkan tombol download agar tidak menghasilkan file kosong atau menimbulkan error.
5. **Penamaan File Standar**: Nama file otomatis mencantumkan rentang tanggal aktif, contoh: `Laporan-Transaksi-2026-09-01-sd-2026-09-30.xlsx`.

---

## 2. Dependensi & Arsitektur Kode

### A. Dependensi Baru (`pubspec.yaml`)
- `excel: ^4.0.6`: Package pure-Dart untuk penyusunan spreadsheet `.xlsx`.
- `pdf: ^3.11.1`: Package untuk penyusunan dokumen `.pdf` deklaratif.
- `share_plus: ^10.1.4`: Share sheet native lintas platform.
- `path_provider: ^2.1.5`: Akses direktori cache penyimpanan sementara pada mobile.

### B. Struktur File Baru
```
lib/
 ├─ core/utils/file_saver/
 │   ├─ file_saver.dart           # Abstraksi universal FileSaver
 │   ├─ file_saver_stub.dart      # Fallback stub
 │   ├─ file_saver_web.dart       # Implementasi browser download via Blob/Anchor
 │   └─ file_saver_mobile.dart    # Implementasi mobile via Share.shareXFiles
 └─ features/transaksi/export/
     ├─ laporan_excel_generator.dart # Generator dokumen Excel (.xlsx) & naming
     ├─ laporan_pdf_generator.dart   # Generator dokumen PDF (.pdf) & naming
     └─ export_laporan_dialog.dart   # UI dialog pemilihan format & validasi
```

---

## 3. Rincian Implementasi Dokumen

### A. Laporan Excel (.xlsx)
- **Kop Laporan**:
  - `LAPORAN TRANSAKSI PEMBELIAN TBS SAWIT` (Bold, 14pt)
  - Periode rentang tanggal & Waktu cetak
- **Kolom Tabel**:
  1. No (Urut)
  2. Kode Transaksi (`kode_transaksi`)
  3. Tanggal (`tanggal_transaksi`)
  4. Nama Penjual (`nama_penjual`)
  5. Status (`status`)
  6. Total Berat (kg) (`total_berat_kg`)
  7. Total Harga Kotor (Rp) (`total_harga`)
  8. Potongan (Rp) (`nilai_potongan`)
  9. Total Bersih (Rp) (`total_bersih`)
- **Baris Total di Akhir**: Menjumlahkan seluruh kolom numerik (Berat, Kotor, Potongan, Bersih).

### B. Laporan PDF (.pdf)
- **Tata Letak**: A4 Landscape.
- **Kop Judul**: Header korporat bergaris tepi bawah dengan aksen biru IBM.
- **Tabel Transaksi**: `pw.TableHelper.fromTextArray` dengan perataan angka rata kanan (*right-aligned*) dan teks rata kiri.
- **Footer Baris Total**: Kotak rekapitulasi total keseluruhan berlatar abu-abu kontras dengan angka total bersih tebal berwarna biru.
- **Footer Halaman**: Menampilkan penomoran halaman otomatis.

---

## 4. Hasil Verifikasi & Pengujian

### A. Pengujian Otomatis (`flutter test`)
Suite pengujian otomatis mencakup 28 test:
- `LaporanExcelGenerator generates proper file name with date range` (**PASS**)
- `LaporanPdfGenerator generates proper file name with date range` (**PASS**)
- `LaporanExcelGenerator generates non-empty byte buffer with data and totals` (**PASS**)
- `LaporanPdfGenerator generates non-empty PDF byte buffer` (**PASS**)
- **Hasil**: **28 passed, 0 failed**.

### B. Pengujian End-to-End di Browser
Pengujian E2E dilakukan pada build rilis web (`http://localhost:8080/`):
1. **Navigasi ke Halaman Riwayat Transaksi**:
   - Tombol **"Export Laporan"** tampil di bilah atas samping tombol refresh.
2. **Uji Ekspor Excel (.xlsx)**:
   - Membuka dialog export $\to$ Muncul info rentang tanggal aktif dan jumlah transaksi.
   - Memilih opsi **Microsoft Excel (.xlsx)** $\to$ Menekan **Download Laporan**.
   - Dokumen Excel berhasil di-generate dan langsung ter-download ke browser.
3. **Uji Ekspor PDF (.pdf)**:
   - Membuka dialog export $\to$ Memilih **Dokumen PDF (.pdf)**.
   - Menekan **Download Laporan** $\to$ File PDF berhasil diunduh ke browser.
4. **Uji Penanganan Kondisi Kosong (0 Transaksi)**:
   - Filter diubah ke status transaksi yang tidak memiliki data (0 transaksi).
   - Membuka tombol **Export Laporan**.
   - Dialog secara otomatis menampilkan kotak peringatan merah:
     > *"Tidak ada transaksi pada rentang tanggal ini. Silakan sesuaikan filter tanggal sebelum mengekspor."*
   - Tombol **Download Laporan** dinonaktifkan (disabled) untuk melindungi integritas file.

---

## 5. Checklist Acceptance Criteria FR-7.x

| Kriteria | Deskripsi | Status | Catatan Verifikasi |
|---|---|:---:|---|
| **FR-7.1** | Export laporan transaksi untuk rentang tanggal tertentu dalam format Excel & PDF | **PASS** | Tersedia opsi Excel (.xlsx) dan PDF (.pdf) |
| **FR-7.2** | Isi laporan Excel memuat rincian lengkap & baris total di akhir | **PASS** | Memuat 9 kolom termasuk kotor, potongan, bersih, dan baris total |
| **FR-7.3** | Isi laporan PDF format ringkas siap cetak (kop judul, tabel, total) | **PASS** | A4 Landscape, kop korporat, terpaginasi rapi |
| **FR-7.4** | Tombol export tersedia di halaman Riwayat Transaksi dengan filter aktif | **PASS** | Tombol di header Riwayat Transaksi mengambil rentang filter |
| **FR-7.5** | Unduh di Web dan Share Sheet di Mobile via `share_plus` | **PASS** | Modul universal `FileSaver` dengan conditional import |
| **FR-7.6** | Data bersumber dari view `v_transaksi_ringkasan` tanpa hitung ulang | **PASS** | Angka murni dari model `TransaksiRingkasan` |
| **Tugas §5** | Nama file otomatis menyertakan rentang tanggal | **PASS** | Format: `Laporan-Transaksi-YYYY-MM-DD-sd-YYYY-MM-DD` |
| **Tugas §7** | Penanganan kondisi kosong (0 transaksi) | **PASS** | Peringatan komunikatif dan tombol download dinonaktifkan |
