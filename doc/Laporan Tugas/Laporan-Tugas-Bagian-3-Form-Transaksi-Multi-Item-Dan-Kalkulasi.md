# Laporan Pelaksanaan Tugas — Bagian 3: Formulir Transaksi Baru & Kalkulasi Otomatis

Dokumen ini mencatat rekam jejak teknis implementasi tugas pada Bagian 3, yang mengacu pada FR-3.x (Input Transaksi Multi-Item, Kalkulasi Otomatis, dan Penomoran Kode Transaksi Otomatis) di dalam PRD.

---

## 1. Ringkasan Tugas

- **Instruksi Pengguna**:
  1. Halaman "Transaksi Baru": Memilih penjual menggunakan komponen picker dari Bagian 2, lalu menyusun daftar baris item transaksi.
  2. Setiap baris item: Dropdown master jenis buah (Tandan Besar/Kecil/Berondolan), input harga/kg (numeric), input berat kg (numeric), dan subtotal otomatis (read-only, harga × berat) yang update real-time saat diketik.
  3. Tombol "Tambah Jenis Buah" untuk menambah baris baru — maksimal 3 baris (satu per jenis buah), serta cegah pemilihan jenis buah yang sama dua kali dalam satu transaksi (validasi UI sesuai unique constraint DB).
  4. Tampilkan ringkasan total berat (kg) dan total harga (Rp) secara real-time di bagian bawah form.
  5. Validasi sebelum simpan: Berat $> 0$, Harga $\ge 0$, minimal 1 item.
  6. Saat simpan: Insert ke tabel `transaksi` lalu `transaksi_item`. Kode transaksi wajib digenerate otomatis oleh trigger database (`trg_generate_kode_transaksi`) — tidak digenerate di client.
  7. Tampilkan konfirmasi sukses dengan kode transaksi yang baru dibuat.
  8. Uji di browser: Buat 1 transaksi dengan 2 jenis buah berbeda, verifikasi subtotal dan total, ambil screenshot, dan laporkan.
- **Status**: Selesai & Terverifikasi (10/10 Tests Passed & Browser E2E Verified)

---

## 2. Arsitektur Kalkulasi & Single Source of Truth

### A. Anti Floating-Point Error (Client Live Preview)
- Menghindari tipe data `double` primitif untuk kalkulasi moneter.
- Input teks harga dan berat diparsing ke tipe `Decimal` dari package `decimal`.
- Formula Subtotal Baris:
  $$\text{Subtotal} = \text{hargaPerKg} \times \text{beratKg}$$
- Formula Total Transaksi:
  $$\text{Total Berat (kg)} = \sum \text{beratKg} \quad (\text{format: } 1.500,00 \text{ kg})$$
  $$\text{Total Pembayaran (Rp)} = \sum \text{subtotal} \quad (\text{format: } \text{Rp } 3.900.000)$$
- Listener reaktif dipasang langsung pada controller teks sehingga setiap kali pengguna mengetik satu digit, subtotal baris dan box total di bagian bawah langsung diperbarui secara instan.

### B. Database Single Source of Truth
- **Subtotal Stored Generated Column**: Nilai `subtotal` **tidak pernah dikirim oleh client**. Kolom `subtotal` pada tabel `public.transaksi_item` dihitung dan dikunci secara otomatis oleh PostgreSQL:
  ```sql
  subtotal numeric(14,2) generated always as (harga_per_kg * berat_kg) stored
  ```
- **Kode Transaksi Otomatis**: Client tidak pernah menyusun string kode transaksi. Database trigger `trg_generate_kode_transaksi` mengeksekusi penomoran urut harian:
  ```sql
  new.kode_transaksi := 'TRX-' || tanggal_str || '-' || lpad(next_seq::text, 4, '0');
  ```
- **Total Transaksi Teragregasi**: Dibaca langsung melalui view database `public.v_transaksi_ringkasan`.

---

## 3. Berkas yang Ditambahkan (NEW)

### A. Repositories
- **[lib/features/transaksi/jenis_buah_repository.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/jenis_buah_repository.dart)**:
  - Membaca data master jenis buah dari tabel `public.jenis_buah`.
  - Menyediakan fallback data bawaan ('TB' Tandan Besar, 'TK' Tandan Kecil, 'BR' Berondolan) untuk kehandalan mode offline.
- **[lib/features/transaksi/transaksi_repository.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/transaksi_repository.dart)**:
  - `createTransaksi()`:
    1. Menyimpan header ke tabel `transaksi` tanpa menyertakan kolom `kode_transaksi`.
    2. Menangkap `id` dan `kode_transaksi` resmi yang diproduksi oleh trigger database.
    3. Menyimpan multi-item secara *batch* ke `transaksi_item`.
    4. Mengambil ringkasan data dari view `v_transaksi_ringkasan`.

### B. State Management & Form Controller
- **[lib/features/transaksi/transaksi_form_state.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/transaksi_form_state.dart)**:
  - `TransaksiItemRowState`: Menyimpan state baris item buah, controller harga & berat, serta getter subtotal `Decimal`.
  - `TransaksiFormState`: Menyimpan penjual terpilih, tanggal transaksi, daftar baris item, status penyimpanan, getter total berat & harga, serta validasi batas 3 baris (`canAddRow`) dan pencegahan duplikasi jenis buah (`hasDuplicateFruit`).
