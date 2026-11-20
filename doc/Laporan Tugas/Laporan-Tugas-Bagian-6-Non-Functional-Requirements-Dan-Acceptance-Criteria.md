# Laporan Tugas Bagian 6: Non-Functional Requirements & Acceptance Criteria (PRD §9 & §12)

**Tanggal Pelaksanaan**: 4 September 2026  
**Status**: **SELESAI (100% PASS)**  
**Target Platform**: Android, iOS, Web (Verified Production Web Build)  
**Referensi**: [PRD.md §9 & §12](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/PRD.md), [AGENTS.md](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/AGENTS.md)

---

## 1. Ringkasan Eksekutif

Tugas Bagian 6 merupakan tahap finalisasi, audit mutu, penguatan non-fungsional (*non-functional requirements*), dan pengujian kriteria penerimaan (*Acceptance Criteria*) aplikasi sistem transaksi jual beli buah kelapa sawit (TBS). 

Fokus utama Bagian 6 meliputi:
1. **Audit Responsiveness**: Memastikan seluruh halaman (`LoginPage`, `DashboardPage`, `PenjualListPage`, `TransaksiFormPage`, `TransaksiListPage`, `TransaksiDetailPage`) beradaptasi secara otomatis dan proporsional antara layar mobile/ponsel (portrait $\le 450$px) dan tablet/desktop ($\ge 768$px) menggunakan `LayoutBuilder` / breakpoint tunggal.
2. **Audit Presisi Keuangan & Berat (Anti-Floating Point Error)**: Memastikan **tidak ada** penggunaan tipe data primitif `double` pada komputasi harga, subtotal, total pembayaran, atau agregasi. Seluruh perhitungan menggunakan package `decimal` dan `BigInt` dengan representasi `numeric` eksak ke database.
3. **Pusat Penanganan Error Ramah Pengguna (Bahasa Indonesia)**: Mengimplementasikan `AppExceptionHelper` untuk menerjemahkan error Supabase Auth, PostgreSQL exception (duplikasi 23505, foreign key 23503, check constraint 23514, row not found PGRST116, RLS 42501), serta kendala koneksi/timeout menjadi pesan komunikatif berbahasa Indonesia.
4. **Pengujian Acceptance Criteria PRD §12 (AC-1 s/d AC-8)**: Menjalankan pengujian otomatis & manual end-to-end (E2E) menggunakan subagent browser pada target web. Seluruh kriteria berhasil diverifikasi dengan status **PASS**.
5. **Kompilasi Rilis Produksi Web**: Menjalankan `flutter build web --release` dengan status kompilasi bersih (0 error, waktu kompilasi 41.9 detik).
6. **Dokumentasi Batasan v1 & Roadmap Masa Depan (PRD §13)**: Merangkum arsitektur v1 yang telah diselesaikan serta menyusun rencana peningkatan fitur di masa mendatang.

---

## 2. Perubahan & Penguatan Kode Sumber

### A. Helper Sentral Error Handling (`AppExceptionHelper`)
- **File Baru**: [lib/core/utils/app_exception_helper.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/core/utils/app_exception_helper.dart)
- **Tujuan**: Menerjemahkan setiap jenis error teknis menjadi instruksi yang jelas bagi kasir/operator non-teknis:
  - `AuthException`: Kredensial tidak cocok, email belum konfirmasi, user sudah terdaftar, rate limiting.
  - `PostgrestException`:
    - Code `23505`: Menangani duplikat kode transaksi, duplikat jenis buah pada satu transaksi, dan duplikat data umum.
    - Code `23503`: Menangani foreign key integrity saat data sedang berelasi.
    - Code `23514`: Menangani pelanggaran constraint validasi (misal berat $\le 0$ kg).
    - Code `PGRST116`: Menangani data tidak ditemukan.
    - Code `42501`: Menangani pelanggaran izin akses Row Level Security (RLS).
  - Jaringan / Timeout: Socket exception, connection refused, offline, dan timeout response.
- **Penerapan**: Diintegrasikan di seluruh *try-catch block* pada `transaksi_repository.dart`, `penjual_repository.dart`, `dashboard_repository.dart`, dan form UI.

