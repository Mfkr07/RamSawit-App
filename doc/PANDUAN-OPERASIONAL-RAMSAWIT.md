# Buku Panduan Operasional Aplikasi RamSawit
## Standard Operating Procedure (SOP) Kasir, Mandor, & Pemilik Loading Ramp Sawit

Dokumen ini adalah panduan praktis alur kerja harian sistem **RamSawit** untuk memastikan pencatatan transaksi pembelian TBS petani, pengiriman ke pabrik (PKS), rekonsiliasi kas/saldo, dan operasional ramp berjalan tertib, presisi, dan bebas dari selisih timbangan.

---

## DAFTAR ISI
1. [Setup Awal Organisasi & Database (BYOD)](#1-setup-awal-organisasi--database-byod)
2. [Alur Pembelian TBS dari Petani (Kasir Timbangan)](#2-alur-pembelian-tbs-dari-petani-kasir-timbangan)
3. [Alur Pengiriman Buah ke Pabrik (PKS - 2 Fase)](#3-alur-pengiriman-buah-ke-pabrik-pks---2-fase)
4. [Pencatatan Biaya Operasional & Kas Ramp](#4-pencatatan-biaya-operasional--kas-ramp)
5. [Manajemen Saldo Kasir & Modal Pembelian](#5-manajemen-saldo-kasir--modal-pembelian)
6. [Laporan Pendapatan, Laba Bersih, & Ekspor Excel](#6-laporan-pendapatan-laba-bersih--ekspor-excel)
7. [Konsultasi Bisnis via AI Analytics Advisor](#7-konsultasi-bisnis-via-ai-analytics-advisor)
8. [Panduan Mode Offline & Sinkronisasi Data](#8-panduan-mode-offline--sinkronisasi-data)

---

## 1. Setup Awal Organisasi & Database (BYOD)
Aplikasi RamSawit menggunakan arsitektur **Bring-Your-Own-Database (BYOD)**. Data bisnis Anda sepenuhnya tersimpan di akun cloud Supabase milik Anda sendiri.

### Langkah Setup (Cukup Sekali di Awal):
1. Buat project baru di [https://supabase.com](https://supabase.com).
2. Buka menu **SQL Editor** pada sidebar kiri dashboard Supabase.
3. Salin seluruh isi berkas `supabase/master_tenant_schema.sql`, tempelkan ke SQL Editor, lalu klik tombol **Run**.
4. Buat akun kasir/admin di menu **Authentication** -> **Users** -> **Add User**.
5. Buka menu **Project Settings** -> **API**, salin:
   - **Project URL** (misal: `https://xyz.supabase.co`)
   - **anon public key** (`eyJh...`)
6. Buka aplikasi RamSawit di Android atau Windows.
7. Di layar Login, klik **"Setup Organisasi & Database"**, masukkan nama ramp Anda beserta URL dan Anon Key tersebut, lalu simpan.
8. Login dengan akun yang sudah dibuat.

---

## 2. Alur Pembelian TBS dari Petani (Kasir Timbangan)

Setiap truk/pikap petani tiba di ramp timbangan:
1. Klik menu **"Transaksi Baru"** (`Ctrl+N` di desktop atau tab Beli TBS di HP).
2. Pilih nama petani/penjual dari dropdown atau ketik nama untuk pencarian cepat. Jika penjual baru, klik ikon **"+"** untuk mendaftarkan nama dan nomor kontak.
3. Masukkan item buah yang ditimbang:
   - **Jenis Buah**: Tandan Besar (TB), Tandan Kecil (TK), atau Berondolan (BR).
   - **Harga per Kg**: Masukkan harga beli harian yang berlaku di ramp (misal: `Rp 2.450 /kg`).
   - **Berat Kotor**: Berat timbangan bruto (kg).
   - **Potongan (%)**: Potongan tangkai/sampah (misal: `2%` s.d. `5%`).
4. Sistem otomatis menghitung secara presisi tanpa error floating-point:
   - **Berat Bersih (kg)** = `Berat Kotor × (1 - Potongan%)`
   - **Nilai Potongan (Rp)**
   - **Subtotal (Rp)** = `Berat Bersih × Harga/kg`
5. Pilih **Metode Pembayaran**:
   - **Tunai**: Mengambil uang tunai dari kas ramp.
   - **Non Tunai (Transfer)**: Pembayaran melalui transfer rekening bank petani.
6. Klik **"Simpan & Cetak Struk"**. Struk nota timbang otomatis tercetak di printer thermal atau tersimpan rapi di riwayat.

---

## 3. Alur Pengiriman Buah ke Pabrik (PKS - 2 Fase)

Proses penjualan TBS ke Pabrik Kelapa Sawit menggunakan sistem **Alur Dua Fase**:

### Fase 1: Keberangkatan Truk dari Ramp
1. Buka menu **"Pengiriman ke Pabrik"** -> **Form Keberangkatan**.
2. Masukkan identitas armada:
   - Nomor Polisi Truk (Plat Nomor)
   - Nama Sopir
   - Pabrik Tujuan (PKS)
   - Berat TBS Dikirim (kg) hasil timbangan jembatan timbang ramp.
3. Simpan. Status pengiriman menjadi **"Berangkat"**.

### Fase 2: Rekonsiliasi Nota Timbang Pabrik (PKS)
Setelah truk selesai bongkar di pabrik dan sopir membawa slip timbangan resmi PKS:
1. Buka menu **"Riwayat Pengiriman"**, cari armada yang bersangkutan, lalu klik **"Input Hasil Pabrik"**.
2. Masukkan data dari slip PKS:
   - **Berat Sampai (kg)** (timbangan bruto PKS)
   - **Berat Ditolak (kg)** (buah mentah / restan yang diretur)
   - **Potongan Wajib Pabrik (%)**
   - **Harga Jual /kg yang disepakati**
   - **Potongan Sortasi per Kg & Potongan Lainnya** (jika ada klaim mutu)
3. Sistem otomatis mengaudit:
   - **Susut Buah Selama Perjalanan (kg)** = `Berat Dikirim - Berat Sampai`
   - **Total Nilai Jual Bersih yang Ditransfer PKS**
4. Ubah status menjadi **"Selesai"**.

---

## 4. Pencatatan Biaya Operasional & Kas Ramp

Semua pengeluaran rutin ramp dicatat pada menu **"Pengeluaran"**:
1. Klik **"Tambah Pengeluaran"**.
2. Pilih Kategori Biaya:
   - BBM & Transportasi Armada
   - Gaji / Upah Bongkar Muat
   - Perawatan Kendaraan & Alat Berat
   - Operasional Kantor / ATK
   - Lain-lain
3. Tentukan nominal dan **Metode Pembayaran (Tunai / Non Tunai)**.
4. Jika dibayar **Tunai**, saldo modal ramp akan otomatis terpotong saat itu juga.

---

## 5. Manajemen Saldo Kasir & Modal Pembelian

Menu **"Saldo / Dana Modal"** khusus untuk peran Admin:
1. **Top Up Saldo**: Catat penambahan uang tunai modal dari rekening utama ke laci kasir ramp.
2. **Rekonsiliasi Realtime**:
   - `Sisa Saldo Kas Ramp = Total Top Up Modal - Total Pembelian Tunai - Total Pengeluaran Tunai`.
3. Kasir tidak perlu menghitung manual di buku kas fisik setiap sore; laporan sisa uang fisik wajib cocok dengan angka sisa saldo aplikasi.

---

## 6. Laporan Pendapatan, Laba Bersih, & Ekspor Excel

Menu **"Laporan Pendapatan"** menyajikan ringkasan kinerja finansial per periode:
1. Filter tanggal harian, mingguan, atau bulanan.
2. Ringkasan indikator bisnis:
   - Total Pembelian Petani (Rp) & Total Tonase (kg)
   - Total Penjualan PKS (Rp) & Total Tonase (kg)
   - Margin Kotor
   - Total Biaya Operasional
   - **Laba Bersih Riil Ramp**
3. Klik tombol **"Ekspor Laporan (Excel)"** untuk menghasilkan berkas `.xlsx` komprehensif berstandar perbankan yang siap dikirim via WhatsApp atau dicetak.

---

## 7. Konsultasi Bisnis via AI Analytics Advisor

Fitur cerdas berbasis LLM untuk membantu evaluasi bisnis ramp:
1. Buka menu **"Analitik AI"**.
2. Anda dapat menanyakan pertanyaan analitis seperti:
   - *"Berapa rata-rata margin keuntungan kita minggu ini?"*
   - *"Pabrik mana yang memberikan potongan sortasi paling rendah?"*
   - *"Berapa rekomendasi harga beli TBS petani untuk besok agar margin tetap di atas Rp 200/kg?"*
3. AI menganalisis data transaksi operasional ramp Anda secara aman tanpa pernah mengubah data di database.

---

## 8. Panduan Mode Offline & Sinkronisasi Data

RamSawit dirancang khusus untuk kondisi sinyal kebun sawit yang minim:
1. **Offline Penuh**: Saat koneksi internet terputus, banner status berwarna kuning/oranye muncul (*"Mode Offline"*). Anda **tetap dapat mencatat transaksi, timbangan, dan pengeluaran seperti biasa**. Data tersimpan aman di database SQLite lokal perangkat.
2. **Sinkronisasi Otomatis**: Saat perangkat mendeteksi jaringan internet (Wi-Fi atau seluler), engine sinkronisasi (`SyncEngine`) otomatis mengunggah seluruh data yang belum tersinkron ke cloud Supabase setiap 30 detik.
3. Anda juga dapat menekan tombol **"Sinkronkan Sekarang"** pada status bar kapan saja.
