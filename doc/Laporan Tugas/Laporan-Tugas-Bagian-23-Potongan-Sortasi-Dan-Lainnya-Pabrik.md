# LAPORAN IMPLEMENTASI TUGAS: BAGIAN 23
## Modul Potongan Sortasi (Rp/kg) & Potongan Biaya Lainnya pada Pengiriman Pabrik

---

### 1. Ringkasan Eksekutif
Tugas Bagian 23 menyempurnakan kalkulasi penjualan TBS ke pabrik (PKS) dengan mengakomodasi dua jenis potongan faktur pabrik riil: potongan sortasi berbasis satuan berat (Rp/kg) dan potongan tetap lainnya (Rp) seperti denda tangkai panjang atau sampah.

### 2. Skema Database
- **Perluasan Kolom pada `public.pengiriman_pabrik`**:
  - `potongan_lainnya_rp numeric(12,2) default 0.00`
  - `potongan_sortasi_rp_per_kg numeric(10,2) default 0.00`
  - `total_potongan_sortasi_rp numeric(14,2) generated always as (round(berat_bersih_kg * potongan_sortasi_rp_per_kg, 2)) stored`
  - `total_nilai_jual numeric(14,2)` diperbarui formulanya menjadi:
    `((berat_bersih_kg * harga_jual_per_kg) - total_potongan_sortasi_rp - potongan_lainnya_rp)`

### 3. Implementasi Dart & Flutter
- **Model**: `PengirimanPabrik` diperkaya dengan field-field potongan baru.
- **Controller & UI**: Form Fase 2 Pengiriman Pabrik dilengkapi input interaktif untuk Potongan Sortasi (Rp/kg) dan Potongan Lainnya (Rp).
- **Fitur Ekspor**: Kolom baru disertakan dalam ekspor PDF dan Excel Laporan Penjualan Pabrik.

### 4. Hasil Verifikasi
- Pengujian komprehensif pada `test/bagian23_potongan_lainnya_sortasi_test.dart` dinyatakan **LULUS (PASS)**.
