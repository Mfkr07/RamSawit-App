# Laporan Tugas Bagian 15: Alur Dua Fase Pengiriman Pabrik (Keberangkatan & Penyelesaian)

**Tanggal Pelaksanaan**: 10 September 2026  
**Branch Git**: `fitur/pengiriman-2-fase`  
**Status**: **SELESAI (100% PASS, 50/50 Tests Passed, Browser Verified)**  
**Target Platform**: Android, iOS, Web (Responsive Codebase)  
**Referensi**: [PRD.md §7.8 (FR-8.1 s/d FR-8.9)](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/PRD-Aplikasi-Transaksi-Sawit.md#L124), [Database.md §8.2](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/Database-Aplikasi-Transaksi-Sawit.md#L699), [AGENTS.md](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/AGENTS.md)

---

## 1. Ringkasan Eksekutif & Latar Belakang

Pada implementasi awal (Bagian 11), pencatatan penjualan TBS ke pabrik pengolahan kelapa sawit (PKS) dilakukan dalam satu langkah formulir sekaligus, di mana seluruh parameter (mulai dari berat kotor awal hingga berat ditolak, potongan sortasi, dan harga jual final) harus diisi sekaligus dan langsung berstatus `'selesai'`.

Namun dalam operasional bisnis riil di lapangan, proses penjualan TBS ke pabrik selalu berjalan dalam **2 fase waktu yang terpisah**:
1. **Fase 1 (Keberangkatan Truk dari Timbangan Ram/Kebun)**:
   - Operator hanya mengetahui: Pabrik PKS tujuan, armada (nomor polisi truk), nama sopir, tanggal keberangkatan, dan berat kotor muatan awal TBS.
   - Status pengiriman: **`berangkat`**.
   - Kolom-kolom hasil penerimaan pabrik (berat ditolak, potongan sortasi, dan harga beli kesepakatan) **belum ada dan bernilai null**.
2. **Fase 2 (Penyelesaian Nota Hasil Pabrik / Settlement)**:
   - Dilakukan setelah armada truk tiba di pabrik, dilakukan penimbangan, sortasi mutu, dan sopir kembali membawa surat/slip timbang resmi dari PKS.
   - Operator membuka kembali pengiriman berstatus `berangkat`, lalu menginput: **Berat Ditolak (retur)**, **Potongan Sortasi (%)**, dan **Harga Jual Kesepakatan per kg (Rp)**.
   - Begitu data disimpan, status otomatis beralih menjadi **`selesai`**.

Tugas Bagian 15 mengimplementasikan alur 2-fase ini secara penuh dari sisi client model, repository, controller state management, UI forms, tab switcher riwayat pengiriman, detail modal, hingga isolasi ketat pada dashboard analitik dan generator export laporan.

---

## 2. Alur Bisnis Dua Fase (State Diagram)

```
       [RAM / Timbangan Kebun]
                  │
                  ▼
      ┌───────────────────────┐
      │ FASE 1: KEBERANGKATAN │
      │  - Pilih Pabrik PKS   │
      │  - No. Plat Truk      │
      │  - Nama Sopir         │
      │  - Tanggal Kirim      │
      │  - Berat Kotor (kg)   │
      └───────────┬───────────┘
                  │
                  ▼
         status: 'berangkat'
                  │
                  ├───────────────────────────────┐
                  ▼                               ▼
       [Truk Menuju Pabrik]             [Pembatalan di Jalan]
       (Timbang PKS & Sortasi)                    │
                  │                     status: 'dibatalkan'
                  ▼
      ┌───────────────────────┐
      │  FASE 2: PENYELESAIAN │
      │  (Buka Tab "Belum     │
      │   Selesai" di Riwayat)│
      │  - Berat Ditolak (kg) │
      │  - Potongan PKS (%)   │
      │  - Harga Jual/kg (Rp) │
      └───────────┬───────────┘
                  │
                  ▼
          status: 'selesai'
                  │
                  ▼
     ┌─────────────────────────┐
     │  Masuk ke Rekapitulasi: │
     │  - Dashboard Analitik   │
     │  - Margin Harian        │
     │  - Export Excel & PDF   │
     └─────────────────────────┘
```

---

## 3. Database Migration Script (Database.md §8.2)

Sesuai instruksi khusus: **Migration tidak dieksekusi langsung oleh coding agent ke database production**, melainkan disiapkan secara presisi untuk dijalankan oleh pengelola database di SQL Editor Supabase:

```sql
-- 1. Mengubah kolom fase 2 menjadi NULLABLE (karena belum terisi pada Fase 1)
alter table public.pengiriman_pabrik
    alter column berat_ditolak_kg drop not null,
    alter column berat_ditolak_kg drop default,
    alter column persentase_potongan_pabrik drop not null,
    alter column persentase_potongan_pabrik drop default,
    alter column harga_jual_per_kg drop not null;

-- 2. Memperbarui check constraint status untuk mendukung status 'berangkat'
alter table public.pengiriman_pabrik
    drop constraint if exists pengiriman_pabrik_status_check;

alter table public.pengiriman_pabrik
    add constraint pengiriman_pabrik_status_check
    check (status in ('berangkat', 'selesai', 'dibatalkan'));

-- 3. Menjadikan status default 'berangkat' saat insert baru
alter table public.pengiriman_pabrik
    alter column status set default 'berangkat';
```

---

## 4. Perubahan Komponen Kode Sumber

### A. Model Data: `lib/models/pengiriman_pabrik.dart`
- Mengubah properti fase-2 menjadi nullable `Decimal?`:
  - `beratDitolakKg`, `beratDiterimaKg`, `persentasePotonganPabrik`, `beratBersihKg`, `hargaJualPerKg`, `nilaiPotonganRp`, `totalNilaiJual`.
- Menambahkan getter status helper:
  - `bool get isBerangkat => status == 'berangkat';`
  - `bool get isSelesai => status == 'selesai';`
  - `bool get isDibatalkan => status == 'dibatalkan';`
- Memperbarui `toInsertMap()` agar hanya mengirimkan kolom Fase 1 dengan `status: 'berangkat'`. Kolom fase 2 tidak dikirimkan ke payload insert sehingga tersimpan sebagai `NULL` di PostgreSQL.

### B. Repository: `lib/features/pengiriman_pabrik/pengiriman_pabrik_repository.dart`
- **`createPengiriman` (Fase 1)**: Menyimpan data keberangkatan armada dengan berat kotor awal dan status `'berangkat'`.
- **`selesaikanPengirimanFase2` (Fase 2)**:
  - Menerima `id`, `beratDitolakKg`, `persentasePotonganPabrik`, `hargaJualPerKg`, dan `catatan`.
  - Melakukan update baris dengan `status: 'selesai'`.
  - Supabase PostgreSQL secara otomatis mengkalkulasi kolom generated (`berat_diterima_kg`, `berat_bersih_kg`, `nilai_potongan_rp`, `total_nilai_jual`).
- **`cancelPengiriman`**: Mendukung pembatalan transaksi dari status `berangkat` maupun `selesai` disertai pencatatan alasan pembatalan.

### C. Controller & State: `lib/features/pengiriman_pabrik/pengiriman_pabrik_controller.dart`
- **`PengirimanFormNotifier`**: Disederhanakan khusus untuk validasi dan pengiriman formulir Fase 1.
- **`SelesaikanFormState` & `SelesaikanFormNotifier`**: State notifier khusus untuk formulir penyelesaian Fase 2 dengan *real-time live preview* berbasis `Decimal`:
  - $\text{Berat Diterima} = \text{Berat Kotor} - \text{Berat Ditolak}$
  - $\text{Berat Bersih} = \text{Berat Diterima} \times (1 - \text{Potongan\%})$
  - $\text{Total Nilai Jual} = \text{Harga Jual/kg} \times \text{Berat Bersih}$
- **`selesaikanFormProvider`**: StateNotifierProvider berparadigma autoDispose & family terikat pada instance `PengirimanPabrik`.

### D. Formulir Keberangkatan: `lib/features/pengiriman_pabrik/pengiriman_pabrik_form_page.dart`
- Disederhanakan menjadi Formulir Fase 1:
  - Input: Pabrik PKS Tujuan, Nomor Plat Truk, Nama Sopir, Tanggal Kirim, Berat Kotor Muatan TBS (kg), Catatan Keberangkatan.
  - Menghilangkan input berat ditolak, potongan sortasi, dan harga jual per kg.
  - Panel samping memuat panduan Alur 2-Fase dengan indikator step aktif dan preview berat kotor terinput.
  - Tombol CTA: `"Catat Keberangkatan Truk (Fase 1)"`.
  - Modal Sukses: Menampilkan Kode Pengiriman resmi, rincian keberangkatan, status `BERANGKAT`, dan petunjuk penyelesaian Fase 2 saat armada kembali.

### E. Halaman Penyelesaian: `lib/features/pengiriman_pabrik/selesaikan_pengiriman_page.dart`
- Halaman baru khusus penyelesaian Fase 2:
  - Menampilkan panel ringkasan data keberangkatan Fase 1 (Pabrik, Plat Nomor, Sopir, Tgl Kirim, Berat Kotor) berstatus read-only.
  - Form input: Berat Ditolak (kg), Potongan Mutu/Sortasi Pabrik (%), Harga Jual per kg (Rp), dan Catatan Tambahan.
  - Kartu live preview kalkulasi real-time.
  - Tombol aksi: Batal dan `"Selesaikan & Simpan Nota Penjualan"`.

### F. Riwayat Pengiriman: `lib/features/pengiriman_pabrik/pengiriman_pabrik_list_page.dart`
- **Tab Switcher di Bagian Atas**:
  - **Tab 1: "Belum Selesai"**: Filter pengiriman dengan `status = 'berangkat'` dengan badge counter oranye.
  - **Tab 2: "Semua Riwayat"**: Menampilkan seluruh riwayat pengiriman.
- **Tampilan Card Khusus Status Berangkat**:
  - Badge status: `BERANGKAT` (warna oranye IBM Carbon).
  - Teks nilai penjualan: `"Menunggu Truk"` / `"Belum ada slip PKS"`.
  - Tombol aksi langsung pada card: **`"Selesaikan"`** (membuka halaman penyelesaian Fase 2) dan tombol **Batalkan**.
- **Detail Modal Pintar**:
  - Untuk item `berangkat`: Kolom fase 2 ditampilkan sebagai `"Belum diisi (Menunggu slip PKS)"` dengan tombol `"Selesaikan Pengiriman Sekarang"`.
  - Untuk item `selesai`: Menampilkan seluruh data timbangan dan nilai penjualan lengkap.

### G. Isolasi Ketat Dashboard & Export
- **Dashboard Analitik** (`v_pengiriman_harian`, `v_margin_harian`, `list_transaksi_terakhir.dart`):
  - View database secara inheren hanya memproses baris berstatus `'selesai'`.
  - List transaksi terakhir di dashboard menampilkan badge `'Berangkat'` dan label `'Menunggu Truk'` tanpa menyebabkan floating point error ataupun crash null pointer.
- **Export Dokumen Excel & PDF** (`laporan_pengiriman_excel_generator.dart`, `laporan_pengiriman_pdf_generator.dart`):
  - Filter wajib: `where((item) => item.isSelesai)` sehingga armada yang masih `berangkat` atau `dibatalkan` tidak tercampur ke dalam omzet dan rekapitulasi penjualan.

---

## 5. Hasil Pengujian & Verifikasi

### A. Pengujian Otomatis (Unit & Widget Tests)
Pengujian menyeluruh dijalankan pada seluruh suite test aplikasi:

```bash
flutter test
```

**Hasil**:
```
00:07 +50: All tests passed!
```
- **50 dari 50 test case berhasil lulus 100% (PASS)**, meliputi:
  1. `test/pengiriman_2_fase_test.dart`:
     - Model Serialization & `toInsertMap()` Fase 1 (status `berangkat`, kolom fase 2 null).
     - Live preview `SelesaikanFormState` (berat diterima, berat bersih, nilai potongan, total nilai jual).
     - Validasi edge cases (0% potongan, 0 ditolak).
     - Isolasi export Excel & PDF hanya mengikutsertakan pengiriman berstatus `selesai`.
  2. `test/pengiriman_pabrik_test.dart`:
     - Kalkulasi resmi dan serialisasi model dengan Decimal.
  3. `test/dashboard_lengkap_test.dart`:
     - Multi-modul dashboard, filter periode, kartu ringkasan, dan grafik fl_chart.
  4. `test/widget_test.dart`:
     - Seluruh modul transaksi multi-item, potongan per level berat, dan error handling.

### B. Analisis Kode Sumber (`flutter analyze`)
```bash
flutter analyze
```
**Hasil**:
```
Analyzing Aplikasi Transaksi TBS sawit...
No issues found! (ran in 5.9s)
```
- **0 Error, 0 Warning, 0 Lint issue**.

### C. Verifikasi Antarmuka Pengguna (Browser Verification)
Pengujian visual dilakukan pada build web aplikasi (`http://localhost:5050`):
1. **Formulir Fase 1**: Form input keberangkatan tampil proporsional dengan layout 2 kolom dan panel info alur 2-fase.
2. **Validasi Constraint Database**: Berhasil membuktikan bahwa payload insert Fase 1 mengirimkan nilai `null` pada kolom fase 2.
3. **Tab Switcher Riwayat**: Tab "Belum Selesai" dan "Semua Riwayat" berfungsi mulus dengan badge counter dinamis.
4. **Modal Detail**: Menampilkan status `BERANGKAT` dan rincian yang belum diisi dengan pesan informatif tanpa nilai kosong Rp 0 yang membingungkan.

---

## 6. Kesimpulan

Implementasi Tugas Bagian 15 telah berhasil menyelesaikan seluruh spesifikasi alur 2-fase pengiriman penjualan ke pabrik (FR-8.1 s/d FR-8.9) dengan integritas data tinggi, presisi moneter `Decimal`, serta desain antarmuka enterprise IBM Carbon yang komunikatif dan siap pakai.
