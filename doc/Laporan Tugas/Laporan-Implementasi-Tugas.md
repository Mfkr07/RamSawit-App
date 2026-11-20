# Laporan Perubahan dan Implementasi Tugas
## Aplikasi Transaksi Jual Beli Buah Kelapa Sawit (TBS)

Dokumen ini mencatat seluruh rekam jejak teknis implementasi tugas yang telah diselesaikan oleh AI Agent, meliputi berkas yang ditambah, diubah, maupun aturan/pendekatan yang sengaja dihindari (dikurangi) demi mematuhi PRD, skema database, dan aturan arsitektur proyek.

---

## Ringkasan Tahapan yang Telah Diselesaikan

| Bagian | Deskripsi Tugas | Status |
|---|---|---|
| **Bagian 0** | Penyusunan Rules & Panduan Proyek (`AGENTS.md`) | Selesai |
| **Bagian 1** | Setup Proyek Flutter, Dependencies, Skema Database SQL, Core Config, & Data Models Dart | Selesai |
| **Bagian 2** | Autentikasi Supabase, Session Persistence, Manajemen Data Penjual (CRUD, Soft Delete), & Reusable `PenjualPicker` | Selesai |
| **Bagian 3** | Formulir Transaksi Baru Multi-Item, Kalkulasi Otomatis Presisi Tinggi (`Decimal`), Pencegahan Duplikasi, & Kode Transaksi Otomatis Database | Selesai |
| **Bagian 4** | Riwayat Transaksi (`v_transaksi_ringkasan`), Filter Multi-Kriteria, Detail Nota Transaksi, & Soft Cancellation dengan Alasan | Selesai |
| **Bagian 5** | Dashboard Analitik, Kartu Ringkasan (Hari/Minggu/Bulan), Grafik Tren & Breakdown (`fl_chart`), 10 Transaksi Terakhir, & Landing Page | Selesai |
| **Bagian 6** | Non-Functional Requirements, Audit Presisi Moneter (`Decimal`), Error Handling Supabase (Bahasa Indonesia), Checklist AC-1 s/d AC-8, & Web Release Build | Selesai |
| **Bagian 7** | Fitur Potongan Transaksi (Persentase Tingkat Transaksi & Migrasi Skema) | Selesai |
| **Bagian 8** | Export Laporan Transaksi ke Format Excel (.xlsx) dan PDF Siap Cetak | Selesai |
| **Bagian 9** | Potongan Manual Fleksibel pada Transaksi Pembelian | Selesai |
| **Bagian 10** | Potongan Dipindah ke Level Berat per Jenis Buah (Refaktor Grading TBS) | Selesai |
| **Bagian 11** | Modul Penjualan TBS ke Pabrik Kelapa Sawit (PKS) & Master Pabrik | Selesai |
| **Bagian 12** | Alur Dua Fase Pengiriman Pabrik (Keberangkatan & Penyelesaian serta Tab Belum Selesai) | Selesai |
| **Bagian 13** | Dashboard Lengkap & Multi-Modul (Pembelian Petani + Penjualan Pabrik + Margin Keuntungan) | Selesai |
| **Bagian 14** | Export Laporan Pembelian Detail per Item (11 Kolom + Baris Total) & Export Penjualan Pabrik | Selesai |

