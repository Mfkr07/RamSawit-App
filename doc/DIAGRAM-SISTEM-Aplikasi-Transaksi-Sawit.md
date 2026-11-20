# ARSITEKTUR VISUAL & DIAGRAM SISTEM
# Aplikasi Transaksi Timbangan Sawit (TBS)

> **Dokumen Diagram Resmi: ERD, Use Case Diagram, Flowchart Alur Kerja, dan Analisis Fishbone (Ishikawa)**  
> *Versi Sistem: 1.8.1 | Database: PostgreSQL (Supabase) | Framework: Flutter*

---

## DAFTAR ISI DIAGRAM

1. [Entity Relationship Diagram (ERD) Lengkap](#1-entity-relationship-diagram-erd-lengkap)
   - 1.1 Diagram ERD Relasi Tabel Fisik
   - 1.2 Diagram Arsitektur Database View (Reporting & Analitik)
2. [Use Case Diagram Sistem](#2-use-case-diagram-sistem)
   - 2.1 Diagram Use Case Global (Admin, Kasir, & Sistem)
   - 2.2 Matriks Hak Akses Aktor (Role-Based Access Control)
   - 2.3 Rincian Deskripsi Aktor & Skenario Use Case
3. [Flowchart Sistem & Alur Kerja Bisnis](#3-flowchart-sistem--alur-kerja-bisnis)
   - 3.1 Alur Autentikasi & Keamanan Sesi 24 Jam
   - 3.2 Alur Transaksi Pembelian TBS Petani (Multi-Item & Potongan)
   - 3.3 Alur Pembatalan Transaksi Pembelian (Void)
   - 3.4 Alur Penjualan ke Pabrik (Alur Dua Fase Pengiriman)
   - 3.5 Alur Ekspor Laporan Pendapatan (Khusus Admin)
4. [Diagram Fishbone (Ishikawa) — Akar Masalah & Solusi](#4-diagram-fishbone-ishikawa--akar-masalah--solusi)
   - 4.1 Diagram Tulang Ikan (6M: Man, Method, Machine, Material, Measurement, Milieu)
   - 4.2 Matriks Masalah vs Solusi Aplikasi

---

## 1. Entity Relationship Diagram (ERD) Lengkap

### 1.1 Diagram ERD Relasi Tabel Fisik

Database dinormalisasi hingga 3NF dengan prinsip *Single Source of Truth*. Seluruh nilai turunan (`subtotal`, `berat_bersih_kg`, `total_nilai_jual`) menggunakan kolom `GENERATED ALWAYS AS ... STORED` agar anti-floating point error dan mencegah anomali pembaruan.

```mermaid
erDiagram
    PROFILES ||--o{ PENJUAL : "mencatat (created_by)"
    PROFILES ||--o{ TRANSAKSI : "mencatat (created_by)"
    PROFILES ||--o{ PABRIK : "mencatat (created_by)"
    PROFILES ||--o{ PENGIRIMAN_PABRIK : "mencatat (created_by)"
    PROFILES ||--o{ PENGELUARAN : "mencatat (created_by)"
    PROFILES ||--o{ TOPUP_SALDO : "input_modal (created_by)"

    PENJUAL ||--o{ TRANSAKSI : "melakukan"
    TRANSAKSI ||--|{ TRANSAKSI_ITEM : "memiliki (1..3 item)"
    JENIS_BUAH ||--o{ TRANSAKSI_ITEM : "diklasifikasikan ke"

    PABRIK ||--o{ PENGIRIMAN_PABRIK : "menerima buah dari"
    JENIS_PENGELUARAN ||--o{ PENGELUARAN : "mengelompokkan biaya"

    PROFILES {
        uuid id PK "auth.users uuid"
        text nama "Nama lengkap operator"
        text role "admin | kasir"
        timestamptz created_at
    }

    PENJUAL {
        uuid id PK
        text nama "Nama petani / pemasok"
        text no_telepon "Nomor HP / WhatsApp"
        text alamat "Desa / Lokasi kebun"
        text catatan
        boolean is_active "Status aktif petani"
        uuid created_by FK "profiles.id"
        timestamptz created_at
        timestamptz updated_at
    }

    JENIS_BUAH {
        smallint id PK
        text kode "TB | TK | BR"
        text nama "Tandan Besar | Tandan Kecil | Berondolan"
        boolean is_active
    }

    TRANSAKSI {
        uuid id PK
        text kode_transaksi "TRX-YYYYMMDD-XXXX (Unik)"
        uuid penjual_id FK "penjual.id"
        date tanggal_transaksi "Tanggal timbang nota"
        text status "selesai | dibatalkan"
        text jenis_pembayaran "tunai | non_tunai"
        text catatan
        text alasan_pembatalan "Wajib diisi jika status dibatalkan"
        uuid created_by FK "profiles.id (Kasir/Admin pencatat)"
        timestamptz created_at
        timestamptz updated_at
    }

    TRANSAKSI_ITEM {
        uuid id PK
        uuid transaksi_id FK "transaksi.id (on delete cascade)"
        smallint jenis_buah_id FK "jenis_buah.id"
        numeric harga_per_kg "Harga beli per kg (Rp)"
        numeric berat_kotor_kg "Angka timbangan kotor (kg)"
        numeric persentase_potongan "Potongan sampah / tangkai (0-100%)"
        numeric berat_bersih_kg "GENERATED: berat_kotor * (1 - potongan/100)"
        numeric nilai_potongan_rp "GENERATED: harga * berat_kotor * potongan/100"
        numeric subtotal "GENERATED: harga * berat_bersih_kg"
        timestamptz created_at
    }

    PABRIK {
        uuid id PK
        text nama "Nama Pabrik Kelapa Sawit (PKS)"
        text alamat "Lokasi pabrik"
        text kontak "No telepon timbangan pabrik"
        boolean is_active
        uuid created_by FK "profiles.id"
        timestamptz created_at
        timestamptz updated_at
    }

    PENGIRIMAN_PABRIK {
        uuid id PK
        text nomor_do "Nomor DO / Nota Pengiriman"
        uuid pabrik_id FK "pabrik.id"
        text plat_nomor "Nomor polisi truk"
        text nama_sopir "Nama supir pengangkut"
        date tanggal_kirim "Tanggal truk berangkat"
        numeric berat_dikirim_kg "Timbangan kotor ram (kg)"
        numeric berat_sampai_kg "Timbangan kotor di pabrik (kg)"
        numeric susut_buah_kg "GENERATED: berat_dikirim - berat_sampai"
        numeric berat_ditolak_kg "Sortasi/buah busuk ditolak pabrik"
        numeric berat_diterima_kg "GENERATED: berat_sampai - berat_ditolak"
        numeric persentase_potongan_pabrik "Potongan kadar kotoran pabrik (%)"
        numeric berat_bersih_kg "GENERATED: berat_diterima * (1 - potongan/100)"
        numeric harga_jual_per_kg "Harga kesepakatan pabrik (Rp/kg)"
        numeric nilai_potongan_rp "GENERATED: rupiah potongan persen"
        numeric potongan_lainnya_rp "Potongan klaim biaya lain (Rp)"
        numeric potongan_sortasi_rp_per_kg "Potongan sortasi buah (Rp/kg)"
        numeric total_potongan_sortasi_rp "GENERATED: berat_bersih * potongan_sortasi"
        numeric total_nilai_jual "GENERATED: nilai bersih setelah seluruh potongan"
        text status "berangkat | selesai | dibatalkan"
        text catatan
        uuid created_by FK "profiles.id"
        timestamptz created_at
        timestamptz updated_at
    }

    JENIS_PENGELUARAN {
        uuid id PK
        text nama "Kategori Biaya Operasional"
        text deskripsi
        boolean is_active
        timestamptz created_at
        timestamptz updated_at
    }

    PENGELUARAN {
        uuid id PK
        date tanggal "Tanggal biaya dikeluarkan"
        uuid jenis_pengeluaran_id FK "jenis_pengeluaran.id"
        numeric nominal "Nominal biaya (Rp)"
        text keterangan "Detail peruntukan uang"
        uuid created_by FK "profiles.id"
        timestamptz created_at
        timestamptz updated_at
    }

    TOPUP_SALDO {
        uuid id PK
        date tanggal "Tanggal penambahan modal kas"
        numeric nominal "Nominal modal tunai (Rp)"
        text keterangan
        uuid created_by FK "profiles.id"
        timestamptz created_at
        timestamptz updated_at
    }
```

---

### 1.2 Diagram Arsitektur Database View (Reporting & Analitik)

Untuk menjaga performa dan integritas matematis, Flutter client membaca agregasi data melalui Database Views yang terisolasi:

```mermaid
flowchart TD
    subgraph TABEL_DASAR ["Tabel Transaksional (Physical Tables)"]
        T1[(transaksi)]
        T2[(transaksi_item)]
        T3[(penjual)]
        T4[(pengiriman_pabrik)]
        T5[(pabrik)]
        T6[(jenis_pengeluaran)]
        T7[(pengeluaran)]
        T8[(topup_saldo)]
    end

    subgraph VIEW_PEMBELIAN ["View Modul Pembelian Petani"]
        V1["v_transaksi_ringkasan<br/><i>(Total berat kotor, bersih, potongan, jenis bayar & nilai)</i>"]
        V2["v_transaksi_harian<br/><i>(Akumulasi tonase dan omzet harian petani)</i>"]
        V3["v_breakdown_jenis_buah<br/><i>(Proporsi volume TB, TK, BR harian)</i>"]
        V8["v_transaksi_non_tunai_harian<br/><i>(Agregasi transaksi non-tunai)</i>"]
    end

    subgraph VIEW_PENJUALAN ["View Modul Penjualan Pabrik"]
        V4["v_pengiriman_ringkasan<br/><i>(Detail pengiriman truk, supir, susut & sortasi)</i>"]
        V5["v_pengiriman_harian<br/><i>(Total tonase kirim & nilai jual harian)</i>"]
        V6["v_breakdown_pabrik<br/><i>(Distribusi volume penjualan per pabrik)</i>"]
    end

    subgraph VIEW_MARGIN ["View Analitik, Saldo & Laba Bersih"]
        V7["v_margin_harian<br/><i>(Total Beli vs Total Jual vs Margin Bersih Harian)</i>"]
        V9["v_saldo_ringkasan<br/><i>(Total Topup, Pemakaian Kas Tunai, & Sisa Saldo)</i>"]
        V10["v_laporan_pendapatan_harian<br/><i>(Laba Kotor, Biaya Operasional, & Laba Bersih)</i>"]
    end

    subgraph CLIENT_OUTPUT ["Konsumsi di Sisi Flutter Client"]
        C1["Dashboard: Kartu Ringkasan Hari Ini, Minggu Ini, Bulan Ini"]
        C2["Dashboard: Grafik Tren & Donut Chart Proporsi"]
        C3["Ekspor: Laporan Pembelian & Laporan Pabrik (Excel/PDF)"]
        C4["Ekspor: Laporan Pendapatan 1 Bulan, 3 Bulan, 1 Tahun (Admin Only)"]
    end

    T1 --> V1
    T2 --> V1
    T3 --> V1
    V1 --> V2
    T2 --> V3
    T1 --> V3

    T4 --> V4
    T5 --> V4
    V4 --> V5
    T4 --> V6
    T5 --> V6

    V2 --> V7
    V5 --> V7

    V1 & V2 --> C1
    V3 & V6 --> C2
    V1 & V4 --> C3
    V7 --> C4
```

---

## 2. Use Case Diagram Sistem

Use Case Diagram menggambarkan interaksi antara para pengguna sistem (**Aktor**) dengan fungsi-fungsi utama aplikasi, lengkap dengan relasi kepemilikan dan batas hak akses (*Role-Based Access Control*).

### 2.1 Diagram Use Case Global (Admin, Kasir, & Sistem)

```mermaid
flowchart LR
    %% Aktor
    subgraph AKTOR ["Aktor Pengguna"]
        Admin["👤 Admin (Pemilik Usaha)"]
        Kasir["👤 Kasir (Operator Timbangan)"]
        Sistem["⚙️ Sistem Background / Engine"]
    end

    %% Batas Sistem
    subgraph SISTEM_TBS ["Aplikasi Transaksi Timbangan Sawit (TBS)"]

        subgraph UC_AUTH ["1. Autentikasi & Keamanan Sesi"]
            UC1(["Masuk Akun (Login)"])
            UC2(["Keluar Sesi (Logout)"])
            UC3(["Pengecekan Kedaluwarsa Sesi 24 Jam"])
        end

        subgraph UC_PETANI ["2. Modul Pembelian TBS Petani"]
            UC4(["Kelola Data Petani (Tambah / Edit / Cari)"])
            UC5(["Catat Transaksi Pembelian Baru (Multi-Item)"])
            UC5a(["Hitung Potongan Timbangan (% / kg)"]):::includeCase
            UC5b(["Generate Kode Transaksi Otomatis"]):::includeCase
            UC6(["Lihat Riwayat Transaksi & Filter Periode (Termasuk Kustom)"])
            UC7(["Batalkan Transaksi (Void) dengan Alasan"])
        end

        subgraph UC_PABRIK ["3. Modul Penjualan TBS ke Pabrik (PKS)"]
            UC8(["Kelola Master Data Pabrik"])
            UC9(["Catat Truk Berangkat (Fase 1: Timbang Ram)"])
            UC10(["Input Tiket & Selesaikan Pengiriman (Fase 2)"])
            UC11(["Lihat Riwayat Pengiriman Pabrik & Filter"])
        end

        subgraph UC_DASHBOARD ["4. Modul Dashboard & Analitik"]
            UC12(["Pantau Kartu Ringkasan (Hari Ini, Minggu Ini, Bulan Ini)"])
            UC13(["Filter Fleksibel Kartu Bulan Ini (Mode 1-4)"]):::adminOnly
            UC14(["Pantau Proporsi Volume Buah & Pabrik"])
            UC15(["Pantau Tab Margin Keuntungan & Laba Bersih"]):::adminOnly
            UC16(["Pantau Grafik Tren Nilai & Tonase"]):::adminOnly
        end

        subgraph UC_EXPORT ["5. Modul Ekspor Laporan"]
            UC17(["Ekspor Laporan Pembelian Petani (Excel/PDF)"])
            UC18(["Ekspor Laporan Pengiriman Pabrik (Excel/PDF)"])
            UC19(["Ekspor Laporan Pendapatan (1 Bulan/3 Bulan/1 Tahun)"]):::adminOnly
        end
    end

    classDef adminOnly fill:#e8f0fe,stroke:#0f62fe,stroke-width:2px;
    classDef includeCase fill:#f4f4f4,stroke:#8d8d8d,stroke-dasharray: 5 5;

    %% Relasi Kasir (Akses Operasional)
    Kasir --> UC1
    Kasir --> UC2
    Kasir --> UC4
    Kasir --> UC5
    Kasir --> UC6
    Kasir --> UC7
    Kasir --> UC8
    Kasir --> UC9
    Kasir --> UC10
    Kasir --> UC11
    Kasir --> UC12
    Kasir --> UC14
    Kasir --> UC17
    Kasir --> UC18

    %% Relasi Admin (Akses Penuh: Seluruh Kasir + Eksekutif Keuangan)
    Admin --> UC1
    Admin --> UC2
    Admin --> UC4
    Admin --> UC5
    Admin --> UC6
    Admin --> UC7
    Admin --> UC8
    Admin --> UC9
    Admin --> UC10
    Admin --> UC11
    Admin --> UC12
    Admin --> UC13
    Admin --> UC14
    Admin --> UC15
    Admin --> UC16
    Admin --> UC17
    Admin --> UC18
    Admin --> UC19

    %% Relasi Sistem Engine
    Sistem --> UC3
    UC1 -.->|"<<extend>>"| UC3
    UC5 -.->|"<<include>>"| UC5a
    UC5 -.->|"<<include>>"| UC5b
```

---

### 2.2 Matriks Hak Akses Aktor (Role-Based Access Control)

| Modul & Use Case | Kasir (Operator) | Admin (Pemilik) | Keterangan Akses |
|---|:---:|:---:|---|
| **Masuk Akun (Login) & Keluar Sesi (Logout)** | Ya | Ya | Didukung pengecekan usia sesi maksimal 24 jam. |
| **Kelola Data Petani (Tambah / Edit / Cari)** | Ya | Ya | Pencarian cepat berbasis nama, telepon, atau alamat desa. |
| **Catat Pembelian TBS Petani (Multi-Item)** | Ya | Ya | Mendukung hingga 3 baris jenis buah dalam 1 nota timbang. |
| **Hitung Potongan Timbangan (% atau kg)** | Ya | Ya | Sistem otomatis menghitung potongan berat & berat bersih. |
| **Riwayat Transaksi Petani & Filter Periode** | Ya | Ya | Filter: Hari Ini, 1 & 2 Minggu, 1, 3, 6 Bulan, 1 Tahun, Semua, serta Kustom Tanggal. |
| **Batalkan Transaksi (Void) dengan Alasan** | Ya | Ya | Wajib mencantumkan alasan pembatalan demi audit pembukuan. |
| **Kelola Master Pabrik Kelapa Sawit** | Ya | Ya | Mendaftarkan nama pabrik, kontak, dan alamat PKS. |
| **Catat Keberangkatan Truk (Fase 1: Timbang Ram)** | Ya | Ya | Truk berangkat dengan status *Dalam Perjalanan*. |
| **Input Tiket Pabrik & Sortasi (Fase 2: Selesai)** | Ya | Ya | Input berat ditolak, potongan %, dan harga final pabrik. |
| **Lihat Riwayat Pengiriman ke Pabrik** | Ya | Ya | Memantau tonase & status truk dengan filter periode standar & kustom. |
| **Lihat Kartu Ringkasan Dashboard** | Ya | Ya | Ringkasan omzet dan tonase Hari Ini, Minggu Ini, Bulan Ini. |
| **Atur Filter Khusus Kartu Bulan Ini** | **Tidak** | **Ya** | Mode bulan berjalan, pilih bulan, 1 tahun penuh, atau rentang kustom. |
| **Lihat Proporsi Donut Chart (Buah & Pabrik)** | Ya | Ya | Distribusi volume Tandan Besar/Kecil/Berondolan & pabrik tujuan. |
| **Lihat Tab Margin Keuntungan Usaha** | **Tidak** | **Ya** | Disembunyikan dari Kasir demi kerahasiaan profit ram sawit. |
| **Lihat Grafik Tren Nilai & Tonase** | **Tidak** | **Ya** | Disembunyikan dari Kasir, hanya tampak pada Dashboard Admin. |
| **Ekspor Laporan Pembelian & Pengiriman Pabrik** | Ya | Ya | Format Microsoft Excel (.xlsx) dan Dokumen PDF (.pdf). |
| **Ekspor Laporan Pendapatan (Laba Rugi)** | **Tidak** | **Ya** | Khusus Admin: Agregasi 1 Bulan (mingguan), 3 Bulan, 1 Tahun (kuartalan). |

---

### 2.3 Rincian Deskripsi Aktor & Skenario Use Case

#### Aktor Sistem:
1. **Kasir (Operator Timbangan)**:
   - Pengguna operasional harian yang bertugas di lokasi jembatan timbang ram sawit.
   - Bertanggung jawab menimbang buah petani, mendaftarkan petani baru, mencatat truk kirim ke pabrik, dan memasukkan tiket timbang pabrik yang kembali.
   - Tidak memiliki akses ke angka keuntungan bersih (*margin*) maupun laporan laba pendapatan.
2. **Admin (Pemilik Pengepul / Pimpinan Ram)**:
   - Pengguna dengan hak akses tertinggi (*super user*).
   - Memiliki seluruh kewenangan Kasir ditambah kemampuan mengevaluasi kesehatan finansial, memantau tren harga beli vs harga jual, mengontrol filter kartu dashboard, dan mengunduh Laporan Pendapatan berkala.
3. **Sistem (Background Engine / Supabase Auth)**:
   - Entitas otomatis yang memvalidasi otentikasi, menjalankan timer periodik pengecekan kedaluwarsa sesi (24 jam), melakukan komputasi generated column database, serta menyusun nomor urut kode transaksi (`TRX-...` / `KRM-...`).

---

## 3. Flowchart Sistem & Alur Kerja Bisnis

### 3.1 Alur Autentikasi & Keamanan Sesi 24 Jam

Flowchart ini menggambarkan mekanisme login, pengecekan usia sesi (maksimal 24 jam) di dua titik (saat aplikasi dibuka & timer periodik), serta pembatasan peran (*Role-Based Access Control*).

```mermaid
flowchart TD
    Start([Pengguna Membuka Aplikasi]) --> CheckSession{Ada Session Aktif?}
    
    CheckSession -- Tidak --> LoginPage[Tampilkan Halaman Login]
    CheckSession -- Ya --> CheckAgeA{Usia Sesi Sejak Login<br/>> 24 Jam?}

    CheckAgeA -- Ya (Kedaluwarsa) --> AutoLogoutA[Paksa Logout / Clear Session Storage]
    AutoLogoutA --> BannerMsg["Tampilkan Banner Oranye:<br/>'Sesi login Anda telah berakhir (24 jam)'"]
    BannerMsg --> LoginPage

    CheckAgeA -- Tidak (Valid) --> StartTimer[Nyalakan Timer Periodik<br/>Pengecekan Sesi di Background]
    
    LoginPage --> InputCred[Input Email & Kata Sandi]
    InputCred --> ClickLogin[Klik 'Masuk ke Sistem']
    ClickLogin --> AuthSupabase{Verifikasi Kredensial<br/>di Supabase Auth}
    
    AuthSupabase -- Gagal --> ShowErr[Tampilkan Pesan Error / Validasi]
    ShowErr --> LoginPage
    
    AuthSupabase -- Berhasil --> SaveTime[Simpan Waktu Login Sekarang<br/>di Local Storage]
    SaveTime --> GetRole[Ambil Profil & Role dari Database]
    GetRole --> StartTimer
    
    StartTimer --> CheckRole{Apakah Role = Admin?}
    
    CheckRole -- Ya (Admin) --> AdminDash[Dashboard Admin Lengkap:<br/>- Akses Seluruh Grafik Tren & Tab Margin<br/>- Filter Periode Bebas s/d 1 Tahun<br/>- Tombol & Menu Laporan Pendapatan Aktif]
    
    CheckRole -- Tidak (Kasir) --> KasirDash[Dashboard Kasir Terbatas:<br/>- Sembunyikan Tab Margin Keuntungan<br/>- Sembunyikan Seluruh Grafik Tren Nilai<br/>- Filter Maksimal 1 Bulan<br/>- Menu Laporan Pendapatan Disembunyikan]

    StartTimer -.-> PeriodikCheck{Timer 1 Menit:<br/>Waktu Sekarang - Waktu Login > 24 Jam?}
    PeriodikCheck -- Ya --> AutoLogoutB[Paksa Logout Seketika]
    AutoLogoutB --> BannerMsg
    PeriodikCheck -- Tidak --> KeepRunning[Tetap Bekerja Normal]
```

---

### 3.2 Alur Transaksi Pembelian TBS Petani (Multi-Item & Potongan)

```mermaid
flowchart TD
    A([Petani Tiba Membawa TBS]) --> B[Kasir Buka Menu 'Transaksi Baru']
    B --> C[Cari & Pilih Nama Petani]
    C --> D{Petani Sudah Terdaftar?}
    
    D -- Belum --> E[Klik '+ Tambah Penjual'<br/>Isi Nama, No HP, Alamat Desa]
    E --> F[Simpan Data Petani]
    F --> G[Pilih Petani yang Baru Dibuat]
    D -- Sudah --> G
    
    G --> H[Pilih Jenis Buah Baris 1:<br/>Tandan Besar / Tandan Kecil / Berondolan]
    H --> I[Input Berat Kotor Timbangan kg]
    I --> J[Input Harga Beli per kg Rp]
    J --> K[Input Potongan Timbangan:<br/>Pilihan Persen % atau Kilogram kg]
    
    K --> L{Ada Jenis Buah Lain<br/>dalam 1 Kendaraan?}
    L -- Ya (Maks 3 Baris) --> M[Klik '+ Tambah Jenis Buah']
    M --> H
    L -- Tidak --> N[Sistem Menghitung Otomatis:<br/>- Berat Bersih Tiap Item<br/>- Nilai Potongan Rp<br/>- Subtotal Rp Tiap Item<br/>- Total Bersih & Total Pembayaran]
    
    N --> O[Kasir & Petani Memeriksa Live Preview Ringkasan]
    O --> P{Data Sudah Sesuai?}
    P -- Perlu Koreksi --> H
    P -- Sesuai --> Q[Klik Tombol 'Simpan Transaksi']
    
    Q --> R[Database Menyimpan Transaksi<br/>Kode Unik: TRX-YYYYMMDD-XXXX<br/>Status: Selesai]
    R --> S[Kasir Menyerahkan Uang Pembayaran<br/>sesuai Total Nilai Nota]
    S --> End([Transaksi Pembelian Selesai])
```

---

### 3.3 Alur Pembatalan Transaksi Pembelian (Void)

```mermaid
flowchart TD
    A([Kasir Menyadari Salah Input Nota]) --> B[Buka Menu 'Riwayat Transaksi']
    B --> C[Pilih Transaksi yang Ingin Dibatalkan]
    C --> D[Buka Halaman Detail Nota]
    D --> E[Klik Tombol Merah 'Batalkan Transaksi']
    
    E --> F[Muncul Dialog Konfirmasi Pembatalan]
    F --> G[Kasir Wajib Mengisi 'Alasan Pembatalan'<br/><i>Contoh: Kelebihan digit nol pada berat kotor</i>]
    
    G --> H{Alasan Sudah Diisi?}
    H -- Kosong --> I[Tombol Konfirmasi Tetap Dinonaktifkan]
    I --> G
    H -- Terisi --> J[Klik 'Konfirmasi Batal']
    
    J --> K[Database Memperbarui Status:<br/>status = 'dibatalkan'<br/>alasan_pembatalan = text<br/>updated_at = now()]
    
    K --> L[View Menarik Kembali Nilai Rupiah & Tonase<br/>dari Perhitungan Omzet & Laporan]
    L --> M[Nota Ditandai Merah: 'DIBATALKAN'<br/><i>(Data Tidak Dihapus Permanen Demi Audit)</i>]
    M --> End([Pembatalan Selesai])
```

---

### 3.4 Alur Penjualan ke Pabrik (Alur Dua Fase Pengiriman)

```mermaid
flowchart TD
    subgraph FASE_1 ["FASE 1: Keberangkatan Truk dari Ram Timbangan"]
        A1([Buah Dimuat ke Truk]) --> B1[Kasir Buka 'Pengiriman ke Pabrik']
        B1 --> C1[Klik '+ Kirim TBS ke Pabrik']
        C1 --> D1[Pilih Pabrik Tujuan, Plat Nomor, Nama Supir]
        D1 --> E1[Timbang Truk di Ram:<br/>Input Berat Kotor Ram kg]
        E1 --> F1[Input Estimasi Harga Jual/kg]
        F1 --> G1[Klik 'Simpan Pengiriman']
        G1 --> H1[Status Pengiriman:<br/>KUNING 'Dalam Perjalanan'<br/>Kode: KRM-YYYYMMDD-XXXX]
        H1 --> I1([Truk Berangkat ke Pabrik])
    end

    subgraph FASE_2 ["FASE 2: Kepulangan Supir Membawa Tiket Timbangan Pabrik (SPB)"]
        I1 -. Perjalanan & Timbang di PKS .-> A2([Supir Pulang Membawa Tiket Pabrik])
        A2 --> B2[Kasir Buka 'Riwayat Pengiriman']
        B2 --> C2[Cari Truk Berstatus 'Dalam Perjalanan']
        C2 --> D2[Klik 'Selesaikan / Input Nota Pabrik']
        D2 --> E2[Input Berat Ditolak / Sortasi kg<br/><i>(Otomatis divalidasi: <= Berat Kotor)</i>]
        E2 --> F2[Input Potongan Wajib Pabrik %]
        F2 --> G2[Input Harga Resmi Final Pabrik Rp/kg]
        G2 --> H2[Sistem Otomatis Menghitung:<br/>1. Berat Diterima = Kotor - Ditolak<br/>2. Berat Bersih = Diterima * (1 - Potongan%)<br/>3. Total Nilai Jual = Harga * Berat Bersih]
        H2 --> I2[Klik 'Konfirmasi Selesai']
        I2 --> J2[Status Berubah: HIJAU 'Selesai']
        J2 --> K2([Pencatatan Penjualan Pabrik Lengkap])
    end
```

---

### 3.5 Alur Ekspor Laporan Pendapatan (Khusus Admin)

```mermaid
flowchart TD
    A([Pemilik / Admin Buka Aplikasi]) --> B[Klik 'Laporan Pendapatan' di Header/Sidebar]
    B --> C[Muncul Modal Dialog 'Ekspor Laporan Pendapatan']
    
    C --> D[Pilih Cakupan Periode Evaluasi]
    
    D --> E1[Pilihan '1 Bulan']
    D --> E2[Pilihan '3 Bulan']
    D --> E3[Pilihan '1 Tahun']
    
    E1 --> F1[Pilih Bulan & Tahun<br/><i>Contoh: September 2026</i>]
    F1 --> G1[Agregasi Sisi Flutter (Per Minggu):<br/>- Minggu 1: tgl 1-7<br/>- Minggu 2: tgl 8-14<br/>- Minggu 3: tgl 15-21<br/>- Minggu 4: tgl 22-28<br/>- Minggu 5: tgl 29-akhir bulan]
    
    E2 --> F2[Pilih Kuartal & Tahun<br/><i>Contoh: Kuartal 3 (Jul-Sep) 2026</i>]
    F2 --> G2[Agregasi Sisi Flutter (Per Bulan):<br/>- Bulan 1 (Juli)<br/>- Bulan 2 (Agustus)<br/>- Bulan 3 (September)]
    
    E3 --> F3[Pilih Tahun Kalender<br/><i>Contoh: Tahun 2026</i>]
    F3 --> G3[Agregasi Sisi Flutter (Per Kuartal):<br/>- Kuartal 1: Jan-Mar<br/>- Kuartal 2: Apr-Jun<br/>- Kuartal 3: Jul-Sep<br/>- Kuartal 4: Okt-Des]
    
    G1 & G2 & G3 --> H[Sistem Menghitung untuk Setiap Baris:<br/>1. Total Pembelian Petani Rp<br/>2. Total Penjualan Pabrik Rp<br/>3. Margin Bersih = Penjualan - Pembelian<br/>4. Baris TOTAL KESELURUHAN]
    
    H --> I[Pratinjau Tabel Muncul Seketika di Layar<br/>- Angka Surplus berwarna Hijau/Biru<br/>- Angka Defisit berwarna Merah minus]
    
    I --> J{Pilih Format Dokumen}
    
    J -- Excel (.xlsx) --> K[Klik 'Unduh EXCEL'<br/>Laporan Pendapatan berformat XLSX IBM Carbon]
    J -- PDF (.pdf) --> L[Klik 'Unduh PDF'<br/>Dokumen Cetak Resmi A4 Portrait]
    
    K & L --> M[Browser / HP Mengunduh File Laporan]
    M --> End([Laporan Siap untuk Arsip / Rapat Evaluasi])
```

---

## 4. Diagram Fishbone (Ishikawa) — Akar Masalah & Solusi

Diagram Fishbone ini mengurai mengapa operasional timbangan sawit konvensional (menggunakan buku nota kertas & kalkulator manual) kerap mengalami kebocoran kas, perselisihan hitungan, dan ketidakpastian laba, serta bagaimana sistem ini menyelesaikannya secara tuntas.

### 4.1 Diagram Tulang Ikan (6M)

```mermaid
graph LR
    subgraph MAN ["1. MAN (SDM / Operator)"]
        M1["Salah ketik angka kalkulator"]
        M2["Kecurangan selisih timbang kasir"]
        M3["Lupa logout saat pergantian shift"]
    end

    subgraph METHOD ["2. METHOD (Metode Prosedur)"]
        ME1["Nota kertas tercecer / basah kena hujan"]
        ME2["Aturan potongan sampah tidak konsisten"]
        ME3["Truk kirim pabrik tidak terpantau statusnya"]
    end

    subgraph MACHINE ["3. MACHINE (Alat & Software)"]
        MC1["Floating-point error komputer biasa"]
        MC2["Sistem tidak punya soft delete / audit log"]
        MC3["Tanpa sinkronisasi database cloud"]
    end

    subgraph MATERIAL ["4. MATERIAL (Karakteristik TBS)"]
        MT1["TBS campur: Tandan Besar, Kecil, Berondolan"]
        MT2["Sampah tangkai panjang & pasir ikut tertimbang"]
        MT3["Penyusutan bobot restan bermalam"]
    end

    subgraph MEASUREMENT ["5. MEASUREMENT (Pengukuran & Laporan)"]
        MS1["Selisih timbangan ram vs timbangan pabrik"]
        MS2["Tidak tahu laba/margin harian secara seketika"]
        MS3["Rekap pembukuan bulanan butuh berhari-hari"]
    end

    subgraph MILIEU ["6. MILIEU (Lingkungan Lapangan)"]
        ML1["Sinyal internet di pedalaman kebun naik-turun"]
        ML2["Tekanan antrean truk panjang memicu ketergesaan"]
        ML3["Debu timbangan & kondisi lapangan keras"]
    end

    %% Cabang Menuju Masalah Utama
    MAN --> PROBLEM
    METHOD --> PROBLEM
    MACHINE --> PROBLEM
    MATERIAL --> PROBLEM
    MEASUREMENT --> PROBLEM
    MILIEU --> PROBLEM

    PROBLEM["<b>MASALAH UTAMA:</b><br/>Kebocoran Kas Keuangan,<br/>Perselisihan Petani & Pabrik,<br/>Serta Ketidakpastian Margin Usaha Ram"]
```

---

### 4.2 Matriks Masalah vs Solusi Aplikasi Transaksi Sawit

Berikut adalah rangkuman bagaimana fitur-fitur yang dibangun dari Bagian 1 hingga Bagian 19 menuntaskan setiap akar masalah di atas:

| Kategori 6M | Akar Masalah Lapangan | Solusi Nyata pada Aplikasi (v1.8.1) |
|---|---|---|
| **MAN (SDM)** | Kasir salah hitung atau curang | Perhitungan otomatis tanpa kalkulator, hak akses Kasir dibatasi (RBAC), pembatalan nota wajib isi alasan audit. |
| **MAN (SDM)** | Komputer timbangan ditinggal terbuka | **Keamanan Sesi 24 Jam**: Aplikasi otomatis logout jika sesi sudah lebih dari 24 jam. |
| **METHOD** | Nota kertas hilang atau sobek | Seluruh transaksi tersimpan permanen di cloud database Supabase dengan nomor kode unik (`TRX-...`). |
| **METHOD** | Pengiriman truk ke pabrik tidak terkontrol | **Alur Dua Fase Pengiriman**: Memisahkan fase keberangkatan truk dan fase pengembalian tiket timbang pabrik. |
| **MACHINE** | Selisih desimal uang pada komputasi digital | Menggunakan tipe data presisi tinggi `Decimal` (anti-*floating point error*) dan formula `GENERATED ALWAYS AS STORED` di database. |
| **MATERIAL** | Petani membawa aneka jenis buah sawit | **Form Multi-Item**: Mendukung 3 jenis buah (Tandan Besar, Tandan Kecil, Berondolan) dalam 1 nota timbang. |
| **MATERIAL** | Pemotongan sampah pasir/tangkai panjang | **Potongan Level Item**: Bisa diisi persen (%) atau kilogram (kg) per jenis buah secara adil dan transparan. |
| **MEASUREMENT**| Susut timbangan & sortasi pabrik | Form pengiriman mencatat berat kotor ram, buah ditolak/sortasi, dan potongan kadar air PKS secara terpisah. |
| **MEASUREMENT**| Pemilik tidak tahu keuntungan bersih | **Dashboard Analitik & Margin**: Real-time memantau selisih jual pabrik vs beli petani per hari/bulan/tahun. |
| **MEASUREMENT**| Rekapitulasi laporan pembukuan lambat | **Ekspor 1-Klik**: Laporan Pendapatan (mingguan, bulanan, kuartalan) langsung terbit dalam format Excel dan PDF siap cetak. |
| **MILIEU** | Koneksi internet minim di area perkebunan | Arsitektur responsif, caching lokal cepat, dan persiapan integrasi *Offline-First* (PowerSync). |

---

*Dokumen ini merupakan spesifikasi visual resmi arsitektur sistem Aplikasi Transaksi Timbangan Sawit (TBS).*