### B. Penguatan Format & Presisi Uang/Berat
- **File**: [lib/core/utils/currency_formatter.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/core/utils/currency_formatter.dart)
  - Menghapus ketergantungan pada konversi `toDouble()`.
  - Format angka Rupiah murni dilakukan melalui string grouping pada `BigInt` (contoh: `Rp 2.450.000` hingga `Rp 15.000.000.000`).
- **File**: [lib/core/utils/weight_formatter.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/core/utils/weight_formatter.dart)
  - Menghapus pemanggilan `NumberFormat` double.
  - Formatting berat dilakukan via pemisahan bagian bulat dan 2 desimal berbasis `Decimal.toString()` (contoh: `1.250,50 kg`).
- **File**: [lib/features/transaksi/transaksi_repository.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/transaksi_repository.dart)
  - Nilai `harga_per_kg` dan `berat_kg` saat diserialisasi ke JSON Supabase dikirim menggunakan `.toString()` agar Postgres menerima nilai exact `numeric`, bukan double floating-point.

### C. Refinement Responsiveness Layar Mobile & Desktop
- **File**: [lib/features/transaksi/transaksi_detail_page.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/transaksi_detail_page.dart)
  - Mengintegrasikan `LayoutBuilder` pada daftar rincian item nota.
  - Pada layar lebar ($\ge 520$px): Menampilkan tabel enterprise 4-kolom (*Jenis Buah, Harga/kg, Berat kg, Subtotal*).
  - Pada layar kecil ($< 520$px): Menampilkan susunan kartu item modular 2-baris yang rapi dan tidak terpotong.
- **File Lain**: Seluruh form dan dashboard (`dashboard_page.dart`, `transaksi_form_page.dart`, `penjual_list_page.dart`) telah memiliki breakpoint responsif bawaan untuk layar ponsel $390 \times 844$ maupun desktop widescreen.

---

## 3. Hasil Audit Checklist Acceptance Criteria (PRD §12)

Berikut adalah status verifikasi setiap poin Kriteria Penerimaan dari PRD §12 yang diuji secara end-to-end:

