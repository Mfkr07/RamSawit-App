# Laporan Tugas Bagian 11: Modul Penjualan ke Pabrik

**Tanggal Pelaksanaan**: 7 September 2026  
**Branch Git**: `fitur/penjualan-pabrik`  
**Status**: **SELESAI (100% PASS)**  
**Target Platform**: Android, iOS, Web (Responsive Codebase)  
**Referensi**: [PRD.md §7.8 (FR-8.1 s/d FR-8.6)](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/PRD-Aplikasi-Transaksi-Sawit.md#L115), [Database.md §7](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/Database-Aplikasi-Transaksi-Sawit.md#L460), [AGENTS.md](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/AGENTS.md)

---

## 1. Ringkasan Eksekutif

Tugas Bagian 11 merupakan implementasi modul baru yang fundamental: **Modul Penjualan TBS ke Pabrik Kelapa Sawit (PKS)**. Modul ini melengkapi siklus bisnis usaha sawit dengan mencatat penjualan hasil komoditas buah sawit (yang sebelumnya dibeli dari petani/pengepul) ke pabrik pengolahan tujuan.

### Mengapa Modul Ini Dirancang Terpisah?
1. **Pemisahan Siklus Usaha**: Siklus pembelian dari petani (modul transaksi yang sudah berjalan) mencatat arus masuk barang (*inflow*), sedangkan penjualan ke pabrik mencatat pengiriman armada dan arus keluar barang (*outflow*).
2. **Keamanan Data Production**: Aplikasi sudah aktif digunakan di production. Modul baru ini menggunakan dua tabel terpisah (`pabrik` dan `pengiriman_pabrik`) **tanpa mengubah satu pun kolom atau data pada tabel transaksi, transaksi_item, atau penjual**.
3. **Karakteristik Timbangan Pabrik**: Transaksi ke pabrik memiliki parameter timbangan yang spesifik (ada armada truk/sopir, berat kotor, berat ditolak/retur, dan potongan mutu pabrik) yang berbeda mekanismenya dengan penerimaan buah di timbangan ram petani.

### Prinsip Utama yang Dipenuhi:
1. **Isolasi Git Produksi**: Seluruh implementasi dikerjakan di branch baru `fitur/penjualan-pabrik`, sehingga branch `main` tetap terlindungi.
2. **Integritas Database & Single Source of Truth**: Sesuai `AGENTS.md`, kolom `berat_diterima_kg`, `berat_bersih_kg`, `nilai_potongan_rp`, dan `total_nilai_jual` merupakan kolom `GENERATED ALWAYS AS ... STORED` di database. Client Flutter tidak mengenerate kode pengiriman maupun total di client secara ad-hoc saat simpan, melainkan mengandalkan trigger dan komputasi database.
3. **Presisi Finansial (Anti-Floating Point Error)**: Seluruh kalkulasi menggunakan library `Decimal` dengan pembulatan eksak 2 desimal (`scale: 2`), mencegah kehilangan akurasi angka.
4. **Alur Berat Resmi Terverifikasi**: Berat Kotor dikurangi Berat Ditolak menghasilkan Berat Diterima, kemudian Berat Diterima dikenakan Potongan% pabrik menghasilkan Berat Bersih. Total Nilai Jual merupakan perkalian Harga Jual/kg dengan Berat Bersih.
5. **UI Enterprise IBM Carbon (Bahasa Indonesia)**: Komponen antarmuka pengguna mematuhi IBM Carbon styling dengan bahasa Indonesia baku dan komunikatif.

---

## 2. Alur Komputasi Berat & Nilai Penjualan

Urutan komputasi data pengiriman ke pabrik mengikuti alur resmi yang disepakati pada PRD §7.8 dan Database.md §7:

```
[ Berat Kotor ] (Input manual, wajib > 0 kg)
       │
       ▼
 [ - Berat Ditolak ] (Input manual, opsional, default 0, validasi <= Berat Kotor)
       │
       ▼
 = [ Berat Diterima ] (Otomatis: Berat Kotor - Berat Ditolak)
       │
       ▼
 [ - Potongan Pabrik % ] (Input manual, opsional, default 0%, rentang 0 - 100%)
       │
       ▼
 = [ Berat Bersih (Netto) ] (Otomatis: Berat Diterima x (1 - Potongan%))
       │
       ▼
 [ x Harga Jual / kg ] (Input manual, fluktuatif, wajib >= 0)
       │
       ▼
 = [ Total Nilai Jual ] (Otomatis: Harga Jual/kg x Berat Bersih)
```

### Tabel Parameter dan Kolom Data

| Parameter | Tipe Data | Sumber | Definisi / Formula |
|---|---|---|---|
| **Pabrik Tujuan** | UUID (FK) | Input User | Dipilih via autocomplete / picker pabrik |
| **Plat Nomor Truk** | Text | Input User | Identitas armada pengangkut |
| **Nama Sopir** | Text | Input User | Nama penanggung jawab pengiriman |
| **Tanggal Kirim** | Date | Input User | Default tanggal hari ini (`current_date`) |
| **Berat Kotor** | `numeric(10,2)` | Input User | Berat total timbangan kotor truk (kg) |
| **Berat Ditolak** | `numeric(10,2)` | Input User | Berat buah yang ditolak/retur pabrik (kg) |
| **Berat Diterima** | `numeric(10,2)` | **Generated DB** | $\text{round}(\text{berat\_kotor} - \text{berat\_ditolak}, 2)$ |
| **Potongan Pabrik (%)** | `numeric(5,2)` | Input User | Persentase sortasi/sampah dari pabrik ($0 - 100\%$) |
| **Berat Bersih (Netto)**| `numeric(10,2)` | **Generated DB** | $\text{round}((\text{berat\_kotor} - \text{berat\_ditolak}) \times (1 - \frac{\text{potongan}}{100}), 2)$ |
| **Harga Jual / kg** | `numeric(12,2)` | Input User | Harga satuan resmi yang ditetapkan pabrik |
| **Nilai Potongan (Rp)** | `numeric(14,2)` | **Generated DB** | $\text{round}(\text{harga} \times \text{berat\_diterima} \times \frac{\text{potongan}}{100}, 2)$ |
| **Total Nilai Jual** | `numeric(14,2)` | **Generated DB** | $\text{round}(\text{harga} \times \text{berat\_bersih}, 2)$ |
| **Kode Pengiriman** | Text | **Trigger DB** | Format otomatis: `KRM-YYYYMMDD-0001` |

---

## 3. Rincian Perubahan Kode Sumber

### A. Skrip DDL Database Supabase (Database.md §7.3 & §7.4)
Telah disiapkan dan dieksekusi pada database PostgreSQL / Supabase:
- **Tabel `pabrik`**: Master data pabrik (id, nama, alamat, kontak, is_active, audit trail).
- **Tabel `pengiriman_pabrik`**: Header pengiriman dengan 4 kolom generated stored (`berat_diterima_kg`, `berat_bersih_kg`, `nilai_potongan_rp`, `total_nilai_jual`) dan check constraint (`berat_ditolak_kg <= berat_kotor_kg`).
- **Trigger `generate_kode_pengiriman`**: Menghasilkan sequence format `KRM-YYYYMMDD-0001` harian secara otomatis.
- **Trigger `set_updated_at`**: Pembaruan timestamp `updated_at` otomatis pada mutasi data.
- **Row Level Security (RLS)**: Policy akses penuh bagi authenticated users pada tabel `pabrik` dan `pengiriman_pabrik`.
- **View Reporting**: `v_pengiriman_ringkasan`, `v_pengiriman_harian`, dan `v_margin_harian`.

### B. Lapisan Data & Model (Dart)
- **[lib/models/pabrik.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/models/pabrik.dart)**:
  - Model entitas tabel `pabrik` dengan serializer `fromJson`, `toJson`, `toInsertMap`, dan `copyWith`.
- **[lib/models/pengiriman_pabrik.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/models/pengiriman_pabrik.dart)**:
  - Model entitas `pengiriman_pabrik` dengan representasi presisi tinggi `Decimal` pada seluruh atribut berat dan nilai rupiah.
  - Relasi opsional `Pabrik? pabrik`.
  - Method `toInsertMap()` hanya mengekstrak field input tanpa kolom generated untuk memastikan komputasi diserahkan seutuhnya ke database.

### C. Master Data Pabrik
- **[lib/features/pabrik/pabrik_repository.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/pabrik/pabrik_repository.dart)**:
  - Repositori PostgREST Supabase dengan fallback mock data lokal saat offline/demo mode.
  - Mendukung `getPabrikList` (pencarian nama/alamat/kontak dan filter aktif), `createPabrik`, `updatePabrik`, dan `toggleActiveStatus` (soft delete).
- **[lib/features/pabrik/pabrik_controller.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/pabrik/pabrik_controller.dart)**:
  - `PabrikFilterNotifier` & `PabrikListNotifier` berbasis Riverpod AsyncNotifier.
- **[lib/features/pabrik/pabrik_form_modal.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/pabrik/pabrik_form_modal.dart)**:
  - Dialog modal IBM Carbon untuk input/edit pabrik (nama wajib, kontak, alamat).
- **[lib/features/pabrik/pabrik_list_page.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/pabrik/pabrik_list_page.dart)**:
  - Halaman master data pabrik: list view, pencarian real-time, tombol tambah, edit data, serta dialog konfirmasi aktifkan/nonaktifkan pabrik.
- **[lib/features/pabrik/widgets/pabrik_picker.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/pabrik/widgets/pabrik_picker.dart)**:
  - Komponen reusable autocomplete/picker pabrik yang dilengkapi kemampuan **menambah pabrik baru secara inline** tanpa harus keluar dari formulir pengiriman.

### D. Formulir & Riwayat Pengiriman ke Pabrik
- **[lib/features/pengiriman_pabrik/pengiriman_pabrik_repository.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/pengiriman_pabrik/pengiriman_pabrik_repository.dart)**:
  - Menyimpan pengiriman ke Supabase dan mengambil riwayat dengan filter tanggal, pencarian, dan pembatalan status.
- **[lib/features/pengiriman_pabrik/pengiriman_pabrik_controller.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/pengiriman_pabrik/pengiriman_pabrik_controller.dart)**:
  - StateNotifier `PengirimanFormNotifier` yang menghitung live preview otomatis:
    - `beratDiterima`: $\text{beratKotor} - \text{beratDitolak}$
    - `beratBersih`: $\text{beratDiterima} \times (1 - \text{potongan}\% / 100)$
    - `nilaiPotonganRp`: $\text{hargaJual} \times \text{beratDiterima} \times \text{potongan}\% / 100$
    - `totalNilaiJual`: $\text{hargaJual} \times \text{beratBersih}$
- **[lib/features/pengiriman_pabrik/pengiriman_pabrik_form_page.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/pengiriman_pabrik/pengiriman_pabrik_form_page.dart)**:
  - Layout 2 kolom responsif (Form input kiri, Live Preview kalkulasi resmi kanan).
  - Validasi ketat: Berat Kotor $> 0$, Berat Ditolak $\ge 0$ dan $\le$ Berat Kotor, Potongan $0 - 100\%$, Harga Jual $\ge 0$.
  - Dialog nota sukses menampilkan kode pengiriman resmi dari DB (contoh `KRM-YYYYMMDD-XXXX`).
- **[lib/features/pengiriman_pabrik/pengiriman_pabrik_list_page.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/pengiriman_pabrik/pengiriman_pabrik_list_page.dart)**:
  - Daftar riwayat pengiriman ke pabrik dengan rincian timbangan lengkap, status pengiriman (`SELESAI` / `DIBATALKAN`), modal nota detail, dan dialog pembatalan nota bersyarat.

### E. Integrasi Navigasi Aplikasi
- **[lib/core/widgets/main_layout_page.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/core/widgets/main_layout_page.dart)**:
  - Menyediakan navigasi menu terstruktur dengan pemisahan kategori yang jelas:
    - **PEMBELIAN PETANI**: Dashboard Analitik, Transaksi Baru, Riwayat Transaksi, Data Penjual.
    - **PENJUALAN KE PABRIK**: Pengiriman ke Pabrik, Riwayat Pengiriman, Master Data Pabrik.
  - Tampilan mobile dilengkapi Drawer menu lengkap dan Bottom Navigation Bar 5 slot (`Dashboard`, `Beli TBS`, `Jual Pabrik`, `Riwayat`, `Menu`).

---

## 4. Matriks Kriteria Penerimaan (Acceptance Criteria Bagian 11)

| ID Kriteria | Uraian Kriteria Penerimaan | Status | Bukti Implementasi & Verifikasi |
|---|---|:---:|---|
| **AC-11.1** | Skrip DDL tabel `pabrik`, `pengiriman_pabrik`, trigger sequence `KRM-...`, trigger `updated_at`, dan RLS tersedia lengkap tanpa mengubah skema tabel transaksi lama | **PASS** | Skrip SQL terverifikasi di Database.md §7.3 dan telah dieksekusi di database Supabase |
| **AC-11.2** | Halaman master data Pabrik mendukung pencarian nama, tambah pabrik, dan soft delete via `is_active` | **PASS** | `PabrikListPage` dan `PabrikFormModal` dengan switch aktif/nonaktif dan search controller |
| **AC-11.3** | Komponen picker/autocomplete pabrik yang reusable dengan opsi tambah pabrik baru secara inline | **PASS** | `PabrikPicker` dan dialog `_PabrikSelectionDialog` dengan tombol inline "Baru" |
| **AC-11.4** | Form Pengiriman ke Pabrik terpisah dari Transaksi Pembelian Petani | **PASS** | `PengirimanPabrikFormPage` terdaftar di rute dan navigasi tersendiri |
| **AC-11.5** | Kalkulasi real-time sesuai urutan resmi: Berat Diterima $\to$ Berat Bersih $\to$ Total Nilai Jual | **PASS** | Panel kalkulasi live: $1000 - 50 = 950\text{ kg} \to 950 \times 0,98 = 931\text{ kg} \to 931 \times 2200 = \text{Rp } 2.048.200$ |
| **AC-11.6** | Validasi integritas: Berat Kotor $> 0$, Berat Ditolak $\ge 0$ dan $\le$ Berat Kotor, Potongan $0-100\%$, Harga $\ge 0$ | **PASS** | Validasi di Form Validator dan `PengirimanFormNotifier.submit()` |
| **AC-11.7** | Kode pengiriman digenerate otomatis oleh database (bukan di-generate client) | **PASS** | Client hanya mengirim field input mentah; kode `KRM-YYYYMMDD-XXXX` di-generate trigger PostgreSQL |
| **AC-11.8** | Model Dart `Pabrik` dan `PengirimanPabrik` memiliki field identik dengan kolom database | **PASS** | `Pabrik` dan `PengirimanPabrik` lengkap dengan getter status dan serialisasi Decimal |
| **AC-11.9** | Menu navigasi "Penjualan ke Pabrik" terpasang rapi di desktop sidebar dan mobile layout | **PASS** | `MainLayoutPage` mengelompokkan menu Pembelian Petani dan Penjualan Pabrik |

---

## 5. Hasil Pengujian & Verifikasi

### A. Pengujian Otomatis Unit Test (`flutter test`)
Pengujian dilakukan menggunakan test suite [test/pengiriman_pabrik_test.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/test/pengiriman_pabrik_test.dart) dengan hasil:

```
00:00 +0: Modul Penjualan ke Pabrik - Unit Test Kalkulasi & Model Verifikasi Kalkulasi Resmi Bagian 11: 1000kg - 50kg, 2%, Rp 2200/kg
00:00 +1: Modul Penjualan ke Pabrik - Unit Test Kalkulasi & Model Pabrik Model JSON Serialization
00:00 +2: Modul Penjualan ke Pabrik - Unit Test Kalkulasi & Model PengirimanPabrik Model JSON Serialization with Decimals
00:00 +3: All tests passed!
```

**Rincian Evaluasi Nilai Skenario Uji**:
- **Berat Kotor Input**: $1.000\text{ kg}$
- **Berat Ditolak Input**: $50\text{ kg}$
- **Potongan Pabrik Input**: $2\%$
- **Harga Jual / kg Input**: $\text{Rp } 2.200$
- **Verifikasi Output**:
  - $\text{Berat Diterima} = 1.000 - 50 = \mathbf{950{,}00\text{ kg}}$ *(LULUS)*
  - $\text{Berat Bersih} = 950 \times (1 - 0{,}02) = \mathbf{931{,}00\text{ kg}}$ *(LULUS)*
  - $\text{Total Nilai Jual} = 931 \times 2.200 = \mathbf{\text{Rp } 2.048.200}$ *(LULUS)*
  - $\text{Nilai Potongan} = 2.200 \times 950 \times 2\% = \mathbf{\text{Rp } 41.800}$ *(LULUS)*

### B. Pengujian Statis Kode (`flutter analyze`)
Hasil evaluasi `flutter analyze`: **0 Errors** pada seluruh berkas kode aplikasi.

---

## 6. Kesimpulan & Langkah Selanjutnya

Seluruh sasaran tugas **Bagian 11: Modul Penjualan ke Pabrik** telah selesai dikerjakan dengan standar kualitas tinggi, memenuhi seluruh kriteria fungsional dan non-fungsional, menjaga integritas database produksi, dan terverifikasi secara menyeluruh.

Dengan telah dieksekusinya skrip SQL migration pada database Supabase oleh pengguna, aplikasi siap digunakan untuk mencatat operasional penjualan TBS sawit ke pabrik pengolahan kelapa sawit secara end-to-end.
