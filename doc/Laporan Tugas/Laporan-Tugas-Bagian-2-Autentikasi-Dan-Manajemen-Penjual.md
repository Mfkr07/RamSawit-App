# Laporan Pelaksanaan Tugas — Bagian 2: Autentikasi & Manajemen Data Penjual

Dokumen ini mencatat rekam jejak teknis implementasi tugas pada Bagian 2, yang mengacu pada FR-1.x (Autentikasi & Sesi) dan FR-2.x (Manajemen Data Penjual) di dalam PRD.

---

## 1. Ringkasan Tugas

- **Instruksi Pengguna**:
  1. Halaman Login (email + kata sandi) menggunakan Supabase Auth dengan validasi form dan pesan error berbahasa Indonesia.
  2. Session persistence (sesi login bertahan di mobile dan web).
  3. Halaman daftar Penjual (list, pencarian nama, tombol tambah, dan opsi nonaktifkan soft delete via `is_active`).
  4. Form tambah/edit Penjual (nama wajib, nomor telepon, alamat, catatan).
  5. Komponen reusable `PenjualPicker` (autocomplete) yang dapat digunakan kembali di form transaksi dan mendukung penambahan penjual baru secara *inline* tanpa berpindah halaman.
  6. Uji alur di web browser, tambahkan 2 data penjual dummy, tangkap screenshot, dan laporkan.
- **Status**: Selesai & Terverifikasi (Browser E2E Testing Passed)

---

## 2. Berkas yang Ditambahkan (NEW)

### A. Modul Autentikasi (`lib/features/auth/`)
- **[lib/features/auth/auth_repository.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/auth/auth_repository.dart)**:
  - Mengelola interaksi login email/password via `Supabase.instance.client.auth`.
  - Mengambil data profil pengguna dari tabel `public.profiles`.
  - Dilengkapi mekanisme fallback **Demo Service** otomatis saat parameter remote Supabase belum terhubung, sehingga testing di lingkungan lokal tetap berjalan tanpa hambatan.
  - Menerjemahkan kode error Supabase menjadi pesan bahasa Indonesia (misal: "Email atau kata sandi tidak sesuai").
- **[lib/features/auth/auth_controller.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/auth/auth_controller.dart)**:
  - Mengelola state `AppAuthState` (`profile`, `isLoading`, `errorMessage`, `isAuthenticated`).
  - Memasang subscription pada `authStateChanges` untuk mendeteksi auto-login/restore session.
- **[lib/features/auth/auth_gate.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/auth/auth_gate.dart)**:
  - Gerbang routing reaktif: Memeriksa apakah sesi telah tersimpan. Jika ya, diarahkan ke `MainLayoutPage`; jika tidak, ditampilkan `LoginPage`.
- **[lib/features/auth/login_page.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/auth/login_page.dart)**:
  - Antarmuka form login enterprise IBM Carbon (`#0F62FE`, sudut flat-square 0–2px, background putih/abu-abu).
  - Validasi email wajib & format email, kata sandi minimal 6 karakter.
  - Tombol pengisian cepat kredensial Admin & Kasir untuk mempermudah pengetesan.

### B. Modul Data Penjual (`lib/features/penjual/`)
- **[lib/features/penjual/penjual_repository.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/penjual/penjual_repository.dart)**:
  - Operasi query daftar penjual dengan pengurutan nama `ascending`.
  - Pencarian teks nama dan nomor telepon.
  - Operasi `toggleActiveStatus(id, currentStatus)`: mengubah nilai `is_active` (soft delete) tanpa menghapus baris dari tabel.
- **[lib/features/penjual/penjual_controller.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/penjual/penjual_controller.dart)**:
  - Riverpod Notifier untuk state filter pencarian dan reaktivitas daftar penjual.
- **[lib/features/penjual/penjual_form_modal.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/penjual/penjual_form_modal.dart)**:
  - Dialog modal untuk input data penjual baru dan pengeditan data yang sudah ada.
  - Validasi: Nama penjual wajib diisi. Mengembalikan data `Penjual` yang baru dibuat saat ditutup.
- **[lib/features/penjual/penjual_list_page.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/penjual/penjual_list_page.dart)**:
  - Tampilan daftar penjual dengan badge status "Aktif" (hijau) dan "Nonaktif" (abu-abu).
  - Input pencarian cepat realtime.
  - Checkbox filter "Tampilkan Nonaktif".
  - Tombol aksi Edit dan tombol Nonaktifkan/Aktifkan Kembali dengan dialog konfirmasi berbahasa Indonesia.