- **[lib/features/transaksi/transaksi_form_controller.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/transaksi_form_controller.dart)**:
  - Notifier Riverpod yang memasang listener reaktif pada input harga dan berat.
  - Mengelola penambahan baris baru (maksimal 3), penghapusan baris, pengubahan jenis buah, reset form, dan proses submit transaksi.

### C. Antarmuka Formulir Transaksi
- **[lib/features/transaksi/transaksi_form_page.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/transaksi/transaksi_form_page.dart)**:
  - **Seksi 1 (Penjual & Tanggal)**: Mengintegrasikan `PenjualPicker` (dengan pencarian dan fitur inline add penjual) serta date picker localized Indonesia.
  - **Seksi 2 (Daftar Baris Item Buah)**:
    - Dropdown jenis buah yang menyaring opsi yang sudah dipilih pada baris lain (anti-duplikasi).
    - Input harga per kg (dengan prefix 'Rp ') dan berat timbangan (dengan suffix 'kg').
    - Badge readonly subtotal otomatis yang ter-update secara real-time.
    - Tombol `+ Tambah Jenis Buah` (otomatis nonaktif saat mencapai 3 baris).
  - **Seksi 3 (Catatan Transaksi)**: Input catatan opsional (misal: nomor plat armada).
  - **Seksi 4 (Sticky Summary Box)**: Kotak ringkasan total berat (kg) dan total pembayaran (Rp) beraksen tebal IBM Blue, serta tombol submit `Simpan Transaksi`.
  - **Dialog Konfirmasi Sukses**: Menampilkan centang sukses, kode resmi dari database (`TRX-YYYYMMDD-XXXX`), rincian penjual & total, dan tombol untuk memulai transaksi baru (mereset form).

---

## 4. Berkas yang Diubah (MODIFIED)

1. **[lib/core/widgets/main_layout_page.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/core/widgets/main_layout_page.dart)**:
   - Menambahkan menu navigasi "Transaksi Baru" pada sidebar desktop dan bottom bar mobile.
2. **[lib/main.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/main.dart)**:
   - Menambahkan inisialisasi `await initializeDateFormatting('id_ID', null)` untuk memastikan pemformatan tanggal localized Indonesia berjalan stabil di lingkungan Flutter Web.
3. **[test/widget_test.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/test/widget_test.dart)**:
   - Menambahkan unit test kalkulasi multi-item: memastikan perkalian dan penjumlahan `Decimal` menghasilkan nilai eksak tanpa pembulatan IEEE floating-point.
   - Menambahkan unit test validasi batas maksimal 3 baris dan deteksi duplikasi jenis buah.

---

## 5. Hasil Verifikasi & Pengujian Browser

### A. Pengujian Otomatis
- **`flutter analyze`**: **0 issues found** (kode bersih dan mematuhi aturan linting Flutter).
- **`flutter test`**: **10 dari 10 tes lolos (100% Passed)**.

### B. Pengujian End-to-End di Web Browser
Pengujian transaksi nyata dilakukan menggunakan subagent browser pada Google Chrome:
1. **Pilih Penjual**: Memilih *Haji Sukirman (Koperasi Sawit Makmur)* dari dropdown `PenjualPicker`.
2. **Input Item 1**:
   - Jenis Buah: **Tandan Besar (TB)**
   - Harga per kg: `2500`
   - Berat: `1000`
   - Subtotal otomatis terhitung: **`Rp 2.500.000`**
3. **Tambah Baris Baru (+ Tambah Jenis Buah)**:
   - Baris kedua muncul tanpa opsi duplikasi Tandan Besar.
4. **Input Item 2**:
   - Jenis Buah: **Berondolan (BR)**
   - Harga per kg: `2800`
   - Berat: `500`
   - Subtotal otomatis terhitung: **`Rp 1.400.000`**
5. **Verifikasi Ringkasan Total Real-Time**:
   - **TOTAL BERAT TBS**: **`1.500,00 kg`**
   - **TOTAL PEMBAYARAN**: **`Rp 3.900.000`**
6. **Simpan Transaksi**:
   - Menekan tombol **Simpan Transaksi**.
   - Muncul dialog modal sukses yang menampilkan kode resmi otomatis dari trigger database: **`TRX-20260904-0001`**.

### Dokumentasi Tangkapan Layar (Screenshots)

| Formulir Transaksi Awal | Formulir Terisi & Kalkulasi Real-Time |
| :---: | :---: |
| ![Form Awal](file:///C:/Users/lenov/.gemini/antigravity-ide/brain/1dade70d-b696-49f3-8ad3-f44f94891125/transaksi_baru_initial_1788523190559.png) | ![Form Terisi](file:///C:/Users/lenov/.gemini/antigravity-ide/brain/1dade70d-b696-49f3-8ad3-f44f94891125/transaksi_baru_filled_1788523466129.png) |

| Dialog Konfirmasi Sukses & Kode Transaksi Database |
| :---: |
| ![Sukses Transaksi](file:///C:/Users/lenov/.gemini/antigravity-ide/brain/1dade70d-b696-49f3-8ad3-f44f94891125/transaksi_baru_success_1788523663801.png) |
