# LAPORAN PENYELESAIAN TUGAS BAGIAN 20
## Koreksi Alur Operasional & Field Penjualan ke Pabrik (FR-8.x & Database.md §9)

**Tanggal Eksekusi**: 17 September 2026  
**Branch Git**: `fitur/koreksi-flow-pabrik`  
**Status**: **SELESAI (100% Terverifikasi & Lolos Seluruh Pengujian)**

---

## 1. Ringkasan Eksekutif & Latar Belakang

Modul Penjualan ke Pabrik (PKS) telah diperbaiki secara menyeluruh untuk memulihkan keselarasan sistem dengan alur operasional fisik perkebunan sawit di lapangan:
1. **Fase 1 (Keberangkatan Truk / `berangkat`)**:
   - Hanya mencatat timbangan kotor sebelum truk berangkat dari ramp / timbangan internal pengepul.
   - Kolom diubah namanya menjadi **`berat_dikirim_kg`** (sebelumnya `berat_kotor_kg`).
2. **Fase 2 (Penyelesaian Nota Pabrik / `selesai`)**:
   - Diisi bersamaan dalam **1 form / 1 aksi** ketika sopir menyerahkan SPB / nota pabrik.
   - Kolom input manual:
     - **`berat_sampai_kg`** (*BARU* — timbangan kotor saat truk tiba di pabrik).
     - **`berat_ditolak_kg`** (manual dari pabrik).
     - **`persentase_potongan_pabrik`** (manual potongan sortasi/sampah dari pabrik).
     - **`harga_jual_per_kg`** (manual kesepakatan harga).
3. **Formula & Nilai Turunan Otomatis (Stored Generated Column di Database)**:
   - **Berat Diterima (kg)**: $\text{berat\_sampai\_kg} - \text{berat\_ditolak\_kg}$
   - **Berat Bersih (kg)**: $\text{berat\_diterima\_kg} \times (1 - \text{persentase\_potongan\_pabrik} / 100)$
   - **Total Nilai Jual (Rp)**: $\text{harga\_jual\_per\_kg} \times \text{berat\_bersih\_kg}$
   - **Susut Buah (kg)** (*BARU*): $\text{berat\_dikirim\_kg} - \text{berat\_sampai\_kg}$ (susut bobot selama perjalanan pengiriman)
4. **Validasi Kritis**:
   - Berat Ditolak tidak boleh lebih besar dari Berat Sampai: $\text{berat\_ditolak\_kg} \le \text{berat\_sampai\_kg}$ (bukan dibandingkan terhadap berat dikirim).

---

## 2. Verifikasi Integritas Data Pasca-Migrasi (3 Baris Sampel Production)

Migrasi database dieksekusi dengan aman melalui skrip transaksi SQL (`20260909_koreksi_alur_dan_field_pengiriman_pabrik.sql`) setelah backup data diekspor oleh pengguna.

Pada proses backfill data historis, `berat_sampai_kg` disetel sama dengan `berat_dikirim_kg` untuk seluruh 25 baris yang berstatus `'selesai'`. Berikut adalah perbandingan langsung nilai baseline sebelum migrasi vs nilai aktual query REST API Supabase pasca-migrasi:

