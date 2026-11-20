# Laporan Tugas Bagian 35: Investigasi Video Rekaman HP, Penyelesaian ClassNotFoundException MainActivity, dan Rilis APK v3

## 1. Analisis Rekaman Video Ponsel Pengguna
- **File Rekaman:** `video_2523e6d594bd.mp4` (5.78 detik, 576x1280 px).
- **Hasil Ekstraksi & Inspeksi Frame:**
  1. **Frame 1 (06:36 WIB):** Pengguna berada pada folder home screen bernama "Project" dan mengetuk ikon aplikasi `manajemen_ra...`.
  2. **Frame 2:** Jendela aplikasi terbuka menampilkan kanvas putih polos (*blank white window*).
  3. **Frame 3:** Dalam hitungan detik tanpa memunculkan login page, jendela aplikasi terlempar kembali ke launcher (*instant crash / force close*).

---

## 2. Investigasi Mendalam Akar Masalah (*Root Cause Identified*)
Melalui dekompilasi bytecode DEX (`classes.dex`) dan audit manifest:
- **`AndroidManifest.xml`** mendefinisikan launcher activity:
  ```xml
  <activity
      android:name=".MainActivity"
      android:exported="true" ... />
  ```
  Di mana manifest memiliki package namespace `com.sawit.manajemen_ram_sawit_app`.
  Secara otomatis, Android mencari class: `com.sawit.manajemen_ram_sawit_app.MainActivity`.
- **Namun di direktori Kotlin source code:**
  File `MainActivity.kt` berada pada package lama:
  ```kotlin
  package com.sawit.transaksi_sawit_app
  class MainActivity : FlutterActivity()
  ```
- **Dampak Fatal:**
  Saat pengguna mengetuk ikon aplikasi di HP, sistem Android melempar:
  ```text
  java.lang.ClassNotFoundException: Didn't find class "com.sawit.manajemen_ram_sawit_app.MainActivity" on path: DexPathList[...]
  ```
  Karena Activity utama tidak pernah ditemukan oleh Android runtime, engine Flutter bahkan belum sempat dijalankan sama sekali. Hal ini menyebabkan layar putih 1 detik lalu *force close* seketika.

---

## 3. Tindakan Perbaikan
1. Menyelaraskan struktur direktori Kotlin Android dari `com/sawit/transaksi_sawit_app/` menjadi `com/sawit/manajemen_ram_sawit_app/`.
2. Memperbarui deklarasi package di `MainActivity.kt`:
   ```kotlin
   package com.sawit.manajemen_ram_sawit_app

   import io.flutter.embedding.android.FlutterActivity

   class MainActivity : FlutterActivity()
   ```
3. Melakukan kompilasi ulang rilis Android APK universal.
4. Memvalidasi bytecode DEX hasil kompilasi:
   - Command: `strings classes.dex | grep MainActivity`
   - Output: `0Lcom/sawit/manajemen_ram_sawit_app/MainActivity;` (TERVERIFIKASI ADA & TEPAT).

---

## 4. Hasil Verifikasi Akhir
- **File APK Baru:** `TransaksiSawit-Release-v3-Fixed.apk` (Ukuran: 69.1 MB / 72.485.948 bytes).
- **Lokasi:** `C:/Users/lenov/OneDrive/Dokumen/Project/Bukti_Verifikasi/TransaksiSawit-Release-v3-Fixed.apk`.
- **Status Signature:** Terverifikasi valid dengan APK Signature Scheme v2.
- **Git Safety Rule:** Tidak melakukan git commit & push.
