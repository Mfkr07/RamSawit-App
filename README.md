# RamSawit — Aplikasi Transaksi Jual Beli Buah Kelapa Sawit (TBS)

Aplikasi manajemen operasional dan kasir timbangan kelapa sawit (*Loading Ramp*) modern, tangguh, dan berarsitektur **Multi-Tenant (BYOD Supabase)** serta **Offline-First (Drift SQLite)**. Dibangun menggunakan Flutter dengan target utama **Android (.apk)** dan desktop **Windows (.exe)**.

---

## 🌴 Gambaran Arsitektur

```
┌────────────────────────────────────────────────────────────────────────┐
│                   RamSawit Client App (Flutter)                        │
│       Target: Native Windows (POS / Komputer Timbangan) & Android      │
├────────────────────────────────────────────────────────────────────────┤
│  UI / Design System: IBM Carbon Enterprise (IBM Plex Sans, Flat Style) │
│  State Management: Flutter Riverpod 2.x                                │
│  Komputasi Presisi: Decimal / BigInt (Anti Floating-Point Finansial)   │
├────────────────────────────────────────────────────────────────────────┤
│  Penyimpanan Lokal: Drift SQLite (Offline-First Local Write)           │
│  Sinkronisasi: SyncEngine (Auto-sync 30s background & manual)          │
│  Kecerdasan Buatan: AI Analytics Advisor (9Router / Ollama / OpenAI)   │
└───────────────────▲────────────────────────────────▲───────────────────┘
                    │                                │
            (Internet Terhubung)             (Pengecekan Versi)
                    │                                │
┌───────────────────▼──────────────────┐ ┌───────────▼──────────────────┐
│      Tenant Cloud Database           │ │     Portal Rilis & Update    │
│         (Supabase BYOD)              │ │         (version.json)       │
│  - PostgreSQL 15+ & Auth             │ │  - Deteksi update semver     │
│  - Row Level Security (RLS)          │ │  - Notifikasi rilis baru     │
│  - Generated Financial Columns       │ │  - Unduh APK & ZIP           │
└──────────────────────────────────────┘ └──────────────────────────────┘
```

---

## ✨ Fitur Unggulan

1. **Kasir Pembelian TBS (Petani)**:
   - Pencatatan transaksi multi-item dengan potongan berat (%) otomatis per jenis buah (Tandan Besar, Tandan Kecil, Berondolan).
   - Dukungan jenis pembayaran **Tunai (Kas Ramp)** vs **Non-Tunai (Transfer)**.
   - Cetak struk timbangan & nota pembelian.
2. **Penjualan ke Pabrik Kelapa Sawit (PKS - Alur 2 Fase)**:
   - **Fase 1 (Ramp)**: Pencatatan SPB, armada, sopir, pabrik tujuan, dan berat kirim.
   - **Fase 2 (Pabrik)**: Rekonsiliasi slip timbangan pabrik (berat sampai, ditolak, potongan wajib, sortasi per kg, potongan lainnya, dan audit susut berat).
3. **Pengeluaran Operasional Ramp**:
   - Pencatatan biaya BBM/transport, gaji/upah, perawatan kendaraan, dll.
   - Terintegrasi dengan metode pembayaran tunai/transfer untuk rekonsiliasi kas.
4. **Saldo & Kas Modal**:
   - Pemantauan modal ramp secara realtime; pengeluaran kas tunai otomatis memotong saldo ramp.
5. **Laporan & Analitik Keuangan**:
   - Laporan laba kotor, laba bersih harian, dan margin penjualan vs pembelian.
   - Ekspor laporan berformat Excel (`.xlsx`) dan PDF rapi.
   - Visualisasi tren transaksi dan pie chart komposisi pembayaran.
6. **AI Analytics Advisor (Fase 2)**:
   - Konsultasi bisnis interaktif, pendeteksi anomali sortasi pabrik, dan peramalan tren harga TBS.
7. **Offline-First Penuh**:
   - Transaksi tetap berjalan lancar tanpa jaringan internet di pedalaman kebun. Data tersimpan di SQLite lokal dan tersinkronisasi otomatis saat terhubung kembali.
8. **Multi-Tenant (BYOD - Bring Your Own Database)**:
   - Setiap organisasi/perusahaan mengontrol datanya sendiri melalui kredensial Supabase masing-masing.

---

## 🛠️ Persyaratan Sistem & Tech Stack

- **Flutter SDK**: 3.24+ (Dart 3.5+)
- **Windows Target**: Windows 10 / 11 (64-bit), MSVC C++ toolchain (Visual Studio Build Tools)
- **Android Target**: Android 8.0 (API 26) ke atas (arsitektur arm64-v8a / armeabi-v7a)
- **Database Cloud**: PostgreSQL 15+ di Supabase

---

## 🚀 Memulai Pengembangan

### 1. Kloning Repositori & Pasang Dependensi
```bash
git clone https://github.com/<username>/ramsawit-app.git
cd ramsawit-app
flutter pub get
```

### 2. Jalankan Pengujian Otomatis
```bash
flutter analyze
flutter test
```

### 3. Kompilasi Build Rilis

#### Native Windows (Desktop POS Timbangan):
```bash
flutter build windows --release
```
Hasil biner tersimpan di `build/windows/x64/runner/Release/RamSawit.exe`.

#### Native Android (APK):
```bash
flutter build apk --release
```
Hasil file APK tersimpan di `build/app/outputs/flutter-apk/app-release.apk`.

---

## 🗄️ Menyiapkan Organisasi / Tenant Baru

Setiap organisasi baru hanya perlu mengeksekusi satu skrip SQL di Supabase:
1. Buka file [`supabase/master_tenant_schema.sql`](supabase/master_tenant_schema.sql).
2. Salin seluruh isi skrip dan jalankan di **SQL Editor** pada project Supabase Anda.
3. Masukkan **Project URL** dan **Anon Key** pada menu **"Setup Organisasi & Database"** di halaman login aplikasi RamSawit.
4. Panduan lengkap tersedia di [`supabase/README.md`](supabase/README.md).

---

## 📜 Lisensi
Dikembangkan untuk modernisasi operasional industri kelapa sawit Indonesia. Hak cipta dilindungi.