| ID Kriteria | Kriteria Penerimaan (PRD §12) | Hasil Uji | Catatan & Bukti Verifikasi |
| :--- | :--- | :---: | :--- |
| **AC-1** | **Login & Sesi Persisten**:<br>Login berhasil dengan kredensial valid, sesi tersimpan saat browser di-refresh / aplikasi dibuka ulang. | **PASS** | Sesi tersimpan di local storage/auth state; user kasir otomatis tetap login setelah reload browser.<br>Bukti: `ac1_session_persistence_1788530217690.png` |
| **AC-2** | **Tambah Penjual Inline**:<br>Penjual baru bisa ditambahkan secara inline saat membuat transaksi tanpa harus keluar dari form transaksi. | **PASS** | Form modal inline picker berhasil menambahkan `Petani Uji AC2` dan langsung terpilih otomatis di form transaksi.<br>Bukti: `ac2_inline_seller_added_1788530310375.png` & `ac2_seller_search_verified_1788530534312.png` |
| **AC-3** | **Kalkulasi Real-time Multi-Item**:<br>Input berat dan harga per kg otomatis menghitung subtotal tiap item dan total transaksi secara real-time tanpa delay. | **PASS** | Live preview subtotal: Item 1 = Rp 2.500.000, Item 2 = Rp 1.400.000. Total berat = 1.500,00 kg dan Total bayar = Rp 3.900.000 terupdate instan.<br>Bukti: `ac3_realtime_calculation_1788530400127.png` |
| **AC-4** | **Pencegahan Buah Duplikat**:<br>Tidak dapat menyimpan transaksi jika jenis buah yang sama dipilih lebih dari satu kali (ada peringatan validasi). | **PASS** | Banner peringatan merah muncul ketika memilih jenis buah ganda ("Tandan Besar"), dan tombol Simpan dinonaktifkan.<br>Bukti: `ac4_duplicate_fruit_prevented_1788530361634.png` |
| **AC-5** | **Format Kode Transaksi Otomatis**:<br>Kode transaksi unik ter-generate otomatis dengan format `TRX-YYYYMMDD-XXXX` berurutan per hari. | **PASS** | Transaksi baru berhasil disimpan dan mendapat kode resmi otomatis dari database: `TRX-20260904-0002`.<br>Bukti: `ac5_transaction_created_1788530410080.png` |
| **AC-6** | **Konsistensi Dashboard Analitik**:<br>Dashboard menampilkan ringkasan harian, mingguan, dan bulanan yang sesuai dengan data riwayat transaksi. | **PASS** | Agregasi dashboard bersumber dari `v_transaksi_harian` & `v_breakdown_jenis_buah`. Nilai konsisten dengan ringkasan riwayat.<br>Bukti: `ac6_dashboard_overview_1788530238299.png` |
| **AC-7** | **Tampilan Responsif Mobile & Desktop**:<br>Tampilan responsif dan proporsional di layar HP (portrait $\le 450$px) maupun layar tablet/desktop ($\ge 768$px). | **PASS** | Diuji pada viewport ponsel $390 \times 844$ dan desktop $1040 \times 720$. Komponen form, kartu omset, dan navbar menyesuaikan tanpa overflow.<br>Bukti: `ac7_mobile_dashboard_1788530255403.png` & `ac7_mobile_transaksi_form_1788530265861.png` |
| **AC-8** | **Integritas Void / Pembatalan Transaksi**:<br>Transaksi yang dibatalkan tidak lagi dihitung dalam total nilai/berat di dashboard, namun tetap muncul di riwayat transaksi dengan status "dibatalkan". | **PASS** | Transaksi `TRX-20260904-0002` dibatalkan dengan alasan validasi terisi. Status berubah menjadi `DIBATALKAN` dan omset dashboard otomatis mengecualikan nilai tersebut.<br>Bukti: `ac6_transaction_canceled_1788530487645.png` & `ac6_dashboard_after_cancellation_1788530507930.png` |

---

## 4. Hasil Verifikasi Kode & Pengujian Otomatis

### A. Analisis Statis Kode (`flutter analyze`)
```bash
flutter analyze
# Analyzing Aplikasi Transaksi TBS sawit...
# No issues found! (ran in 5.9s)
```
Status: **0 Error, 0 Warning, 0 Lint Issue**.

### B. Unit & Widget Tests (`flutter test`)
Sebanyak 19 unit & widget test dijalankan mencakup:
- App smoke test & login UI.
- `CurrencyFormatter` & `WeightFormatter` (termasuk nilai ekstrem Rp 15 Miliar & 15 Juta kg).
- Model serialisasi (`Profile`, `Penjual`, `JenisBuah`, `Transaksi`, `TransaksiItem`, `TransaksiRingkasan`, `TransaksiHarian`, `BreakdownJenisBuah`).
- Form multi-item, kalkulasi `Decimal`, pencegahan jenis buah ganda, limit maksimal 3 baris.
- Filter riwayat transaksi, pembatalan transaksi dengan alasan.
- Dashboard analitik 30 hari & breakdown jenis buah.
- `AppExceptionHelper` penerjemahan error database, autentikasi, dan jaringan.
```bash
00:03 +19: All tests passed!
```
Status: **19 PASS, 0 FAIL**.

### C. Kompilasi Rilis Web Produksi (`flutter build web --release`)
```bash
flutter build web --release
# Compiling lib\main.dart for the Web...
# Wasm dry run succeeded.
# Tree-shaking CupertinoIcons (99.4%) & MaterialIcons (99.3%).
# Compiling lib\main.dart for the Web... 41.9s
# √ Built build\web
```
Status: **Berhasil terkompilasi bersih ke direktori `build/web/`**.

---

## 5. Ringkasan Fitur yang Selesai Dibangun (v1)

