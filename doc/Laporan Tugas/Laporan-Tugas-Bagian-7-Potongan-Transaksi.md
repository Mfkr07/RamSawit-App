# Laporan Tugas Bagian 7: Implementasi Fitur Potongan Transaksi (PRD FR-6.x & Database §5)

**Tanggal Pelaksanaan**: 5 September 2026  
**Branch Git**: `fitur/potongan-dan-export`  
**Status**: **SELESAI (100% PASS)**  
**Target Platform**: Android, iOS, Web (Verified Production Web Build)  
**Referensi**: [PRD.md §FR-6.x](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/PRD-Aplikasi-Transaksi-Sawit.md), [Database.md §5](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/Database-Aplikasi-Transaksi-Sawit.md), [AGENTS.md](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/AGENTS.md)

---

## 1. Ringkasan Eksekutif

Tugas Bagian 7 mengimplementasikan fungsionalitas **Potongan Transaksi** (*transaction fee deduction / handling fee*) sesuai spesifikasi baru pada PRD FR-6.x dan skema database Database.md Bagian 5.

Sistem kini memperhitungkan persentase potongan (default 5%) yang secara otomatis mengurangi total harga kotor transaksi menjadi **Total Bersih** yang dibayarkan kepada petani/penjual TBS.

Prinsip & batasan utama yang dipenuhi selama implementasi:
1. **Safety & Zero Data Loss**: Aplikasi berada dalam status produksi aktif. Seluruh skema database diperbarui menggunakan `ALTER TABLE` dan `CREATE OR REPLACE VIEW` tanpa menyentuh struktur data lama (`NO DROP TABLE`, `NO DROP COLUMN`, `NO TRUNCATE`).
2. **Isolasi Git**: Seluruh pengerjaan dilakukan di branch baru `fitur/potongan-dan-export`, menjaga branch `main` tetap bersih dan stabil.
3. **Resiliensi Skema Client**: Repository client dilengkapi mekanisme fallback adaptif sehingga transaksi tetap berjalan mulus baik sebelum maupun sesudah migrasi SQL dieksekusi di database Supabase produksi.
4. **Presisi Finansial**: Seluruh kalkulasi diskon dan nilai bersih menggunakan package `decimal` untuk mencegah *floating-point error*.
5. **Verifikasi End-to-End**: Pengujian menyeluruh telah dilakukan mulai dari unit/widget testing (24 test lolos) hingga simulasi transaksi riil di browser dengan nominal 400 kg @ Rp 2.500 (Kotor: Rp 1.000.000, Potongan 5%: Rp 50.000, Total Bersih: Rp 950.000).

---

## 2. SQL Migration & Skema Database

File migrasi telah disiapkan pada:  
`supabase/migrations/20260905_tambah_potongan_transaksi.sql`

### Skrip Migrasi SQL:
```sql
-- ============================================================
-- Migrasi: Tambah Kolom persentase_potongan & Update Views
-- Sesuai doc/Database-Aplikasi-Transaksi-Sawit.md Bagian 5
-- ============================================================

-- 1. Tambah kolom persentase_potongan dengan default 5%
alter table public.transaksi
    add column if not exists persentase_potongan numeric(5,2) not null default 5.00
    check (persentase_potongan >= 0 and persentase_potongan <= 100);

-- 2. Perbarui view v_transaksi_ringkasan
-- Kolom 1 s/d 12 sama persis dengan urutan skema awal, 3 kolom potongan di-append di akhir (kolom 13, 14, 15)
create or replace view public.v_transaksi_ringkasan as
select
    t.id,
    t.kode_transaksi,
    t.tanggal_transaksi,
    t.status,
    p.id as penjual_id,
    p.nama as nama_penjual,
    coalesce(sum(ti.berat_kg), 0) as total_berat_kg,
    coalesce(sum(ti.subtotal), 0) as total_harga,
    t.catatan,
    t.created_by,
    t.created_at,
    t.updated_at,
    t.persentase_potongan,
    round(coalesce(sum(ti.subtotal), 0) * t.persentase_potongan / 100, 2) as nilai_potongan,
    round(coalesce(sum(ti.subtotal), 0) * (1 - t.persentase_potongan / 100), 2) as total_bersih
from public.transaksi t
join public.penjual p on p.id = t.penjual_id
left join public.transaksi_item ti on ti.transaksi_id = t.id
group by 
    t.id, 
    t.kode_transaksi, 
    t.tanggal_transaksi, 
    t.status, 
    p.id, 
    p.nama, 
    t.catatan, 
    t.created_by, 
    t.created_at, 
    t.updated_at, 
    t.persentase_potongan;

-- 3. Perbarui view v_transaksi_harian (total_nilai menggunakan total_bersih)
-- Kolom 1 s/d 4 tetap sama namanya (total_nilai di kolom 4 menghitung total_bersih)
-- Kolom 5 & 6 (total_kotor, total_potongan) di-append di akhir
create or replace view public.v_transaksi_harian as
select
    tanggal_transaksi,
    count(distinct id) as jumlah_transaksi,
    sum(total_berat_kg) as total_berat_kg,
    sum(total_bersih) as total_nilai,
    sum(total_harga) as total_kotor,
    sum(nilai_potongan) as total_potongan
from public.v_transaksi_ringkasan
where status = 'selesai'
group by tanggal_transaksi
order by tanggal_transaksi;
```