| Kode Pengiriman | Parameter | Baseline Sebelum Migrasi | Aktual Pasca Migrasi | Status Integritas |
|---|---|---|---|---|
| **`KRM-20260912-0001`** | `berat_dikirim_kg` | 5.700,00 kg (kotor) | 5.700,00 kg | **IDENTIK 100%** |
| | `berat_sampai_kg` | - | 5.700,00 kg | **BERHASIL DI-BACKFILL** |
| | `berat_ditolak_kg` | 178,00 kg | 178,00 kg | **IDENTIK 100%** |
| | **`berat_diterima_kg`** | **5.522,00 kg** | **5.522,00 kg** | **IDENTIK 100%** |
| | `persentase_potongan_pabrik` | 4,00% | 4,00% | **IDENTIK 100%** |
| | **`berat_bersih_kg`** | **5.301,12 kg** | **5.301,12 kg** | **IDENTIK 100%** |
| | `susut_buah_kg` | - | 0,00 kg | **SESUAI LOGIKA HISTORIS** |
| | `harga_jual_per_kg` | Rp 3.500,00 | Rp 3.500,00 | **IDENTIK 100%** |
| | **`total_nilai_jual`** | **Rp 18.553.920,00** | **Rp 18.553.920,00** | **IDENTIK 100%** |
| **`KRM-20260911-0002`** | `berat_dikirim_kg` | 2.127,00 kg (kotor) | 2.127,00 kg | **IDENTIK 100%** |
| | `berat_sampai_kg` | - | 2.127,00 kg | **BERHASIL DI-BACKFILL** |
| | `berat_ditolak_kg` | 0,00 kg | 0,00 kg | **IDENTIK 100%** |
| | **`berat_diterima_kg`** | **2.127,00 kg** | **2.127,00 kg** | **IDENTIK 100%** |
| | `persentase_potongan_pabrik` | 1,30% | 1,30% | **IDENTIK 100%** |
| | **`berat_bersih_kg`** | **2.099,35 kg** | **2.099,35 kg** | **IDENTIK 100%** |
| | `susut_buah_kg` | - | 0,00 kg | **SESUAI LOGIKA HISTORIS** |
| | `harga_jual_per_kg` | Rp 3.070,00 | Rp 3.070,00 | **IDENTIK 100%** |
| | **`total_nilai_jual`** | **Rp 6.445.001,43** | **Rp 6.445.001,43** | **IDENTIK 100%** |
| **`KRM-20260911-0001`** | `berat_dikirim_kg` | 6.470,00 kg (kotor) | 6.470,00 kg | **IDENTIK 100%** |
| | `berat_sampai_kg` | - | 6.470,00 kg | **BERHASIL DI-BACKFILL** |
| | `berat_ditolak_kg` | 0,00 kg | 0,00 kg | **IDENTIK 100%** |
| | **`berat_diterima_kg`** | **6.470,00 kg** | **6.470,00 kg** | **IDENTIK 100%** |
| | `persentase_potongan_pabrik` | 3,50% | 3,50% | **IDENTIK 100%** |
| | **`berat_bersih_kg`** | **6.243,55 kg** | **6.243,55 kg** | **IDENTIK 100%** |
| | `susut_buah_kg` | - | 0,00 kg | **SESUAI LOGIKA HISTORIS** |
| | `harga_jual_per_kg` | Rp 3.500,00 | Rp 3.500,00 | **IDENTIK 100%** |
| | **`total_nilai_jual`** | **Rp 21.852.425,00** | **Rp 21.852.425,00** | **IDENTIK 100%** |

*Kesimpulan Integritas*: Seluruh 25 data pengiriman lama berhasil dipertahankan tanpa perubahan nilai nominal uang maupun berat bersih sedikit pun!

---

## 3. Rangkuman Perubahan Kode

### A. Database Migration SQL
- [`supabase/migrations/20260909_koreksi_alur_dan_field_pengiriman_pabrik.sql`](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/supabase/migrations/20260909_koreksi_alur_dan_field_pengiriman_pabrik.sql):
  - Rename `berat_kotor_kg` $\rightarrow$ `berat_dikirim_kg`.
  - Tambah kolom `berat_sampai_kg numeric(10,2)`.
  - Rekonstruksi generated columns: `berat_diterima_kg`, `berat_bersih_kg`, `nilai_potongan_rp`, `total_nilai_jual`, dan kolom baru `susut_buah_kg`.
  - Update check constraint menjadi `pengiriman_pabrik_ditolak_lte_sampai_check`.
  - Memperbarui 4 view laporan: `v_pengiriman_ringkasan`, `v_pengiriman_harian`, `v_margin_harian`, dan `v_breakdown_pabrik`.

### B. Model & Repository
- [`lib/models/pengiriman_pabrik.dart`](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/models/pengiriman_pabrik.dart):
  - Properti baru `beratDikirimKg`, `beratSampaiKg`, `susutBuahKg`.
  - Getter alias `beratKotorKg => beratDikirimKg` untuk backward compatibility.
  - Method `toInsertMap()` (hanya kirim `berat_dikirim_kg`) dan `toSelesaikanMap()`.
- [`lib/features/pengiriman_pabrik/pengiriman_pabrik_repository.dart`](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/pengiriman_pabrik/pengiriman_pabrik_repository.dart):
  - `createPengiriman()` menyimpan `berat_dikirim_kg`.
  - `selesaikanPengirimanFase2()` memvalidasi `berat_sampai_kg > 0` dan `berat_ditolak_kg <= berat_sampai_kg`.

### C. State Management & Controllers
- [`lib/features/pengiriman_pabrik/pengiriman_pabrik_controller.dart`](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/pengiriman_pabrik/pengiriman_pabrik_controller.dart):
  - `PengirimanFormState`: mendukung `beratDikirim`.
  - `SelesaikanFormState`: input pertama `beratSampai`, kalkulasi real-time interaktif untuk `susutBuah`, `beratDiterima`, `beratBersih`, `totalNilaiJual`.

### D. Tampilan Antarmuka (UI)
- [`lib/features/pengiriman_pabrik/pengiriman_pabrik_form_page.dart`](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/pengiriman_pabrik/pengiriman_pabrik_form_page.dart):
  - Label dan placeholder diperbarui menjadi **"Berat Dikirim (kg)"**.
- [`lib/features/pengiriman_pabrik/selesaikan_pengiriman_page.dart`](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/pengiriman_pabrik/selesaikan_pengiriman_page.dart):
  - Input field pertama adalah **"Berat Sampai di Pabrik (kg)"**.
  - Tampilan card live calculation interaktif dengan rumus transparan.
  - Tampilan responsif dengan `Wrap` dan `ConstrainedBox` (lolos pengujian layar sempit 320x640 tanpa overflow).
