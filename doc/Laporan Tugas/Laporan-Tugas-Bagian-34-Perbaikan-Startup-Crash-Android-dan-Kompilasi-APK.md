# Laporan Tugas Bagian 34: Perbaikan Startup Crash Android & Kompilasi APK Universal Release

## 1. Ringkasan Eksekusi
- **Objektif:**
  1. Menyelidiki dan menyelesaikan kendala *force close* seketika (crash sebelum login page) pada Android APK saat dibuka di perangkat ponsel fisik.
  2. Memverifikasi kesiapan responsivitas antarmuka mobile di seluruh layar (Dashboard, Navigasi Bawah, Drawer, Header Saldo, serta Modul Chatbot Bisnis AI).
  3. Mengimplementasikan *safe error boundary* dan penanganan Keystore storage yang andal pada Android.
  4. Melakukan kompilasi ulang berkas Universal APK (`app-release.apk`) tanpa error, memvalidasi integritas pengujian (145/145 PASS), dan menyediakan berkas APK siap pakai bagi pengguna.

---

## 2. Investigasi Akar Masalah (*Root Cause Analysis*)
Sebelumnya, aplikasi mengalami *crash / force close* saat diluncurkan di perangkat Android karena:
1. **Unprotected Startup Initialization di `main.dart`:**
   Pemanggilan `initializeDateFormatting()` dan `SupabaseConfig.initialize()` dijalankan secara asinkron tanpa blok penanganan pengecualian (`try-catch`). Jika terjadi kendala koneksi atau kegagalan pembacaan KeyStore sistem di level OS, Flutter melempar exception unhandled yang langsung mematikan proses Android.
2. **Android Keystore Inconsistency pada `flutter_secure_storage`:**
   Pada `TenantConfigService`, inisialisasi `FlutterSecureStorage` default tanpa parameter `resetOnError: true` berisiko memicu crash ketika OS Android gagal mendekripsi kunci lama (misalnya saat instalasi ulang atau pembaruan build dengan signature baru).
3. **Penyelarasan Layout Responsif:**
   Ditemukan inkonsistensi baris tombol header pada halaman *Saldo / Dana Modal* di layar sempit ponsel yang telah diperbaiki dengan layout `Wrap` responsif adaptif.

---

## 3. Rincian Perubahan Kode
1. **`lib/main.dart`:**
   - Menambahkan pembungkusan proteksi `try-catch` terisolasi pada bootstrap `initializeDateFormatting` dan `SupabaseConfig.initialize()`.
   - Menjamin alur `runApp()` tetap dieksekusi secara mulus meskipun salah satu layanan eksternal mengalami kendala jaringan atau storage saat startup.
2. **`lib/core/tenant_config_service.dart`:**
   - Menambahkan konfigurasi `AndroidOptions(resetOnError: true)` pada instance `FlutterSecureStorage`.
   - Mencegah *unhandled KeyStore exception* dengan mereset kunci penyimpanan secara otomatis jika terjadi korupsi kunci enkripsi Android Keystore.
3. **`lib/features/saldo/saldo_page.dart`:**
   - Memperbaiki tata letak header halaman Saldo agar rapi dan bebas overflow saat diakses di perangkat seluler dengan lebar layar sempit (<= 400px).

---

## 4. Hasil Verifikasi & Pengujian
- **Analisis Kode Statis (`flutter analyze`):**
  - **Hasil:** `No issues found!` (0 error, 0 warning).
- **Pengujian Unit & Widget Otomatis (`flutter test`):**
  - **Hasil:** `145 / 145 Tests Passed` (100% PASS, 0 failure).
- **Kompilasi Rilis Android (`flutter build apk --release`):**
  - **Hasil:** Berhasil mengompilasi Universal Fat APK `build/app/outputs/flutter-apk/app-release.apk` berukuran **68.8 MB** (72.109.116 bytes) yang mencakup seluruh arsitektur ABI (ARM64-v8a, ARMeabi-v7a, x86_64).
  - Berkas disalin ke direktori: `C:/Users/lenov/OneDrive/Dokumen/Project/Bukti_Verifikasi/TransaksiSawit-Release-v2.apk`.

---

## 5. Kepatuhan Kebijakan Git
- **Git Commit & Push:** DILARANG dan TIDAK DILAKUKAN sama sekali sesuai instruksi keselamatan pengguna.
