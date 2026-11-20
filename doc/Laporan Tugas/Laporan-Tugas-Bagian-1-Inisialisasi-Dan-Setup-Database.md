# Laporan Pelaksanaan Tugas — Bagian 1: Inisialisasi Proyek & Setup Database

Dokumen ini mencatat rekam jejak implementasi teknis pada Bagian 1, meliputi pembuatan proyek Flutter multiplatform, penambahan dependencies, pembuatan berkas migrasi SQL Supabase lengkap, konfigurasi core client, utilitas angka, dan pembuatan model data Dart.

---

## 1. Ringkasan Tugas

- **Instruksi Pengguna**:
  1. Inisialisasi project Flutter baru dengan target Android, iOS, dan Web aktif.
  2. Tambahkan dependency: `supabase_flutter`, `flutter_riverpod`, `fl_chart`, `intl`, `decimal`.
  3. Buat konfigurasi Supabase client (`lib/core/supabase_client.dart`) menggunakan environment variable (`SUPABASE_URL` dan `SUPABASE_ANON_KEY`).
  4. Siapkan berkas migrasi DDL SQL lengkap (§8.3 & §8.4 PRD) siap eksekusi di Supabase SQL Editor.
  5. Buat model data Dart 1:1 schema database: `Profile`, `Penjual`, `JenisBuah`, `Transaksi`, `TransaksiItem`.
  6. Verifikasi via `flutter analyze` dan pastikan tidak ada error.
- **Status**: Selesai & Terverifikasi (0 Issues Found)

---

## 2. Berkas yang Ditambahkan (NEW)

### A. Skrip Database Supabase
- **[supabase/migrations/20260904_initial_schema.sql](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/supabase/migrations/20260904_initial_schema.sql)**:
  - Ekstensi: `pgcrypto` untuk pembuatan UUID acak dan `pg_trgm` untuk pencarian indeks teks nama penjual.
  - DDL Tabel `profiles`: Terhubung dengan `auth.users(id)` onDelete cascade, role enum check (`admin`, `kasir`).
  - DDL Tabel `penjual`: Master data petani/pengepul dengan soft delete flag `is_active`.
  - DDL Tabel `jenis_buah`: Master 3 jenis buah ('TB' Tandan Besar, 'TK' Tandan Kecil, 'BR' Berondolan).
  - DDL Tabel `transaksi`: Header transaksi dengan status check (`draft`, `selesai`, `dibatalkan`).
  - DDL Tabel `transaksi_item`: Detail item dengan kolom generated `subtotal numeric(14,2) generated always as (harga_per_kg * berat_kg) stored` dan constraint `UNIQUE(transaksi_id, jenis_buah_id)`.
  - Database Triggers:
    - `handle_new_user()` pada `auth.users` untuk auto-insert profil pengguna.
    - `generate_kode_transaksi()` otomatis membuat kode berformat `TRX-YYYYMMDD-XXXX`.
    - `set_updated_at()` untuk update timestamp otomatis pada tabel penjual dan transaksi.
  - Row Level Security (RLS): Policy SELECT/INSERT/UPDATE untuk role `authenticated` dan `admin`.
  - Views Pelaporan: `v_transaksi_ringkasan`, `v_transaksi_harian`, dan `v_breakdown_jenis_buah`.

### B. Core & Utilitas
- **[lib/core/supabase_client.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/core/supabase_client.dart)**:
  - Membaca kredensial via `String.fromEnvironment('SUPABASE_URL')` dan `String.fromEnvironment('SUPABASE_ANON_KEY')`.
  - Menyediakan singleton `SupabaseConfig.initialize()` dan Riverpod provider `supabaseClientProvider`.
- **[lib/core/utils/currency_formatter.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/core/utils/currency_formatter.dart)**:
  - Formatter Rupiah Indonesia (contoh: `Rp 2.450.000`) dan parser teks input toleran format Indonesia yang mengembalikan nilai bertipe `Decimal`.
- **[lib/core/utils/weight_formatter.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/core/utils/weight_formatter.dart)**:
  - Formatter berat timbangan presisi 2 desimal dengan suffix (contoh: `1.250,50 kg`) dan parser teks input yang mengembalikan nilai bertipe `Decimal`.
- **[lib/core/theme/app_theme.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/core/theme/app_theme.dart)**:
  - Konfigurasi tema enterprise IBM Carbon: IBM Blue (`#0F62FE`), flat square border radius (0–2px), card tanpa bayangan bergaris batas halus.

### C. Data Models Dart
- **[lib/models/profile.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/models/profile.dart)**:
  - Properti: `id`, `nama`, `role` ('admin' / 'kasir'), `createdAt`.
  - Getter: `isAdmin`, `isKasir`.
- **[lib/models/penjual.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/models/penjual.dart)**:
  - Properti: `id`, `nama`, `noTelepon`, `alamat`, `catatan`, `isActive`, `createdBy`, `createdAt`, `updatedAt`.
  - Helper: `toInsertMap()` dan `copyWith()`.
- **[lib/models/jenis_buah.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/models/jenis_buah.dart)**:
  - Properti: `id`, `kode`, `nama`, `isActive`.
- **[lib/models/transaksi_item.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/models/transaksi_item.dart)**:
  - Properti: `id`, `transaksiId`, `jenisBuahId`, `hargaPerKg` (Decimal), `beratKg` (Decimal), `subtotal` (Decimal), `createdAt`.
  - Helper: `toInsertMap()` (hanya mengirim `harga_per_kg` dan `berat_kg` ke Supabase).
- **[lib/models/transaksi.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/models/transaksi.dart)**:
  - `Transaksi`: Header transaksi (`id`, `kodeTransaksi`, `penjualId`, `tanggalTransaksi`, `status`, `catatan`, `createdBy`, `createdAt`, `updatedAt`).
  - `TransaksiRingkasan`: Model pemetaan view agregasi `v_transaksi_ringkasan` memuat `totalBeratKg` (Decimal) dan `totalHarga` (Decimal).

---

## 3. Berkas yang Diubah (MODIFIED)

1. **[pubspec.yaml](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/pubspec.yaml)**:
   - Dikonfigurasi dengan nama package `transaksi_sawit_app`.
   - Ditambahkan dependencies:
     ```yaml
     supabase_flutter: ^2.8.0
     flutter_riverpod: ^2.6.1
     fl_chart: ^0.70.2
     intl: ^0.20.2
     decimal: ^3.0.2
     ```
2. **[lib/main.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/main.dart)**:
   - Inisialisasi awal `SupabaseConfig.initialize()` dan pembungkusan root widget dengan `ProviderScope`.

---

## 4. Hasil Verifikasi

- **`flutter pub get`**: Sukses mengunduh dan menghubungkan seluruh dependensi tanpa konflik versi.
- **`flutter analyze`**:
  ```
  Analyzing Aplikasi Transaksi TBS sawit...                       
  No issues found! (ran in 8.1s)
  ```
- **`flutter test`**:
  ```
  00:00 +0: App smoke test
  00:00 +1: Formatter Tests CurrencyFormatter formats and parses IDR properly
  00:00 +2: Formatter Tests WeightFormatter formats and parses weight properly
  00:00 +3: Model Serialization Tests Profile model parses and serializes correctly
  00:00 +4: Model Serialization Tests Penjual model parses and serializes correctly
  00:00 +5: Model Serialization Tests JenisBuah model parses correctly
  00:00 +6: Model Serialization Tests Transaksi and TransaksiItem models parse with Decimal correctly
  00:00 +7: All tests passed!
  ```
