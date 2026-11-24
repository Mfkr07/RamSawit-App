# Rules & Panduan Pengembangan Proyek
## Aplikasi Transaksi Jual Beli Buah Kelapa Sawit (TBS)

Dokumen ini adalah ringkasan aturan teknis dan konvensi arsitektur proyek yang wajib dipatuhi oleh seluruh AI coding agent dan pengembang. Sumber kebenaran utama (Single Source of Truth) dari struktur database, requirement, dan desain merujuk pada `doc/PRD-RamSawit.md`, `doc/Database-RamSawit.md`, dan `doc/DESIGN.md`.

---

## 1. Tech Stack & Dependencies

- **Framework**: Flutter (Target utama: Android (.apk) dan Windows (.exe) — migrasi lepas dari web; Responsive Single Codebase)
- **Backend / Database**: Supabase (PostgreSQL 15+, Supabase Auth, Row Level Security, Realtime) + **Drift (SQLite lokal untuk offline-first)**
- **State Management**: Flutter Riverpod (`flutter_riverpod` / `riverpod_annotation`)
- **Visualisasi & Grafik**: `fl_chart`
- **Tipe Data Presisi & Utility**: `decimal`, `intl` (format mata uang IDR dan tanggal localized Indonesia)
- **AI Analytics**: LLM OpenAI-compatible via 9Router / Ollama (`http`), konfigurasi endpoint via `flutter_secure_storage`
- **Codegen Database Lokal**: `drift_dev` + `build_runner`
- **Desain & Tipografi**: IBM Carbon Design System Style (Font: IBM Plex Sans, flat square corners 0–4px, aksen IBM Blue `#0f62fe`, clean enterprise layout)

---

## 2. Struktur Folder Wajib

Struktur folder project wajib mengikuti standar Bagian 10 PRD, dengan tambahan modul offline-first dan AI:

```
lib/
 ├─ core/
 │   ├─ supabase_client.dart       # Inisialisasi & konfigurasi Supabase
 │   ├─ database/                  # AppDatabase Drift (tabel Local*, database: sawit_offline_db)
 │   ├─ sync/                      # SyncEngine, SyncStatusBar (sinkronisasi lokal ↔ cloud)
 │   ├─ services/                  # ai_endpoint_config_service, session_storage_service
 │   ├─ tenant_config_service.dart # Konfigurasi tenant/organisasi
 │   ├─ theme/                     # Tema warna, tipografi (IBM Carbon / IBM Plex Sans)
 │   ├─ utils/                     # Formatter Rupiah, berat (kg), tanggal, validator
 │   └─ widgets/                   # Widget reusable
 ├─ models/
 │   ├─ penjual.dart               # Model data penjual / petani
 │   ├─ jenis_buah.dart            # Model data master jenis buah
 │   ├─ transaksi.dart             # Model transaksi & v_transaksi_ringkasan
 │   └─ transaksi_item.dart        # Model item transaksi
 ├─ features/
 │   ├─ ai_analytics/              # Chat advisor AI: page, controller, services/, widgets/
 │   ├─ auth/                      # Login email/password, auth gate, session handler
 │   ├─ dashboard/
 │   │   ├─ dashboard_page.dart    # Halaman utama dashboard
 │   │   └─ widgets/               # kartu_ringkasan, chart_tren, chart_breakdown, list_transaksi_terakhir
 │   ├─ pabrik/                    # Modul penjualan ke pabrik
 │   ├─ pengeluaran/               # Modul pencatatan pengeluaran
 │   ├─ pengiriman_pabrik/         # Modul pengiriman 2 fase ke pabrik
 │   ├─ penjual/
 │   │   ├─ penjual_list_page.dart # Daftar master penjual + pencarian
 │   │   └─ penjual_form_page.dart # Form tambah/edit penjual (modal / inline support)
 │   ├─ saldo/                     # Modul dana/saldo modal
 │   ├─ tenant/                    # Setup organisasi (multi-tenant)
 │   └─ transaksi/
 │       ├─ transaksi_form_page.dart   # Form input transaksi baru multi-item
 │       ├─ transaksi_list_page.dart   # Riwayat transaksi + filter
 │       └─ transaksi_detail_page.dart # Detail nota transaksi + aksi batal/void
 └─ main.dart                      # Entry point aplikasi
windows/                           # Runner desktop Windows (root project)
```

---

## 3. Konvensi Bahasa & Penamaan

- **Kode Sumber (Bahasa Inggris)**:
  - Nama variabel, parameter, konstanta: `camelCase` (contoh: `sellerId`, `grossWeightKg`, `unitPrice`)
  - Nama fungsi dan method: `camelCase` (contoh: `fetchRecentTransactions()`, `calculatePreviewSubtotal()`)
  - Nama class, model, enum: `PascalCase` (contoh: `TransactionRepository`, `SellerModel`, `FruitType`)
  - Nama file dan direktori: `snake_case` (contoh: `transaksi_form_page.dart`, `currency_formatter.dart`)
  - Komentar arsitektural dan dokumentasi kode teknis ditulis dalam bahasa Inggris yang ringkas.
- **Antarmuka Pengguna / UI Text (Bahasa Indonesia)**:
  - Seluruh teks yang tampak oleh pengguna (label input, placeholder, tombol CTA, judul navbar/appbar, tooltip, status badge) WAJIB menggunakan bahasa Indonesia baku dan komunikatif.
  - Seluruh pesan interaktif (pesan validasi input, konfirmasi aksi, snackbar sukses, pesan error exception, dialog pembatalan) WAJIB berbahasa Indonesia.
  - Istilah domain sawit menggunakan istilah resmi: "Tandan Besar", "Tandan Kecil", "Berondolan", "Penjual", "Pengepul", "Berat Kotor", "Subtotal", "Total Nilai", "Dibatalkan", "Selesai".

