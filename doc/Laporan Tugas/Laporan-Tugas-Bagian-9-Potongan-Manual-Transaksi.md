# Laporan Tugas Bagian 9: Potongan Manual Transaksi (PRD §FR-6.x Update)

**Tanggal Pelaksanaan**: 6 September 2026  
**Branch Git**: `fitur/potongan-manual`  
**Status**: **SELESAI (100% PASS)**  
**Target Platform**: Android, iOS, Web (Verified Production Web Build)  
**Referensi**: [PRD.md §7.6 (FR-6.1 s/d FR-6.4)](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/PRD-Aplikasi-Transaksi-Sawit.md#L96), [Database.md §5](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/Database-Aplikasi-Transaksi-Sawit.md#L321), [AGENTS.md](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/AGENTS.md)

---

## 1. Ringkasan Eksekutif

Tugas Bagian 9 mengimplementasikan pembaruan fungsionalitas **Potongan Transaksi** pada aplikasi kasir jual beli kelapa sawit (TBS). 

Sebelumnya pada Tugas Bagian 7, potongan transaksi dihitung secara otomatis sebesar 5% tetap. Berdasarkan kebutuhan operasional lapangan terbaru, potongan transaksi kini dapat **diisi atau diubah secara manual oleh kasir per transaksi**, dengan nilai bawaan (*default*) terisi otomatis **5%** saat form dibuka.

Prinsip dan batasan utama yang dipatuhi selama implementasi:
1. **Zero Database Migration**: Kolom `persentase_potongan numeric(5,2)` beserta view agregasi `v_transaksi_ringkasan` dan `v_transaksi_harian` telah tersedia sejak Bagian 7. Tidak ada perubahan DDL database sama sekali (`NO ALTER TABLE`, `NO MIGRATION`).
2. **Isolasi Git Produksi**: Aplikasi berada dalam status produksi aktif. Seluruh pekerjaan diisolasi di branch baru `fitur/potongan-manual`, menjaga branch `main` tetap bersih dan stabil.
3. **Kalkulasi Real-Time & Presisi Finansial**: Perubahan angka persentase potongan langsung meng-update rincian *Total Kotor $\to$ Nilai Potongan $\to$ Total Bersih* secara seketika menggunakan package `Decimal` guna menjamin nol *floating-point error*.
4. **Validasi Bahasa Indonesia Komunikatif**: Nilai persentase potongan divalidasi ketat dalam rentang `0` sampai `100`. Jika kosong, bukan angka, atau di luar rentang, pesan error berbahasa Indonesia muncul dan form menolak submit.
5. **Dinamis & Kompatibel ke Belakang**: Halaman Riwayat dan Detail Transaksi menampilkan persentase potongan riil yang tersimpan di masing-masing transaksi (tidak diasumsikan selalu 5%). Transaksi lama yang tersimpan dengan persentase 5% tetap tampil dan terhitung akurat.

---

## 2. Arsitektur & Perubahan Kode Sumber

### A. Utilitas Baru
- **[lib/core/utils/percentage_formatter.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/core/utils/percentage_formatter.dart)**:
  Class utilitas `PercentageFormatter` untuk menyajikan nilai `Decimal` persentase secara rapi dan profesional di antarmuka pengguna:
  - Angka bulat: `5.00` atau `5` diformat menjadi `"5%"`, `7.00` menjadi `"7%"`, `0` menjadi `"0%"`.
  - Angka desimal: `7.50` diformat menjadi `"7.5%"`, `2.25` menjadi `"2.25%"`.

### B. State Management & Form Controller
- **[lib/features/transaksi/transaksi_form_state.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/transaksi_form_state.dart)**:
  - Menambahkan properti `potonganErrorMessage` (`String?`).
  - Menambahkan getter `isPotonganValid`:
    ```dart
    bool get isPotonganValid =>
        potonganErrorMessage == null &&
        persentasePotongan >= Decimal.zero &&
        persentasePotongan <= Decimal.fromInt(100);
    ```
  - Mengintegrasikan `isPotonganValid` ke dalam evaluasi `isFormValid`.
  - Memperbarui `copyWith` untuk mendukung manipulasi `potonganErrorMessage`.

- **[lib/features/transaksi/transaksi_form_controller.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/transaksi_form_controller.dart)**:
  - Menambahkan method `setPersentasePotonganString(String rawInput)` yang menangani toleransi koma/titik desimal Indonesia dan validasi:
    - Kosong: *"Persentase potongan tidak boleh kosong."*
    - Bukan angka: *"Format persentase harus berupa angka valid."*
    - Di luar 0–100: *"Persentase potongan harus bernilai antara 0 dan 100."*
    - Valid: Mengubah `persentasePotongan` ke nilai `Decimal` dan menghapus error.
  - Memperbarui method `submitTransaksi()` agar memvalidasi `isPotonganValid` dan mengirim nilai aktual `state.persentasePotongan` ke `TransaksiRepository`.
  - Memperbarui `resetForm()` agar selalu mengembalikan nilai default ke `Decimal.parse('5.00')`.

### C. Antarmuka Pengguna (UI)
- **[lib/features/transaksi/transaksi_form_page.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/transaksi_form_page.dart)**:
  - Menambahkan `TextEditingController _potonganController` diinisialisasi nilai `'5'` pada `initState`, di-dispose pada `dispose()`, dan di-reset ke `'5'` pada dialog selesai.
  - Mengubah tampilan teks statis `POTONGAN (5%)` pada card sticky summary bawah menjadi `TextFormField` numerik (`key: input_persentase_potongan`) dengan akhiran `%`, border IBM Carbon, dan pesan error interaktif di bawahnya.
  - Nilai rincian nominal potongan `- Rp X.XXX` (`summary_potongan_text`) dan Total Bersih (`summary_total_bersih_text`) terhubung reaktif dan ter-update seketika saat user mengetik.
  - Dialog konfirmasi sukses menampilkan persentase potongan dinamis via `PercentageFormatter`.

- **[lib/features/transaksi/transaksi_list_page.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/transaksi_list_page.dart)**:
  - Menampilkan persentase potongan riil per baris kartu riwayat:
    `Kotor: Rp X.XXX • Pot. ${PercentageFormatter.format(transaksi.persentasePotongan)}`

- **[lib/features/transaksi/transaksi_detail_page.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/transaksi_detail_page.dart)**:
  - Mengubah label box potongan nota menjadi dinamis:
    `POTONGAN (${PercentageFormatter.format(trx.persentasePotongan)})`

- **[lib/features/transaksi/export/laporan_pdf_generator.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/export/laporan_pdf_generator.dart)**:
  - Mengubah header kolom PDF dari `'Potongan (5%)'` menjadi `'Potongan (Rp)'` agar general untuk transaksi dengan persentase potongan beragam.

---

## 3. Matriks Kriteria Penerimaan (Acceptance Criteria)

| ID Kriteria | Deskripsi Kriteria | Status | Bukti Implementasi / Verifikasi |
|---|---|:---:|---|
| **AC-9.1** | Form Transaksi Baru menyediakan input field numeric potongan dengan nilai default 5 | **PASS** | `_potonganController` terisi otomatis `'5'` saat form dimuat; widget `input_persentase_potongan` |
| **AC-9.2** | Rincian Total Kotor $\to$ Potongan $\to$ Total Bersih ter-update real-time saat potongan diubah | **PASS** | Teruji real-time pada unit test & simulasi browser (Kotor: 1.000.000 $\to$ Potongan 10%: -100.000 $\to$ Bersih: 900.000) |
| **AC-9.3** | Validasi rentang 0–100 dengan pesan error bahasa Indonesia jika kosong atau di luar rentang | **PASS** | Validasi di `TransaksiFormNotifier.setPersentasePotonganString` dan UI alert text `error_persentase_potongan` |
| **AC-9.4** | Nilai `persentase_potongan` yang diinput kasir dikirim ke DB saat disimpan (bukan hardcode 5) | **PASS** | Payload insert ke Supabase menyertakan `persentase_potongan: pct.toString()` |
| **AC-9.5** | Halaman Riwayat dan Detail Transaksi menampilkan persentase potongan riil tiap transaksi | **PASS** | Kartu riwayat menampilkan `Pot. 5%` vs `Pot. 10%`; halaman detail menampilkan `POTONGAN (X%)` |
| **AC-9.6** | Transaksi lama (dengan persentase_potongan 5% default lama) tetap tampil dan terhitung benar | **PASS** | Kompatibilitas model `Transaksi` dan `TransaksiRingkasan` backward-compatible 100% |

---

## 4. Hasil Pengujian & Verifikasi

### A. Pengujian Otomatis (`flutter test`)
Suite pengujian otomatis mencakup **32 test** yang seluruhnya lulus tanpa error:

```
00:04 +28: Tugas Bagian 9: Potongan Manual Transaksi Tests PercentageFormatter formats whole and decimal numbers cleanly
00:04 +29: Tugas Bagian 9: Potongan Manual Transaksi Tests TransaksiFormState recalculates real-time with custom manual percentage
00:04 +30: Tugas Bagian 9: Potongan Manual Transaksi Tests TransaksiFormState validates percentage range (0-100) and error state
00:04 +31: Tugas Bagian 9: Potongan Manual Transaksi Tests TransaksiRepository createTransaksi produces custom percentage in demo mode
00:05 +32: All tests passed!
```

### B. Pengujian End-to-End di Browser
Pengujian verifikasi dilakukan pada lingkungan web browser (`http://localhost:8080/`):

1. **Skenario 1 – Pembuatan Transaksi Potongan Default 5%**:
   - Penjual: Haji Sukirman
   - Item TBS: Tandan Besar 400 kg @ Rp 2.500
   - Input Potongan: Dibiarkan default `5`%
   - Hasil Kalkulasi: Total Kotor `Rp 1.000.000`, Potongan 5% `- Rp 50.000`, Total Bersih **`Rp 950.000`**
   - Kode Transaksi Berhasil: `TRX-20260906-0001`

2. **Skenario 2 – Pembuatan Transaksi Potongan Manual Kustom (10%)**:
   - Penjual: Haji Sukirman
   - Item TBS: Tandan Besar 400 kg @ Rp 2.500
   - Input Potongan: Diubah manual dari 5 menjadi `10`%
   - Hasil Kalkulasi Real-time: Total Kotor `Rp 1.000.000`, Potongan 10% `- Rp 100.000`, Total Bersih **`Rp 900.000`**
   - Kode Transaksi Berhasil: `TRX-20260906-0002`

3. **Verifikasi Halaman Riwayat Transaksi**:
   - Kedua transaksi tampil berdampingan dengan persentase potongan yang tersimpan di masing-masing transaksi:
     - `TRX-20260906-0002`: **Rp 900.000** (`Kotor: Rp 1.000.000 • Pot. 10%`)
     - `TRX-20260906-0001`: **Rp 950.000** (`Kotor: Rp 1.000.000 • Pot. 5%`)

4. **Verifikasi Dashboard Analitik**:
   - Total volume panen: **800 kg**
   - Total transaksi: **2 TRX**
   - Akumulasi Total Bersih: **Rp 1.850.000** (konsisten dengan Rp 950.000 + Rp 900.000).

---

## 5. Dokumentasi Tangkapan Layar (Screenshots)

| Alur Pengujian | Dokumentasi Visual |
|---|---|
| **Form Transaksi 1 (Default 5%)** | Rincian Kotor Rp 1.000.000, Potongan Rp 50.000, Bersih Rp 950.000 dengan input potongan 5% |
| **Dialog Sukses Transaksi 1** | Kode `TRX-20260906-0001`, Potongan (5%) -Rp 50.000, Total Bersih Rp 950.000 |
| **Form Transaksi 2 (Kustom 10%)** | Input potongan diisi `10`%, rincian langsung ter-update: Potongan -Rp 100.000, Bersih Rp 900.000 |
| **Dialog Sukses Transaksi 2** | Kode `TRX-20260906-0002`, Potongan (10%) -Rp 100.000, Total Bersih Rp 900.000 |
| **Halaman Riwayat Transaksi** | Menampilkan kedua transaksi dengan potongan masing-masing (`Pot. 10%` dan `Pot. 5%`) |
| **Dashboard Analitik** | Menampilkan ringkasan keuangan harian terakumulasi Rp 1.850.000 dari total bersih transaksi |

*(Catatan: Tangkapan layar artefak pengujian tersimpan pada direktori laporan antarmuka [walkthrough.md](file:///C:/Users/lenov/.gemini/antigravity-ide/brain/9ee3f14b-5d37-408b-8c26-75ba5217dc94/walkthrough.md)).*

---

## 6. Kesimpulan

Implementasi fitur potongan manual transaksi (Tugas Bagian 9) telah diselesaikan dengan mematuhi seluruh aturan arsitektur sistem (`AGENTS.md`):
- **Aman bagi Produksi**: Tidak ada perubahan struktur database, terisolasi di branch `fitur/potongan-manual`.
- **Presisi Tinggi**: Anti-floating point error dengan `Decimal`.
- **Pengalaman Pengguna (UX)**: Responsif real-time, validasi ramah pengguna dalam bahasa Indonesia, dan penyajian data konsisten di seluruh modul aplikasi.
