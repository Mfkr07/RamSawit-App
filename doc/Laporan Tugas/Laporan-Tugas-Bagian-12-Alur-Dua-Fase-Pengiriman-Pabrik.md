# Laporan Tugas Bagian 12: Alur Dua Fase Pengiriman Pabrik (Keberangkatan & Penyelesaian)

**Tanggal Pelaksanaan**: 7 September 2026  
**Branch Git**: `fitur/penjualan-pabrik`  
**Status**: **SELESAI (100% PASS)**  
**Target Platform**: Android, iOS, Web (Responsive Codebase)  
**Referensi**: [PRD.md §7.8 (FR-8.2, FR-8.3, FR-8.6)](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/PRD-Aplikasi-Transaksi-Sawit.md#L124), [Database.md §8.2](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/doc/Database-Aplikasi-Transaksi-Sawit.md#L699), [AGENTS.md](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/AGENTS.md)

---

## 1. Ringkasan Eksekutif

Tugas Bagian 12 merupakan penyempurnaan alur operasional pada modul Penjualan ke Pabrik Kelapa Sawit (PKS) dengan menerapkan **Siklus Pencatatan Dua Fase (Two-Phase Dispatch Cycle)**:
1. **Fase 1 — Keberangkatan Truk (Status: `berangkat`)**
2. **Fase 2 — Penyelesaian Hasil Timbangan Pabrik (Status: `selesai`)**

### Latar Belakang & Kebutuhan Lapangan
Dalam operasional riil usaha pengumpulan TBS kelapa sawit:
- Saat armada truk berangkat dari RAM timbangan pedagang/pengepul, operator hanya mengetahui **identitas pabrik tujuan, nomor polisi armada, nama sopir, tanggal kirim, dan berat kotor awal**.
- Parameter penerimaan resmi dari pabrik seperti **berat buah ditolak (retur), persentase potongan grading mutu (sampah/tangkai panjang), dan harga beli resmi per kg** baru diketahui setelah truk tiba di pabrik, ditimbang, dan surat timbang pabrik dibawa kembali oleh sopir.
- Oleh karena itu, pengiriman tidak boleh dipaksa langsung berstatus `selesai` dengan menginput angka dummy atau perkiraan.

---

## 2. Rincian Alur Dua Fase

```
┌────────────────────────────────────────────────────────┐
│               FASE 1: KEBERANGKATAN                    │
│   (Diisi saat truk berangkat dari RAM/timbangan)       │
│                                                        │
│  - Pilih Pabrik Tujuan                                 │
│  - Plat Nomor Truk                                     │
│  - Nama Sopir                                          │
│  - Tanggal Kirim (default: hari ini)                   │
│  - Berat Kotor (kg) (wajib > 0)                        │
│                                                        │
│  => Disimpan dengan status: 'berangkat'                │
│  => Kode Pengiriman Otomatis: KRM-YYYYMMDD-XXXX        │
└──────────────────────────┬─────────────────────────────┘
                           │
                           │  Truk menuju PKS & ditimbang
                           │  Sopir kembali membawa nota timbang PKS
                           ▼
┌────────────────────────────────────────────────────────┐
│               FASE 2: PENYELESAIAN                     │
│   (Diisi setelah truk kembali membawa tiket timbang)   │
│                                                        │
│  - Berat Ditolak (kg) (opsional, default 0)            │
│  - Potongan Mutu Pabrik (%) (opsional, default 0%)     │
│  - Harga Jual Pabrik / kg (wajib diisi)                │
│                                                        │
│  Kalkulasi Otomatis:                                   │
│  * Berat Diterima = Berat Kotor - Berat Ditolak        │
│  * Berat Bersih   = Berat Diterima x (1 - Potongan%)   │
│  * Total Nilai    = Berat Bersih x Harga Jual/kg       │
│                                                        │
│  => Status diperbarui menjadi: 'selesai'               │
└────────────────────────────────────────────────────────┘
```

---

## 3. Spesifikasi Perubahan Database (Database.md §8.2)

Untuk mendukung status `berangkat` dan kolom yang baru terisi di Fase 2, skema tabel `pengiriman_pabrik` disesuaikan:

```sql
-- 1. Menjadikan kolom fase-2 nullable (boleh kosong saat status 'berangkat')
alter table public.pengiriman_pabrik
    alter column berat_ditolak_kg drop not null,
    alter column berat_ditolak_kg drop default,
    alter column persentase_potongan_pabrik drop not null,
    alter column persentase_potongan_pabrik drop default,
    alter column harga_jual_per_kg drop not null;

-- 2. Memperbarui check constraint status pengiriman
alter table public.pengiriman_pabrik
    drop constraint pengiriman_pabrik_status_check;

alter table public.pengiriman_pabrik
    add constraint pengiriman_pabrik_status_check
    check (status in ('berangkat', 'selesai', 'dibatalkan'));

-- 3. Menetapkan status default saat insert awal menjadi 'berangkat'
alter table public.pengiriman_pabrik
    alter column status set default 'berangkat';
```

### Karakteristik Kolom Generated
Kolom turunan database (`berat_diterima_kg`, `berat_bersih_kg`, `nilai_potongan_rp`, `total_nilai_jual`) secara otomatis bernilai `null` selama input pendukung fase 2 belum lengkap, dan otomatis terisi saat status dinaikkan menjadi `selesai`.

---

## 4. Rincian Implementasi Client Flutter

### A. Model Data & Repositori
- **`lib/models/pengiriman_pabrik.dart`**:
  - Kolom `beratDitolakKg`, `persentasePotonganPabrik`, `hargaJualPerKg`, `beratDiterimaKg`, `beratBersihKg`, dan `totalNilaiJual` dijadikan *nullable* (`Decimal?`).
  - Helper getter `isBerangkat`, `isSelesai`, `isDibatalkan`.
- **`lib/features/pengiriman_pabrik/pengiriman_pabrik_repository.dart`**:
  - Method `createPengirimanFase1()`: Menyimpan draft awal keberangkatan.
  - Method `selesaikanPengirimanFase2()`: Mengisi data hasil timbang pabrik dan mengubah status menjadi `selesai`.
  - Filter query memisahkan pengiriman berstatus `berangkat` untuk tab khusus.

### B. Antarmuka Pengguna (UI)
1. **Daftar Terpisah "Pengiriman Belum Selesai" (FR-8.6)**:
   - Pada halaman riwayat pengiriman, disediakan tab/filter khusus armada yang sedang `berangkat`.
   - Menampilkan indikator peringatan visual agar kasir/operator tidak melupakan truk yang belum diselesaikan nota timbangnya.
2. **Tombol Aksi "Selesaikan Pengiriman"**:
   - Tiap item berstatus `berangkat` memiliki tombol CTA langsung untuk membuka modal/form penyelesaian Fase 2.
3. **Validasi & Proteksi Integritas**:
   - Berat ditolak divalidasi tidak boleh melebihi berat kotor.
   - Harga jual wajib $> 0$ untuk menyelesaikan fase 2.

---

## 5. Matriks Kriteria Penerimaan (Acceptance Criteria Bagian 12)

| ID Kriteria | Uraian Kriteria Penerimaan | Status | Bukti Implementasi & Verifikasi |
|---|---|:---:|---|
| **AC-12.1** | Dukungan status `berangkat` pada skema database dan model Dart | **PASS** | Constraint `pengiriman_pabrik_status_check` & model `PengirimanPabrik` |
| **AC-12.2** | Kolom fase 2 (`berat_ditolak`, `potongan`, `harga_jual`) bersifat opsional/nullable di Fase 1 | **PASS** | Skrip DDL `Database.md §8.2` dan serializer Dart |
| **AC-12.3** | Fase 1 dapat disimpan hanya dengan input armada dan berat kotor | **PASS** | Validasi form keberangkatan berhasil simpan status `berangkat` |
| **AC-12.4** | Fase 2 menghitung otomatis berat diterima, berat bersih, dan total jual secara presisi | **PASS** | Kalkulasi berbasis `Decimal` aktif saat input Fase 2 disubmit |
| **AC-12.5** | Tersedia tab/filter pemantau armada yang belum kembali (Belum Selesai) | **PASS** | Riwayat pengiriman menampilkan daftar status `berangkat` terpisah |

---

## 6. Kesimpulan

Implementasi alur dua fase pada Bagian 12 berhasil menyelaraskan sistem aplikasi dengan alur nyata di perkebunan sawit. Data keberangkatan terdokumentasi rapi tanpa risiko terlupa, dan akurasi finansial terlindungi karena kalkulasi final hanya dieksekusi saat surat timbang resmi PKS telah diterima.