Dokumen detail per bagian tersedia di:
- [Laporan Tugas Bagian 0: Rules & Panduan Proyek](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/Laporan-Tugas-Bagian-0-Rules-Dan-Panduan.md)
- [Laporan Tugas Bagian 1: Inisialisasi & Setup Database](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/Laporan-Tugas-Bagian-1-Inisialisasi-Dan-Setup-Database.md)
- [Laporan Tugas Bagian 2: Autentikasi & Manajemen Penjual](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/Laporan-Tugas-Bagian-2-Autentikasi-Dan-Manajemen-Penjual.md)
- [Laporan Tugas Bagian 3: Form Transaksi Multi-Item & Kalkulasi](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/Laporan-Tugas-Bagian-3-Form-Transaksi-Multi-Item-Dan-Kalkulasi.md)
- [Laporan Tugas Bagian 4: Riwayat & Detail Transaksi](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/Laporan-Tugas-Bagian-4-Riwayat-Dan-Detail-Transaksi.md)
- [Laporan Tugas Bagian 5: Dashboard Analitik & Visualisasi Grafik](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/Laporan-Tugas-Bagian-5-Dashboard-Dan-Grafik.md)
- [Laporan Tugas Bagian 6: Non-Functional Requirements & Acceptance Criteria](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/Laporan-Tugas-Bagian-6-Non-Functional-Requirements-Dan-Acceptance-Criteria.md)
- [Laporan Tugas Bagian 7: Potongan Transaksi](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/Laporan-Tugas-Bagian-7-Potongan-Transaksi.md)
- [Laporan Tugas Bagian 8: Export Laporan](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/Laporan-Tugas-Bagian-8-Export-Laporan.md)
- [Laporan Tugas Bagian 9: Potongan Manual Transaksi](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/Laporan-Tugas-Bagian-9-Potongan-Manual-Transaksi.md)
- [Laporan Tugas Bagian 10: Potongan Level Berat per Jenis Buah](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/Laporan-Tugas-Bagian-10-Potongan-Level-Berat.md)
- [Laporan Tugas Bagian 11: Modul Penjualan ke Pabrik](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/Laporan-Tugas-Bagian-11-Modul-Penjualan-Ke-Pabrik.md)
- [Laporan Tugas Bagian 12: Alur Dua Fase Pengiriman Pabrik](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/Laporan-Tugas-Bagian-12-Alur-Dua-Fase-Pengiriman-Pabrik.md)
- [Laporan Tugas Bagian 13: Dashboard Lengkap & Multi-Modul](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/Laporan-Tugas-Bagian-13-Dashboard-Lengkap-Dan-Multi-Modul.md)
- [Laporan Tugas Bagian 14: Export Laporan Detail per Item & Penjualan Pabrik](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/Laporan-Tugas-Bagian-14-Export-Laporan-Detail-Dan-Pabrik.md)

---

## 1. Berkas yang Ditambahkan (NEW)

### A. Aturan & Skrip Database
1. **`AGENTS.md`**
   - **Tujuan**: Single source of truth aturan teknis dan konvensi AI coding agent.
   - **Isi**: Tech stack (Flutter + Riverpod + Supabase + fl_chart), struktur folder Bagian 10 PRD, konvensi bahasa (kode: Inggris, UI/pesan: Indonesia), aturan anti floating-point error untuk uang & berat, dan larangan kalkulasi sum manual di client untuk total transaksi.
2. **`supabase/migrations/20260904_initial_schema.sql`**
   - **Tujuan**: Skrip DDL dan migrasi database PostgreSQL 15+ yang siap dijalankan langsung di Supabase Dashboard SQL Editor.
   - **Isi**:
     - Extensions: `pgcrypto` (UUID generator) dan `pg_trgm` (pencarian teks cepat).
     - Tabel: `profiles` (extend `auth.users`), `penjual`, `jenis_buah`, `transaksi`, `transaksi_item`.
     - Stored Generated Column: `subtotal numeric(14,2) generated always as (harga_per_kg * berat_kg) stored` pada tabel `transaksi_item`.
     - Constraints: `UNIQUE(transaksi_id, jenis_buah_id)` untuk mencegah jenis buah ganda per transaksi.
     - Triggers: `on_auth_user_created` (auto-create profile), `trg_generate_kode_transaksi` (auto-generate `TRX-YYYYMMDD-XXXX`), `trg_penjual_updated_at`, `trg_transaksi_updated_at`.
     - Seed Data: Master 3 jenis buah ('TB' Tandan Besar, 'TK' Tandan Kecil, 'BR' Berondolan).
     - Row Level Security (RLS) policies untuk user terautentikasi dan hak kelola admin.
     - Views: `v_transaksi_ringkasan`, `v_transaksi_harian`, `v_breakdown_jenis_buah`.

