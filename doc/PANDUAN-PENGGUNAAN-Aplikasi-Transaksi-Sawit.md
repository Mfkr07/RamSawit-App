# BUKU PANDUAN PENGGUNA (USER MANUAL) — RAMSAWIT
## Aplikasi Kasir & Manajemen Loading Ramp Transaksi Buah Kelapa Sawit (TBS)

> **Untuk Pemilik Pengepul (Admin), Kasir Timbangan, Mandor Lapangan, dan Operator Ramp**  
> *Versi Aplikasi: 2.5.4 (Build 9) | Bahasa: Indonesia | Multi-Platform: Windows Desktop & Android Mobile*

---

## DAFTAR ISI

1. [Mengenal Aplikasi RamSawit](#1-mengenal-aplikasi-ramsawit)
2. [Setup Awal Organisasi & Database (BYOD)](#2-setup-awal-organisasi--database-byod)
3. [Perbedaan Hak Akses: Pemilik (Admin) vs Kasir](#3-perbedaan-hak-akses-pemilik-admin-vs-kasir)
4. [Masuk Akun (Login) & Keamanan Sesi 24 Jam](#4-masuk-akun-login--keamanan-24-jam)
5. [Panduan Mode Offline & Status Sinkronisasi](#5-panduan-mode-offline--status-sinkronisasi)
6. [Panduan Pembelian TBS dari Petani](#6-panduan-pembelian-tbs-dari-petani)
   - 6.1 Mendaftarkan Petani Baru & Pencarian Cepat
   - 6.2 Mengisi Form Timbangan Multi-Item (TB, TK, BR)
   - 6.3 Mengatur Potongan Tangkai / Sampah (%)
   - 6.4 Memilih Metode Pembayaran: Tunai vs Non Tunai (Transfer)
   - 6.5 Cetak Struk Nota & Membatalkan Transaksi (Void)
7. [Panduan Pengiriman Buah ke Pabrik (PKS - 2 Fase)](#7-panduan-pengiriman-buah-ke-pabrik-pks---2-fase)
   - 7.1 Fase 1: Keberangkatan Truk dari Ramp
   - 7.2 Fase 2: Rekonsiliasi Slip PKS (Susut Buah & Sortasi)
   - 7.3 Memantau Armada dalam Perjalanan
8. [Panduan Pencatatan Pengeluaran Biaya Operasional](#8-panduan-pencatatan-pengeluaran-biaya-operasional)
9. [Panduan Manajemen Saldo Kas Modal Kasir (Admin Only)](#9-panduan-manajemen-saldo-kas-modal-kasir-admin-only)
10. [Membaca Dashboard & Analitik Usaha Eksekutif](#10-membaca-dashboard--analitik-usaha-eksekutif)
11. [Konsultasi Bisnis via AI Analytics Advisor](#11-konsultasi-bisnis-via-ai-analytics-advisor)
12. [Mencetak & Mengekspor Laporan (Excel & PDF)](#12-mencetak--mengekspor-laporan-excel--pdf)
13. [Pembaruan Aplikasi Otomatis (Auto-Update)](#13-pembaruan-aplikasi-otomatis-auto-update)
14. [Tombol Pintas Keyboard (Windows Desktop)](#14-tombol-pintas-keyboard-windows-desktop)
15. [Tanya Jawab & Solusi Kendala (FAQ)](#15-tanya-jawab--solusi-kendala-faq)

---

## 1. Mengenal Aplikasi RamSawit

**RamSawit** adalah sistem kasir dan pembukuan terintegrasi yang dirancang khusus untuk operasional **Loading Ramp / Pengepul Kelapa Sawit (TBS)**. Aplikasi ini dirancang untuk bekerja secara mulus di dua perangkat utama:
- **Komputer Kasir Windows (`RamSawit.exe`):** Untuk kasir di pos timbangan jembatan timbang ramp.
- **HP / Tablet Android (`RamSawit.apk`):** Untuk mandor lapangan, pengepul keliling, atau pemilik usaha yang memantau dari mana saja.

### Keunggulan Utama RamSawit v2.5.4:
- **Tahan Tanpa Internet (Offline-First):** Tetap bisa menimbang dan mencetak nota meskipun sinyal internet di kebun mati total. Data otomatis tersinkron saat internet tersambung kembali.
- **Kalkulasi Presisi Tinggi (Bebas Salah Hitung):** Menghitung potongan sampah, berat bersih, rupiah, dan susut timbangan menggunakan presisi desimal matematika mutlak (anti floating-point error).
- **Pemisahan Kas Tunai & Bank Transfer:** Pembayaran non-tunai (transfer rekening) tidak akan mengacaukan uang fisik di laci kas timbangan kasir.
- **Audit Pengiriman Pabrik 2-Fase:** Mengaudit selisih tonase antara jembatan timbang ramp dengan timbangan pabrik kelapa sawit (PKS) untuk mendeteksi penyusutan di perjalanan.
- **Asisten Bisnis Cerdas (AI Advisor):** Anda dapat menanyakan langsung kondisi usaha Anda ("Berapa laba bersih minggu ini?", "Pabrik mana yang paling menguntungkan?").

---

## 2. Setup Awal Organisasi & Database (BYOD)

RamSawit menggunakan arsitektur **Bring Your Own Database (BYOD)**. Data transaksi Anda 100% tersimpan di akun database cloud Supabase milik Anda sendiri.

### Langkah Setup Sekali di Awal:
1. Buka [https://supabase.com](https://supabase.com) dan buat project baru (gratis).
2. Buka menu **SQL Editor**, buka berkas `supabase/master_tenant_schema.sql`, salin seluruh kodenya, lalu klik tombol **Run**.
3. Di dashboard Supabase, buka menu **Project Settings -> API**, salin:
   - **Project URL** (contoh: `https://xxxx.supabase.co`)
   - **anon public key** (`eyJh...`)
4. Buka aplikasi RamSawit di Windows atau Android.
5. Pada layar Login, klik tautan tombol **"Setup Organisasi & Database"**.
6. Masukkan Nama Ramp Anda beserta Project URL dan Anon Key tadi, lalu klik **Simpan & Hubungkan**.
7. Aplikasi langsung terhubung ke database bisnis Anda!

---

## 3. Perbedaan Hak Akses: Pemilik (Admin) vs Kasir

Untuk melindungi kerahasiaan keuntungan usaha dan mencegah manipulasi, aplikasi membagi hak akses pengguna:

| Menu & Fitur | Pemilik Usaha (Admin) | Kasir Timbangan | Penjelasan untuk Kasir |
|---|:---:|:---:|---|
| **Input Pembelian Petani** | Ya | Ya | Kasir leluasa menimbang dan mencetak nota. |
| **Pendaftaran Petani Baru** | Ya | Ya | Bisa tambah petani baru langsung di form penimbangan. |
| **Batalkan Nota (Void)** | Ya | Ya (Wajib Alasan) | Kasir wajib menuliskan kenapa nota dibatalkan. |
| **Pengiriman Buah ke Pabrik** | Ya | Ya | Kasir menginput truk berangkat & hasil slip PKS. |
| **Pencatatan Biaya Operasional** | Ya | Ya | Kasir bisa mencatat beli solar, konsumsi, dan biaya harian. |
| **Kelola Kategori Pengeluaran** | Ya | **Disembunyikan** | Hanya pemilik yang boleh menambah kategori biaya. |
| **Saldo & Kas Modal Timbangan** | Ya | **Disembunyikan** | Sisa uang modal dan rekap mutasi hanya untuk pemilik. |
| **Tab "Margin Keuntungan"** | Ya | **Disembunyikan** | Laba bersih dan keuntungan usaha disembunyikan. |
| **Grafik Tren Finansial** | Ya | **Disembunyikan** | Kasir hanya melihat kartu tonase dan jumlah transaksi. |
| **Filter Periode Dashboard** | Bebas (s/d 1 Tahun) | **Maksimal 1 Bulan** | Kasir difokuskan pada operasional berjalan. |
| **Ekspor Laporan Pendapatan** | Ya | **Disembunyikan** | Rekapitulasi laba rugi hanya hak akses pemilik usaha. |
| **AI Analytics Advisor** | Ya | Ya | Konsultasi analisis data operasional ramp. |

---

## 4. Masuk Akun (Login) & Keamanan Sesi 24 Jam

### Cara Masuk ke Aplikasi:
1. Masukkan **Alamat Email** dan **Kata Sandi** yang telah didaftarkan.
2. Klik tombol biru bertuliskan **"Masuk ke Sistem"**.
3. Sistem otomatis mendeteksi apakah akun Anda adalah **Admin** atau **Kasir**.

### Aturan Keamanan Sesi 24 Jam:
- Demi keamanan uang kas dan integritas data ramp sawit, **sesi login dibatasi maksimal 24 jam berturut-turut**.
- Jika aplikasi sudah terbuka lebih dari 24 jam sejak waktu login terakhir, sistem secara otomatis melakukan **logout paksa** dan menampilkan pesan oranye:
  > *"Sesi login Anda telah berakhir demi keamanan (maksimal 24 jam). Silakan masuk kembali."*
- Cukup masukkan ulang kata sandi Anda untuk mulai bekerja kembali.

---

## 5. Panduan Mode Offline & Status Sinkronisasi

Aplikasi RamSawit dilengkapi komponen **Bilah Status Sinkronisasi (`SyncStatusBar`)** di bagian atas atau bawah layar:

1. **Hijau — "Tersinkron Penuh":**  
   Semua transaksi di komputer/HP Anda sudah terkirim aman ke database cloud.
2. **Biru Animasi — "Menyinkronkan [n] data...":**  
   Aplikasi sedang mengirim transaksi baru ke cloud di latar belakang.
3. **Oranye — "Mode Offline ([n] antrean)":**  
   Koneksi internet sedang terputus. Anda **tetap bisa bekerja menimbang seperti biasa**. Data tersimpan aman di memori lokal laptop/HP.
4. **Merah — "Gagal Sinkron (Coba Lagi)":**  
   Terjadi gangguan jaringan saat pengiriman. Klik tombol **"Coba Lagi"** untuk mengulang pengiriman.

---

## 6. Panduan Pembelian TBS dari Petani

### 6.1 Mendaftarkan Petani Baru & Pencarian Cepat
1. Buka menu **"Transaksi Baru"** (`Ctrl+N` di desktop).
2. Di kolom Penjual, ketik nama petani. Sistem menggunakan pencarian pintar (*Fuzzy Trigram Search*).
3. Jika petani belum terdaftar, klik tombol **"+" (Tambah Penjual)** di samping kolom nama.
4. Masukkan Nama Lengkap, Nomor HP/WhatsApp, dan Alamat Desa, lalu klik **Simpan**. Petani langsung terpilih.

### 6.2 Mengisi Form Timbangan Multi-Item (TB, TK, BR)
Satu mobil/pikap petani bisa membawa campuran buah:
1. **Baris 1:**
   - Pilih Jenis Buah: **Tandan Besar (TB)**, **Tandan Kecil (TK)**, atau **Berondolan (BR)**.
   - Masukkan **Berat Kotor (kg)** dari display timbangan.
   - Masukkan **Harga per Kg (Rp)** yang disepakati hari ini.
   - Masukkan **Potongan (%)** sampah/tangkai.
2. Jika ada buah lain (misal campur Berondolan), klik tombol **"+ Tambah Jenis Buah"** (maksimal 3 jenis).
3. Sistem otomatis menghitung total berat bersih dan total uang yang harus dibayarkan.

### 6.3 Mengatur Potongan Tangkai / Sampah (%)
- Potongan persen berlaku per baris buah (misal Tandan Besar 3%, Berondolan 0%).
- Rumus perhitungan sistem:
  $$\text{Berat Bersih} = \text{Berat Kotor} \times \left(1 - \frac{\text{Potongan \%}}{100}\right)$$
  $$\text{Subtotal} = \text{Berat Bersih} \times \text{Harga per kg}$$

### 6.4 Memilih Metode Pembayaran: Tunai vs Non Tunai (Transfer)
- **Tunai (Default):** Pilih ini jika petani dibayar langsung dengan uang kas fisik di laci timbangan. Nilai nota akan **mengurangi Sisa Saldo Kas Modal Kasir**.
- **Non Tunai (Transfer):** Pilih ini jika pemilik atau kasir membayar via transfer bank (BCA, Mandiri, BRI, dll). Nilai nota **TIDAK akan mengurangi saldo fisik laci kas kasir**, sehingga uang di laci kas tetap cocok saat dihitung fisik sore hari.

### 6.5 Cetak Struk Nota & Membatalkan Transaksi (Void)
- Klik tombol **"Simpan & Cetak Nota"**. Struk thermal langsung tercetak atau tampil di layar.
- **Jika Salah Input (Pembatalan/Void):**
  1. Buka menu **"Riwayat Transaksi"**.
  2. Klik nota yang bersangkutan, lalu klik tombol merah **"Batalkan Transaksi"**.
  3. Masukkan **Alasan Pembatalan** (wajib diisi, misal: *salah ketik berat kotor*).
  4. Status nota berubah menjadi **"Dibatalkan"**. Uang dan tonase ditarik kembali dari omzet harian.

---

## 7. Panduan Pengiriman Buah ke Pabrik (PKS - 2 Fase)

Proses penjualan buah ke Pabrik Kelapa Sawit (PKS) dibagi menjadi dua fase:

### 7.1 Fase 1: Keberangkatan Truk dari Ramp
1. Buka menu **"Pengiriman Pabrik"** -> Klik **"+ Kirim TBS ke Pabrik"**.
2. Pilih **Pabrik Tujuan (PKS)**, masukkan **Nomor Polisi Truk** (Plat Nomor), dan **Nama Sopir**.
3. Masukkan **Berat Dikirim (kg)** hasil timbangan sebelum truk berangkat.
4. Klik **Simpan**. Truk tercatat dengan status kuning: **"Dalam Perjalanan"** (`berangkat`).

### 7.2 Fase 2: Rekonsiliasi Slip PKS (Susut Buah & Sortasi)
Setelah truk selesai bongkar di pabrik dan sopir pulang membawa slip timbangan resmi PKS:
1. Buka menu **"Riwayat Pengiriman"** -> Buka tab **"Dalam Perjalanan"**.
2. Cari truk yang bersangkutan, lalu klik **"Input Hasil Pabrik"**.
3. Masukkan data persis sesuai slip pabrik:
   - **Berat Sampai (kg):** Timbangan kotor di pabrik.
   - **Berat Ditolak (kg):** Buah mentah yang dipulangkan pabrik (jika ada).
   - **Potongan Pabrik (%):** Potongan wajib kadar air/sampah dari pabrik.
   - **Harga Jual per kg (Rp):** Harga resmi PKS hari itu.
   - **Potongan Sortasi per kg & Potongan Lainnya (Rp):** Klaim penalti mutu jika ada.
4. Sistem otomatis mengaudit:
   - **Susut Buah (kg):** Selisih timbangan ramp sendiri dengan timbangan pabrik.
   - **Total Nilai Jual (Rp):** Uang bersih yang akan ditransfer pihak pabrik ke rekening ramp.
5. Klik **Konfirmasi Selesai**. Status berubah menjadi hijau: **"Selesai"**.

---

## 8. Panduan Pencatatan Pengeluaran Biaya Operasional

1. Buka menu **"Pengeluaran"** di sidebar/menu bawah.
2. Klik tombol **"+ Catat Pengeluaran"**.
3. Pilih **Kategori Biaya** (BBM/Transportasi, Gaji/Upah Harian, Perawatan Kendaraan, Konsumsi/Kantor, dll).
4. Masukkan **Nominal (Rp)** dan **Keterangan**.
5. Pilih **Metode Pembayaran (Tunai / Non Tunai)**.
6. Klik **Simpan**. Biaya harian otomatis terakumulasi untuk perhitungan Laba Bersih Admin.

---

## 9. Panduan Manajemen Saldo Kas Modal Kasir (Admin Only)

Modul ini memastikan uang modal kasir di lapangan selalu terpantau dan tidak mengalami defisit:

1. **Mencatat Tambahan Modal (Top Up):**
   - Saat pemilik menyerahkan uang modal kas (misal Rp 50.000.000 ke kasir), buka menu **"Saldo Modal"** -> Klik **"+ Top Up Saldo"**.
   - Masukkan nominal uang dan keterangan (misal: *Modal awal timbangan Senin pagi*).
2. **Membaca Sisa Saldo Kas:**
   - Kartu utama menampilkan **Sisa Saldo Kas Modal Aktif**.
   - Rumus otomatis:
     $$\text{Sisa Saldo} = \text{Total Top Up} - \text{Total Pembelian TUNAI}$$
3. **Linimasa Mutasi Harian:**
   - Memperlihatkan berapa uang tunai yang keluar untuk membayar petani per hari.
4. **Tab "Non Tunai":**
   - Memantau akumulasi transaksi yang dibayar via transfer bank tanpa memotong kas fisik laci.

---

## 10. Membaca Dashboard & Analitik Usaha Eksekutif

Dashboard RamSawit menyajikan visual data real-time:
- **Filter Periode Terpadu:** Pilih rentang **Hari Ini, 1 Minggu, 2 Minggu, 1 Bulan, 3 Bulan, 6 Bulan, 1 Tahun, atau Kustom Tanggal**.
- **Tab Pembelian:** Memantau total tonase kotor, bersih, potongan kg, rupiah pembelian, dan pie chart jenis buah.
- **Tab Penjualan Pabrik:** Memantau total tonase kirim, bersih PKS, susut perjalanan, dan nilai penjualan.
- **Tab Margin & Laba Bersih (Khusus Admin):**
  - **Margin Kotor:** $\text{Total Penjualan Pabrik} - \text{Total Pembelian Petani}$.
  - **Laba Bersih:** $\text{Margin Kotor} - \text{Total Biaya Operasional}$.
  - **Grafik Tren:** Garis pergerakan tonase dan uang beli vs jual sepanjang waktu.
  - **Filter Khusus "Bulan Ini":** Admin dapat memilih bulan dan tahun tertentu untuk melihat evaluasi bulan lalu.

---

## 11. Konsultasi Bisnis via AI Analytics Advisor

RamSawit v2.5.4 dilengkapi asisten analitik cerdas:
1. Buka menu **"AI Advisor"** di sidebar.
2. Anda dapat langsung mengklik tombol pertanyaan cepat:
   - *"Bagaimana evaluasi margin minggu ini?"*
   - *"Pabrik mana yang memberikan keuntungan tertinggi?"*
   - *"Apakah ada anomali susut buah pada pengiriman truk?"*
3. AI menganalisis data transaksi Anda secara aman (read-only) dan memberikan saran strategi dalam bahasa Indonesia.
4. Jika koneksi AI offline, sistem otomatis beralih ke mesin hitung deterministik internal.

---

## 12. Mencetak & Mengekspor Laporan (Excel & PDF)

1. Buka menu riwayat mana pun (Transaksi, Pengiriman, Pengeluaran, atau Saldo).
2. Pasang filter periode tanggal yang ingin dilaporkan.
3. Klik tombol **"Ekspor"** di pojok kanan atas:
   - **Excel (.xlsx):** Berkas spreadsheet rapi dengan formula jumlah otomatis, siap diedit atau dianalisis di Microsoft Excel.
   - **PDF (.pdf):** Dokumen cetak siap print ukuran A4 portrait lengkap dengan kop dan rincian per baris.
4. **Laporan Pendapatan (Khusus Admin):**
   - Pilih menu **"Laporan Pendapatan"**, pilih rentang 1 Tahun (kuartalan), 3 Bulan (bulanan), atau 1 Bulan (mingguan). Sekali klik, dokumen laba rugi ramp sawit langsung terbit!

---

## 13. Pembaruan Aplikasi Otomatis (Auto-Update)

- Setiap kali aplikasi dibuka di Windows atau Android, sistem secara otomatis mengecek ketersediaan rilis baru ke portal resmi ([https://ramsawit-portal.vercel.app](https://ramsawit-portal.vercel.app)).
- Jika ada versi pembaruan (misal v2.5.5), akan muncul jendela notifikasi pembaruan dengan daftar fitur baru dan tombol **"Unduh Pembaruan Sekarang"**.
- Anda tidak perlu khawatir kehilangan data saat meng-update aplikasi, karena database lokal tersimpan aman di direktori sistem.

---

## 14. Tombol Pintas Keyboard (Windows Desktop)

Untuk mempercepat kerja kasir di pos timbangan komputer desktop:

| Tombol Pintas | Fungsi |
|---|---|
| `Ctrl + N` | Membuka Form Transaksi Baru |
| `Ctrl + F` | Membuka Kolom Pencarian Petani / Nota |
| `Ctrl + P` | Mencetak Struk Nota Timbangan Terakhir |
| `Esc` | Menutup Dialog Pop-up / Membatalkan Input |
| `Tab` | Pindah ke Kolom Input Berikutnya |
| `Enter` | Konfirmasi Simpan Transaksi |

---

## 15. Tanya Jawab & Solusi Kendala (FAQ)

**Q: Internet di kebun saya mati tiba-tiba, apakah kasir bisa tetap menimbang?**  
**A:** Sangat bisa! RamSawit adalah aplikasi *Offline-First*. Bilah status akan berubah menjadi oranye (*Mode Offline*). Seluruh transaksi tersimpan aman di laptop kasir. Begitu sinyal WiFi/kuota HP menyala, data otomatis terkirim sendiri ke cloud.

**Q: Petani menjual 1 pikap berisi Tandan Besar dan Berondolan sekaligus, bagaimana mencatatnya?**  
**A:** Cukup isi baris pertama untuk Tandan Besar, lalu klik tombol "+ Tambah Jenis Buah", dan pilih Berondolan untuk baris kedua. Keduanya tercatat dalam satu nota transaksi yang sama.

**Q: Kasir keliru mengetik berat kotor dan nota sudah terlanjur disimpan, apakah bisa diperbaiki?**  
**A:** Buka menu Riwayat Transaksi, buka detail nota tersebut, lalu klik tombol merah "Batalkan Transaksi". Tuliskan alasan pembatalan. Setelah itu, buat transaksi baru dengan angka yang benar.

**Q: Bagaimana cara memastikan uang di laci kasir cocok dengan pembukuan?**  
**A:** Pemilik cukup melihat modul "Saldo Modal". Sistem hanya menghitung pengeluaran dari transaksi yang dipilih "Tunai". Jika petani dibayar transfer bank, uang fisik di laci tidak akan berkurang di sistem.

---
*Buku panduan ini merupakan dokumentasi operasional resmi aplikasi RamSawit v2.5.4.*
