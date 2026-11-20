# Laporan Tugas Bagian 30: Resolusi Fallback Autentikasi Demo Mode & Audit Perbandingan Dashboard Role

## 1. Ringkasan Eksekutif
Pada pengujian awal aplikasi Windows desktop (`transaksi_sawit_app.exe`), ditemukan kendala saat proses autentikasi di mana aplikasi menampilkan pesan kesalahan:
`AuthException(message: Invalid API key, statusCode: null, code: null)`

Setelah dilakukan penelusuran mendalam terhadap riwayat git commit (`fd88810`), ditemukan bahwa konfigurasi bawaan `defaultValue` pada `lib/core/supabase_client.dart` memuat URL remote dan token API key placeholder dummy yang terpotong (`eyJhbG...VdZg`). Keberadaan nilai string non-kosong tersebut menyebabkan logika pengecekan `SupabaseConfig.isConfigured` bernilai `true`, sehingga aplikasi secara keliru berusaha menghubungi remote backend Supabase dengan key yang cacat alih-alih mengaktifkan fallback otomatis ke `isDemoMode`.

Pada Bagian 30 ini, masalah tersebut telah diselesaikan secara tuntas dengan:
1. Mengembalikan nilai default `SUPABASE_URL` dan `SUPABASE_ANON_KEY` menjadi string kosong (`''`) pada `lib/core/supabase_client.dart`.
2. Melakukan kompilasi ulang (rebuild) untuk target **Web** dan **Windows Desktop (Release)**.
3. Melakukan pengujian fungsional login langsung pada browser web untuk memastikan fungsionalitas sistem berjalan normal.
4. Menangkap bukti visual (screenshot) antarmuka login serta dashboard untuk role **Administrator** dan role **Operator Kasir**.
5. Menyusun matriks perbandingan komprehensif antara dashboard Administrator dan Operator Kasir.
6. Memastikan seluruh rangkaian pengujian otomatis (140 automated tests) lulus 100% tanpa regresi.

---

## 2. Analisis Akar Masalah & Solusi

### Akar Masalah:
- Pengecekan pada `lib/features/auth/auth_repository.dart` mendefinisikan mode demo sebagai:
  ```dart
  bool get isDemoMode => !SupabaseConfig.isConfigured || _client == null;
  ```
- Sedangkan pada `lib/core/supabase_client.dart`:
  ```dart
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
  ```
- Karena `url` berisi `'https://hrifbuqhkhzjelzokbmi.supabase.co'` dan `anonKey` berisi string terpotong `'eyJhbG...VdZg'`, `isConfigured` mengevaluasi ke `true`. Akibatnya, `isDemoMode` bernilai `false` dan aplikasi memanggil `_client.auth.signInWithPassword()`, yang langsung memicu penolakan dari server Supabase karena API Key tidak valid.

### Solusi yang Diterapkan:
1. Menyetel default parameter environment menjadi string kosong:
   ```dart
   static const String url = String.fromEnvironment(
     'SUPABASE_URL',
     defaultValue: '',
   );

   static const String anonKey = String.fromEnvironment(
     'SUPABASE_ANON_KEY',
     defaultValue: '',
   );
   ```
2. Dengan perubahan ini:
   - Jika aplikasi dijalankan secara lokal (baik web maupun desktop) tanpa flag `--dart-define` atau tanpa konfigurasi form Setup Organisasi, aplikasi langsung masuk ke **Demo Mode (In-Memory / Drift Local SQLite)** yang stabil dan bebas error.
   - Jika pengguna memasukkan kredensial Supabase riil melalui fitur **Setup Organisasi & Database**, koneksi remote akan diinisialisasi secara dinamis tanpa hambatan.

---

## 3. Matriks Perbandingan Dashboard: Administrator vs Operator Kasir

| Aspek / Komponen | Dashboard Administrator (Admin) | Dashboard Operator Kasir (Kasir) |
| :--- | :--- | :--- |
| **Identitas Akun** | Nama: `Administrator Sawit`, Badge: **ADMIN** (Biru) | Nama: `Operator Kasir`, Badge: **KASIR** (Abu-abu) |
| **Akses Modul Pembelian Petani** | Tersedia lengkap: Transaksi Baru, Riwayat, Data Penjual, Analitik. | Tersedia lengkap: Transaksi Baru, Riwayat, Data Penjual, Analitik. |
| **Akses Modul Penjualan Pabrik** | Tersedia lengkap: Pengiriman Pabrik, Riwayat, Master Data Pabrik. | Terbatas untuk operasional timbang dan pengiriman. |
| **Tab Metrik Dashboard** | 3 Tab: *Pembelian Petani*, *Penjualan Pabrik*, dan *Margin Keuntungan*. | 2 Tab: *Pembelian Petani* dan *Penjualan Pabrik* (Tab Margin disembunyikan). |
| **Tombol Tindakan Cepat** | Tersedia: *Segarkan*, *+ Transaksi Baru*, dan *Laporan Pendapatan*. | Tersedia: *Segarkan* dan *+ Transaksi Baru* (Tombol Laporan Pendapatan disembunyikan). |
| **Grafik Tren Finansial** | Menampilkan grafik tren analitik omzet & margin bisnis harian/mingguan/bulanan. | Dibatasi pada grafik proporsi volume komoditas (bebas dari data margin laba sensitif). |
| **Hak Manajemen Harga & Void** | Memiliki wewenang mengubah harga dasar dan membatalkan/void transaksi. | Hanya dapat menginput sesuai harga acuan aktif dan merekam transaksi. |

---

## 4. Bukti Verifikasi Artefak Visual
Tangkapan layar aktual tersimpan pada repositori lokal di direktori `doc/diagram/`:
1. `doc/diagram/dashboard_admin_demo.png` — Bukti tampilan Dashboard Analitik Terpadu untuk role Administrator.
2. `doc/diagram/dashboard_kasir_demo.png` — Bukti tampilan Dashboard Analitik Terpadu untuk role Operator Kasir.

---

## 5. Status Verifikasi Sistem
- **Kompilasi Web:** `flutter build web --release` berhasil tanpa error.
- **Kompilasi Desktop:** `flutter build windows --release` berhasil menghasilkan `transaksi_sawit_app.exe`.
- **Automated Testing:** `flutter test` — **140/140 PASS** (100% lulus, 0 gagal).
- **Git State:** Bersih dari commit maupun push sesuai batasan instruksi pengguna.
