# Laporan Tugas Bagian 28: Sync Engine Dua Arah & Bilah Status Koneksi (Offline-First)

## Ringkasan Eksekusi
Sebagai kelanjutan dari **Milestone 3** (Database Lokal Drift SQLite) pada rencana modernisasi multi-platform offline-first, pada tahap **Milestone 4** ini telah diimplementasikan arsitektur sinkronisasi dua arah (**Sync Engine**) dan komponen antarmuka pengguna responsif (**SyncStatusBar**).

Aplikasi kini mampu:
1. Mendeteksi status konektivitas jaringan secara otomatis (Online vs Offline).
2. Menghitung jumlah entitas data transaksi/perubahan lokal yang belum tersinkronisasi ke server Supabase cloud.
3. Memberikan umpan balik visual instan di dashboard melalui bilah status (Sync Status Bar) dengan animasi rotasi ketika sinkronisasi sedang berlangsung.
4. Menyediakan tombol pemicu sinkronisasi manual (*Sync Now*) yang responsif.
5. Menjalankan proses sinkronisasi periodik (latar belakang) setiap 60 detik saat terhubung ke internet.

Semua perubahan kode mematuhi standar arsitektur:
- Logika state dikelola melalui Riverpod `StateNotifierProvider` (`syncEngineProvider`).
- Dilarang keras melakukan `git commit` dan `git push` (seluruh berkas tetap di working tree lokal).
- 100% automated tests PASS (140/140 tests).

---

## 1. Berkas yang Dibuat & Dimodifikasi

1. **`lib/core/sync/sync_engine.dart`** (Dibuat)
   - Enum `SyncStatus`: `idle`, `syncing`, `offline`, `error`.
   - Model `SyncEngineState`: Menyimpan `status`, `unsyncedCount`, `lastSyncTime`, `errorMessage`, dan getter `isOnline`, `isSyncing`.
   - Class `SyncEngine` (`StateNotifier<SyncEngineState>`):
     - Memonitor antrean transaksi dan master data lokal Drift SQLite.
     - Menyediakan method `syncNow()` yang mengeksekusi push data lokal ke cloud dan pull pembaruan dari Supabase.
     - Memproteksi eksekusi terhadap lingkungan tanpa inisialisasi cloud (safe fallback offline-first).
     - Menjadwalkan polling background otomatis setiap 60 detik.

2. **`lib/core/sync/sync_status_bar.dart`** (Dibuat)
   - Komponen visual compact setinggi 36px yang disematkan pada `AppBar` dashboard.
   - Menampilkan badge status:
     - Hijau (*Terhubung*): Ketika sinkronisasi selesai dan tidak ada antrean pending.
     - Kuning/Amber (*Mode Offline / N Data Pending*): Menginformasikan kasir/pengguna bahwa ada data lokal yang aman tersimpan di perangkat dan akan disinkronkan saat online.
     - Biru (*Menyinkronkan...*): Menampilkan ikon sinkronisasi berputar.
     - Merah (*Gagal Sinkron*): Menampilkan pesan error jika otentikasi atau jaringan terputus.
   - Tombol manual *"Sinkronkan"* dengan key pencarian testable `btn_sync_now`.

3. **`lib/features/dashboard/dashboard_page.dart`** (Dimodifikasi)
   - Menambahkan `PreferredSize` pada Scaffold Dashboard utama yang memuat `SyncStatusBar` di bawah `SafeArea`.

4. **`test/sync_engine_test.dart`** (Dibuat)
   - Unit test untuk lifecycle inisialisasi `SyncEngine` dan penghitungan data belum tersinkron.
   - Widget test untuk verifikasi rendering `SyncStatusBar` pada state idle, offline, pending data, dan syncing.

5. **`test/bagian17_dashboard_role_dan_filter_test.dart`** (Dimodifikasi)
   - Menyesuaikan ukuran viewport test `tester.view.physicalSize` pada pengujian dialog filter dashboard untuk memastikan konsistensi layout dengan penambahan status bar.

---

## 2. Bukti Verifikasi Kualitas & Visual

### A. Verifikasi Analisis & Kompilasi
* `flutter analyze`: **0 issues found** (Bersih dari warning/error).
* `flutter test`: **140/140 tests PASS** (Zero regression pada seluruh modul).

### B. Bukti Screenshot UI Sistem Aktif
Telah diambil tangkapan layar langsung dari aplikasi yang berjalan pada web server lokal:
* Lokasi Berkas: `Bukti_Verifikasi/bukti_sync_engine_status_bar.png`
* Elemen yang terverifikasi secara visual:
  1. Bilah atas *SyncStatusBar* aktif menampilkan status: `Offline (3 data lokal tersimpan)`.
  2. Tombol aksi `Sinkronkan` tersedia di sisi kanan bilah status.
  3. Status Engine reaktif terhadap input pengguna dan event sinkronisasi.

---

## 3. Status Milestone Fase 1

| Milestone | Deskripsi | Status |
|---|---|---|
| **Milestone 1** | Windows Desktop Native Runner (`.exe`) & Drift Deps | Selesai |
| **Milestone 2** | Multi-Tenant Config UI & Dynamic Client Setup | Selesai |
| **Milestone 3** | Database Lokal Drift SQLite & Skema Tabel Sync | Selesai |
| **Milestone 4** | Sync Engine Dua Arah & Bilah Status Koneksi | Selesai |
| **Milestone 5** | Build Executable Windows Native Final & Android APK | Tahap Selanjutnya |
