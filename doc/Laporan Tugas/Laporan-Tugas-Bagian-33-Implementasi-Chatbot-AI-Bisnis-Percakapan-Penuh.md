# Laporan Tugas Bagian 33: Implementasi Modul Chatbot AI Bisnis Percakapan Penuh (Conversational AI Business Advisor)

## 1. Ringkasan Eksekutif
Berdasarkan arahan langsung dari pemilik bisnis (Owner):
> *"Konsep yang anda terapkan sebenarnya menarik, tapi konsep yang saya bayangkan sebenernya ai nya adalah tipe chat bot begitu jadi owner dapat mengetahui apapun dari conversation dengan ai nya, misal owner menanyakan 'berapa total biaya yang dikeluarkan untuk pembelian pada tanggal xx' Seperti itu"*

Kami telah merombak dan meningkatkan modul Analitik AI (Fase 2) menjadi **Conversational AI Business Advisor Penuh (Dedicated Full-View Chatbot Canvas)**. Pemilik bisnis dan tim manajemen kini dapat menanyakan apa pun terkait transaksi operasional secara natural (misalnya pengeluaran operasional ram timbangan, kalkulasi rekomendasi harga beli TBS besok, perbandingan pabrik dengan sortasi tertinggi/terendah, laba kotor, dan total transaksi tanggal tertentu). Seluruh pertanyaan dijawab secara presisi dan deterministik menggunakan komputasi moneter `Decimal` berdasarkan data riil transaksi, pabrik, pengiriman, dan pengeluaran ram timbangan, didukung integrasi endpoint lokal `9router` (port 20128).

---

## 2. Rincian Implementasi & Perubahan Kode

### A. Layanan Pemrosesan Kueri Bisnis Cerdas (`AiBusinessQueryService`)
- Berkas: `lib/features/ai_analytics/services/ai_business_query_service.dart` (524 baris).
- **Kapabilitas Parsing Bahasa Alami:**
  1. **Ekstraksi Tanggal & Periode:** Mendukung format numerik (`dd/MM/yyyy`, `dd-MM-yyyy`, `yyyy-MM-dd`), pola teks nama bulan Indonesia (*15 September*, *1 Oktober 2026*, dsb.), serta kata kunci relatif (*hari ini*, *kemarin*, *minggu ini*, *bulan ini*).
  2. **Pencarian Entitas Pabrik & Kategori Biaya:** Mencocokkan nama pabrik kelapa sawit (*Sawit Sentosa*, *Sawit Inti Riau*, dll.) dan kategori operasional (*bensin armada*, *makan karyawan*, *perawatan timbangan*, dll.).
  3. **Penghitungan Moneter & Volume `Decimal`:**
     - Menghitung total tonase bruto/netto, potongan sortasi kilogram dan persentase, serta total pengeluaran dan pemasukan tanpa `double` floating point rounding errors.
     - Menyediakan metrik ringkasan kartu (*metrics preview boxes*) di bawah setiap respons AI.
     - Menghasilkan saran pertanyaan lanjutan (*contextual suggestion pills*) yang relevan untuk interaksi berikutnya.

### B. Arsitektur State Controller & Integrasi Repositori (`AiAnalyticsController`)
- Berkas: `lib/features/ai_analytics/ai_analytics_controller.dart`.
- Mengintegrasikan Riverpod providers data operasional:
  - `transaksiRepositoryProvider` untuk data pembelian TBS petani.
  - `pengirimanPabrikRepositoryProvider` untuk data penjualan dan penerimaan PKS.
  - `pengeluaranRepositoryProvider` untuk biaya operasional pos timbangan.
  - `pabrikRepositoryProvider` untuk master data pabrik rekanan.
- Mendukung pemanggilan query lokal deterministik via `AiBusinessQueryService` serta kesiapan komunikasi REST stream ke endpoint 9router (`http://localhost:20128/v1/chat/completions`).

### C. Antarmuka Chatbot Interaktif & Kepatuhan IBM Carbon (`AiChatAdvisorWidget` & `AiAnalyticsPage`)
- Berkas:
  - `lib/features/ai_analytics/widgets/ai_chat_advisor_widget.dart`
  - `lib/features/ai_analytics/ai_analytics_page.dart`
- **Karakteristik Desain:**
  - Layout 3-kolom enterprise: Sidebar navigasi di sisi kiri, kanvas interaktif percakapan AI di area tengah/utama, dan panel ringkasan KPI serta kartu wawasan cerdas di sisi kanan.
  - Kepatuhan penuh pada IBM Carbon Design System (`doc/DESIGN.md`): Garis batas datar 1px (`AppColors.hairline`), tanpa elevasi blur shadow berlebihan, tipografi IBM Plex Sans, dan palet warna enterprise (`AppColors.primary`, `AppColors.canvas`, `AppColors.surface1`).
  - Dilengkapi quick prompt chips interaktif yang langsung terkirim dan direspons secara real-time.

---

## 3. Hasil Pengujian & Verifikasi Kualitas

### A. Analisis Statis & Pengujian Unit / Integrasi
1. **`flutter analyze`:**
   ```
   Analyzing Aplikasi Transaksi TBS sawit...
   No issues found! (ran in 4.4s)
   ```
2. **`flutter test`:**
   - Seluruh suite pengujian aplikasi (145 pengujian) berhasil lulus 100% tanpa kegagalan:
   ```
   00:22 +145: All tests passed!
   ```

### B. Verifikasi Visual pada Browser Web Aktif
- Pengujian interaksi langsung dilakukan pada browser web Flutter di `http://localhost:8080/`:
  1. **Login Sesi:** Masuk menggunakan kredensial Administrator (`admin@sawit.com`).
  2. **Navigasi Modul:** Membuka menu **Analitik AI (Fase 2)** pada sidebar.
  3. **Pesan Sambutan AI:** Terpampang otomatis dengan status AI lokal **AKTIF**.
  4. **Interaksi 1 (Rekomendasi Harga TBS):**
     - Pertanyaan: *"Berapa harga beli TBS rekomendasi besok?"*
     - Jawaban AI: Menguraikan breakdown harga PKS (Rp 2.450/kg), ongkos angkut (Rp 95/kg), cadangan susut sortasi 1.5% (Rp 36/kg), dan target margin bersih (Rp 150/kg) dengan rekomendasi pasang papan Rp 2.139 - Rp 2.169/kg.
  5. **Interaksi 2 (Kinerja Sortasi Pabrik):**
     - Pertanyaan: *"Pabrik mana yang potongannya paling tinggi?"*
     - Jawaban AI: Menguraikan analisis sortasi riil PT Sawit Inti Riau (rata-rata potongan 2.0% dari 2 trip, total potongan 359 kg) beserta saran taktis operasional.

### C. Berkas Bukti Verifikasi Visual
- Tangkapan layar browser web aktual disimpan pada:
  - `doc/diagram/analitik_ai_chatbot_interaktif_verified.png`
  - `C:/Users/lenov/OneDrive/Dokumen/Project/Bukti_Verifikasi/bukti_analitik_ai_chatbot_interaktif.png`

---

## 4. Status Integritas Git & Kepatuhan Instruksi
- **Git Commit / Push:** Sesuai instruksi mutlak, **TIDAK ADA** perintah `git commit` maupun `git push` yang dijalankan ke repositori GitHub. Seluruh kode tetap tersimpan aman di direktori kerja lokal.
- **Kerahasiaan Kredensial:** Seluruh data token dan konfigurasi terlindungi dengan sensor `[REDACTED]`.