### B. Lapisan Inti & Utilitas (`lib/core/`)
3. **`lib/core/supabase_client.dart`**
   - Konfigurasi `SUPABASE_URL` dan `SUPABASE_ANON_KEY` berbasis `String.fromEnvironment` (`--dart-define`) agar kredensial tidak ter-hardcode.
   - Menyediakan instance singleton `SupabaseConfig` dan Riverpod provider `supabaseClientProvider`.
4. **`lib/core/theme/app_theme.dart`**
   - Implementasi tema visual enterprise berdasarkan spesifikasi `doc/DESIGN.md` (IBM Carbon Design System).
   - Warna aksen IBM Blue (`#0F62FE`), Charcoal Ink (`#161616`), Canvas White (`#FFFFFF`), Surface (`#F4F4F4`), dan sudut elemen flat-square (0–2px).
5. **`lib/core/utils/currency_formatter.dart`**
   - Formatter mata uang Rupiah Indonesia (`Rp 2.450.000`) dan parser input toleran format lokal Indonesia yang mengembalikan nilai bertipe `Decimal`.
6. **`lib/core/utils/weight_formatter.dart`**
   - Formatter berat timbangan presisi 2 desimal dengan suffix satuan (`1.250,50 kg`) dan parser input yang mengembalikan nilai bertipe `Decimal`.
7. **`lib/core/widgets/main_layout_page.dart`**
   - Kerangka layout navigasi responsif (Sidebar untuk Desktop/Web dan Bottom Navigation Bar untuk Mobile).
   - Menampilkan identitas user login, badge role ("Admin" / "Kasir"), tombol keluar sesi (Logout) dengan dialog konfirmasi, dan tab navigasi aplikasi.

### C. Model Data Dart 1:1 Schema Database (`lib/models/`)
8. **`lib/models/profile.dart`** -> Memetakan tabel `public.profiles`.
9. **`lib/models/penjual.dart`** -> Memetakan tabel `public.penjual` (memiliki helper `toInsertMap()` dan `copyWith()`).
10. **`lib/models/jenis_buah.dart`** -> Memetakan tabel `public.jenis_buah`.
11. **`lib/models/transaksi_item.dart`** -> Memetakan tabel `public.transaksi_item` dengan field harga, berat, dan subtotal menggunakan presisi `Decimal`.
12. **`lib/models/transaksi.dart`** -> Memetakan header tabel `public.transaksi` dan view agregasi `public.v_transaksi_ringkasan` (`TransaksiRingkasan`).

### D. Modul Autentikasi (`lib/features/auth/`)
13. **`lib/features/auth/auth_repository.dart`**
    - Abstraksi komunikasi dengan Supabase Auth + query profil dari tabel `profiles`.
    - Dilengkapi fallback **Demo Service** otomatis jika aplikasi dijalankan tanpa parameter Supabase remote, sehingga pengetesan lokal/web browser dapat berjalan mulus.
    - Penerjemah pesan error Supabase ke Bahasa Indonesia komunikatif.
14. **`lib/features/auth/auth_controller.dart`**
    - StateNotifier Riverpod untuk mengelola status sesi, loading, dan error state.
15. **`lib/features/auth/auth_gate.dart`**
    - Gerbang navigasi aplikasi: memeriksa apakah sesi aktif sudah tersimpan (session persistence). Jika ya, langsung masuk ke layout utama; jika tidak, tampilkan login page.
16. **`lib/features/auth/login_page.dart`**
    - Halaman login bergaya IBM Carbon, validasi form email dan password, banner error, dan tombol akses cepat demo.

### E. Modul Data Penjual (`lib/features/penjual/`)
17. **`lib/features/penjual/penjual_repository.dart`**
    - Mengelola operasi PostgREST tabel `penjual`: query daftar, pencarian teks, insert, update, dan soft-delete.
