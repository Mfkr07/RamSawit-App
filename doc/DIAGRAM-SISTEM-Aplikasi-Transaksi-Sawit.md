# ARSITEKTUR VISUAL & DIAGRAM SISTEM — RAMSAWIT
## Aplikasi Kasir & Manajemen Loading Ramp Transaksi Buah Kelapa Sawit (TBS)

> **Dokumen Diagram Resmi: Arsitektur Ekosistem 3-Repo, ERD Cloud & Lokal, Use Case RBAC, Flowchart Alur Bisnis, Offline Sync Engine, dan Analisis Fishbone (Ishikawa)**  
> *Versi Sistem: 2.5.4 (Build 9) | Database: PostgreSQL 15+ (Supabase) + SQLite (Drift) | Framework: Flutter Native*

---

## DAFTAR ISI DIAGRAM

1. [Arsitektur Ekosistem Sistem Terdistribusi (3-Repo)](#1-arsitektur-ekosistem-sistem-terdistribusi-3-repo)
2. [Entity Relationship Diagram (ERD) Lengkap](#2-entity-relationship-diagram-erd-lengkap)
   - 2.1 Diagram ERD 10 Tabel Fisik Cloud (Supabase PostgreSQL)
   - 2.2 Diagram Arsitektur 12 Database Views (Analitik & Agregasi)
   - 2.3 Diagram Skema Basis Data Lokal Drift SQLite (Offline-First)
3. [Use Case Diagram Sistem & Matriks RBAC](#3-use-case-diagram-sistem--matriks-rbac)
   - 3.1 Use Case Global (Admin, Kasir, & Sistem)
   - 3.2 Matriks Hak Akses Aktor (Role-Based Access Control)
4. [Flowchart Sistem & Alur Kerja Bisnis](#4-flowchart-sistem--alur-kerja-bisnis)
   - 4.1 Alur Autentikasi, Setup Organisasi BYOD, & Sesi 24 Jam
   - 4.2 Alur Transaksi Pembelian TBS Petani (Multi-Item & Metode Bayar)
   - 4.3 Alur Pembatalan Transaksi Pembelian (Void)
   - 4.4 Alur Penjualan Pabrik (Dua Fase Pengiriman & Audit Susut/Sortasi)
   - 4.5 Alur Offline-First & Sinkronisasi Dua Arah (`SyncEngine`)
   - 4.6 Alur Konsultasi AI Analytics Advisor & Fallback Deterministik
   - 4.7 Alur Ekspor Laporan Pendapatan Berjenjang
5. [Diagram Fishbone (Ishikawa) — Akar Masalah & Solusi Nyata](#5-diagram-fishbone-ishikawa--akar-masalah--solusi-nyata)

---

## 1. Arsitektur Ekosistem Sistem Terdistribusi (3-Repo)

Sistem RamSawit dikelola dalam tiga repositori mandiri yang saling terintegrasi:

```mermaid
graph LR
    subgraph Repo1 ["1. Repo Kasir_TBS_Sawit (Legacy Master)"]
        LegacyWeb["Aplikasi Web Tunggal Eksisting<br/>(Supabase Single-Tenant)"]
    end

    subgraph Repo2 ["2. Repo RamSawit_Portal (Distributor & Landing)"]
        Landing["Landing Page Produk & SOP<br/>(HTML5 / Tailwind CSS)"]
        VersionMeta["Metadata version.json<br/>(v2.5.4 / Build 9)"]
        Releases["Distribusi Rilis Langsung:<br/>- RamSawit_V.2.5.4.apk<br/>- RamSawit_Windows_v2.5.4.zip"]
        VercelLive["Live Deployment Vercel:<br/>ramsawit-portal.vercel.app"]
    end

    subgraph Repo3 ["3. Repo RamSawit_App (Native Multi-Platform)"]
        WinExe["RamSawit.exe (Windows Desktop x64)"]
        AndroidApk["RamSawit.apk (Android Mobile)"]
        DriftCore["Drift SQLite (sawit_offline_db.sqlite)"]
        SyncCore["SyncEngine (Riverpod)"]
    end

    subgraph CloudTenant ["Cloud Tenant Organisasi (BYOD Supabase)"]
        TenantDB[("Supabase PostgreSQL 15+<br/>10 Tabel + 12 Views")]
        TenantAuth["Supabase Auth"]
    end

    Landing --> VercelLive
    VersionMeta --> VercelLive
    Releases --> VercelLive

    WinExe & AndroidApk -->|"1. Pengecekan Versi Otomatis"| VersionMeta
    WinExe & AndroidApk -->|"2. Tulis/Baca Lokal Instan"| DriftCore
    DriftCore <-->|"3. Sinkronisasi Data 30s"| SyncCore
    SyncCore <-->|"4. REST API / HTTPS"| TenantDB
    WinExe & AndroidApk -.->|"5. Verifikasi Sesi Login"| TenantAuth
```

---

## 2. Entity Relationship Diagram (ERD) Lengkap

### 2.1 Diagram ERD 10 Tabel Fisik Cloud (Supabase PostgreSQL)

```mermaid
erDiagram
    PROFILES ||--o{ PENJUAL : "mencatat (created_by)"
    PROFILES ||--o{ TRANSAKSI : "mencatat (created_by)"
    PROFILES ||--o{ PABRIK : "mencatat (created_by)"
    PROFILES ||--o{ PENGIRIMAN_PABRIK : "mencatat (created_by)"
    PROFILES ||--o{ PENGELUARAN : "mencatat (created_by)"
    PROFILES ||--o{ TOPUP_SALDO : "input_modal (created_by)"

    PENJUAL ||--o{ TRANSAKSI : "melakukan_penjualan"
    TRANSAKSI ||--|{ TRANSAKSI_ITEM : "memiliki_item (1..3)"
    JENIS_BUAH ||--o{ TRANSAKSI_ITEM : "diklasifikasikan_ke"

    PABRIK ||--o{ PENGIRIMAN_PABRIK : "menerima_tbs"
    JENIS_PENGELUARAN ||--o{ PENGELUARAN : "mengelompokkan_biaya"

    PROFILES {
        uuid id PK "auth.users uuid"
        text nama "Nama operator"
        text role "admin | kasir"
        timestamptz created_at
    }

    PENJUAL {
        uuid id PK
        text nama "Trigram index pg_trgm"
        text no_telepon
        text alamat
        text catatan
        boolean is_active
        uuid created_by FK
        timestamptz created_at
        timestamptz updated_at
    }

    JENIS_BUAH {
        smallint id PK
        text kode UK "TB | TK | BR"
        text nama UK "Tandan Besar | Kecil | Berondolan"
        boolean is_active
    }

    PABRIK {
        uuid id PK
        text nama "Trigram index pg_trgm"
        text alamat
        text kontak
        boolean is_active
        uuid created_by FK
        timestamptz created_at
        timestamptz updated_at
    }

    JENIS_PENGELUARAN {
        smallint id PK
        text nama UK
        boolean is_active
    }

    TRANSAKSI {
        uuid id PK
        text kode_transaksi UK "TRX-YYYYMMDD-XXXX"
        uuid penjual_id FK
        date tanggal_transaksi
        text status "draft | selesai | dibatalkan"
        text jenis_pembayaran "tunai | non_tunai"
        text catatan
        uuid created_by FK
        timestamptz created_at
        timestamptz updated_at
    }

    TRANSAKSI_ITEM {
        uuid id PK
        uuid transaksi_id FK
        smallint jenis_buah_id FK
        numeric harga_per_kg
        numeric berat_kotor_kg
        numeric persentase_potongan
        numeric berat_bersih_kg "GENERATED"
        numeric nilai_potongan_rp "GENERATED"
        numeric subtotal "GENERATED"
        timestamptz created_at
    }

    PENGIRIMAN_PABRIK {
        uuid id PK
        text kode_pengiriman UK "KRM-YYYYMMDD-XXXX"
        uuid pabrik_id FK
        text plat_nomor
        text nama_sopir
        date tanggal_kirim
        numeric berat_dikirim_kg
        numeric berat_sampai_kg
        numeric berat_ditolak_kg
        numeric persentase_potongan_pabrik
        numeric harga_jual_per_kg
        numeric potongan_lainnya_rp
        numeric potongan_sortasi_per_kg
        numeric berat_diterima_kg "GENERATED"
        numeric berat_bersih_kg "GENERATED"
        numeric susut_buah_kg "GENERATED"
        numeric nilai_potongan_rp "GENERATED"
        numeric nilai_potongan_sortasi_rp "GENERATED"
        numeric total_nilai_jual "GENERATED"
        text status "berangkat | selesai | dibatalkan"
        text catatan
        uuid created_by FK
        timestamptz created_at
        timestamptz updated_at
    }

    PENGELUARAN {
        uuid id PK
        date tanggal_pengeluaran
        smallint jenis_pengeluaran_id FK
        text keterangan
        numeric nominal
        text metode_pembayaran "tunai | non_tunai"
        uuid created_by FK
        timestamptz created_at
        timestamptz updated_at
    }

    TOPUP_SALDO {
        uuid id PK
        date tanggal
        numeric nominal
        text keterangan
        uuid created_by FK
        timestamptz created_at
    }
```

### 2.2 Diagram Arsitektur 12 Database Views (Analitik & Agregasi)

```mermaid
graph TD
    subgraph TABEL_DASAR ["Tabel Transaksional Supabase"]
        T1["transaksi"]
        T2["transaksi_item"]
        T3["penjual"]
        T4["pengiriman_pabrik"]
        T5["pabrik"]
        T6["pengeluaran"]
        T7["topup_saldo"]
    end

    subgraph VIEW_PEMBELIAN ["Views Pembelian Petani"]
        V1["v_transaksi_ringkasan<br/><i>(Header, Tonase Kotor/Bersih, Nilai, Metode Bayar)</i>"]
        V2["v_transaksi_harian<br/><i>(Tren Tonase & Nilai Beli Harian)</i>"]
        V3["v_breakdown_jenis_buah<br/><i>(Distribusi Volume TB, TK, BR)</i>"]
        V12["v_transaksi_non_tunai_harian<br/><i>(Monitoring Transfer Bank)</i>"]
    end

    subgraph VIEW_PABRIK ["Views Penjualan ke Pabrik"]
        V4["v_pengiriman_ringkasan<br/><i>(Rincian Truk, Pabrik, Susut, Sortasi)</i>"]
        V5["v_pengiriman_harian<br/><i>(Tren Tonase Kirim, Bersih, Nilai Jual)</i>"]
        V6["v_breakdown_pabrik<br/><i>(Distribusi Volume per Pabrik Tujuan)</i>"]
    end

    subgraph VIEW_KEUANGAN ["Views Finansial & Saldo Kas"]
        V7["v_margin_harian<br/><i>(Penjualan Pabrik - Pembelian Petani)</i>"]
        V8["v_pengeluaran_harian<br/><i>(Biaya Operasional Harian)</i>"]
        V9["v_breakdown_jenis_pengeluaran<br/><i>(Distribusi per Kategori Biaya)</i>"]
        V10["v_laba_bersih_harian<br/><i>(Margin Kotor - Pengeluaran)</i>"]
        V11["v_saldo_ringkasan<br/><i>(Topup - Pembelian TUNAI Selesai)</i>"]
    end

    subgraph FLUTTER_OUTPUT ["Konsumsi Antarmuka Flutter"]
        OUT1["Dashboard Ringkasan & FlChart Tren"]
        OUT2["Modul Saldo & Kas Modal Kasir"]
        OUT3["Ekspor Excel & PDF (Nota & Laba Pendapatan)"]
    end

    T1 & T2 & T3 --> V1
    V1 --> V2
    T1 & T2 --> V3
    V1 --> V12

    T4 & T5 --> V4
    V4 --> V5
    T4 & T5 --> V6

    V2 & V5 --> V7
    T6 --> V8
    T6 --> V9
    V7 & V8 --> V10
    T7 & V1 --> V11

    V1 & V2 & V4 & V5 & V7 & V10 --> OUT1
    V11 & V12 --> OUT2
    V1 & V4 & V8 & V10 & V11 --> OUT3
```

### 2.3 Diagram Skema Basis Data Lokal Drift SQLite (Offline-First)

```mermaid
classDiagram
    class SyncColumns {
        <<Mixin>>
        +bool isSynced
        +String deviceId
        +DateTime localUpdatedAt
        +DateTime deletedAt
    }

    class LocalPenjual {
        +String id (UUID)
        +String nama
        +String noTelepon
        +String alamat
        +bool isActive
    }

    class LocalTransaksi {
        +String id (UUID)
        +String kodeTransaksi
        +String penjualId
        +DateTime tanggalTransaksi
        +String status
        +String jenisPembayaran
    }

    class LocalTransaksiItem {
        +String id (UUID)
        +String transaksiId
        +int jenisBuahId
        +String hargaPerKg (Decimal)
        +String beratKg (Decimal)
        +String subtotal (Decimal)
    }

    class LocalPengirimanPabrik {
        +String id (UUID)
        +String noSpb
        +String pabrikId
        +DateTime tanggalKirim
        +String status
        +String beratKirimKg (Decimal)
    }

    class LocalPengeluaran {
        +String id (UUID)
        +int jenisPengeluaranId
        +String nominal (Decimal)
        +String metodePembayaran
        +DateTime tanggal
    }

    class LocalTopupSaldo {
        +String id (UUID)
        +String nominal (Decimal)
        +DateTime tanggal
        +String keterangan
    }

    SyncColumns <|-- LocalPenjual
    SyncColumns <|-- LocalTransaksi
    SyncColumns <|-- LocalTransaksiItem
    SyncColumns <|-- LocalPengirimanPabrik
    SyncColumns <|-- LocalPengeluaran
    SyncColumns <|-- LocalTopupSaldo
```

---

## 3. Use Case Diagram Sistem & Matriks RBAC

### 3.1 Use Case Global (Admin, Kasir, & Sistem)

```mermaid
flowchart LR
    Admin["👤 Admin (Pemilik Usaha)"]
    Kasir["👤 Kasir (Operator Timbangan)"]
    Sistem["⚙️ Sistem Engine (Drift, Sync, Vercel)"]

    subgraph SISTEM_RAMSAWIT ["Aplikasi RamSawit (v2.5.4)"]
        subgraph UC_TENANT ["Setup Organisasi & Keamanan"]
            UC_BYOD(["Setup Organisasi & Database BYOD"])
            UC_AUTH(["Masuk Akun (Login Email/Password)"])
            UC_SESSION(["Validasi Usia Sesi (Maksimal 24 Jam)"])
            UC_UPDATE(["Cek & Dialog Auto-Update Versi Baru"])
        end

        subgraph UC_OPERASIONAL ["Modul Operasional Timbangan"]
            UC_PETANI(["Kelola & Cari Petani (Trigram Search)"])
            UC_TRX(["Input Pembelian TBS (Multi-Item & Potongan %)"])
            UC_BAYAR(["Pilih Metode Pembayaran (Tunai / Non Tunai)"])
            UC_VOID(["Batalkan Transaksi (Void) dengan Alasan"])
            UC_PABRIK1(["Catat Truk Berangkat (Fase 1: Ramp)"])
            UC_PABRIK2(["Input Hasil Tiket PKS (Fase 2: Sortasi & Susut)"])
            UC_PENGELUARAN(["Catat Biaya Operasional (BBM, Upah, Konsumsi)"])
        end

        subgraph UC_EKSEKUTIF ["Modul Eksekutif & Analitik Bisnis"]
            UC_SALDO(["Pantau Sisa Saldo Kas Modal & Mutasi Harian"]):::adminOnly
            UC_TOPUP(["Input Top Up Saldo Kas Modal"]):::adminOnly
            UC_MARGIN(["Pantau Tab Margin & Laba Bersih"]):::adminOnly
            UC_TREN(["Pantau Grafik Tren Nilai & Tonase"]):::adminOnly
            UC_EXP_REV(["Ekspor Laporan Pendapatan Berjenjang"]):::adminOnly
            UC_AI(["Konsultasi AI Analytics Advisor"])
        end

        subgraph UC_SYNC ["Engine Offline-First"]
            UC_OFFLINE(["Simpan Transaksi ke SQLite Lokal"])
            UC_BG_SYNC(["Sinkronisasi Dua Arah Otomatis (30s)"])
        end
    end

    classDef adminOnly fill:#e8f0fe,stroke:#0f62fe,stroke-width:2px;

    Kasir --> UC_AUTH
    Kasir --> UC_PETANI
    Kasir --> UC_TRX
    Kasir --> UC_BAYAR
    Kasir --> UC_VOID
    Kasir --> UC_PABRIK1
    Kasir --> UC_PABRIK2
    Kasir --> UC_PENGELUARAN
    Kasir --> UC_AI

    Admin --> UC_BYOD
    Admin --> UC_AUTH
    Admin --> UC_PETANI
    Admin --> UC_TRX
    Admin --> UC_BAYAR
    Admin --> UC_VOID
    Admin --> UC_PABRIK1
    Admin --> UC_PABRIK2
    Admin --> UC_PENGELUARAN
    Admin --> UC_SALDO
    Admin --> UC_TOPUP
    Admin --> UC_MARGIN
    Admin --> UC_TREN
    Admin --> UC_EXP_REV
    Admin --> UC_AI

    Sistem --> UC_SESSION
    Sistem --> UC_UPDATE
    Sistem --> UC_OFFLINE
    Sistem --> UC_BG_SYNC
```

### 3.2 Matriks Hak Akses Aktor (Role-Based Access Control)

| Modul & Fitur Sistem | Kasir Timbangan | Pemilik Usaha (Admin) | Batasan & Keamanan |
|---|:---:|:---:|---|
| **Setup Organisasi BYOD** | Ya | Ya | Diperlukan saat awal inisialisasi aplikasi di perangkat |
| **Login & Sesi 24 Jam** | Ya | Ya | Auto-logout paksa setelah 24 jam berturut-turut |
| **Transaksi Pembelian TBS** | Full Akses | Full Akses | Input berat kotor, harga, potongan %, cetak struk |
| **Metode Pembayaran (Tunai/Non Tunai)** | Ya | Ya | Default Tunai; Non Tunai tidak memotong saldo kas fisik |
| **Pembatalan Transaksi (Void)** | Ya (Wajib Alasan) | Ya (Wajib Alasan) | Status berubah jadi `dibatalkan`, tercatat di audit trail |
| **Pengiriman Pabrik (Fase 1 & 2)** | Full Akses | Full Akses | Audit susut buah, potongan sortasi, dan nilai jual |
| **Pencatatan Biaya Operasional** | Full Akses | Full Akses | Input biaya harian tunai maupun non-tunai |
| **Kelola Master Kategori Biaya** | **Disembunyikan** | **Ya** | Hanya Admin yang boleh menambah/mengubah kategori biaya |
| **Modul Saldo & Kas Modal Ramp** | **Disembunyikan** | **Ya** | Sisa saldo kas = Total Top Up − Total Pembelian TUNAI |
| **Dashboard — Tab Margin & Laba** | **Disembunyikan** | **Ya** | Demi kerahasiaan omzet & laba bersih loading ramp |
| **Dashboard — Grafik Tren Nilai** | **Disembunyikan** | **Ya** | Kasir hanya melihat kartu tonase & volume buah |
| **Filter Periode Dashboard** | Maksimal 1 Bulan | Bebas (s/d 1 Tahun) | Kasir difokuskan pada pemantauan operasional berjalan |
| **Filter Khusus "Bulan Ini"** | **Disembunyikan** | **Ya** | Admin dapat memilih bulan/tahun komparasi historis |
| **Ekspor Laporan Pendapatan** | **Disembunyikan** | **Ya** | Laporan pendapatan berjenjang hanya untuk pemilik |
| **AI Analytics Advisor** | Ya | Ya | Konsultasi bisnis interaktif (read-only context) |
| **Bilah Status Sinkronisasi** | Ya | Ya | Menampilkan status tersinkron, antrean, dan mode offline |

---

## 4. Flowchart Sistem & Alur Kerja Bisnis

### 4.1 Alur Autentikasi, Setup Organisasi BYOD, & Sesi 24 Jam

```mermaid
flowchart TD
    Start([Pengguna Meluncurkan RamSawit]) --> CheckUpdate[AppUpdateService: Cek version.json di Vercel]
    CheckUpdate --> UpdatePrompt{Ada Versi Baru?}
    UpdatePrompt -- Ya --> ShowModalUpdate[Tampilkan Dialog Update & Tautan Unduh]
    UpdatePrompt -- Tidak --> CheckBYOD{Kredensial Tenant Tersimpan?}
    ShowModalUpdate --> CheckBYOD

    CheckBYOD -- Belum Ada --> SetupPage[Layar Setup Organisasi & Database BYOD]
    SetupPage --> InputKey[Input Nama Ramp, URL Supabase, & Anon Public Key]
    InputKey --> TestConn{Uji Koneksi Supabase?}
    TestConn -- Gagal --> ShowErrConn[Tampilkan Pesan Error Koneksi] --> SetupPage
    TestConn -- Sukses --> SaveSecure[Simpan Terenkripsi di flutter_secure_storage] --> LoginPage

    CheckBYOD -- Sudah Ada --> CheckSession{Ada Sesi Login Aktif?}
    CheckSession -- Tidak --> LoginPage[Tampilkan Halaman Login]
    CheckSession -- Ya --> CheckAge{Usia Sesi Sejak Login<br/>> 24 Jam?}

    CheckAge -- Ya (Kedaluwarsa) --> ForceLogout[Paksa Logout & Bersihkan Cache Sesi]
    ForceLogout --> BannerOrange["Tampilkan Banner: 'Sesi login telah berakhir (24 jam)'"] --> LoginPage
    CheckAge -- Tidak (Valid) --> StartTimer[Jalankan Timer Periodik Cek Sesi 15 Menit] --> MainApp

    LoginPage --> InputAuth[Input Email & Kata Sandi]
    InputAuth --> SubmitAuth[Klik 'Masuk ke Sistem']
    SubmitAuth --> VerifyAuth{Verifikasi di Supabase Auth}
    VerifyAuth -- Gagal --> ShowErrAuth[Tampilkan Pesan Validasi] --> LoginPage
    VerifyAuth -- Sukses --> SaveLoginTime[Simpan Timestamp Waktu Login] --> StartTimer --> MainApp[Masuk ke Menu Utama Sesuai Role]
```

### 4.2 Alur Transaksi Pembelian TBS Petani (Multi-Item & Metode Bayar)

```mermaid
flowchart TD
    A([Petani Tiba Membawa TBS]) --> B[Buka Menu 'Transaksi Baru' Ctrl+N]
    B --> C[Pilih Petani atau Tambah Petani Baru via Dialog Inline]
    C --> D[Pilih Jenis Buah Baris 1: TB / TK / BR]
    D --> E[Input Berat Kotor kg & Harga per kg Rp]
    E --> F[Input Potongan Tangkai/Sampah %]
    
    F --> G{Ada Jenis Buah Lain?}
    G -- Ya (Maksimal 3 Baris) --> H[Klik '+ Tambah Jenis Buah'] --> D
    G -- Tidak --> I[Sistem Live Preview Menghitung Presisi Decimal:<br/>- Potongan kg = Berat Kotor * Potongan%<br/>- Berat Bersih = Berat Kotor - Potongan kg<br/>- Subtotal = Harga * Berat Bersih<br/>- Total Berat Kotor, Total Bersih, & Total Rupiah]
    
    I --> J[Pilih Metode Pembayaran: TUNAI atau NON TUNAI]
    J --> K{Kasir Konfirmasi Simpan?}
    K -- Koreksi --> D
    K -- Setuju --> L[Tulis ke Database Lokal Drift SQLite: LocalTransaksi & LocalTransaksiItem<br/>isSynced = false]
    
    L --> M{Pilihan Metode Bayar?}
    M -- Tunai --> N[Mengurangi Sisa Saldo Kas Modal Timbangan]
    M -- Non Tunai --> O[Tercatat Informatif di Tab Transfer Bank; Saldo Kas Fisik Tetap Utuh]
    
    N & O --> P[Cetak Struk Nota Timbangan / Share PDF]
    P --> Q[SyncEngine Mendeteksi Antrean & Memulai Background Sync]
    Q --> End([Selesai])
```

### 4.3 Alur Pembatalan Transaksi Pembelian (Void)

```mermaid
flowchart TD
    A([Kasir / Admin Menemukan Kesalahan Nota]) --> B[Buka Menu 'Riwayat Transaksi']
    B --> C[Pilih Nota & Buka Halaman Detail]
    C --> D[Klik Tombol Merah 'Batalkan Transaksi']
    D --> E[Muncul Dialog: Wajib Mengisi 'Alasan Pembatalan']
    E --> F{Alasan Diisi?}
    F -- Kosong --> G[Tombol Konfirmasi Tetap Dinonaktifkan] --> E
    F -- Terisi --> H[Klik 'Konfirmasi Pembatalan']
    
    H --> I[Update Status di Database Lokal Drift:<br/>status = 'dibatalkan'<br/>alasan_batal = text<br/>isSynced = false]
    I --> J[Nilai Transaksi Ditarik dari Agregasi Omzet & Perhitungan Saldo]
    J --> K[Nota Ditandai Badge Merah 'DIBATALKAN' (Audit Trail Tetap Utuh)]
    K --> L[SyncEngine Mengirim Mutasi Status ke Cloud Supabase]
    L --> End([Pembatalan Selesai])
```

### 4.4 Alur Penjualan Pabrik (Dua Fase Pengiriman & Audit Susut/Sortasi)

```mermaid
flowchart TD
    subgraph FASE_1 ["FASE 1: Keberangkatan Truk dari Loading Ramp"]
        A1([Truk Selesai Memuat TBS di Ramp]) --> B1[Buka Menu 'Pengiriman Pabrik' -> Form Keberangkatan]
        B1 --> C1[Pilih Pabrik Tujuan PKS, Nomor Polisi, & Nama Sopir]
        C1 --> D1[Input Berat Dikirim kg hasil Jembatan Timbang Ramp]
        D1 --> E1[Simpan: Kode Otomatis KRM-YYYYMMDD-XXXX<br/>Status: 'berangkat']
        E1 --> F1([Truk Berangkat Menuju PKS])
    end

    subgraph FASE_2 ["FASE 2: Rekonsiliasi Nota Slip Timbangan PKS"]
        F1 -. Perjalanan & Timbang di Pabrik .-> A2([Sopir Kembali Membawa Slip PKS])
        A2 --> B2[Buka 'Riwayat Pengiriman' -> Tab 'Dalam Perjalanan']
        B2 --> C2[Pilih Armada & Klik 'Input Hasil Pabrik']
        C2 --> D2[Input Data Slip PKS:<br/>- Berat Sampai kg<br/>- Berat Ditolak kg<br/>- Potongan Pabrik %<br/>- Harga Jual per kg Rp<br/>- Potongan Lainnya Rp & Potongan Sortasi Rp/kg]
        
        D2 --> E2[Validasi Sistem:<br/>Berat Ditolak <= Berat Sampai]
        E2 --> F2[Kalkulasi Otomatis Generated Columns:<br/>1. Berat Diterima = Sampai - Ditolak<br/>2. Berat Bersih = Diterima * (1 - Potongan%)<br/>3. Susut Buah = Dikirim - Sampai (Audit Selisih Timbangan)<br/>4. Potongan Sortasi Rp = Sortasi per kg * Berat Sampai<br/>5. Total Nilai Jual = (Harga * Bersih) - Potongan Lain - Sortasi]
        
        F2 --> G2[Simpan: Status Berubah menjadi 'selesai']
        G2 --> H2([Penjualan Pabrik Selesai & Tercatat di Dashboard Margin])
    end
```

### 4.5 Alur Offline-First & Sinkronisasi Dua Arah (`SyncEngine`)

```mermaid
flowchart TD
    Trigger([Trigger: Mutasi Data / Timer 30s / Klik 'Sinkron Sekarang']) --> CheckState{SyncEngine Sedang Berjalan?}
    CheckState -- Ya --> Abort[Abaikan Panggilan Baru]
    CheckState -- Tidak --> SetSyncing[Set Status: SyncStatus.syncing]
    
    SetSyncing --> CheckNet{Koneksi Internet & Supabase Config Valid?}
    CheckNet -- Tidak Ada --> SetOffline[Set Status: SyncStatus.offline<br/>Hitung Antrean: isSynced = false<br/>SyncStatusBar Tampil Oranye] --> End
    
    CheckNet -- Terhubung --> GetUnsynced[Query Data Lokal yang Belum Tersinkron:<br/>- LocalTransaksi<br/>- LocalTransaksiItem<br/>- LocalPengirimanPabrik<br/>- LocalPengeluaran<br/>- LocalTopupSaldo]
    
    GetUnsynced --> HasData{Ada Antrean Data?}
    HasData -- Tidak Ada --> MarkIdle[Set Status: SyncStatus.idle<br/>SyncStatusBar Tampil Hijau 'Tersinkron Penuh'] --> End
    
    HasData -- Ada Data --> PushCloud[Kirim Paket Mutasi ke Endpoint Supabase REST API]
    PushCloud --> ResponseCheck{Respon Server 200/201 OK?}
    
    ResponseCheck -- Sukses --> UpdateLocal[Tandai di SQLite Lokal: isSynced = true<br/>Update lastSyncTime = DateTime.now]
    UpdateLocal --> MarkIdle
    
    ResponseCheck -- Gagal / Error --> SetError[Set Status: SyncStatus.error<br/>Simpan Pesan Kesalahan<br/>SyncStatusBar Tampil Merah dengan Tombol 'Coba Lagi']
    SetError --> End([Siklus Selesai])
```

### 4.6 Alur Konsultasi AI Analytics Advisor & Fallback Deterministik

```mermaid
flowchart TD
    User([Pengguna Buka Halaman 'AI Analytics Advisor']) --> Init[AI Controller Injeksi Konteks Operasional Terkini:<br/>- Tonase Beli & Jual Hari Ini/Minggu Ini<br/>- Total Omzet & Estimasi Margin Kotor<br/>- Pabrik Paling Aktif & Petani Teratas]
    
    Init --> SelectAction{Pengguna Mengirim Pertanyaan}
    SelectAction -- Klik Shortcut Populer --> QuickPrompt["Pertanyaan Cepat:<br/>'Evaluasi Margin Minggu Ini'<br/>'Pabrik Mana Paling Menguntungkan?'"]
    SelectAction -- Ketik Manual --> CustomPrompt[Input Pertanyaan Analisis Bebas]
    
    QuickPrompt & CustomPrompt --> CheckEndpoint{AiEndpointConfigService:<br/>Endpoint LLM Aktif & Terjangkau?}
    
    CheckEndpoint -- Aktif (9Router/Ollama) --> SendLLM[Kirim Prompt + Konteks Ringkasan ke LLM API<br/>Model Default: ag/gemini-3.8-flash-medium]
    SendLLM --> ParseLLM[Parse Respon Cerdas Berbahasa Indonesia]
    ParseLLM --> DisplayChat[Tampilkan Jawaban di Layar Chat]
    
    CheckEndpoint -- Nonaktif / Gagal Koneksi --> FallbackEngine[Alihkan ke AiBusinessQueryService<br/>Mesin Query Deterministik Lokal]
    FallbackEngine --> ExecSQL[Eksekusi Analisis Statistik Mandiri pada SQLite/View]
    ExecSQL --> FormatLocal[Susun Penjelasan Terstruktur Berbahasa Indonesia]
    FormatLocal --> DisplayChat
```

### 4.7 Alur Ekspor Laporan Pendapatan Berjenjang

```mermaid
flowchart TD
    A([Admin Buka Menu 'Laporan Pendapatan']) --> B[Pilih Rentang Filter Evaluasi]
    
    B --> C1[Pilihan 1 Tahun]
    B --> C2[Pilihan 3 Bulan]
    B --> C3[Pilihan 1 Bulan]
    
    C1 --> D1[Agregasi Berjenjang Kuartalan (Per 3 Bulan):<br/>Q1 (Jan-Mar), Q2 (Apr-Jun), Q3 (Jul-Sep), Q4 (Okt-Des)]
    C2 --> D2[Agregasi Berjenjang Bulanan (Per 1 Bulan):<br/>Bulan 1, Bulan 2, Bulan 3]
    C3 --> D3[Agregasi Berjenjang Mingguan (Per 7 Hari):<br/>Minggu 1, Minggu 2, Minggu 3, Minggu 4, Minggu 5]
    
    D1 & D2 & D3 --> E[Komputasi Tiap Baris Periode:<br/>- Total Pembelian Petani Rp<br/>- Total Penjualan Pabrik Rp<br/>- Margin Kotor = Penjualan - Pembelian<br/>- Total Pengeluaran Operasional Rp<br/>- Laba Bersih = Margin - Pengeluaran<br/>- Baris Total Akumulasi di Bagian Akhir]
    
    E --> F[Pratinjau Tabel Live di Antarmuka Pengguna]
    F --> G{Pilih Format Ekspor}
    G -- Excel (.xlsx) --> H[Unduh Berkas Spreadsheet Microsoft Excel]
    G -- PDF (.pdf) --> I[Unduh Berkas Dokumen PDF Siap Cetak A4]
    H & I --> End([Ekspor Sukses])
```

---

## 5. Diagram Fishbone (Ishikawa) — Akar Masalah & Solusi Nyata

Diagram Ishikawa (6M) di bawah ini menguraikan bagaimana transformasi digital RamSawit v2.5.4 menuntaskan permasalahan kronis operasional loading ramp konvensional:

```mermaid
graph LR
    subgraph MAN ["1. MAN (SDM / Kasir)"]
        M1["Salah hitung kalkulator & kelelahan mental"]
        M2["Kecurangan selisih nota fisik timbangan"]
        M3["Komputer timbangan ditinggal terbuka"]
    end

    subgraph METHOD ["2. METHOD (SOP Operasional)"]
        ME1["Nota kertas hilang, sobek, atau kena hujan"]
        ME2["Aturan potongan sampah tidak transparan"]
        ME3["Truk kirim pabrik tidak diaudit susutnya"]
        ME4["Uang kas ramp bercampur dengan transfer bank"]
    end

    subgraph MACHINE ["3. MACHINE (Sistem & Hardware)"]
        MC1["Floating-point rounding error komputer biasa"]
        MC2["Sistem lama tidak memiliki audit log void"]
        MC3["Ketergantungan total pada internet cloud"]
    end

    subgraph MATERIAL ["4. MATERIAL (Karakteristik TBS)"]
        MT1["Buah campur (Tandan Besar, Kecil, Berondolan)"]
        MT2["Sampah tangkai panjang, pasir, & restan"]
        MT3["Penyusutan bobot buah selama perjalanan truk"]
    end

    subgraph MEASUREMENT ["5. MEASUREMENT (Audit & Laba)"]
        MS1["Selisih timbangan ramp vs timbangan PKS"]
        MS2["Pemilik tidak tahu laba bersih harian real-time"]
        MS3["Rekap pembukuan bulanan butuh berhari-hari"]
    end

    subgraph MILIEU ["6. MILIEU (Lingkungan Lapangan)"]
        ML1["Sinyal internet di pedalaman kebun sawit tidak stabil"]
        ML2["Antrean panjang truk memicu ketergesaan kasir"]
        ML3["Kekhawatiran data bisnis bocor ke pihak lain"]
    end

    MAN --> PROBLEM
    METHOD --> PROBLEM
    MACHINE --> PROBLEM
    MATERIAL --> PROBLEM
    MEASUREMENT --> PROBLEM
    MILIEU --> PROBLEM

    PROBLEM["<b>TUNTAS PADA RAMSAWIT v2.5.4:</b><br/>Zero Floating-Point Error,<br/>Offline-First Drift SQLite,<br/>Isolasi Kas Tunai vs Transfer,<br/>Audit 2-Fase Susut Pabrik,<br/>& Keamanan Database BYOD"]
```

### Matriks Solusi Komprehensif RamSawit v2.5.4:
1. **Presisi Finansial Anti-Error:** Menggunakan package `Decimal` dan kolom `GENERATED ALWAYS AS STORED` di database.
2. **Offline-First:** Basis data lokal Drift SQLite (`sawit_offline_db.sqlite`) memungkinkan penimbangan tetap berjalan normal 100% tanpa internet.
3. **Pemisahan Kas Tunai & Transfer:** Pilihan metode pembayaran melindungi kas fisik modal kasir dari ketidaksesuaian saldo.
4. **Audit Susut & Sortasi Pabrik:** Alur 2-fase membandingkan berat timbangan ramp dengan hasil pabrik, mendeteksi selisih secara akurat.
5. **Kerahasiaan Bisnis (BYOD & RBAC):** Setiap loading ramp memiliki database Supabase sendiri, dan kasir dibatasi dari melihat margin laba pemilik.
6. **AI Analytics Advisor:** Pemilik usaha dapat mengevaluasi performa ramp, membandingkan pabrik, dan mendeteksi anomali biaya secara instan.

---
*Dokumen ini merupakan spesifikasi arsitektur visual resmi aplikasi RamSawit v2.5.4.*
