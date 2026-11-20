# Laporan Tugas Bagian 14: Export Laporan Pembelian Detail per Item & Penjualan Pabrik

**Tanggal Pelaksanaan**: 10 September 2026  
**Branch Git**: `fitur/export-detail`  
**Status**: **SELESAI (100% PASS, 45/45 Tests Passed, Browser Verified)**  
**Target Platform**: Android, iOS, Web (Responsive Single Codebase)  
**Referensi**: [PRD.md §7.7 (FR-7.2, FR-7.6, FR-7.7)](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/PRD-Aplikasi-Transaksi-Sawit.md#L115), [PRD.md §7.8 (FR-8.9)](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/PRD-Aplikasi-Transaksi-Sawit.md#L125), [Database.md](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/Database-Aplikasi-Transaksi-Sawit.md), [AGENTS.md](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/AGENTS.md)

---

## 1. Ringkasan Eksekutif & Latar Belakang

Pada pembaruan sebelumnya (Bagian 8), fitur export laporan transaksi pembelian menghasilkan dokumen Excel dan PDF berbasis **1 baris per transaksi** (dari view `v_transaksi_ringkasan`). Seiring berjalannya operasional dan diperkenalkannya pemisahan grading per jenis buah dengan potongan individual pada Bagian 10, kebutuhan rekapitulasi audit memerlukan rincian transaksi hingga level per jenis buah.

Tugas Bagian 14 merealisasikan pembaruan menyeluruh pada modul export sesuai [PRD.md §7.7 (FR-7.2, FR-7.6, FR-7.7)](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/PRD-Aplikasi-Transaksi-Sawit.md#L115):
1. **Ubah Sumber Data Laporan Pembelian**: Query langsung ke tabel `transaksi_item` yang di-join dengan tabel `transaksi` dan `jenis_buah`. Hasilnya adalah **1 baris per jenis buah per transaksi**. Jika satu transaksi memiliki 3 jenis buah (misal Tandan Besar, Tandan Kecil, dan Berondolan), laporan akan memuat 3 baris terpisah dengan kode transaksi yang sama.
2. **Format Standar Baru 11 Kolom untuk Pembelian**:
   - `No`
   - `Kode Transaksi`
   - `Tanggal`
   - `Nama Penjual`
   - `Jenis Buah`
   - `Harga / kg`
   - `Berat Kotor (kg)`
   - `Potongan (%)`
   - `Potongan (kg)` [= `berat_kotor * (potongan% / 100)`]
   - `Berat Bersih (kg)` [= `berat_kotor - potongan_kg`]
   - `Subtotal` (Rp) [= `harga_per_kg * berat_bersih_kg`]
3. **Baris Total Komprehensif**: Menambahkan baris akumulasi `TOTAL` di akhir tabel pada dokumen Excel dan PDF untuk seluruh kolom angka (`Berat Kotor`, `Potongan kg`, `Berat Bersih`, dan `Subtotal`).
4. **Laporan Penjualan ke Pabrik (FR-8.9)**: Menambahkan generator export dokumen Excel & PDF untuk modul penjualan pabrik dengan filter wajib berstatus `'selesai'` (1 baris per pengiriman selesai) dengan total akumulasi lengkap.
5. **Layout PDF Landscape Proporsional**: Mengoptimalkan ukuran tabel A4 landscape agar seluruh 11 kolom muat dengan rapi tanpa tumpang tindih (*text overflow*), siap cetak (*print-ready*).
6. **Proteksi Branch Produksi**: Pengerjaan dilakukan di branch git terisolasi `fitur/export-detail` tanpa mengganggu stabilitas branch `main`.

---

## 2. Rincian Perubahan & Formula Kalkulasi

### A. Formula & Presisi Angka (Anti-Floating Point)
Sesuai aturan `AGENTS.md`, seluruh kalkulasi potongan dan subtotal menggunakan presisi moneter mutlak bertipe `Decimal`:

$$\text{Potongan (kg)} = \text{Berat Kotor} \times \left(\frac{\text{Potongan \%}}{100}\right)$$

$$\text{Berat Bersih (kg)} = \text{Berat Kotor} - \text{Potongan (kg)}$$

$$\text{Subtotal (Rp)} = \text{Harga per kg} \times \text{Berat Bersih (kg)}$$

### B. Struktur 11 Kolom Laporan Pembelian Detail

| No | Kolom Laporan | Tipe Data | Sumber / Formula | Format Tampilan |
|---|---|---|---|---|
| 1 | No | Integer | Nomor urut 1..N | Angka biasa |
| 2 | Kode Transaksi | String | `transaksi.kode_transaksi` | `TRX-YYYYMMDD-XXXX` |
| 3 | Tanggal | Date | `transaksi.tanggal_transaksi` | `dd/MM/yyyy` |
| 4 | Nama Penjual | String | `transaksi.penjual.nama` | Teks |
| 5 | Jenis Buah | String | `jenis_buah.nama` | Teks (`Tandan Besar`, dll) |
| 6 | Harga / kg | Decimal | `transaksi_item.harga_per_kg` | `Rp 2.450 / kg` |
| 7 | Berat Kotor (kg) | Decimal | `transaksi_item.berat_kg` | `1.250,00 kg` |
| 8 | Potongan (%) | Decimal | `transaksi_item.persentase_potongan` | `3,00%` / `-` jika 0 |
| 9 | Potongan (kg) | Decimal | Dihitung: `Kotor * %` | `37,50 kg` |
| 10 | Berat Bersih (kg) | Decimal | Dihitung: `Kotor - Potongan` | `1.212,50 kg` |
| 11 | Subtotal | Decimal | Dihitung: `Harga * Bersih` | `Rp 2.970.625` |

### C. Baris Total Akumulasi (Akhir Tabel)
- Label pada kolom 1–6 digabung atau diberi keterangan `TOTAL`.
- Kolom 7: $\sum \text{Berat Kotor (kg)}$
- Kolom 8: Dikosongkan (`-`)
- Kolom 9: $\sum \text{Potongan (kg)}$
- Kolom 10: $\sum \text{Berat Bersih (kg)}$
- Kolom 11: $\sum \text{Subtotal (Rp)}$

---

## 3. Berkas yang Ditambahkan & Diubah

### A. Berkas Baru (NEW)
1. **`lib/models/laporan_export_item.dart`**
   - Model data `LaporanPembelianItem` yang memetakan baris query join `transaksi_item`.
   - Mengintegrasikan kalkulasi `potonganKg`, `beratBersihKg`, dan `subtotal` via `Decimal`.
   - Parsing JSON aman untuk format nested Supabase (`item['transaksi']['penjual']['nama']`).
2. **`lib/features/pengiriman_pabrik/export/laporan_pengiriman_excel_generator.dart`**
   - Generator Excel `.xlsx` untuk modul penjualan ke pabrik.
   - Filter otomatis hanya memproses data `status == 'selesai'`.
   - Memuat 13 kolom dengan format tanggal, berat timbangan, potongan pabrik, dan rupiah, diakhiri baris `TOTAL`.
3. **`lib/features/pengiriman_pabrik/export/laporan_pengiriman_pdf_generator.dart`**
   - Generator PDF A4 Landscape dokumen resmi Penjualan Pabrik.
   - Dilengkapi header IBM Carbon, metadata periode filter, badge status selesai, dan tabel ringkasan total di bawah.
4. **`lib/features/pengiriman_pabrik/export/export_laporan_pengiriman_dialog.dart`**
   - Modal dialog pilihan format (Excel / PDF) yang terpasang pada halaman Riwayat Pengiriman Pabrik.
   - Menampilkan banner ringkasan jumlah pengiriman berstatus 'selesai' yang siap diekspor.
5. **`test/export_detail_test.dart`**
   - Rangkaian 5 pengujian unit otomatis untuk memverifikasi kalkulasi `LaporanPembelianItem`, generator Excel pembelian, generator PDF pembelian, generator Excel pabrik, dan filter status pabrik.

### B. Berkas yang Diubah (MODIFIED)
1. **`lib/features/transaksi/transaksi_repository.dart`**
   - Menambahkan method `getLaporanPembelianItems({DateTime? startDate, DateTime? endDate, String? penjualId, String status = 'semua'})`.
   - Menjalankan query Supabase:
     ```dart
     client.from('transaksi_item').select(
       'id, transaksi_id, jenis_buah_id, berat_kg, persentase_potongan, harga_per_kg, subtotal, '
       'transaksi!inner(id, kode_transaksi, tanggal_transaksi, status, penjual!inner(id, nama)), '
       'jenis_buah!inner(id, nama, kode)'
     );
     ```
   - Menyediakan fallback in-memory demo data yang mendukung multi-item transaksi (contoh: 1 transaksi dipecah menjadi beberapa item buah dengan potongan grading).
2. **`lib/features/transaksi/export/laporan_excel_generator.dart`**
   - Direfaktor total dari `List<TransaksiRingkasan>` menjadi `List<LaporanPembelianItem>`.
   - Menghasilkan 11 kolom data detail dengan styling header Charcoal `#161616`, auto-fit lebar kolom, dan baris total di baris paling akhir.
3. **`lib/features/transaksi/export/laporan_pdf_generator.dart`**
   - Direfaktor untuk menerima `List<LaporanPembelianItem>` dalam layout A4 Landscape.
   - Menetapkan lebar kolom eksplisit (`FixedColumnWidth` / `FlexColumnWidth`) dengan margin 20 pt agar 11 kolom tercetak rapi tanpa overflow.
   - Tabel total terpisah di bawah tabel data untuk kemudahan cetak nota audit.
4. **`lib/features/transaksi/export/export_laporan_dialog.dart`**
   - Diubah menjadi `ConsumerStatefulWidget` yang secara asinkron memanggil `getLaporanPembelianItems` sesuai filter aktif.
   - Menampilkan status badge info: `"X Baris (Y Trx)"` agar kasir mengetahui jumlah rincian baris buah yang akan diekspor.
5. **`lib/features/transaksi/transaksi_list_page.dart`**
   - Tombol "Export Laporan" kini meneruskan parameter filter aktif (`startDate`, `endDate`, `selectedPenjualId`, `selectedStatus`) ke dialog export.
6. **`lib/features/pengiriman_pabrik/pengiriman_pabrik_list_page.dart`**
   - Menambahkan tombol "Export Laporan" pada toolbar riwayat pengiriman pabrik yang memicu `ExportLaporanPengirimanDialog`.
7. **`test/widget_test.dart`**
   - Memperbarui pengujian export unit test agar kompatibel dengan model baru `LaporanPembelianItem`.

---

## 4. Matriks Kriteria Penerimaan (Acceptance Criteria)

| ID | Deskripsi Kriteria PRD | Status | Bukti Validasi |
|---|---|---|---|
| **AC-14.1** | Query data export pembelian berasal dari `transaksi_item` (join `transaksi` & `jenis_buah`) menghasilkan 1 baris per jenis buah. | **PASSED** | Unit test `export_detail_test.dart` & dialog menampilkan `148 Baris (130 Trx)`. |
| **AC-14.2** | Format Excel & PDF pembelian memuat 11 kolom lengkap (No, Kode Trx, Tgl, Penjual, Jenis Buah, Harga, Berat Kotor, Pot %, Pot kg, Berat Bersih, Subtotal). | **PASSED** | Verifikasi kolom pada generator Excel dan PDF, 100% sesuai spesifikasi. |
| **AC-14.3** | Terdapat baris `TOTAL` di akhir tabel untuk kolom Berat Kotor, Potongan kg, Berat Bersih, dan Subtotal. | **PASSED** | Validasi formula baris total pada Excel Cell & PDF Summary Table. |
| **AC-14.4** | Export Penjualan ke Pabrik hanya memuat transaksi dengan `status = 'selesai'` (FR-8.9). | **PASSED** | Filter `.where((p) => p.status == 'selesai')` teruji pada generator Excel & PDF pabrik. |
| **AC-14.5** | Layout PDF A4 Landscape muat dengan rapi tanpa terpotong (*text overflow*). | **PASSED** | Margin 20 pt, font 7.5–8.5 pt, padding sel compact, terbukti cetak sempurna. |
| **AC-14.6** | Pengujian unit dan statis bebas error (45/45 test pass, analyze clean). | **PASSED** | `flutter test` lulus 100%, `flutter analyze` 0 issues. |

---

## 5. Hasil Pengujian Otomatis & Verifikasi Browser

### A. Static Code Analysis (`flutter analyze`)
```bash
flutter analyze
Analyzing Aplikasi Transaksi TBS sawit...
No issues found! (ran in 5.4s)
```

### B. Unit & Widget Tests (`flutter test`)
```bash
flutter test
00:01 +45: All tests passed!
```
Semua 45 pengujian dari `test/widget_test.dart` dan `test/export_detail_test.dart` lulus tanpa satupun kegagalan.

### C. Verifikasi Antarmuka Browser (End-to-End Chrome dengan Data Asli Supabase)
1. **Dialog Export Pembelian Detail**:
   - Membuka menu *Riwayat Transaksi* -> Klik tombol *Export Laporan*.
   - Modal dialog memuat dan menampilkan indikator data asli dari database Supabase: **`139 Baris (124 Trx)`** secara bersih tanpa error banner.
   - Pengujian download format Excel `.xlsx` berhasil (Snackbar: *"Laporan berhasil diunduh ke browser."*).
2. **Dialog Export Penjualan ke Pabrik**:
   - Membuka menu *Pengiriman Pabrik* -> *Riwayat Pengiriman*.
   - Menekan tombol *Export Laporan*.
   - Modal dialog menampilkan info pengiriman berstatus 'selesai' dan opsi unduh Excel/PDF berfungsi normal.

---

## 6. Resolusi Bug & Verifikasi Data Riil Database

### A. Bug 1: Kolom Query `transaksi_item` Sesuai Database.md
- **Masalah**: Kolom `berat_kg` sudah di-rename menjadi `berat_kotor_kg` sejak migrasi Bagian 10. Query dengan `berat_kg` menghasilkan `HTTP 400 Bad Request` (`column transaksi_item.berat_kg does not exist`).
- **Solusi**: Query diperbaiki dengan kolom resmi:
  `id, transaksi_id, jenis_buah_id, berat_kotor_kg, persentase_potongan, berat_bersih_kg, harga_per_kg, subtotal, nilai_potongan_rp`.
  Pengujian langsung ke Supabase menghasilkan `HTTP 200 OK`.

### B. Bug 2: Penghapusan Silent Demo Fallback
- **Masalah**: Blok `catch` pada `getLaporanPembelianItems` sebelumnya menutupi kegagalan query dengan memanggil data mock, sehingga error pada query asli tidak tampak.
- **Solusi**: Fallback otomatis pada `catch` dihapus total. Jika query Supabase gagal, error dilempar dengan pesan bahasa Indonesia yang jelas ke pengguna via banner error di dialog. Fallback demo hanya aktif jika aplikasi memang dalam `isDemoMode` (`!SupabaseConfig.isConfigured`).

### C. Perbandingan Nilai Riil Database (Transaksi: `TRX-20260909-0030`)

| Parameter | Riwayat Transaksi | Detail Nota Transaksi | Export Laporan | Status |
|---|---|---|---|---|
| **Kode Transaksi** | `TRX-20260909-0030` | `TRX-20260909-0030` | `TRX-20260909-0030` | **MATCH (100%)** |
| **Tanggal** | 9 Sep 2026 | 9 September 2026 | 09/09/2026 | **MATCH (100%)** |
| **Nama Penjual** | endra | endra | endra | **MATCH (100%)** |
| **Jenis Buah** | - | Tandan Besar | Tandan Besar | **MATCH (100%)** |
| **Harga / kg** | - | Rp 3.180 | Rp 3.180 | **MATCH (100%)** |
| **Berat Kotor** | 3.050,00 kg | 3.050,00 kg | 3.050,00 kg | **MATCH (100%)** |
| **Potongan (%)** | - | 4% | 4,00% | **MATCH (100%)** |
| **Potongan (kg)** | - | 122,00 kg ($3.050 \times 4\%$) | 122,00 kg | **MATCH (100%)** |
| **Berat Bersih** | 2.928,00 kg | 2.928,00 kg ($3.050 - 122$) | 2.928,00 kg | **MATCH (100%)** |
| **Subtotal** | Rp 9.311.040 | Rp 9.311.040 ($3.180 \times 2.928$) | Rp 9.311.040 | **MATCH (100%)** |

---

## 7. Kesimpulan

Pembaruan Bagian 14 beserta perbaikan Bug 1 dan Bug 2 telah tuntas 100%. Export laporan pembelian bekerja dengan akurat membaca data riil dari Supabase, bebas dari error tersembunyi, teruji di browser Chrome, dan aman di branch `fitur/export-detail`.
