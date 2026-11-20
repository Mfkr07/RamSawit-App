# BUKU PANDUAN PENGGUNA (USER MANUAL)
# Aplikasi Transaksi Timbangan Sawit (TBS)

> **Untuk Pemilik Pengepul (Admin), Kasir Timbangan, dan Operator Lapangan**  
> *Versi Aplikasi: 1.8.1 | Bahasa: Indonesia*

---

## DAFTAR ISI

1. [Mengenal Aplikasi Transaksi Sawit](#1-mengenal-aplikasi-transaksi-sawit)
2. [Perbedaan Hak Akses: Pemilik (Admin) vs Kasir](#2-perbedaan-hak-akses-pemilik-admin-vs-kasir)
3. [Masuk Akun (Login) & Keamanan 24 Jam](#3-masuk-akun-login--keamanan-24-jam)
4. [Siklus Harian: Cara Kerja Operasional Ram Sawit](#4-siklus-harian-cara-kerja-operasional-ram-sawit)
5. [Panduan Pembelian TBS dari Petani](#5-panduan-pembelian-tbs-dari-petani)
   - 5.1 Menambah & Mencari Data Petani (Penjual)
   - 5.2 Mencatat Transaksi Timbangan Baru (Multi-Item)
   - 5.3 Cara Pengisian Potongan Sampah / Tangkai
   - 5.4 Melihat Riwayat & Nota Pembelian
   - 5.5 Membatalkan Transaksi yang Salah Input (Void)
6. [Panduan Pengiriman Buah ke Pabrik (PKS)](#6-panduan-pengiriman-buah-ke-pabrik-pks)
   - 6.1 Mendaftarkan Data Pabrik Kelapa Sawit
   - 6.2 Mencatat Keberangkatan Truk (Fase 1)
   - 6.3 Mengisi Hasil Timbangan & Sortasi Pabrik (Fase 2)
   - 6.4 Memantau Riwayat Pengiriman Pabrik
7. [Membaca Dashboard & Analitik Usaha](#7-membaca-dashboard--analitik-usaha)
   - 7.1 Memahami Kartu Ringkasan (Hari Ini, Minggu Ini, Bulan Ini)
   - 7.2 Mengatur Periode Filter Kartu "Bulan Ini" (Khusus Admin)
   - 7.3 Memantau Proporsi Jenis Buah & Pabrik Tujuan
   - 7.4 Membaca Grafik Tren & Margin Keuntungan (Khusus Admin)
8. [Mencetak & Mengekspor Laporan (Excel & PDF)](#8-mencetak--mengekspor-laporan-excel--pdf)
   - 8.1 Ekspor Laporan Pembelian Petani & Penjualan Pabrik
   - 8.2 Ekspor Laporan Pendapatan / Laba Bersih (Khusus Admin)
9. [Tanya Jawab & Solusi Kendala (FAQ)](#9-tanya-jawab--solusi-kendala-faq)

---

## 1. Mengenal Aplikasi Transaksi Sawit

Aplikasi Transaksi Timbangan Sawit (TBS) adalah sistem pencatatan digital yang dirancang khusus untuk operasional **Pengepul Kelapa Sawit (Ram / Loading Ramp / Timbangan)**.

Aplikasi ini menggantikan buku tulis manual dan kalkulator biasa, sehingga:
- **Timbangan dan Pembayaran Cepat & Tepat**: Menghitung berat kotor, potongan sampah/persen, berat bersih, dan rupiah secara otomatis tanpa takut salah hitung.
- **Data Petani & Pabrik Rapi**: Riwayat penjualan setiap petani dan pengiriman ke pabrik tersimpan aman dan tidak bisa hilang atau sobek.
- **Keuntungan Terpantau Jelas**: Pemilik bisa langsung melihat berapa keuntungan bersih (selisih uang jual ke pabrik dikurangi uang beli ke petani) setiap hari, setiap bulan, hingga tahunan.
- **Laporan Otomatis**: Sekali klik, rekapitulasi langsung berubah menjadi file **Excel** atau **PDF** siap cetak.

---

## 2. Perbedaan Hak Akses: Pemilik (Admin) vs Kasir

Untuk menjaga keamanan keuangan dan kerahasiaan keuntungan usaha, aplikasi membagi pengguna menjadi dua peran (*role*):

| Menu & Fitur | Pemilik Usaha (Admin) | Kasir Timbangan (Kasir) | Penjelasan untuk Kasir |
|---|:---:|:---:|---|
| **Catat Pembelian Petani** | Ya | Ya | Kasir leluasa mencatat timbangan masuk setiap hari. |
| **Kelola Data Petani** | Ya | Ya | Kasir bisa mendaftarkan petani baru langsung di timbangan. |
| **Riwayat Transaksi Petani** | Ya | Ya | Kasir bisa memeriksa transaksi yang baru saja dicatat. |
| **Batalkan Transaksi (Salah Input)** | Ya | Ya (Wajib isi alasan) | Kasir wajib menuliskan kenapa transaksi dibatalkan. |
| **Catat Pengiriman Pabrik** | Ya | Ya | Kasir bisa menginput truk berangkat dan hasil timbang pabrik. |
| **Lihat Tab "Margin Keuntungan"** | Ya | **Disembunyikan** | Demi privasi bisnis, laba bersih ram sawit hanya bisa dilihat oleh pemilik. |
| **Lihat Grafik Tren Omzet & Nilai** | Ya | **Disembunyikan** | Kasir hanya melihat total tonase dan jumlah transaksi operasional. |
| **Filter Periode Dashboard** | Bebas (sampai 1 tahun) | **Maksimal 1 Bulan** | Kasir difokuskan pada pemantauan operasional berjalan. |
| **Ekspor Laporan Pendapatan (Laba)** | Ya | **Disembunyikan** | Dokumen rekap laba bersih hanya hak akses pemilik usaha. |

---

## 3. Masuk Akun (Login) & Keamanan 24 Jam

### Cara Masuk ke Aplikasi:
1. Buka aplikasi di HP Android, Tablet, atau Laptop kasir.
2. Masukkan **Alamat Email** dan **Kata Sandi** yang telah didaftarkan.
3. Klik tombol biru bertuliskan **"Masuk ke Sistem"**.
4. Sistem akan otomatis mengenali apakah Anda masuk sebagai **Admin** atau **Kasir**.

### Aturan Keamanan Sesi 24 Jam:
- Demi keamanan uang kas dan integritas data ram sawit, **sesi login dibatasi maksimal 24 jam berturut-turut**.
- Jika aplikasi sudah terbuka lebih dari 24 jam sejak Anda login (atau jika kasir kemarin lupa logout), sistem akan **otomatis mengeluarkan akun (logout otomatis)** dan memunculkan banner pemberitahuan berwarna oranye di layar login:
  > *"Sesi login Anda telah berakhir demi keamanan (maksimal 24 jam). Silakan masuk kembali."*
- Cukup ketik ulang email dan kata sandi Anda untuk mulai bekerja kembali.

### Cara Keluar (Logout) Manual:
1. Di bilah menu sebelah kiri (atau klik garis tiga di HP), cari tombol **"Keluar Sesi"** di bagian paling bawah.
2. Tekan tombol tersebut, lalu pilih **"Ya, Keluar"** pada kotak dialog konfirmasi.
3. Selalu biasakan logout saat pergantian giliran (*shift*) timbangan!

---

## 4. Siklus Harian: Cara Kerja Operasional Ram Sawit

Secara umum, alur kerja harian menggunakan aplikasi ini terbagi menjadi 3 langkah sederhana:

```
[LANGKAH 1: PAGI - SORE]
Petani datang bawa TBS -> Ditimbang -> Kasir input Transaksi Baru -> Kasir bayar petani sesuai Total Rp

[LANGKAH 2: SIANG - MALAM]
TBS di ram dimuat ke Truk -> Truk ditimbang -> Truk jalan ke Pabrik (Input Pengiriman Fase 1)
Truk pulang bawa Surat Pabrik (SPB) -> Kasir input Hasil Pabrik & Potongan (Fase 2 Selesai)

[LANGKAH 3: MALAM / AKHIR BULAN]
Pemilik membuka Dashboard -> Pantau Margin Bersih -> Unduh Laporan Pendapatan (Excel / PDF)
```

---

## 5. Panduan Pembelian TBS dari Petani

### 5.1 Menambah & Mencari Data Petani (Penjual)
Sebelum menimbang buah, pastikan nama petani sudah terdaftar di sistem.

1. Buka menu **"Data Penjual"** di menu samping.
2. Untuk mencari petani: ketik nama petani, nomor HP, atau nama desa pada kolom pencarian.
3. Untuk mendaftarkan petani baru:
   - Klik tombol **"+ Tambah Penjual"**.
   - Isi **Nama Lengkap** (wajib, contoh: *Pak Joko Santoso*).
   - Isi **Nomor Telepon/WA** dan **Desa / Alamat Kebun**.
   - Klik **"Simpan"**. Petani langsung tersimpan dan bisa langsung dipilih saat menimbang.

---

### 5.2 Mencatat Transaksi Timbangan Baru (Multi-Item)
Gunakan menu **"Transaksi Baru"** saat mobil pick-up, motor gledek, atau truk petani naik ke atas timbangan.

1. **Pilih Nama Petani**:
   - Ketik nama petani pada kotak pencarian penjual, lalu pilih dari daftar yang muncul.
2. **Pilih Tanggal Transaksi**:
   - Otomatis terisi tanggal hari ini (bisa diubah jika mencatat nota susulan).
3. **Pilih Jenis Buah**:
   - Sistem mendukung 3 kategori buah resmi:
     - **Tandan Besar** (TBS normal/bobot matang)
     - **Tandan Kecil** (TBS pokok muda/pasir)
     - **Berondolan** (Buah rontokan lepas)
4. **Masukkan Berat & Harga**:
   - Masukkan **Berat Kotor (kg)** dari angka jarum timbangan (contoh: `1450` kg).
   - Masukkan **Harga per kg** (contoh: `Rp 2.450`).
5. **Menambah Baris Buah Lain (Multi-Item)**:
   - Jika petani membawa campuran (misal: 1 bak Tandan Besar dan 2 karung Berondolan), klik tombol **"+ Tambah Jenis Buah"**.
   - Sistem membolehkan maksimal 3 baris (satu baris untuk setiap jenis buah).
6. **Pilih Jenis Pembayaran**:
   - **Tunai**: Nilai transaksi langsung memotong dana modal kasir di modul Saldo.
   - **Non Tunai**: Nilai transaksi dicatat sebagai pembayaran transfer bank / titipan, tidak memotong uang fisik kas modal timbangan.
7. **Periksa Live Preview (Total Bayar)**:
   - Di bagian bawah form, sistem otomatis menampilkan:
     - Total Berat Kotor
     - Total Potongan Timbangan
     - Total Berat Bersih
     - **Total Pembayaran (Rp)** yang wajib diserahkan kasir kepada petani.
8. Klik tombol biru **"Simpan Transaksi"**. Selesai!

---

### 5.3 Cara Pengisian Potongan Sampah / Tangkai
Setiap ram sawit biasanya memiliki aturan pemotongan timbangan untuk sampah pasir, tanah, tangkai panjang, atau buah mentah.

Aplikasi menyediakan dua cara pengisian potongan per jenis buah:
- **Potongan Persen (%)**: Contoh isi `3%` atau `2.5%`. Sistem otomatis menghitung berapa kilogram yang dipotong dan mengurangi berat kotornya.
- **Potongan Kilogram (kg)**: Contoh isi `50 kg` (misal potongan berat tara terpal/keranjang).

> **Rumus Otomatis Aplikasi**:  
> `Berat Bersih = Berat Kotor - Potongan Berat`  
> `Subtotal Rp = Berat Bersih x Harga per kg`  
> *Anda tidak perlu lagi mencoret-coret kertas atau memencet kalkulator!*

---

### 5.4 Melihat Riwayat & Nota Pembelian
1. Buka menu **"Riwayat Transaksi"**.
2. Anda akan melihat daftar seluruh nota timbangan berurutan dari yang paling baru.
3. **Gunakan Filter Periode & Tanggal Kustom**:
   - Pilihan preset cepat:  
     `Semua` | `Hari Ini` | `1 Minggu` | `2 Minggu` | `1 Bulan` | `3 Bulan` | `6 Bulan` | `1 Tahun`
   - Opsi **"Pilih Tanggal..." (Kustom)**: Jika Anda ingin memeriksa transaksi pada rentang tanggal spesifik (misal tanggal 5 sampai 10 September), cukup klik tombol kalender **"Pilih Tanggal..."** lalu tentukan tanggal mulai dan tanggal akhir.
   - Daftar transaksi langsung tersaring seketika dan nomor halaman otomatis kembali ke halaman pertama.
4. Klik salah satu baris transaksi untuk melihat **Rincian Nota Lengkap**: nama petani, rincian per jenis buah, potongan, jam timbang, dan nama kasir yang mencatat.

---

### 5.5 Membatalkan Transaksi yang Salah Input (Void)
Bagaimana jika kasir salah mengetik angka timbangan (misal harusnya 1.200 kg tapi terketik 12.000 kg)?

1. Buka transaksi yang salah tersebut di menu **"Riwayat Transaksi"**.
2. Masuk ke halaman **Detail Transaksi**.
3. Di bagian bawah, klik tombol merah **"Batalkan Transaksi"**.
4. Kotak dialog akan muncul meminta **Alasan Pembatalan**.
   - Tuliskan alasan dengan jujur dan jelas (contoh: *"Salah ketik berat kotor, kelebihan angka nol"*).
5. Klik **"Konfirmasi Batal"**.
6. Status transaksi akan berubah menjadi **Dibatalkan** (merah).

> **Catatan Penting Keamanan**:  
> Transaksi yang dibatalkan **tidak akan hilang dari sistem**, melainkan dicoret. Nilai rupiahnya otomatis ditarik dari laporan keuangan. Hal ini bertujuan agar pembukuan ram sawit selalu transparan dan mencegah kecurangan uang kas.

---

## 6. Panduan Pengiriman Buah ke Pabrik (PKS)

Modul ini digunakan untuk mencatat buah sawit yang dikirim menggunakan truk dari ram menuju Pabrik Kelapa Sawit (PKS). Modul ini bekerja dengan **Sistem Dua Fase**:

### 6.1 Mendaftarkan Data Pabrik Kelapa Sawit
1. Buka menu **"Master Data Pabrik"**.
2. Klik **"+ Tambah Pabrik"**.
3. Masukkan Nama Pabrik (contoh: *PT. Sawit Mandiri Lestari*), Alamat/Kecamatan, dan Nomor Telepon Timbangan Pabrik.
4. Simpan data.

---

### 6.2 Mencatat Keberangkatan Truk (Fase 1)
Lakukan saat truk selesai dimuat di ram dan siap berangkat ke pabrik:

1. Buka menu **"Pengiriman ke Pabrik"** $\rightarrow$ klik **"+ Kirim TBS ke Pabrik"**.
2. Isi informasi pengiriman:
   - **Pabrik Tujuan**: Pilih pabrik yang dituju.
   - **Nomor Plat Truk**: Contoh `BK 8412 XX`.
   - **Nama Supir**: Contoh `Anto`.
   - **Berat Kotor Ram (kg)**: Angka timbangan saat truk keluar dari ram timbangan Anda (contoh: `12.500 kg`).
   - **Estimasi Harga per kg**: Harga kesepakatan papan pabrik hari itu.
3. Klik **"Simpan Pengiriman"**.
4. Truk tercatat dengan status kuning: **"Dalam Perjalanan"**.

---

### 6.3 Mengisi Hasil Timbangan & Sortasi Pabrik (Fase 2)
Lakukan saat supir kembali dari pabrik membawa **SPB (Surat Pengantar Buah) / Tiket Timbangan Pabrik**:

1. Buka menu **"Riwayat Pengiriman"**.
2. Cari pengiriman truk yang bersangkutan (berstatus kuning *"Berangkat"*).
3. Klik tombol **"Selesaikan / Input Nota Pabrik"**.
4. Masukkan data resmi dari tiket pabrik:
   - **Berat Sampai / Timbang Pabrik (kg)**: Angka timbangan saat truk tiba di pabrik. Sistem otomatis menghitung **Susut Buah (kg)** antara berat ram dan berat pabrik.
   - **Buah Ditolak (kg)**: Berat TBS busuk/mentah yang ditolak dan dikembalikan.
   - **Potongan Wajib Pabrik (%)**: Potongan kadar air/kotoran standar pabrik (contoh: `2%`).
   - **Harga Jual Final Pabrik (Rp/kg)**: Harga resmi per kg dari pabrik.
   - **Potongan Sortasi (Rp/kg)**: Potongan kualitas per kg jika diberlakukan pabrik (sistem otomatis mengalikan dengan berat bersih).
   - **Potongan Lainnya (Rp)**: Biaya denda tangkai panjang, administrasi bongkar, atau klaim lainnya dalam nominal rupiah langsung.
5. Sistem otomatis menghitung **Total Nilai Penjualan Pabrik (Rp)** bersih.
6. Klik **"Konfirmasi Selesai"**. Status berubah menjadi hijau: **"Selesai"**.

---

### 6.4 Memantau Riwayat Pengiriman Pabrik
1. Buka menu **"Riwayat Pengiriman"**.
2. Anda dapat berpindah antara tab **"Belum Selesai"** (truk yang masih di jalan) dan **"Semua Riwayat"**.
3. Gunakan bilah filter periode terstandarisasi (`Semua`, `Hari Ini`, `1 Minggu`, `2 Minggu`, `1 Bulan`, `3 Bulan`, `6 Bulan`, `1 Tahun`) atau klik tombol kalender **"Pilih Tanggal..."** untuk menyaring data berdasarkan rentang tanggal kustom yang diinginkan.
4. Gunakan kotak pencarian untuk mencari berdasarkan nomor polisi truk, nama supir, atau nama pabrik.

---

## 7. Membaca Dashboard & Analitik Usaha

Dashboard adalah layar utama aplikasi yang merangkum kesehatan bisnis ram sawit Anda secara seketika (*real-time*).

### 7.1 Memahami Tiga Kartu Ringkasan Utama
Di bagian atas dashboard, terdapat 3 kartu ringkasan:
1. **Kartu Hari Ini**: Total uang keluar dan kilogram TBS yang dibeli dari petani pada hari kalender saat ini.
2. **Kartu Minggu Ini**: Akumulasi pembelian selama 7 hari kalender berjalan.
3. **Kartu Bulan Ini**: Total uang, berat kotor, berat bersih, dan jumlah nota pembelian sepanjang bulan berjalan.

---

### 7.2 Mengatur Periode Filter Kartu "Bulan Ini" (Khusus Admin)
Khusus pemilik usaha (Admin), pada kartu ke-3 ("Bulan Ini") terdapat tombol **ikon filter/tune** di pojok kanan atas kartu. Tombol ini berguna jika Anda ingin mengevaluasi periode khusus tanpa mengubah grafik lain:
- **Bulan Berjalan**: Menampilkan bulan ini (contoh: September 2026).
- **Pilih Bulan Tertentu**: Melihat performa bulan lalu (misal ingin melihat buku bulan Agustus 2026).
- **Satu Tahun Penuh**: Akumulasi total seluruh transaksi selama tahun 2026 berjalan.
- **Rentang Bulan Kustom**: Memilih rentang misal dari Mei 2026 sampai Juli 2026.

*(Untuk akun Kasir, kartu ini otomatis terkunci pada bulan berjalan).*

---

### 7.3 Memantau Proporsi Jenis Buah & Pabrik Tujuan
Di bagian tengah dashboard, terdapat grafik lingkaran (*Donut Chart*):
- **Proporsi Volume Jenis Buah**: Memperlihatkan persentase pasokan petani, misalnya: *86% Tandan Besar, 11% Tandan Kecil, dan 3% Berondolan*.
- **Proporsi Penjualan per Pabrik**: Menunjukkan ke pabrik mana saja buah Anda paling banyak terjual bulan ini (misal: *78% ke PT. Sawit Jaya, 22% ke PT. Agro Lestari*).

---

### 7.4 Membaca Grafik Tren & Margin Keuntungan (Khusus Admin)
Fitur ini khusus untuk akun Admin:
- **Tab Margin Keuntungan**: Menampilkan selisih uang masuk dari pabrik dikurangi uang keluar ke petani. Inilah angka **Keuntungan Kotor Ram Sawit** Anda.
- **Grafik Tren Nilai**: Garis biru menunjukkan omzet penjualan pabrik, dan garis hijau menunjukkan pembelian petani. Jika garis biru berada di atas garis hijau, usaha Anda sedang mencatatkan surplus profit yang sehat.
- **Grafik Tren Berat**: Memantau fluktuasi pasokan tonase harian apakah musim panen raya atau musim trek (*rendah buah*).

---

## 8. Mencetak & Mengekspor Laporan (Excel & PDF)

Aplikasi menyediakan dua jenis laporan yang bisa diunduh kapan saja tanpa perlu internet kencang:

### 8.1 Ekspor Laporan Pembelian Petani & Penjualan Pabrik
Gunakan menu **"Export Laporan"** di bilah atas Dashboard:
1. Pilih jenis laporan: **Laporan Pembelian Petani** atau **Laporan Penjualan Pabrik**.
2. Pilih rentang tanggal yang diinginkan.
3. Pilih format dokumen:
   - **Microsoft Excel (.xlsx)**: Jika Anda ingin mengolah kembali angka di komputer/laptop.
   - **Dokumen PDF (.pdf)**: Jika Anda ingin langsung mencetak di kertas (*print*) atau mengirim nota ringkasan lewat WhatsApp.
4. Klik tombol **"Unduh Laporan"**. File langsung tersimpan di folder *Download* perangkat Anda.

---

### 8.2 Ekspor Laporan Pendapatan / Laba Bersih (Khusus Admin)
Fitur eksklusif ini dirancang khusus bagi pemilik usaha untuk melihat rekapitulasi laba berkala tanpa pusing membaca ribuan transaksi harian.

1. Buka menu **"Laporan Pendapatan"** di menu samping (atau tombol di header Dashboard).
2. Kotak dialog **"Ekspor Laporan Pendapatan"** akan terbuka.
3. Pilih salah satu dari **3 Cakupan Periode**:
   - **1 Bulan (Per Minggu)**:
     - Dikelompokkan otomatis menjadi 5 baris minggu (Minggu 1: tgl 1–7, Minggu 2: tgl 8–14, dst.).
     - Menampilkan kolom: `Periode`, `Total Pembelian (Rp)`, `Total Penjualan (Rp)`, dan `Margin (Rp)`.
   - **3 Bulan (Per Bulan)**:
     - Dikelompokkan otomatis menjadi 3 baris bulanan (contoh: Juli, Agustus, September).
   - **1 Tahun (Per Kuartal)**:
     - Dikelompokkan otomatis menjadi 4 baris kuartal (Kuartal 1: Jan–Mar, Kuartal 2: Apr–Jun, Kuartal 3: Jul–Sep, Kuartal 4: Okt–Des).
4. Periksa **Pratinjau Tabel (Live Preview)**:
   - Angka margin untung/surplus berwarna biru, sedangkan jika rugi berwarna merah minus.
   - Baris paling bawah (**Total Keseluruhan**) merangkum total rupiah secara akurat.
5. Pilih format **Excel (.xlsx)** atau **PDF (.pdf)**, lalu klik **"Unduh"**.

---

### 8.3 Panduan Modul Pengeluaran Operasional
Modul ini digunakan untuk mencatat seluruh biaya operasional di luar pembelian TBS (misal: solar truk, makan siang timbangan, perbaikan sparepart, dan lain-lain).
1. Buka menu samping, pilih **"Pengeluaran Operasional"**.
2. Klik tombol **"+ Tambah Pengeluaran"**.
3. Pilih **Kategori Pengeluaran** (misal: BBM & Transportasi, Konsumsi & Operasional, Pemeliharaan Mesin).
4. Masukkan tanggal, nominal rupiah, dan keterangan detail.
5. Klik **"Simpan"**.
6. Pengeluaran otomatis mengurangi total margin keuntungan di Laporan Laba Bersih Admin.

---

### 8.4 Panduan Modul Saldo Kas Modal Kasir
Modul ini memantau fisik dana kas yang dipegang kasir/petugas timbangan untuk membayar transaksi pembelian buah:
1. Buka menu samping, pilih **"Saldo Modal / Kas"**.
2. **Top Up Kas Modal**: Klik tombol **"+ Tambah Modal"** saat kasir menerima suntikan modal uang tunai dari pemilik.
3. **Memantau Pemakaian Kas**:
   - Seluruh transaksi pembelian berstatus **Tunai** otomatis memotong sisa saldo secara seketika.
   - Transaksi **Non Tunai** otomatis masuk ke tab terpisah dan tidak memotong fisik uang tunai.
4. **Indikator Peringatan Saldo Minus**:
   - Jika sisa kas kasir menipis atau minus (pemakaian tunai > modal masuk), sistem memunculkan lencana merah dan dialog peringatan untuk segera melakukan penambahan modal kas.
5. Kasir atau Admin dapat mengekspor rekapitulasi mutasi saldo dalam bentuk Excel atau PDF.

---

## 9. Tanya Jawab & Solusi Kendala (FAQ)

### Q1: Tiba-tiba aplikasi keluar sendiri dan meminta login lagi. Apakah data transaksi saya hilang?
**Jawab**: Tidak ada data yang hilang. Itu adalah fitur **Keamanan Sesi 24 Jam**. Sistem secara otomatis mengunci layar jika sudah lewat dari 24 jam sejak login pertama demi melindungi uang kas Anda dari orang lain saat timbangan ditinggalkan. Cukup ketik ulang email dan password Anda, seluruh data tetap aman 100%.

### Q2: Mengapa akun Kasir saya tidak bisa melihat tombol "Laporan Pendapatan" dan tab "Margin"?
**Jawab**: Itu bukan kerusakan sistem. Memang sengaja disembunyikan oleh sistem (*Role-Based Access Control*). Fitur margin dan laba bersih hanya diperuntukkan bagi akun **Admin (Pemilik)** agar rahasia dapur keuntungan usaha tetap aman dan kasir fokus pada timbangan harian.

### Q3: Jika salah mengetik timbangan atau harga, apakah transaksi bisa dihapus?
**Jawab**: Transaksi tidak bisa dihapus permanen (*DELETE*), melainkan harus **Dibatalkan (Void)** dengan menyertakan alasan. Transaksi yang dibatalkan akan otomatis dicoret dan tidak akan dihitung ke kas keuangan. Cara ini menjamin semua catatan kasir tercatat secara jujur dan transparan.

### Q4: Apakah saya bisa menggunakan aplikasi ini di beberapa HP atau Laptop sekaligus?
**Jawab**: Ya. Aplikasi mendukung multi-perangkat. Contohnya: laptop timbangan dioperasikan oleh Kasir untuk input data, sementara Pemilik memantau grafik dashboard dan laporan pendapatan dari HP Android di rumah secara bersamaan.

### Q5: Bagaimana jika jumlah hari dalam satu bulan hanya 30 hari atau 28 hari (Februari)?
**Jawab**: Pada laporan bulanan per minggu, sistem secara otomatis mendeteksi jumlah hari kalender. Minggu ke-5 otomatis disesuaikan mencakup sisa hari sampai akhir bulan kalender tersebut tanpa error perhitungan.

---

*Buku Panduan ini disusun sebagai dokumen pegangan resmi operasional Aplikasi Transaksi Timbangan Sawit (TBS).*
