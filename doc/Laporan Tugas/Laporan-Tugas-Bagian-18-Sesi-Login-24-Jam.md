# Laporan Pelaksanaan Tugas Bagian 18: Sesi Login 24 Jam

**Branch**: `fitur/sesi-login-24-jam`  
**Target Dokumen**: `doc/PRD-Aplikasi-Transaksi-Sawit.md` (FR-1.2, FR-1.4)  
**Tanggal**: 16 September 2026  
**Status**: SELESAI (100% Lulus Verifikasi Unit Test, Widget Test, & Simulasi Visual Browser)

---

## 1. Ringkasan Pekerjaan

Tugas Bagian 18 mengimplementasikan peningkatan keamanan sesi login (Session Expiration Policy) agar sesi pengguna dibatasi tepat 24 jam sejak saat login berhasil, terlepas dari validitas refresh token Supabase Auth:

1. **Penyimpanan Timestamp Login Lokal (`SessionStorageService`)**:
   - Dibuat service modular `lib/core/services/session_storage_service.dart` yang mengabstraksikan penyimpanan lokal persisten berbasis `shared_preferences: ^2.5.5`.
   - Bekerja secara konsisten lintas platform (Web: `window.localStorage`, Mobile Android: `SharedPreferences`, iOS: `NSUserDefaults`).
   - Menyimpan `auth_login_timestamp_ms` (`DateTime.now().millisecondsSinceEpoch`) seketika saat autentikasi email & password berhasil, baik di lingkungan produksi Supabase Auth maupun mode demo/offline.
   - Menyimpan pesan status kedaluwarsa sesi (`auth_session_expired_message`) saat logout paksa dieksekusi, sehingga pesan informatif tetap bertahan setelah navigasi atau reload halaman login.

2. **Mekanisme Pengecekan Usia Sesi**:
   - Dihitung selisih waktu (`DateTime.now().difference(loginTime)`). Jika selisih $\ge 24$ jam (didefinisikan sebagai `AuthRepository.defaultMaxSessionDuration = Duration(hours: 24)`), sesi dinyatakan kedaluwarsa (`isSessionExpired() == true`).
   - Jika ada sesi aktif di Auth tetapi tidak ada timestamp login yang sah di penyimpanan lokal, sistem menerapkan *security defense-in-depth* dengan menganggap sesi kedaluwarsa agar pengguna masuk kembali.

3. **Eksekusi Pengecekan di Dua Titik (FR-1.4)**:
   - **Titik A (Inisialisasi & Refresh)**: Dijalankan di dalam method `_init()` pada `AuthController` saat aplikasi pertama kali dibuka atau halaman browser di-refresh. Jika usia sesi $\ge 24$ jam, langsung memanggil `forceSignOutExpired()`, membersihkan profil, dan mengarahkan pengguna ke halaman login dengan pesan status.
   - **Titik B (Timer Periodik saat Aplikasi Terbuka)**: Dijalankan oleh `Timer.periodic(const Duration(minutes: 1))` selama pengguna aktif dan terautentikasi. Setiap siklus timer memeriksa usia sesi. Jika melewati 24 jam, aplikasi langsung mengeksekusi logout paksa secara otomatis tanpa perlu interaksi pengguna atau refresh halaman. Timer ini dihentikan (`cancel()`) seketika saat pengguna logout manual atau saat controller di-dispose.

4. **Umpan Balik Pengguna yang Jelas di Halaman Login**:
   - Menampilkan alert banner berwarna merah dengan ikon peringatan di atas kolom input login:
     > *"Sesi Anda telah berakhir (melebihi 24 jam). Silakan masuk kembali."*
   - Dilengkapi `Key('login_error_banner')` untuk kemudahan pengujian otomatis.

5. **Simulasi dan Pengujian**:
   - Dilakukan simulasi live dengan memendekkan durasi sesi ke 1 menit (`Duration(minutes: 1)`) dan interval cek ke 5 detik.
   - Terbukti secara visual dan terekam dalam browser testing bahwa aplikasi otomatis keluar sendiri ke halaman login dan menampilkan banner merah setelah 1 menit tanpa refresh halaman.
   - Kode produksi dipulihkan kembali ke batas baku `Duration(hours: 24)` dan `Duration(minutes: 1)`.

---

## 2. File yang Dibuat dan Dimodifikasi

| No | File | Status | Keterangan |
|---|---|---|---|
| 1 | `pubspec.yaml` | MODIFIKASI | Mempromosikan `shared_preferences: ^2.5.5` dari dependency transitif menjadi direct dependency |
| 2 | `lib/core/services/session_storage_service.dart` | BARU | Service penyimpanan timestamp sesi dan pesan kedaluwarsa lokal |
| 3 | `lib/features/auth/auth_repository.dart` | MODIFIKASI | Integrasi `SessionStorageService`, method `isSessionExpired()`, `forceSignOutExpired()`, pencatatan timestamp saat `signIn()`, dan pembersihan saat `signOut()` |
| 4 | `lib/features/auth/auth_controller.dart` | MODIFIKASI | Implementasi Titik A pada `_init()`, Titik B pada `_startSessionAgeTimer()`, method `checkSessionAge()` dan `forceSignOutDueToExpiration()` |
| 5 | `lib/features/auth/login_page.dart` | MODIFIKASI | Penambahan key `login_error_banner` pada container banner error dan verifikasi render pesan kedaluwarsa |
| 6 | `test/bagian18_sesi_24_jam_test.dart` | BARU | 10 pengujian otomatis komprehensif untuk validasi penyimpanan, repository, Titik A, Titik B, dan UI |
| 7 | `test/bagian16_responsif_performa_test.dart` | MODIFIKASI | Penambahan `setUpAll` mock SharedPreferences untuk kompatibilitas widget test |
| 8 | `test/widget_test.dart` | MODIFIKASI | Inisialisasi mock SharedPreferences pada suite pengujian eksisting |
| 9 | `doc/Laporan-Tugas-Bagian-18-Sesi-Login-24-Jam.md` | BARU | Dokumen laporan pelaksanaan dan verifikasi tugas Bagian 18 |

---

## 3. Hasil Pengujian & Verifikasi

### 3.1 Unit Test & Widget Test (`flutter test`)
Seluruh 83 test pada aplikasi lulus 100%:
- `test/bagian18_sesi_24_jam_test.dart`: 10/10 PASS
- `test/bagian17_dashboard_role_dan_filter_test.dart`: 10/10 PASS
- `test/bagian16_responsif_performa_test.dart`: 13/13 PASS
- `test/dashboard_lengkap_test.dart`: 6/6 PASS
- `test/export_detail_test.dart`: 5/5 PASS
- `test/pengiriman_2_fase_test.dart`: 9/9 PASS
- `test/widget_test.dart`: 30/30 PASS

### 3.2 Analisis Kode Statis (`flutter analyze`)
- 0 Errors
- 0 Warnings

### 3.3 Verifikasi Live Browser (Simulasi 1 Menit)
- Pengguna login dan berada di Dashboard.
- Setelah 1 menit tanpa interaksi/refresh, timer Titik B mendeteksi usia sesi kedaluwarsa.
- Aplikasi secara otomatis melakukan transisi kembali ke Halaman Login.
- Alert banner merah dengan teks *"Sesi Anda telah berakhir (melebihi 24 jam). Silakan masuk kembali."* berhasil tampil jelas di layar.
- Tangkapan layar bukti pengujian: `sesi_expired_forced_logout_1789529760425.png`.