Aplikasi Transaksi TBS Sawit telah selesai diimplementasikan secara komprehensif dari Bagian 0 hingga Bagian 6:
1. **Aturan & Standar Proyek (Bagian 0)**: Dokumen [AGENTS.md](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/AGENTS.md) dan IBM Carbon Design System.
2. **Fondasi Database & Model (Bagian 1)**: Skema DDL Supabase PostgreSQL lengkap (tabel, foreign keys, check constraints, RLS policies, views agregasi, fungsi trigger auto-code) dan Dart model models.
3. **Autentikasi & Master Penjual (Bagian 2)**: Supabase Auth, login email/password, session persistence, daftar penjual, pencarian, soft-delete (`is_active`), dan reusable inline seller picker.
4. **Form Transaksi Multi-Item (Bagian 3)**: Form transaksi dinamis dengan maksimal 3 jenis buah, validasi anti-duplikasi, perhitungan otomatis real-time via `Decimal`, dan atomic insert Supabase.
5. **Riwayat Transaksi & Pembatalan Void (Bagian 4)**: View `v_transaksi_ringkasan`, filter rentang tanggal, status, penjual, detail nota transaksi, dan audit trail pembatalan transaksi dengan alasan wajib.
6. **Dashboard Analitik Eksekutif (Bagian 5)**: Kartu ringkasan omset (Hari Ini, Minggu Ini, Bulan Ini), grafik tren 30 hari (`fl_chart`), grafik volume per jenis buah, dan 10 transaksi terakhir dengan *tap-to-detail*.
7. **Kualitas Non-Fungsional & Kriteria Penerimaan (Bagian 6)**: Layout adaptif responsif, penghapusan mutlak tipe data `double` pada uang, sentralisasi pesan error dalam Bahasa Indonesia, dan verifikasi AC-1 s/d AC-8.

---

## 6. Batasan Sistem Saat Ini (v1 Limitations)

Sesuai ruang lingkup v1:
1. **Koneksi Jaringan**: Aplikasi v1 beroperasi secara online dengan Supabase backend. Jika koneksi internet terputus total saat menekan tombol simpan, transaksi tidak dapat disubmit (ditangani dengan pesan error ramah pengguna yang meminta periksa koneksi internet).
2. **Platform Eksekusi Verifikasi**: Pengujian E2E saat ini dilakukan pada lingkungan browser (Web), dengan emulator layout responsif untuk ukuran mobile. Target build mobile (APK/IPA) menggunakan basis kode yang sama (*single responsive codebase*).
3. **Pencetakan Fisik Nota**: Nota saat ini disajikan secara digital di layar dengan format terstruktur dan copyable transaction code. Fitur cetak langsung ke printer thermal Bluetooth belum disertakan pada rilis v1.

---

## 7. Rekomendasi Roadmap Masa Depan (Mengacu PRD §13)

Berdasarkan Bagian 13 PRD, berikut rekomendasi prioritas pengembangan untuk versi berikutnya:
- **v1.1: Thermal Printer Integration**:
  - Integrasi driver printer Bluetooth ESC/POS (58mm / 80mm) untuk cetak struk nota timbangan fisik di lapangan.
- **v1.2: Ekspor Laporan & Rekapitulasi**:
  - Fitur ekspor riwayat transaksi dan rekapitulasi harian/bulanan ke format Excel (`.xlsx`) dan PDF untuk keperluan audit pembukuan.
- **v1.3: Offline-First Support & Local Cache**:
  - Penyimpanan transaksi sementara di SQLite/Hive saat tidak ada sinyal di kebun pedalaman, dengan mekanisme sinkronisasi otomatis (*background sync*) saat jaringan kembali pulih.
- **v2.0: Integrasi Timbangan Digital (IoT)**:
  - Koneksi langsung ke timbangan truk/jembatan timbang via Bluetooth atau Serial RS-232 untuk otomatisasi pengisian berat timbangan tanpa input manual.

---

## 8. Kesimpulan

Seluruh spesifikasi fungsional (FR-1 s/d FR-5), non-fungsional, dan Acceptance Criteria (AC-1 s/d AC-8) dari PRD telah terpenuhi 100%. Kode sumber bersih dari linter error, lulus seluruh pengujian otomatis, dan siap digunakan.
