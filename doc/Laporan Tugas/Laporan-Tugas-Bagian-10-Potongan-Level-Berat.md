# Laporan Tugas Bagian 10: Potongan Dipindah ke Level Berat per Jenis Buah

**Tanggal Pelaksanaan**: 6 September 2026  
**Branch Git**: `fitur/potongan-per-berat`  
**Status**: **SELESAI (100% PASS)**  
**Target Platform**: Android, iOS, Web (Verified Production Web Build)  
**Referensi**: [PRD.md §7.6 (FR-6.1 s/d FR-6.5)](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/PRD-Aplikasi-Transaksi-Sawit.md#L96), [Database.md §6](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/Database-Aplikasi-Transaksi-Sawit.md#L321), [AGENTS.md](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/AGENTS.md)

---

## 1. Ringkasan Eksekutif

Tugas Bagian 10 merupakan implementasi arsitektural penting yang **menggantikan model potongan tingkat transaksi (Bagian 7 & 9)** dengan model baru: **Potongan Dipindah ke Level Berat per Jenis Buah** sesuai spesifikasi terbaru PRD §7.6 dan Database.md §6.

### Mengapa Perubahan Ini Diperlukan?
Dalam praktik operasional pabrik dan pengepul sawit (TBS), potongan mutu/sampah (*grading deduction*) diterapkan langsung pada fisik timbangan buah per jenis (misalnya: Tandan Besar memiliki potongan sampah/tangkai 3%, sedangkan Berondolan bersih tanpa potongan 0%). Pendekatan lama yang memotong nominal rupiah di akhir transaksi tidak mencerminkan berat bersih fisik yang diterima pabrik kelapa sawit.

### Prinsip Utama yang Dipenuhi:
1. **Isolasi Git Produksi**: Seluruh pengerjaan dilakukan di branch baru `fitur/potongan-per-berat`, menjaga branch `main` tetap terlindungi.
2. **Kesiapan Migrasi Database yang Aman**: Skrip SQL dipersiapkan secara komprehensif pada [supabase/migrations/20260906_potongan_berat_per_item.sql](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/supabase/migrations/20260906_potongan_berat_per_item.sql) untuk dieksekusi secara manual dan terverifikasi tanpa merusak integritas data production.
3. **Kompabilitas Mundur (*Backward Compatibility*)**: Entitas model client Flutter (`TransaksiItem`, `Transaksi`, `TransaksiRingkasan`, `TransaksiHarian`, `BreakdownJenisBuah`) dilengkapi dengan getter kompatibilitas (`totalBeratKg`, `totalHarga`, `totalBersih`, `nilaiPotongan`) sehingga seluruh komponen UI lama tetap berjalan normal tanpa regresi.
4. **Presisi Finansial Tanpa Floating-Point Error**: Seluruh rumus komputasi berat bersih, nilai potongan rupiah, dan subtotal menggunakan library `Decimal` dengan pembulatan presisi `scale: 2`.
5. **UI Komunikatif Berbahasa Indonesia**: Antarmuka pengguna menyajikan label baku sawit: *Berat Kotor*, *Potongan (%)*, *Berat Bersih*, *Harga / kg*, *Nilai Potongan Berat*, dan *Total Nilai Transaksi*.

---

## 2. Ringkasan Formula & Model Komputasi Baru

Setiap baris item jenis buah kini memiliki dua input manual dan tiga kolom turunan (*generated/calculated*):

| Komponen | Tipe | Sumber | Formula / Ketentuan |
|---|---|---|---|
| **Jenis Buah** | Relasi Master | Input User | Tandan Besar (TB), Tandan Kecil (TK), Berondolan (BR) |
| **Harga / kg** | Rupiah | Input User | Nominal harga satuan per kg |
| **Berat Kotor** | Desimal (kg) | Input User | Berat kotor timbangan kebun (`numeric(10,2)`) |
| **Potongan (%)** | Persentase | Input User | Opsional, default `0%`, batas rentang `0%` – `100%` |
| **Berat Bersih** | Desimal (kg) | **Dihitung Otomatis** | $\text{round}(\text{berat\_kotor} \times (1 - \text{potongan}\% / 100), 2)$ |
| **Nilai Potongan (Rp)** | Rupiah | **Dihitung Otomatis** | $\text{round}(\text{harga} \times \text{berat\_kotor} \times (\text{potongan}\% / 100), 2)$ |
| **Subtotal** | Rupiah | **Dihitung Otomatis** | $\text{harga} \times \text{berat\_bersih}$ |

Pada tingkat transaksi (ringkasan):
- **Total Berat Kotor**: $\sum \text{berat\_kotor\_kg}$
- **Total Berat Bersih**: $\sum \text{berat\_bersih\_kg}$
- **Total Potongan (Rp)**: $\sum \text{nilai\_potongan\_rp}$
- **Total Nilai Transaksi**: $\sum \text{subtotal}$

---

## 3. Rincian Perubahan Kode Sumber

### A. Skrip Migrasi SQL Supabase
- **[supabase/migrations/20260906_potongan_berat_per_item.sql](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/supabase/migrations/20260906_potongan_berat_per_item.sql)**:
  - Mengubah nama kolom `transaksi_item.berat_kg` menjadi `berat_kotor_kg`.
  - Menambahkan kolom `transaksi_item.persentase_potongan numeric(5,2) not null default 0`.
  - Menghapus kolom subtotal lama dan menambahkan kolom generated `berat_bersih_kg`, `nilai_potongan_rp`, serta `subtotal` baru ($\text{harga} \times \text{berat\_bersih}$).
  - Menghapus kolom `persentase_potongan` dari tabel header `transaksi`.
  - Memperbarui view `v_transaksi_ringkasan`, `v_transaksi_harian`, dan `v_breakdown_jenis_buah` agar menghitung `total_berat_kotor_kg`, `total_berat_bersih_kg`, `total_potongan_rp`, dan `total_nilai`.

### B. Lapisan Data & Model
- **[lib/models/transaksi_item.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/models/transaksi_item.dart)**:
  - Menambahkan properti `beratKotorKg`, `persentasePotongan`, `beratBersihKg`, `nilaiPotonganRp`, dan `subtotal`.
  - Menambahkan getter kompatibilitas `beratKg => beratBersihKg`.
- **[lib/models/transaksi.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/models/transaksi.dart)**:
  - Menambahkan properti `totalBeratKotorKg`, `totalBeratBersihKg`, `totalPotonganRp`, dan `totalNilai` pada `Transaksi` dan `TransaksiRingkasan`.
  - Menambahkan getter kompatibilitas `totalBeratKg => totalBeratBersihKg`, `totalHarga => totalNilai`, `totalBersih => totalNilai`, `nilaiPotongan => totalPotonganRp`.
- **[lib/models/dashboard_analytics.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/models/dashboard_analytics.dart)**:
  - Menambahkan dukungan `totalBeratKotorKg`, `totalBeratBersihKg`, `totalPotonganRp`, dan `totalNilai` pada `TransaksiHarian`, `BreakdownJenisBuah`, dan `RingkasanPeriodik`.

### C. State Management & Controller Form
- **[lib/features/transaksi/transaksi_form_state.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/transaksi_form_state.dart)**:
  - `TransaksiItemRowState` kini memiliki `potonganController` sendiri (default `'0'`).
  - Menghitung live preview per baris: `beratBersihKg`, `nilaiPotonganRp`, `subtotal`.
  - Validasi per baris `isPotonganValid` (rentang $0 \le \text{potongan} \le 100$).
  - `TransaksiFormState` mengagregasi `totalBeratKotorKg`, `totalBeratBersihKg`, `totalPotonganRp`, dan `totalNilai`. Menghapus state potongan global tingkat transaksi.
- **[lib/features/transaksi/transaksi_form_controller.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/transaksi_form_controller.dart)**:
  - Mendukung input potongan per baris item dan mengirimkan `TransaksiItemDraft` berisi `beratKotorKg` dan `persentasePotongan` ke repositori.
- **[lib/features/transaksi/transaksi_repository.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/transaksi_repository.dart)**:
  - Melakukan insert ke `transaksi_item` dengan `berat_kotor_kg` dan `persentase_potongan`.
  - Menyesuaikan query `getTransaksiDetail` agar kompatibel dengan skema terbaru (menghapus referensi kolom usang).

### D. Antarmuka Pengguna (UI)
- **[lib/features/transaksi/transaksi_form_page.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/transaksi_form_page.dart)**:
  - Mengubah baris item menjadi layout responsif: Jenis Buah, Harga / kg, Berat Kotor (kg), dan Potongan (%) berdampingan.
  - Menampilkan live badge perhitungan di bawah setiap baris: *Berat Bersih (kg)*, *Potongan (Rp)*, dan *Subtotal*.
  - Menghapus input field potongan global dari summary bar bawah.
  - Summary bar bawah menyajikan 4 metrik: **Total Berat Kotor**, **Total Berat Bersih**, **Total Potongan**, dan **Total Nilai Transaksi**.
- **[lib/features/transaksi/transaksi_list_page.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/transaksi_list_page.dart)**:
  - Kartu transaksi riwayat menampilkan:
    - Kiri: `Berat: [Bersih] kg (Kotor: [Kotor] kg)`
    - Kanan: `Total Nilai: Rp X.XXX.XXX` dan subteks `Pot. Berat: Rp X.XXX` (atau `Tanpa Potongan` jika 0%).
- **[lib/features/transaksi/transaksi_detail_page.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/transaksi_detail_page.dart)**:
  - Menampilkan tabel rincian buah 6 kolom: **Jenis Buah**, **Berat Kotor**, **Potongan**, **Berat Bersih**, **Harga / kg**, **Subtotal**.
  - Box ringkasan menampilkan: **Total Berat Kotor**, **Total Berat Bersih**, **Nilai Potongan Berat**, dan **Total Nilai Transaksi**.

### E. Ekspor Laporan (Excel & PDF)
- **[lib/features/transaksi/export/laporan_excel_generator.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/export/laporan_excel_generator.dart)**:
  - Memperbarui header dan baris kolom: `No`, `Kode Transaksi`, `Tanggal`, `Nama Penjual`, `Status`, `Berat Kotor (kg)`, `Potongan (Rp)`, `Berat Bersih (kg)`, `Total Nilai (Rp)`.
- **[lib/features/transaksi/export/laporan_pdf_generator.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/export/laporan_pdf_generator.dart)**:
  - Memperbarui tabel cetak PDF dan baris total keseluruhan sesuai kolom baru berat kotor, potongan rupiah, berat bersih, dan total nilai transaksi.

---

## 4. Matriks Kriteria Penerimaan (Acceptance Criteria)

| ID Kriteria | Deskripsi Kriteria | Status | Bukti Implementasi / Verifikasi |
|---|---|:---:|---|
| **AC-10.1** | Setiap baris item di form input memiliki input Berat Kotor (kg) dan Potongan (%) dengan default 0% | **PASS** | `_TransaksiItemCard` memiliki `TextFormField` Potongan (%) dengan nilai awal 0; key `item_potongan_field_{keyId}` |
| **AC-10.2** | Live preview Berat Bersih, Nilai Potongan (Rp), dan Subtotal terhitung instan per baris item | **PASS** | Live preview baris: Tandan Besar 100 kg pot. 3% $\to$ Bersih 97 kg, Pot. -Rp 7.500, Subtotal Rp 242.500 |
| **AC-10.3** | Input potongan level transaksi dihapus total dari form Transaksi Baru | **PASS** | Section potongan global dihapus, summary bawah hanya menampilkan agregasi akumulasi |
| **AC-10.4** | Validasi persentase potongan per baris (rentang 0%–100%) dengan pesan error bahasa Indonesia | **PASS** | Validasi di `TransaksiItemRowState.isPotonganValid`; pesan error otomatis muncul jika input $< 0$ atau $> 100$ |
| **AC-10.5** | Riwayat Transaksi menampilkan Berat Kotor, Berat Bersih, Total Nilai, dan Potongan Berat | **PASS** | Kartu riwayat: `Berat: 147,00 kg (Kotor: 150,00 kg)`, `Total Nilai: Rp 382.500`, `Pot. Berat: Rp 7.500` |
| **AC-10.6** | Tabel Detail Nota Transaksi menyajikan 6 kolom lengkap dan box ringkasan 4 metrik | **PASS** | Tabel 6 kolom (Jenis Buah, Berat Kotor, Potongan, Berat Bersih, Harga/kg, Subtotal) dan box ringkasan nota |
| **AC-10.7** | Ekspor Excel & PDF mencerminkan kolom baru berat kotor, potongan rp, berat bersih, total nilai | **PASS** | Header dan formula total di `LaporanExcelGenerator` & `LaporanPdfGenerator` teruji unit test |
| **AC-10.8** | Dashboard Analitik teragregasi berbasis berat bersih dan total nilai transaksi | **PASS** | Dashboard KPI dan grafik tren ter-update otomatis membaca `total_berat_bersih_kg` dan `total_nilai` |

---

## 5. Hasil Pengujian & Verifikasi

### A. Pengujian Otomatis (`flutter test`)
Seluruh rangkaian pengujian (termasuk unit test matematika finansial `Decimal`, serialisasi JSON, filter transaksi, analitik dashboard, dan ekspor) lulus **100% (30 test passed)**:

```
00:04 +21: Tugas Bagian 10: Potongan Level Berat per Jenis Buah Tests TransaksiItemRowState calculates berat bersih, nilai potongan, and subtotal with Decimal
00:04 +22: Tugas Bagian 10: Potongan Level Berat per Jenis Buah Tests TransaksiItemRowState validates potongan percentage range (0 - 100%)
00:04 +23: Tugas Bagian 10: Potongan Level Berat per Jenis Buah Tests Transaksi and TransaksiItem models serialize and deserialize weight discount columns
00:04 +24: Tugas Bagian 10: Potongan Level Berat per Jenis Buah Tests TransaksiRepository createTransaksi produces item-level weight discount in demo mode
00:04 +25: Tugas Bagian 10: Potongan Level Berat per Jenis Buah Tests PercentageFormatter formats whole and decimal percentages cleanly
00:04 +26: Tugas Bagian 8: Export Laporan Excel & PDF Tests LaporanExcelGenerator generates proper file name with date range
00:04 +27: Tugas Bagian 8: Export Laporan Excel & PDF Tests LaporanPdfGenerator generates proper file name with date range
00:04 +28: Tugas Bagian 8: Export Laporan Excel & PDF Tests LaporanExcelGenerator generates non-empty byte buffer with data and totals
00:05 +29: Tugas Bagian 8: Export Laporan Excel & PDF Tests LaporanPdfGenerator generates non-empty PDF byte buffer
00:05 +30: All tests passed!
```

### B. Pengujian End-to-End di Browser
Pengujian live dilaksanakan di peramban web pada port 8080 (`http://localhost:8080/`):

1. **Skenario Input Multi-Item dengan Potongan Berbeda**:
   - Penjual: **arni**
   - **Item 1**: Tandan Besar (TB), Harga Rp 2.500/kg, Berat Kotor 100 kg, Potongan 3%
     - *Hasil Live*: Berat Bersih = **97,00 kg**, Potongan = **-Rp 7.500**, Subtotal = **Rp 242.500**
   - **Item 2**: Berondolan (BR), Harga Rp 2.800/kg, Berat Kotor 50 kg, Potongan 0%
     - *Hasil Live*: Berat Bersih = **50,00 kg**, Potongan = **Rp 0**, Subtotal = **Rp 140.000**
   - **Summary Bar**:
     - Total Berat Kotor = **150,00 kg**
     - Total Berat Bersih = **147,00 kg**
     - Total Potongan = **- Rp 7.500**
     - Total Nilai Transaksi = **Rp 382.500**

2. **Penyimpanan Transaksi ke Database**:
   - Klik **Simpan Transaksi** berhasil dieksekusi ke Supabase.
   - Dialog konfirmasi sukses muncul menampilkan ringkasan nota:
     - Nomor Transaksi: **`TRX-20260906-0007`**
     - Berat Kotor: **150,00 kg** | Berat Bersih: **147,00 kg** | Total Nilai: **Rp 382.500**

3. **Verifikasi Halaman Detail Nota Transaksi**:
   - Tabel 6 kolom memuat rincian transaksi secara presisi:
     - Tandan Besar: Kotor 100 kg, Pot. 3%, Bersih 97 kg, Rp 2.500/kg $\to$ Subtotal Rp 242.500
     - Berondolan: Kotor 50 kg, Pot. 0%, Bersih 50 kg, Rp 2.800/kg $\to$ Subtotal Rp 140.000
   - Box Ringkasan Nota:
     - Total Berat Kotor: **150,00 kg**
     - Total Berat Bersih: **147,00 kg**
     - Nilai Potongan Berat: **- Rp 7.500**
     - Total Nilai Transaksi: **Rp 382.500**

4. **Verifikasi Halaman Riwayat Transaksi**:
   - Transaksi `TRX-20260906-0007` tampil teratas dengan badge hijau **SELESAI**:
     - `Berat: 147,00 kg (Kotor: 150,00 kg)`
     - `Total Nilai: Rp 382.500`
     - `Pot. Berat: Rp 7.500`

5. **Verifikasi Dashboard Analitik**:
   - Kartu KPI ter-update: Total Transaksi Hari Ini bertambah, Total Berat bertambah 147 kg, dan Total Nilai bertambah Rp 382.500.
   - Daftar 10 transaksi terakhir menampilkan `TRX-20260906-0007`.

---

## 6. Dokumentasi Artefak Visual (Screenshots & Video)

Seluruh rekaman interaksi dan tangkapan layar pengujian telah tersimpan di direktori artefak:

| Artefak Pengujian | Deskripsi Visual | File Artefak |
|---|---|---|
| **Form Preview Multi-Item** | Live preview item 1 & 2 dengan potongan berat per item dan summary bar | `transaksi_form_preview_1788660583730.png` |
| **Dialog Sukses Transaksi** | Konfirmasi transaksi `TRX-20260906-0007` berhasil tersimpan di DB | `transaksi_success_dialog_1788660603325.png` |
| **Detail Nota Transaksi** | Tabel 6 kolom rincian per buah dan box ringkasan 4 metrik | `detail_nota_sukses_1788660834382.png` |
| **Riwayat Transaksi** | Kartu riwayat dengan format berat kotor/bersih dan potongan berat | `transaksi_riwayat_page_1788660675759.png` |
| **Dashboard Analitik** | KPI hari ini dan riwayat transaksi terakhir ter-update | `dashboard_page_1788660694343.png` |
| **Video Rekaman Sesi E2E** | Video WebP interaksi peramban dari input form hingga detail nota | `uji_detail_nota_1788660800987.webp` |

---

## 7. Kesimpulan

Tugas Bagian 10 berhasil diselesaikan secara tuntas dan sesuai dengan standar arsitektur proyek:
- ✅ **Aman bagi Produksi**: Dikerjakan secara terisolasi di branch `fitur/potongan-per-berat`.
- ✅ **Single Source of Truth**: Menghormati struktur schema database `20260906_potongan_berat_per_item.sql`.
- ✅ **Akurasi Tinggi**: Komputasi berat bersih dan finansial presisi anti floating-point error dengan `Decimal`.
- ✅ **Pengujian Menyeluruh**: 30 dari 30 pengujian otomatis lulus, dan pengujian E2E di browser berhasil memverifikasi seluruh antarmuka.