18. **`lib/features/penjual/penjual_controller.dart`**
    - AsyncNotifier untuk mengelola state filter pencarian dan reaktivitas daftar penjual.
19. **`lib/features/penjual/penjual_form_modal.dart`**
    - Modal dialog untuk input dan edit data penjual dengan validasi nama wajib diisi.
20. **`lib/features/penjual/penjual_list_page.dart`**
    - Antarmuka daftar penjual: pencarian instan, filter checkbox "Tampilkan Nonaktif", badge status aktif/nonaktif, aksi ubah, dan aksi nonaktifkan (soft delete).
21. **`lib/features/penjual/widgets/penjual_picker.dart`**
    - Komponen dropdown autocomplete pencarian penjual yang dapat digunakan kembali (*reusable*).
    - Memuat fitur **Inline Creation**: tombol `+ Tambah Penjual Baru Inline` langsung membuka dialog input penjual baru tanpa meninggalkan formulir transaksi, dan otomatis memilih penjual yang baru disimpan (sesuai PRD §6 poin 2).

### F. Modul Transaksi Baru Multi-Item (`lib/features/transaksi/`)
22. **`lib/features/transaksi/jenis_buah_repository.dart`**
    - Mengambil data master 3 jenis buah aktif dari database Supabase dengan fallback data bawaan.
23. **`lib/features/transaksi/transaksi_repository.dart`**
    - Menyimpan transaksi baru: insert header `transaksi` (tanpa membuat kode di client; kode digenerate oleh DB trigger), mengambil ID dan `kode_transaksi`, lalu melakukan insert multi-item ke `transaksi_item`.
24. **`lib/features/transaksi/transaksi_form_state.dart`**
    - Representasi state baris item (`TransaksiItemRowState`) dan form transaksi (`TransaksiFormState`).
    - Menggunakan kalkulasi presisi `Decimal` untuk subtotal baris dan total transaksi.
    - Getter validasi: batas maksimal 3 baris item (`canAddRow`) dan deteksi duplikasi jenis buah (`hasDuplicateFruit`).
25. **`lib/features/transaksi/transaksi_form_controller.dart`**
    - StateNotifier yang memasang listener reaktif pada controller harga dan berat untuk pembaruan instan (*real-time preview*).
26. **`lib/features/transaksi/transaksi_form_page.dart`**
    - Halaman input transaksi baru: integrasi `PenjualPicker`, pemilih tanggal, daftar item 1–3 baris buah, dropdown dengan filter duplikasi buah, input harga & berat, badge subtotal otomatis per baris, box sticky summary total berat dan pembayaran, serta dialog konfirmasi sukses yang menampilkan kode unik resmi dari database.

---

## 2. Berkas yang Diubah (MODIFIED)

1. **`pubspec.yaml`**
   - **Perubahan**:
     - Mengubah nama package menjadi identifier Dart valid: `transaksi_sawit_app`.
     - Menambahkan dependencies utama:
       - `supabase_flutter: ^2.8.0`
       - `flutter_riverpod: ^2.6.1`
       - `fl_chart: ^0.70.2`
       - `intl: ^0.20.2`
       - `decimal: ^3.0.2`
2. **`lib/main.dart`**
   - **Perubahan**:
     - Menginisialisasi `initializeDateFormatting('id_ID', null)` untuk penanganan tanggal lokal Indonesia pada Flutter Web & Mobile.
     - Menginisialisasi `SupabaseConfig.initialize()`.
     - Membungkus root widget dengan `ProviderScope` Riverpod.
     - Menetapkan `AppTheme.lightTheme` sebagai tema utama.
     - Menetapkan `AuthGate` sebagai widget `home` (pengecekan otomatis status login).