---

## 3. Implementasi Kode Sumber (Dart / Flutter)

### A. Lapisan Model Data
1. [lib/models/transaksi.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/models/transaksi.dart):
   - Menambahkan field `persentasePotongan` (`Decimal`, default `5.00`) pada model `Transaksi`.
   - Menambahkan getter komputasi `nilaiPotongan` dan `totalBersih`.
   - Menambahkan field `persentasePotongan`, `nilaiPotongan`, dan `totalBersih` pada model `TransaksiRingkasan`.
2. [lib/models/dashboard_analytics.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/models/dashboard_analytics.dart):
   - Menambahkan properti `totalKotor` dan `totalPotongan` pada model `TransaksiHarian`.
   - Menjamin bahwa `totalNilai` merepresentasikan nominal bersih (*net value*) setelah potongan.

### B. Lapisan Form & State Transaksi Baru
1. [lib/features/transaksi/transaksi_form_state.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/transaksi_form_state.dart):
   - Menambahkan properti `persentasePotongan` (default 5.00).
   - Menambahkan getter `nilaiPotongan` dan `totalBersih` berbasis `Decimal` untuk kalkulasi *live real-time preview*.
2. [lib/features/transaksi/transaksi_form_controller.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/transaksi_form_controller.dart):
   - Menambahkan method `setPersentasePotongan(Decimal value)`.
   - Meneruskan `persentasePotongan` saat memanggil `TransaksiRepository.createTransaksi()`.
3. [lib/features/transaksi/transaksi_form_page.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/transaksi_form_page.dart):
   - Panel ringkasan bawah kini menampilkan breakdown lengkap yang responsif menggunakan `Wrap`:
     - **TOTAL BERAT TBS** (kg)
     - **TOTAL HARGA (KOTOR)** (Rp)
     - **POTONGAN (5%)** (-Rp)
     - **TOTAL BERSIH (DIBAYARKAN)** (Rp, warna biru IBM Carbon `#0f62fe` dan font tebal)
   - Dialog sukses menampilkan rincian Total Kotor, Potongan 5%, dan Total Bersih yang dicetak pada nota.
4. [lib/features/transaksi/transaksi_repository.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/transaksi_repository.dart):
   - Menambahkan ketahanan schema cache: Jika Supabase belum menjalankan migrasi SQL dan merespons `Could not find the 'persentase_potongan' column`, repository otomatis me-retry insert tanpa kolom tersebut dan menghitung potongan secara lokal di client agar kasir tidak terblokir.

### C. Lapisan Riwayat & Detail Transaksi
1. [lib/features/transaksi/transaksi_list_page.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/transaksi_list_page.dart):
   - Menampilkan **Total Bersih** sebagai angka nominal utama pada setiap kartu transaksi.
   - Menyertakan informasi rincian kecil: `Kotor: Rp X • Potongan (5%): Rp Y`.
2. [lib/features/transaksi/transaksi_detail_page.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/transaksi_detail_page.dart):
   - Menampilkan kartu ringkasan nota lengkap:
     - Subtotal Kotor
     - Potongan (5.00%) dengan tanda minus
     - **Total Pembayaran Bersih (Diterima Penjual)** dengan kartu aksen biru korporat.

### D. Lapisan Dashboard & Analitik
1. [lib/features/dashboard/dashboard_repository.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/dashboard/dashboard_repository.dart):
   - Memastikan generator dummy & agregator Supabase mengakumulasi `totalBersih` untuk kartu KPI dan grafik harian.
2. [lib/features/dashboard/widgets/list_transaksi_terakhir.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/dashboard/widgets/list_transaksi_terakhir.dart):
   - Tabel "10 Transaksi Terakhir" menampilkan nilai `totalBersih`.
3. [lib/features/dashboard/widgets/chart_tren.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/dashboard/widgets/chart_tren.dart):
   - Keterangan tooltip dan sumbu chart diperjelas sebagai nilai bersih transaksi.

