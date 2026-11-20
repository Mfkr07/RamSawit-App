# Laporan Pelaksanaan Tugas — Bagian 0: Analisis PRD & Penyusunan Rules Proyek

Dokumen ini adalah rekam jejak teknis detail mengenai penelaahan dokumen kebutuhan produk (PRD), perancangan aturan arsitektural, dan penetapan single source of truth untuk AI coding agent pada proyek **Aplikasi Transaksi Jual Beli Buah Kelapa Sawit (TBS)**.

---

## 1. Ringkasan Tugas

- **Instruksi Pengguna**: Membaca dokumen PRD dan desain database di folder `doc/`, merangkum pemahaman bisnis dan teknis, berkomitmen tidak mengubah skema tanpa izin, serta membuat file rules proyek (`AGENTS.md`).
- **Status**: Selesai & Disetujui (Approved)

---

## 2. Analisis Sumber Dokumen Utama

Pekerjaan diawali dengan membaca dan menganalisis 3 dokumen utama yang telah disediakan pengguna:
1. `doc/PRD-Aplikasi-Transaksi-Sawit.md`: Dokumen spesifikasi kebutuhan produk, alur pengguna (user flow), batasan versi v1, serta milestone pengembangan.
2. `doc/Database-Aplikasi-Transaksi-Sawit.md`: Desain database relasional hingga level normalisasi 3NF, ERD Mermaid, DDL Supabase PostgreSQL, trigger sequence, RLS, serta reporting views.
3. `doc/DESIGN.md`: Panduan desain antarmuka enterprise berbasis IBM Carbon Design System (IBM Plex Sans, aksen IBM Blue `#0F62FE`, sudut flat-square 0–2px, dan kontras tinggi).

---

## 3. Berkas yang Ditambahkan (NEW)

### [AGENTS.md](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/AGENTS.md)
File konfigurasi aturan proyek di root direktori yang menjadi pedoman mutlak untuk pengembangan selanjutnya:
- **Tech Stack Wajib**:
  - Framework: Flutter (Android, iOS, Web - Single Codebase)
  - Backend/Database: Supabase (PostgreSQL 15+, Supabase Auth, Row Level Security, Realtime)
  - State Management: Flutter Riverpod
  - Visualisasi Grafik: `fl_chart`
  - Tipe Data Presisi: `decimal` dan `intl`
  - Tema: IBM Carbon Design System
- **Struktur Folder Standar (Sesuai Bagian 10 PRD)**:
  Memisahkan layer `core/` (config, theme, utils), `models/` (data entity), dan `features/` (auth, dashboard, penjual, transaksi).
- **Konvensi Bahasa & Penamaan**:
  - Nama variabel, fungsi, method, class, dan file: Bahasa Inggris (`camelCase`, `PascalCase`, `snake_case`).
  - Seluruh teks UI, label input, tombol aksi, pesan error, snackbar, dan dialog: Bahasa Indonesia baku.
- **Aturan Angka, Uang, dan Berat (Anti Floating-Point Error)**:
  - Dilarang menggunakan tipe `double` primitif untuk kalkulasi akumulasi uang.
  - Wajib menggunakan package `Decimal` / `BigInt` / `int`.
  - Format Rupiah: `Rp 2.450.000` (pemisah ribuan titik).
  - Format Berat: `1.250,50 kg` (koma untuk desimal, titik untuk ribuan, presisi 2 desimal, suffix "kg").
- **Integritas Database (Single Source of Truth)**:
  - Subtotal per baris item adalah kolom generated di database: `subtotal numeric(14,2) generated always as (harga_per_kg * berat_kg) stored`.
  - Total berat dan total harga transaksi wajib bersumber dari view agregasi database `v_transaksi_ringkasan`, bukan hasil `sum()` manual yang tercecer di client.
  - Perhitungan di form input client hanya berfungsi sebagai *live preview* interaktif.
  - Transaksi tidak boleh di-hard delete fisik, melainkan melalui soft cancellation (`status = 'dibatalkan'`).

---

## 4. Hal yang Sengaja Dihindari / Dikurangi

1. **Menghindari Perubahan Struktur Database**: Memastikan bahwa nama kolom, tabel, dan relasi tidak diubah sepihak tanpa izin pengguna.
2. **Menghindari Penulisan Kode Sebelum Persetujuan**: Menampilkan seluruh ringkasan pemahaman dan draft rules terlebih dahulu dan menunggu konfirmasi pengguna.