3. **`test/widget_test.dart`**
   - **Perubahan**:
     - Mengganti tes bawaan counter Flutter dengan rangkaian pengujian komprehensif:
       - App smoke test (verifikasi halaman login).
       - CurrencyFormatter & WeightFormatter unit tests.
       - Model serialization & deserialization tests (`Profile`, `Penjual`, `JenisBuah`, `Transaksi`, `TransaksiItem`).
       - Transaksi Multi-Item Form & Calculation tests: memvalidasi kalkulasi otomatis subtotal dan total menggunakan `Decimal`, serta validasi pencegahan duplikasi jenis buah dan batas 3 baris.

---

## 3. Hal yang Dikurangi / Dihindari (REMOVED / AVOIDED PATTERNS)

Sesuai aturan ketat PRD dan `AGENTS.md`, beberapa pola pemrograman umum sengaja **ditiadakan** dan diganti dengan pendekatan yang lebih aman:

1. **Dihilangkan: Tipe Data `double` Primitif untuk Uang & Berat**:
   - Tipe `double` IEEE 754 dilarang untuk komputasi akumulasi moneter guna menghindari error presisi seperti `0.1 + 0.2 != 0.3`. Seluruh komputasi perkalian dan penjumlahan menggunakan objek `Decimal`.
2. **Dihilangkan: Generate Kode Transaksi di Client**:
   - Client tidak pernah menyusun format `TRX-YYYYMMDD-XXXX`. Kewenangan penomoran urut diserahkan 100% kepada trigger PostgreSQL `trg_generate_kode_transaksi` untuk menjamin keunikan dan mencegah nomor ganda (*race conditions*).
3. **Dihilangkan: Pengiriman Kolom `subtotal` dari Client**:
   - Nilai subtotal di client hanya untuk *live preview*. Saat dikirim ke database, client hanya mengirim `harga_per_kg` dan `berat_kg`. Database yang secara otomatis menghitung dan mengunci nilai subtotal via kolom `generated always stored`.
4. **Dihilangkan: Hard Delete (DELETE SQL) pada Penjual dan Transaksi**:
   - Operasi penghapusan data penjual diganti dengan mekanisme **Soft Delete** (`is_active = false`), sehingga histori transaksi terdahulu tidak mengalami *foreign key violation* dan jejak audit tetap terjaga.
5. **Dihilangkan: Hardcoded Credentials**:
   - URL dan anon key Supabase tidak dicantumkan langsung di dalam file kode sumber, melainkan dibaca melalui environment parameter (`--dart-define`).

---

## 4. Hasil Verifikasi Kualitas Kode

1. **Static Analysis (`flutter analyze`)**:
   ```
   Analyzing Aplikasi Transaksi TBS sawit...                       
   No issues found!
   ```
2. **Unit & Widget Testing (`flutter test`)**:
   ```
   00:00 +0: App smoke test
   00:00 +1: Formatter Tests CurrencyFormatter formats and parses IDR properly
   00:00 +2: Formatter Tests WeightFormatter formats and parses weight properly
   00:00 +3: Model Serialization Tests Profile model parses and serializes correctly
   00:00 +4: Model Serialization Tests Penjual model parses and serializes correctly
   00:00 +5: Model Serialization Tests JenisBuah model parses correctly
   00:00 +6: Model Serialization Tests Transaksi and TransaksiItem models parse with Decimal correctly
   00:00 +7: Transaksi Multi-Item Form & Calculation Tests Calculates subtotal and total accurately using Decimal
   00:00 +8: Transaksi Multi-Item Form & Calculation Tests Prevents duplicate fruit types and detects max 3 rows limit
   00:00 +9: All tests passed!
   ```
3. **End-to-End Browser Testing (Google Chrome via Browser Subagent)**:
   - Pengujian login, pembuatan 2 data penjual dummy, pencarian penjual, dan komponen picker telah tervalidasi.
   - Pengujian form transaksi baru multi-item (Tandan Besar + Berondolan) berhasil dengan kalkulasi subtotal dan total real-time yang akurat, serta penyimpanan ke database menghasilkan kode resmi `TRX-20260904-0001`.