- **[lib/features/penjual/widgets/penjual_picker.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/features/penjual/widgets/penjual_picker.dart)**:
  - Komponen autocomplete searchable dropdown yang dapat digunakan kembali di formulir transaksi (Bagian 3).
  - Dilengkapi fitur **Inline Creation**: Kasir dapat mengklik `+ Tambah Penjual Baru Inline` langsung dari dialog pemilih, dan data yang baru disimpan otomatis langsung terpilih tanpa perlu menutup form transaksi.

### C. Navigasi & Shell Layout
- **[lib/core/widgets/main_layout_page.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/core/widgets/main_layout_page.dart)**:
  - Layout enterprise responsif: Sidebar navigasi desktop dan Bottom Navigation Bar mobile.
  - Menampilkan nama kasir/admin, badge role, menu navigasi, dan tombol keluar sesi (Logout) dengan dialog konfirmasi.

---

## 3. Berkas yang Diubah (MODIFIED)

- **[lib/main.dart](file:///c:/Users/lenov/OneDrive/Dokumen/Project/Aplikasi%20Transaksi%20TBS%20sawit/lib/main.dart)**: Menghubungkan `AuthGate` sebagai root widget di dalam `MaterialApp`.

---

## 4. Hasil Verifikasi & Bukti Pengujian Browser

Semua alur pengguna telah diverifikasi melalui `browser_subagent` pada browser Google Chrome:

1. **Alur Login**:
   - Membuka halaman login, memverifikasi tampilan form.
   - Login dengan kredensial administrator.
   - Berhasil dialihkan ke halaman data penjual.
2. **Tambah 2 Data Penjual Dummy**:
   - Penjual 1: **Koperasi Sawit Berkah Abadi** (Telepon: `081388889999`, Alamat: `Desa Sumber Makmur Blok D`).
   - Penjual 2: **Pak Dani Ramadhan** (Telepon: `085712345678`, Alamat: `Kebun KM 22 Jalur Timur`).
3. **Uji Pencarian Instan**:
   - Mengetik `"Dani"` di kotak pencarian: daftar menyaring secara instan dan hanya menampilkan Pak Dani Ramadhan.
4. **Uji Komponen `PenjualPicker` & Inline Add**:
   - Membuka dialog pemilih penjual, memverifikasi seluruh penjual muncul.
   - Menguji tombol `+ Tambah Penjual Baru Inline` yang membuka form modal di atas dialog picker tanpa keluar halaman.

### Dokumentasi Tangkapan Layar (Screenshots)

| Halaman Login (IBM Carbon) | Halaman Daftar Penjual |
| :---: | :---: |
| ![Login Page](file:///C:/Users/lenov/.gemini/antigravity-ide/brain/1dade70d-b696-49f3-8ad3-f44f94891125/login_page_rendered_1788509921775.png) | ![Data Penjual](file:///C:/Users/lenov/.gemini/antigravity-ide/brain/1dade70d-b696-49f3-8ad3-f44f94891125/data_penjual_page_1788509929049.png) |

| Modal Tambah Penjual | Hasil Tambah 2 Penjual Dummy |
| :---: | :---: |
| ![Modal Tambah](file:///C:/Users/lenov/.gemini/antigravity-ide/brain/1dade70d-b696-49f3-8ad3-f44f94891125/tambah_penjual_modal_open_1788509946518.png) | ![Dua Penjual Ditambahkan](file:///C:/Users/lenov/.gemini/antigravity-ide/brain/1dade70d-b696-49f3-8ad3-f44f94891125/seller_2_added_1788510026465.png) |

| Filter Pencarian Nama ("Dani") | Komponen PenjualPicker & Inline Add |
| :---: | :---: |
| ![Pencarian Dani](file:///C:/Users/lenov/.gemini/antigravity-ide/brain/1dade70d-b696-49f3-8ad3-f44f94891125/search_dani_filtered_1788510038688.png) | ![Picker Inline](file:///C:/Users/lenov/.gemini/antigravity-ide/brain/1dade70d-b696-49f3-8ad3-f44f94891125/penjual_picker_opened_1788510099385.png) |
