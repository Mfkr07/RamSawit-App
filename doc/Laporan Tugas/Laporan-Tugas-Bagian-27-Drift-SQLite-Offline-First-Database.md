# Laporan Implementasi Tugas Bagian 27: Perancangan Skema Database Lokal Drift SQLite (Offline-First)

## 1. Ringkasan Eksekutif
Dalam rangka mewujudkan kapabilitas **Hybrid Offline-First** pada aplikasi mandiri desktop (`.exe`) dan mobile (`.apk`), **Milestone 3** telah berhasil diselesaikan dengan merancang seluruh skema tabel lokal berbasis **Drift SQLite** yang memetakan model database Supabase cloud, dilengkapi kolom metadata sinkronisasi.

Skema ini memungkinkan aplikasi mencatat transaksi, mutasi saldo, pengeluaran, dan pengiriman secara instan tanpa membutuhkan koneksi internet, serta siap untuk disinkronkan dua arah ke Supabase pada **Milestone 4**.

### Referensi Spesifikasi & Standar:
- **Dokumen Referensi**: `doc/Database-Aplikasi-Transaksi-Sawit.md`, `doc/PRD-Aplikasi-Transaksi-Sawit.md`.
- **Standar Presisi**: Semua kolom nilai moneter dan berat disimpan dengan representasi presisi tinggi (String/Decimal) untuk mencegah *floating point inaccuracies*.
- **Quality Gate**: Zero regression, seluruh automated tests (**138/138**) PASS, `flutter analyze` 0 issues.
- **Aturan Git**: Tidak melakukan `git commit` maupun `git push`.

---

## 2. Struktur Arsitektur & Tabel Lokal Drift

### 2.1. Sinkronisasi Mixin (`SyncColumns`)
Berkas: `lib/core/database/tables.dart`
Setiap tabel lokal mewarisi metadata sinkronisasi berikut:
* `isSynced (bool)`: Flag status sinkronisasi (`false` = belum disinkronkan ke Supabase, `true` = sudah identik).
* `deviceId (text, nullable)`: Pengenal unik perangkat (misal `MOB-KASIR-01` atau `DSK-ADMIN-01`) untuk mencegah bentrok sequence dan pelacakan audit transaksi offline.
* `localUpdatedAt (DateTime)`: Waktu mutasi terakhir di database lokal untuk resolusi konflik *last-write-wins*.
* `deletedAt (DateTime, nullable)`: Kolom *soft delete* untuk mereplikasi penghapusan data secara aman ke Supabase.

### 2.2. Entitas Tabel yang Diimplementasikan (9 Tabel)
1. **`LocalPenjual`**: Master petani/penjual (`id`, `nama`, `noTelepon`, `alamat`, `catatan`, `isActive`, `createdBy`).
2. **`LocalJenisBuah`**: Master jenis TBS (`id`, `kode`, `nama`, `isActive`).
3. **`LocalTransaksi`**: Header transaksi pembelian (`id`, `kodeTransaksi`, `penjualId`, `tanggalTransaksi`, `status`, `alasanBatal`, `jenisPembayaran`, `catatan`, `createdBy`).
4. **`LocalTransaksiItem`**: Detail item transaksi per jenis TBS (`id`, `transaksiId`, `jenisBuahId`, `hargaPerKg`, `beratKg`, `beratKotorKg`, `persenPotongan`, `nilaiPotonganKg`, `subtotal`).
5. **`LocalPabrik`**: Master pabrik kelapa sawit rekanan (`id`, `nama`, `lokasi`, `kontak`, `isActive`).
6. **`LocalPengirimanPabrik`**: Surat Pengantar Buah (SPB) (`id`, `noSpb`, `pabrikId`, `tanggalKirim`, `noKendaraan`, `namaSupir`, `status`, `beratKirimKg`, `beratTimbangPabrikKg`, `toleransiSusutPersen`, `hargaPerKg`, `potonganSortasiPersen`, `potonganSortasiKg`, `potonganLainnyaNominal`, `catatanPotonganLainnya`, `totalNilaiPenjualan`).
7. **`LocalJenisPengeluaran`**: Kategori pengeluaran operasional.
8. **`LocalPengeluaran`**: Buku catatan biaya operasional ram sawit.
9. **`LocalTopupSaldo`**: Mutasi dana modal / kas operasional.

### 2.3. Database Singleton & Query Helper (`AppDatabase`)
Berkas: `lib/core/database/app_database.dart`
- Inisialisasi otomatis melalui helper `driftDatabase` yang kompatibel multi-platform (Windows Native C++ SQLite dan Android).
- Helper methods:
  - `getUnsyncedTransaksi()`: Mengambil daftar transaksi yang perlu di-push ke cloud.
  - `markTransaksiSynced(id)`: Menandai transaksi lokal telah terkirim.
  - `getItemsByTransaksiId(transaksiId)`: Mengambil item transaksi terkait.
  - `getTotalUnsyncedCount()`: Menghitung total entitas yang belum tersinkron di seluruh tabel untuk indikator status bar koneksi.
- Provider Riverpod: `appDatabaseProvider` untuk dependency injection yang rapi.

---

## 3. Hasil Pengujian & Verifikasi

1. **Automated Unit Tests**:
   - Berkas: `test/drift_database_test.dart`
   - Menggunakan in-memory native SQLite (`NativeDatabase.memory()`).
   - Meliputi pengujian:
     - Verifikasi schema version 1 dan 9 tabel terdaftar.
     - Operasi *insert*, *query unsynced*, *query items*, dan pembaruan flag `isSynced`.
     - Penghitungan metrik antrean sinkronisasi pada `LocalPengirimanPabrik` dan `LocalPengeluaran`.
   - Hasil: 3/3 tests PASS.

2. **Full Test Suite & Static Analysis**:
   - `flutter analyze` $\rightarrow$ **0 issues found**.
   - `flutter test` $\rightarrow$ **138 dari 138 automated tests PASS**.

---

## 4. Langkah Selanjutnya (Milestone 4)
* Mengembangkan **Sync Engine Dua Arah (Two-Way Sync Engine)**:
  - Offline-first repository write (simpan ke Drift SQLite lokal terlebih dahulu).
  - Background Push & Pull worker ke Supabase saat perangkat online.
  - Status Bar Indikator Jaringan & Sinkronisasi di UI aplikasi.