---

## 4. Hasil Pengujian & Verifikasi

### A. Pengujian Otomatis (Automated Tests)
Semua suite pengujian otomatis dijalankan melalui perintah `flutter test`:
- **Total Test**: 24 tests
- **Hasil**: **24 passed, 0 failed**
- Termasuk pengujian unit presisi potongan transaksi baru:
  - Validasi perhitungan potongan 5% pada Rp 1.000.000 = Rp 50.000 dan Total Bersih = Rp 950.000.
  - Validasi ketahanan terhadap angka ganjil (contoh: 123 kg @ Rp 2.345 = Rp 288.435 kotor, potongan 5% = Rp 14.421,75, total bersih = Rp 274.013,25).

### B. Pengujian Manual End-to-End di Browser
Pengujian E2E dilakukan pada build web rilis (`http://localhost:8080`):
1. **Input Transaksi Baru**:
   - Penjual: **Budi Santoso**
   - Item: **Tandan Besar (TB)**
   - Berat: **400 kg**
   - Harga: **Rp 2.500 / kg**
   - Live Preview Ringkasan:
     - *Total Berat*: 400,00 kg
     - *Total Harga (Kotor)*: Rp 1.000.000
     - *Potongan (5%)*: -Rp 50.000
     - *Total Bersih*: **Rp 950.000**
2. **Simpan Transaksi**:
   - Transaksi berhasil tersimpan dengan kode transaksi **`TRX-20260905-0005`**.
   - Modal konfirmasi mencantumkan Total Kotor Rp 1.000.000, Potongan Rp 50.000, dan Total Bersih Rp 950.000.
3. **Verifikasi Halaman Riwayat Transaksi**:
   - Transaksi `TRX-20260905-0005` tampil di urutan teratas.
   - Nominal utama tercantum **Rp 950.000** dengan subteks `Kotor: Rp 1.000.000 • Potongan (5%): Rp 50.000`.
4. **Verifikasi Halaman Detail Nota Transaksi**:
   - Rincian item: 400,00 kg @ Rp 2.500 = Rp 1.000.000.
   - Ringkasan nota: Total Kotor Rp 1.000.000, Potongan 5% -Rp 50.000, Total Bersih **Rp 950.000**.
5. **Verifikasi Dashboard**:
   - Kartu KPI "HARI INI": Total nilai bertambah tepat **+Rp 950.000** (menjadi Rp 4.522.300 dengan 5 transaksi).
   - Tabel "10 Transaksi Terakhir": Baris pertama menampilkan `TRX-20260905-0005` dengan nominal Rp 950.000.

---

## 5. Checklist Acceptance Criteria FR-6.x

| Kriteria | Deskripsi | Status | Catatan Verifikasi |
|---|---|:---:|---|
| **AC-FR6.1** | Skema database mendukung persentase potongan (default 5%) | **PASS** | Kolom `persentase_potongan` numeric(5,2) dan view ringkasan/harian diperbarui |
| **AC-FR6.2** | Live calculation potongan di form transaksi | **PASS** | Menggunakan `Decimal`, update real-time saat berat/harga berubah |
| **AC-FR6.3** | Nilai bersih disimpan dan ditampilkan konsisten di riwayat & detail | **PASS** | Nilai Rp 950.000 tampil konsisten di form, modal, riwayat, dan nota detail |
| **AC-FR6.4** | Dashboard KPI dan grafik menggunakan total bersih | **PASS** | View harian dan repository menjumlahkan `total_bersih` sebagai `total_nilai` |
| **AC-FR6.5** | Tanpa *floating point error* | **PASS** | Menggunakan package `decimal` di seluruh jalur komputasi keuangan |
| **AC-FR6.6** | Zero Data Loss (Produksi aman) | **PASS** | Menggunakan `ALTER TABLE` tanpa DROP TABLE / TRUNCATE |

---

## 6. Panduan Menjalankan Migrasi di Supabase

Untuk menyinkronkan database Supabase produksi:
1. Buka [Supabase Dashboard](https://supabase.com/dashboard).
2. Pilih project TBS Sawit.
3. Masuk ke menu **SQL Editor** di panel sebelah kiri.
4. Klik **New Query**, lalu salin dan tempel isi file `supabase/migrations/20260905_tambah_potongan_transaksi.sql`.
5. Klik tombol **Run** (Ctrl+Enter).
6. Selesai. Seluruh data transaksi lama otomatis memiliki `persentase_potongan = 5.00` dan view akan menyajikan data `total_kotor`, `nilai_potongan`, serta `total_bersih`.