- [`lib/features/pengiriman_pabrik/pengiriman_pabrik_list_page.dart`](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/pengiriman_pabrik/pengiriman_pabrik_list_page.dart):
  - Dialog detail menampilkan seluruh 10 field secara lengkap tanpa disembunyikan. Untuk status `berangkat`, kolom Fase 2 diberi badge *"Belum diisi"*.
- [`lib/features/dashboard/widgets/kartu_ringkasan.dart`](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/dashboard/widgets/kartu_ringkasan.dart) & [`chart_tren_berat_penjualan.dart`](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/dashboard/widgets/chart_tren_berat_penjualan.dart):
  - Label modul penjualan pabrik diubah dari "Berat Kotor" menjadi **"Berat Dikirim"**.

### E. Ekspor Laporan Penjualan Pabrik (Excel & PDF)
- [`lib/features/pengiriman_pabrik/export/laporan_pengiriman_excel_generator.dart`](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/pengiriman_pabrik/export/laporan_pengiriman_excel_generator.dart):
  - Menambahkan kolom **Berat Sampai (kg)** dan **Susut Buah (kg)**, header **Berat Dikirim (kg)**. Total keseluruhan diakumulasikan secara tepat.
- [`lib/features/pengiriman_pabrik/export/laporan_pengiriman_pdf_generator.dart`](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/pengiriman_pabrik/export/laporan_pengiriman_pdf_generator.dart):
  - Menambahkan kolom **Dikirim**, **Sampai**, dan **Susut** dalam format tabel lanskap A4 dengan penyesuaian flex width yang proporsional.

---

## 4. Hasil Pengujian Otomatis

### A. Pengujian Unit & Widget (`flutter test`)
```
00:09 +101: All tests passed!
```
- **Total Test**: **101 test suite**
- **Test Lulus**: **101 test (100% PASS)**
- **Test Gagal**: **0**
- File pengujian baru [`test/bagian20_koreksi_flow_pabrik_test.dart`](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/test/bagian20_koreksi_flow_pabrik_test.dart) menguji secara komprehensif:
  - Kalkulasi presisi: $1000 \text{ kg} \rightarrow 980 \text{ kg}, 30 \text{ kg ditolak}, 2\% \text{ pot}, \text{Rp } 2.200/\text{kg} \rightarrow \text{Rp } 2.048.200$.
  - Serialisasi model JSON baru dan backward compatibility.
  - Validasi penolakan jika $\text{berat\_ditolak} > \text{berat\_sampai}$.
  - Validasi pembatasan $\text{berat\_sampai} > 0$.

### B. Analisis Kode Statis (`flutter analyze`)
```
Analyzing Aplikasi Transaksi TBS sawit...                       
No issues found! (ran in 4.4s)
```
- **0 errors, 0 warnings, 0 lints!**

---

## 5. Hasil Verifikasi End-to-End di Browser

Pengujian dilakukan langsung pada aplikasi web Flutter (`http://127.0.0.1:8080/`) dengan alur nyata:

### Skenario Uji:
1. **Fase 1 (Keberangkatan)**:
   - Input: Pabrik: PT. APS, Plat: `BK 9999 TBS`, Sopir: `Anto Verifikasi`, Berat Dikirim: `1.000 kg`.
   - Hasil: Berhasil tersimpan dengan status `BERANGKAT`.
2. **Fase 2 (Penyelesaian Nota)**:
   - Input:
     - Berat Sampai di Pabrik: `980 kg`
     - Berat Ditolak / BS: `30 kg`
     - Potongan Sortasi Pabrik: `2%`
     - Harga Jual Kesepakatan: `Rp 2.200 / kg`
   - **Live Calculation Preview (Interaktif)**:
     - **Susut Buah**: `20,00 kg` ($1000 - 980$)
     - **Berat Diterima**: `950,00 kg` ($980 - 30$)
     - **Berat Bersih**: `931,00 kg` ($950 \times 0,98$)
     - **Total Nilai Jual**: `Rp 2.048.200` ($931 \times 2200$)
   - Hasil Simpan: Status berhasil berubah menjadi `SELESAI` dan data terdaftar di riwayat transaksi.

---

## 6. Kesimpulan

Tugas Bagian 20 telah **selesai secara paripurna**:
- Database production berhasil dimigrasikan dan seluruh data historis 100% terjaga.
- Alur form dan rumus kalkulasi di client Flutter telah sesuai dengan PRD dan Database.md versi final.
- Ekspor Excel & PDF telah memuat seluruh 15 kolom pengiriman termasuk Berat Sampai dan Susut Buah.
- Seluruh 101 automated test dan static analysis lulus dengan sempurna.
- Verifikasi visual di browser membuktikan seluruh perhitungan berjalan akurat hingga angka desimal terakhir.