---

## 4. Aturan Angka, Uang, dan Berat

- **Presisi Uang (Anti-Floating Point Error)**:
  - **DILARANG** menggunakan tipe data `double` primitif untuk kalkulasi akumulasi atau penyimpanan nominal uang.
  - Gunakan tipe `int` (untuk nilai Rupiah bulat) atau package `Decimal` / `BigInt` saat komputasi sebelum dikirim ke database (`numeric(12,2)` / `numeric(14,2)`).
- **Format Rupiah**:
  - Gunakan pemisah ribuan titik (`.`) dengan prefix `Rp ` (contoh: `Rp 2.450.000`).
  - Parsing input mata uang harus toleran terhadap format localized Indonesia.
- **Format Berat**:
  - Nilai berat menggunakan presisi hingga 2 desimal (`numeric(10,2)`).
  - Tampilan di UI wajib menggunakan koma (`,`) untuk desimal dan titik (`.`) untuk ribuan, disertai suffix satuan `" kg"` (contoh: `1.250,50 kg`).

---

## 5. Integritas Data & Single Source of Truth

- **Perhitungan Nilai Transaksi**:
  - Subtotal item adalah kolom generated di database: `subtotal numeric(14,2) generated always as (harga_per_kg * berat_kg) stored`.
  - Total berat transaksi (`total_berat_kg`) dan total pembayaran (`total_harga`) **WAJIB bersumber dari database** melalui view `v_transaksi_ringkasan` atau query agregasi database, bukan hasil sum() manual yang tercecer di berbagai file Flutter client.
  - Perhitungan di form input transaksi client hanya berfungsi sebagai *live preview* interaktif sebelum data di-submit ke Supabase.
- **Imutabilitas Skema Database**:
  - Dilarang mengubah struktur tabel, nama kolom, view, tipe data, atau constraint yang sudah ditetapkan pada `doc/PRD-RamSawit.md` dan `doc/Database-RamSawit.md` tanpa persetujuan eksplisit dari pemilik proyek.
- **Audit & Keamanan**:
  - Transaksi tidak boleh dihapus secara permanen (`DELETE`), melainkan melalui perubahan status menjadi `'dibatalkan'` disertai pencatatan alasan.
  - Setiap mutasi data menyertakan referensi `created_by` dari authenticated user (`auth.uid()`).

---

## 6. Aturan Operasi Git (Larangan git add, commit, dan push)

- **DILARANG KERAS** bagi AI Agent untuk mengeksekusi perintah `git add`, `git commit`, dan `git push` secara langsung melalui terminal.
- **Kewenangan Penuh Pengguna**: Operasi *staging*, *committing*, dan *pushing* ke remote repository sepenuhnya berada di tangan pengguna. AI bertugas menyiapkan rekomendasi perintahnya.
- **Perintah Git yang Diperbolehkan**: AI Agent diperbolehkan menjalankan perintah git diagnostik/pembacaan status seperti `git status`, `git diff`, `git log`, `git branch`, dan perintah git lainnya selain `git add`, `git commit`, dan `git push`.

---

## 7. Standar Commit Message

- **Format utama**: `<versi> <tipe>: <deskripsi>` — contoh: `2.3.3 fix: making mobile ui more responsive`, `1.9.1 feat: adding new modul pengeluaran`.
- **Tipe yang dipakai**: `feat` (fitur baru), `fix` (perbaikan bug), `docs` (dokumentasi).
- **Varian conventional commit** juga dipakai: `feat(pabrik): ...`, `fix(dashboard): ...`.
- Deskripsi boleh Bahasa Inggris atau Bahasa Indonesia, ringkas satu baris.
- Nomor versi mengikuti rilis berikutnya (naik patch untuk fix/docs, minor untuk feat).

---

## 8. Aturan Offline-First & Sinkronisasi

- **Local-first**: tulis data ke tabel Drift lokal (`LocalPenjual`, `LocalTransaksi`, `LocalPengeluaran`, dll. di `core/database/tables.dart`) terlebih dahulu; kolom `isSynced` menandai data yang belum terkirim ke cloud.
- **SyncEngine** (`core/sync/sync_engine.dart`, `StateNotifier`): status `idle` / `syncing` / `offline` / `error`; method `syncNow()`, `startPeriodicSync()` (default tiap 30 detik), `refreshUnsyncedCount()`. Diakses via `syncEngineProvider`.
- UI **wajib** menampilkan `SyncStatusBar` agar pengguna selalu tahu status sinkronisasi.
- **Dilarang** mengasumsikan koneksi selalu tersedia — repository harus tetap punya fallback demo/offline (mengikuti pola `_demoList` yang sudah ada).
- Test database lokal memakai `AppDatabase.forTesting(NativeDatabase.memory())`.
- Perubahan skema lokal: edit `tables.dart`, jalankan `build_runner`, naikkan `schemaVersion` di `AppDatabase`.

---

## 9. Aturan Modul AI Analytics

- LLM bersifat **read-only**: data operasional di-inject sebagai konteks, AI **dilarang** memutasi data.
- Provider: OpenAI-compatible — default **9Router** (`http://localhost:20128/v1`, model default `ag/gemini-3.8-flash-medium`); alternatif Ollama / LLM lokal.
- Jika endpoint nonaktif atau URL tidak valid, **wajib** fallback ke `AiBusinessQueryService` (mesin query deterministik lokal).
- Konfigurasi endpoint terpusat di `AiEndpointConfigService`; API key disimpan di `flutter_secure_storage` — **dilarang hardcode**.
- Output AI untuk pengguna wajib Bahasa Indonesia.
