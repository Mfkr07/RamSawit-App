-- ==============================================================================
-- MASTER TENANT SCHEMA - RAMSAWIT (APLIKASI TRANSAKSI JUAL BELI TBS SAWIT)
-- Target Database: PostgreSQL 15+ / Supabase
-- Versi Skema: v2.5.4 (Konsolidasi Penuh Seluruh Modul & Fitur)
-- 
-- PANDUAN PENGGUNAAN UNTUK ORGANISASI BARU:
-- 1. Buat project baru di https://supabase.com.
-- 2. Buka menu "SQL Editor" di sidebar Supabase.
-- 3. Copy-paste seluruh isi file ini ke dalam SQL Editor, lalu klik tombol "Run".
-- 4. Buka menu Project Settings -> API:
--    - Salin "Project URL" (https://xxxx.supabase.co)
--    - Salin "anon public" API Key (eyJh...)
-- 5. Buka aplikasi RamSawit (Windows / Android), klik tombol "Setup Organisasi & Database",
--    masukkan URL dan Anon Key tersebut, lalu simpan.
-- 6. Aplikasi langsung terhubung dan siap digunakan secara penuh!
-- ==============================================================================

BEGIN;

-- ==============================================================================
-- 1. EXTENSIONS
-- ==============================================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto"; -- UUID generator
CREATE EXTENSION IF NOT EXISTS pg_trgm;    -- Pencarian teks cepat (fuzzy/trigram search)

-- ==============================================================================
-- 2. TABEL: PROFILES (User & Role Management)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nama TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'kasir' CHECK (role IN ('admin', 'kasir')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Function & Trigger: Otomatis membuat profile saat user mendaftar via Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, nama, role)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'nama', NEW.email),
        COALESCE(NEW.raw_user_meta_data->>'role', 'kasir')
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Trigger Helper: Auto-update updated_at pada tabel-tabel data
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==============================================================================
-- 3. TABEL MASTER: PENJUAL (Petani / Supplier TBS)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.penjual (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nama TEXT NOT NULL,
    no_telepon TEXT,
    alamat TEXT,
    catatan TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_penjual_nama ON public.penjual USING gin (nama gin_trgm_ops);

DROP TRIGGER IF EXISTS trg_penjual_updated_at ON public.penjual;
CREATE TRIGGER trg_penjual_updated_at
    BEFORE UPDATE ON public.penjual
    FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

-- ==============================================================================
-- 4. TABEL MASTER: JENIS BUAH (TBS)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.jenis_buah (
    id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    kode TEXT NOT NULL UNIQUE,
    nama TEXT NOT NULL UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Seed awal master jenis buah standar industri TBS
INSERT INTO public.jenis_buah (kode, nama) VALUES
    ('TB', 'Tandan Besar'),
    ('TK', 'Tandan Kecil'),
    ('BR', 'Berondolan')
ON CONFLICT (kode) DO NOTHING;

-- ==============================================================================
-- 5. TABEL MASTER: PABRIK KELAPA SAWIT (PKS)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.pabrik (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nama TEXT NOT NULL,
    alamat TEXT,
    kontak TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pabrik_nama ON public.pabrik USING gin (nama gin_trgm_ops);

DROP TRIGGER IF EXISTS trg_pabrik_updated_at ON public.pabrik;
CREATE TRIGGER trg_pabrik_updated_at
    BEFORE UPDATE ON public.pabrik
    FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

-- ==============================================================================
-- 6. TABEL MASTER: JENIS PENGELUARAN
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.jenis_pengeluaran (
    id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nama TEXT NOT NULL UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Seed awal kategori pengeluaran operasional ramp
INSERT INTO public.jenis_pengeluaran (nama) VALUES
    ('BBM/Transportasi'),
    ('Gaji/Upah'),
    ('Perawatan Kendaraan'),
    ('Operasional Kantor'),
    ('Lain-lain')
ON CONFLICT (nama) DO NOTHING;

-- ==============================================================================
-- 7. TABEL TRANSAKSI: PEMBELIAN TBS DARI PETANI (Header & Detail)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.transaksi (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    kode_transaksi TEXT NOT NULL UNIQUE,
    penjual_id UUID NOT NULL REFERENCES public.penjual(id),
    tanggal_transaksi DATE NOT NULL DEFAULT CURRENT_DATE,
    status TEXT NOT NULL DEFAULT 'selesai' CHECK (status IN ('draft', 'selesai', 'dibatalkan')),
    jenis_pembayaran TEXT NOT NULL DEFAULT 'tunai' CHECK (jenis_pembayaran IN ('tunai', 'non_tunai')),
    catatan TEXT,
    created_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_transaksi_tanggal ON public.transaksi (tanggal_transaksi DESC);
CREATE INDEX IF NOT EXISTS idx_transaksi_penjual ON public.transaksi (penjual_id);
CREATE INDEX IF NOT EXISTS idx_transaksi_status ON public.transaksi (status);
CREATE INDEX IF NOT EXISTS idx_transaksi_jenis_pembayaran ON public.transaksi (jenis_pembayaran);

DROP TRIGGER IF EXISTS trg_transaksi_updated_at ON public.transaksi;
CREATE TRIGGER trg_transaksi_updated_at
    BEFORE UPDATE ON public.transaksi
    FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

-- Trigger Auto-generate kode transaksi TRX-YYYYMMDD-0001
CREATE OR REPLACE FUNCTION public.generate_kode_transaksi()
RETURNS TRIGGER AS $$
DECLARE
    next_seq INT;
    tanggal_str TEXT;
BEGIN
    IF NEW.kode_transaksi IS NULL OR NEW.kode_transaksi = '' THEN
        tanggal_str := TO_CHAR(COALESCE(NEW.tanggal_transaksi, CURRENT_DATE), 'YYYYMMDD');
        SELECT COALESCE(MAX(
            (REGEXP_MATCH(kode_transaksi, 'TRX-' || tanggal_str || '-(\d+)'))[1]::INT
        ), 0) + 1
        INTO next_seq
        FROM public.transaksi
        WHERE kode_transaksi LIKE 'TRX-' || tanggal_str || '-%';

        NEW.kode_transaksi := 'TRX-' || tanggal_str || '-' || LPAD(next_seq::TEXT, 4, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_generate_kode_transaksi ON public.transaksi;
CREATE TRIGGER trg_generate_kode_transaksi
    BEFORE INSERT ON public.transaksi
    FOR EACH ROW EXECUTE PROCEDURE public.generate_kode_transaksi();

-- Detail item transaksi per jenis buah dengan potongan berat
CREATE TABLE IF NOT EXISTS public.transaksi_item (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaksi_id UUID NOT NULL REFERENCES public.transaksi(id) ON DELETE CASCADE,
    jenis_buah_id SMALLINT NOT NULL REFERENCES public.jenis_buah(id),
    harga_per_kg NUMERIC(12,2) NOT NULL CHECK (harga_per_kg >= 0),
    berat_kotor_kg NUMERIC(10,2) NOT NULL CHECK (berat_kotor_kg > 0),
    persentase_potongan NUMERIC(5,2) NOT NULL DEFAULT 0 CHECK (persentase_potongan >= 0 AND persentase_potongan <= 100),
    berat_bersih_kg NUMERIC(10,2) GENERATED ALWAYS AS (ROUND(berat_kotor_kg * (1 - persentase_potongan / 100), 2)) STORED,
    nilai_potongan_rp NUMERIC(14,2) GENERATED ALWAYS AS (ROUND(harga_per_kg * berat_kotor_kg * (persentase_potongan / 100), 2)) STORED,
    subtotal NUMERIC(14,2) GENERATED ALWAYS AS (ROUND(harga_per_kg * berat_kotor_kg * (1 - persentase_potongan / 100), 2)) STORED,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (transaksi_id, jenis_buah_id)
);

CREATE INDEX IF NOT EXISTS idx_item_transaksi ON public.transaksi_item (transaksi_id);

-- ==============================================================================
-- 8. TABEL PENJUALAN KE PABRIK (PKS - Alur 2 Fase)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.pengiriman_pabrik (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    kode_pengiriman TEXT NOT NULL UNIQUE,
    pabrik_id UUID NOT NULL REFERENCES public.pabrik(id),
    plat_nomor TEXT NOT NULL,
    nama_sopir TEXT NOT NULL,
    tanggal_kirim DATE NOT NULL DEFAULT CURRENT_DATE,

    -- Fase 1: Data Pengiriman dari Ramp
    berat_dikirim_kg NUMERIC(10,2) NOT NULL CHECK (berat_dikirim_kg > 0),

    -- Fase 2: Hasil Timbangan & Verifikasi PKS (Nullable di awal)
    berat_sampai_kg NUMERIC(10,2) CHECK (berat_sampai_kg IS NULL OR berat_sampai_kg > 0),
    berat_ditolak_kg NUMERIC(10,2) CHECK (berat_ditolak_kg IS NULL OR berat_ditolak_kg >= 0),
    persentase_potongan_pabrik NUMERIC(5,2) CHECK (persentase_potongan_pabrik IS NULL OR (persentase_potongan_pabrik >= 0 AND persentase_potongan_pabrik <= 100)),
    harga_jual_per_kg NUMERIC(12,2) CHECK (harga_jual_per_kg IS NULL OR harga_jual_per_kg >= 0),
    potongan_lainnya_rp NUMERIC(14,2) CHECK (potongan_lainnya_rp IS NULL OR potongan_lainnya_rp >= 0),
    potongan_sortasi_per_kg NUMERIC(12,2) CHECK (potongan_sortasi_per_kg IS NULL OR potongan_sortasi_per_kg >= 0),

    -- Kolom Kalkulasi Otomatis (Generated Columns)
    berat_diterima_kg NUMERIC(10,2) GENERATED ALWAYS AS (
        ROUND(berat_sampai_kg - berat_ditolak_kg, 2)
    ) STORED,

    berat_bersih_kg NUMERIC(10,2) GENERATED ALWAYS AS (
        ROUND((berat_sampai_kg - berat_ditolak_kg) * (1 - persentase_potongan_pabrik / 100), 2)
    ) STORED,

    susut_buah_kg NUMERIC(10,2) GENERATED ALWAYS AS (
        ROUND(berat_dikirim_kg - berat_sampai_kg, 2)
    ) STORED,

    nilai_potongan_rp NUMERIC(14,2) GENERATED ALWAYS AS (
        ROUND(harga_jual_per_kg * (berat_sampai_kg - berat_ditolak_kg) * persentase_potongan_pabrik / 100, 2)
    ) STORED,

    nilai_potongan_sortasi_rp NUMERIC(14,2) GENERATED ALWAYS AS (
        ROUND(COALESCE(potongan_sortasi_per_kg, 0) * berat_sampai_kg, 2)
    ) STORED,

    total_nilai_jual NUMERIC(14,2) GENERATED ALWAYS AS (
        ROUND(
            harga_jual_per_kg * (berat_sampai_kg - berat_ditolak_kg) * (1 - persentase_potongan_pabrik / 100)
            - COALESCE(potongan_lainnya_rp, 0)
            - ROUND(COALESCE(potongan_sortasi_per_kg, 0) * berat_sampai_kg, 2)
        , 2)
    ) STORED,

    status TEXT NOT NULL DEFAULT 'berangkat' CHECK (status IN ('berangkat', 'selesai', 'dibatalkan')),
    catatan TEXT,
    created_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT pengiriman_pabrik_ditolak_lte_sampai_check
        CHECK (berat_sampai_kg IS NULL OR berat_ditolak_kg IS NULL OR berat_ditolak_kg <= berat_sampai_kg)
);

CREATE INDEX IF NOT EXISTS idx_pengiriman_tanggal ON public.pengiriman_pabrik (tanggal_kirim DESC);
CREATE INDEX IF NOT EXISTS idx_pengiriman_pabrik ON public.pengiriman_pabrik (pabrik_id);
CREATE INDEX IF NOT EXISTS idx_pengiriman_status ON public.pengiriman_pabrik (status);

DROP TRIGGER IF EXISTS trg_pengiriman_updated_at ON public.pengiriman_pabrik;
CREATE TRIGGER trg_pengiriman_updated_at
    BEFORE UPDATE ON public.pengiriman_pabrik
    FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

-- Trigger Auto-generate kode pengiriman KRM-YYYYMMDD-0001
CREATE OR REPLACE FUNCTION public.generate_kode_pengiriman()
RETURNS TRIGGER AS $$
DECLARE
    next_seq INT;
    tanggal_str TEXT;
BEGIN
    IF NEW.kode_pengiriman IS NULL OR NEW.kode_pengiriman = '' THEN
        tanggal_str := TO_CHAR(COALESCE(NEW.tanggal_kirim, CURRENT_DATE), 'YYYYMMDD');
        SELECT COALESCE(MAX(
            (REGEXP_MATCH(kode_pengiriman, 'KRM-' || tanggal_str || '-(\d+)'))[1]::INT
        ), 0) + 1
        INTO next_seq
        FROM public.pengiriman_pabrik
        WHERE kode_pengiriman LIKE 'KRM-' || tanggal_str || '-%';

        NEW.kode_pengiriman := 'KRM-' || tanggal_str || '-' || LPAD(next_seq::TEXT, 4, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_generate_kode_pengiriman ON public.pengiriman_pabrik;
CREATE TRIGGER trg_generate_kode_pengiriman
    BEFORE INSERT ON public.pengiriman_pabrik
    FOR EACH ROW EXECUTE PROCEDURE public.generate_kode_pengiriman();

-- ==============================================================================
-- 9. TABEL PENGELUARAN OPERASIONAL
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.pengeluaran (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tanggal_pengeluaran DATE NOT NULL DEFAULT CURRENT_DATE,
    jenis_pengeluaran_id SMALLINT NOT NULL REFERENCES public.jenis_pengeluaran(id),
    keterangan TEXT,
    nominal NUMERIC(14,2) NOT NULL CHECK (nominal > 0),
    metode_pembayaran TEXT NOT NULL DEFAULT 'tunai' CHECK (metode_pembayaran IN ('tunai', 'non_tunai')),
    created_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pengeluaran_tanggal ON public.pengeluaran (tanggal_pengeluaran DESC);
CREATE INDEX IF NOT EXISTS idx_pengeluaran_metode_pembayaran ON public.pengeluaran (metode_pembayaran);

DROP TRIGGER IF EXISTS trg_pengeluaran_updated_at ON public.pengeluaran;
CREATE TRIGGER trg_pengeluaran_updated_at
    BEFORE UPDATE ON public.pengeluaran
    FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

-- ==============================================================================
-- 10. TABEL MODAL & SALDO (DANA KAS RAMP)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.topup_saldo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tanggal DATE NOT NULL DEFAULT CURRENT_DATE,
    nominal NUMERIC(14,2) NOT NULL CHECK (nominal > 0),
    keterangan TEXT,
    created_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_topup_saldo_tanggal ON public.topup_saldo (tanggal DESC);

-- ==============================================================================
-- 11. VIEWS AGREGASI, ANALITIK, & LAPORAN
-- ==============================================================================

-- Drop views terdahulu secara berurutan agar clean
DROP VIEW IF EXISTS public.v_laba_bersih_harian CASCADE;
DROP VIEW IF EXISTS public.v_margin_harian CASCADE;
DROP VIEW IF EXISTS public.v_breakdown_pabrik CASCADE;
DROP VIEW IF EXISTS public.v_pengiriman_harian CASCADE;
DROP VIEW IF EXISTS public.v_pengiriman_ringkasan CASCADE;
DROP VIEW IF EXISTS public.v_pengeluaran_harian CASCADE;
DROP VIEW IF EXISTS public.v_breakdown_jenis_pengeluaran CASCADE;
DROP VIEW IF EXISTS public.v_transaksi_non_tunai_harian CASCADE;
DROP VIEW IF EXISTS public.v_saldo_ringkasan CASCADE;
DROP VIEW IF EXISTS public.v_breakdown_jenis_buah CASCADE;
DROP VIEW IF EXISTS public.v_transaksi_harian CASCADE;
DROP VIEW IF EXISTS public.v_transaksi_ringkasan CASCADE;

-- 1. Ringkasan per transaksi pembelian
CREATE VIEW public.v_transaksi_ringkasan AS
SELECT
    t.id,
    t.kode_transaksi,
    t.tanggal_transaksi,
    t.status,
    p.id AS penjual_id,
    p.nama AS nama_penjual,
    COALESCE(SUM(ti.berat_kotor_kg), 0)::NUMERIC(10,2) AS total_berat_kotor_kg,
    COALESCE(SUM(ti.berat_bersih_kg), 0)::NUMERIC(10,2) AS total_berat_bersih_kg,
    COALESCE(SUM(ti.nilai_potongan_rp), 0)::NUMERIC(14,2) AS total_potongan_rp,
    COALESCE(SUM(ti.subtotal), 0)::NUMERIC(14,2) AS total_nilai,
    t.created_at,
    t.jenis_pembayaran
FROM public.transaksi t
JOIN public.penjual p ON p.id = t.penjual_id
LEFT JOIN public.transaksi_item ti ON ti.transaksi_id = t.id
GROUP BY t.id, t.kode_transaksi, t.tanggal_transaksi, t.status, p.id, p.nama, t.created_at, t.jenis_pembayaran;

-- 2. Tren pembelian harian
CREATE VIEW public.v_transaksi_harian AS
SELECT
    tanggal_transaksi,
    COUNT(DISTINCT id)::INT AS jumlah_transaksi,
    SUM(total_berat_kotor_kg)::NUMERIC(10,2) AS total_berat_kotor_kg,
    SUM(total_berat_bersih_kg)::NUMERIC(10,2) AS total_berat_bersih_kg,
    SUM(total_potongan_rp)::NUMERIC(14,2) AS total_potongan_rp,
    SUM(total_nilai)::NUMERIC(14,2) AS total_nilai
FROM public.v_transaksi_ringkasan
WHERE status = 'selesai'
GROUP BY tanggal_transaksi
ORDER BY tanggal_transaksi;

-- 3. Breakdown jenis buah harian
CREATE VIEW public.v_breakdown_jenis_buah AS
SELECT
    jb.nama AS jenis_buah,
    DATE_TRUNC('day', t.tanggal_transaksi)::DATE AS tanggal,
    SUM(ti.berat_kotor_kg)::NUMERIC(10,2) AS total_berat_kotor_kg,
    SUM(ti.berat_bersih_kg)::NUMERIC(10,2) AS total_berat_bersih_kg,
    SUM(ti.subtotal)::NUMERIC(14,2) AS total_nilai
FROM public.transaksi_item ti
JOIN public.transaksi t ON t.id = ti.transaksi_id
JOIN public.jenis_buah jb ON jb.id = ti.jenis_buah_id
WHERE t.status = 'selesai'
GROUP BY jb.nama, DATE_TRUNC('day', t.tanggal_transaksi)::DATE;

-- 4. Ringkasan pengiriman ke pabrik
CREATE VIEW public.v_pengiriman_ringkasan AS
SELECT
    pp.id,
    pp.kode_pengiriman,
    pp.tanggal_kirim,
    pp.status,
    pb.id AS pabrik_id,
    pb.nama AS nama_pabrik,
    pp.plat_nomor,
    pp.nama_sopir,
    pp.berat_dikirim_kg,
    pp.berat_sampai_kg,
    pp.berat_ditolak_kg,
    pp.berat_diterima_kg,
    pp.persentase_potongan_pabrik,
    pp.berat_bersih_kg,
    pp.susut_buah_kg,
    pp.harga_jual_per_kg,
    pp.nilai_potongan_rp,
    pp.potongan_lainnya_rp,
    pp.potongan_sortasi_per_kg,
    pp.nilai_potongan_sortasi_rp,
    pp.total_nilai_jual,
    pp.created_at
FROM public.pengiriman_pabrik pp
JOIN public.pabrik pb ON pb.id = pp.pabrik_id;

-- 5. Agregasi penjualan pabrik harian
CREATE VIEW public.v_pengiriman_harian AS
SELECT
    tanggal_kirim,
    COUNT(DISTINCT id)::INT AS jumlah_pengiriman,
    SUM(berat_dikirim_kg)::NUMERIC(10,2) AS total_berat_dikirim_kg,
    SUM(berat_ditolak_kg)::NUMERIC(10,2) AS total_berat_ditolak_kg,
    SUM(berat_bersih_kg)::NUMERIC(10,2) AS total_berat_bersih_kg,
    SUM(susut_buah_kg)::NUMERIC(10,2) AS total_susut_buah_kg,
    SUM(nilai_potongan_rp)::NUMERIC(14,2) AS total_potongan_rp,
    SUM(total_nilai_jual)::NUMERIC(14,2) AS total_nilai_jual
FROM public.v_pengiriman_ringkasan
WHERE status = 'selesai'
GROUP BY tanggal_kirim
ORDER BY tanggal_kirim;

-- 6. Breakdown penjualan per pabrik
CREATE VIEW public.v_breakdown_pabrik AS
SELECT
    pb.nama AS nama_pabrik,
    DATE_TRUNC('day', pp.tanggal_kirim)::DATE AS tanggal,
    SUM(pp.berat_dikirim_kg)::NUMERIC(10,2) AS total_berat_dikirim_kg,
    SUM(pp.berat_dikirim_kg)::NUMERIC(10,2) AS total_berat_kotor_kg,
    SUM(pp.berat_bersih_kg)::NUMERIC(10,2) AS total_berat_bersih_kg,
    SUM(pp.total_nilai_jual)::NUMERIC(14,2) AS total_nilai_jual
FROM public.pengiriman_pabrik pp
JOIN public.pabrik pb ON pb.id = pp.pabrik_id
WHERE pp.status = 'selesai'
GROUP BY pb.nama, DATE_TRUNC('day', pp.tanggal_kirim)::DATE;

-- 7. Margin kotor harian (Penjualan Pabrik - Pembelian Petani)
CREATE VIEW public.v_margin_harian AS
SELECT
    COALESCE(t.tanggal_transaksi, p.tanggal_kirim) AS tanggal,
    COALESCE(t.total_nilai, 0)::NUMERIC(14,2) AS total_pembelian,
    COALESCE(p.total_nilai_jual, 0)::NUMERIC(14,2) AS total_penjualan,
    (COALESCE(p.total_nilai_jual, 0) - COALESCE(t.total_nilai, 0))::NUMERIC(14,2) AS margin
FROM public.v_transaksi_harian t
FULL OUTER JOIN public.v_pengiriman_harian p ON p.tanggal_kirim = t.tanggal_transaksi
ORDER BY tanggal;

-- 8. Pengeluaran operasional harian
CREATE VIEW public.v_pengeluaran_harian AS
SELECT
    tanggal_pengeluaran AS tanggal,
    COALESCE(SUM(nominal), 0)::NUMERIC(14,2) AS total_pengeluaran,
    COUNT(*)::INT AS jumlah_transaksi_pengeluaran
FROM public.pengeluaran
GROUP BY tanggal_pengeluaran;

-- 9. Breakdown pengeluaran per kategori
CREATE VIEW public.v_breakdown_jenis_pengeluaran AS
SELECT
    jp.nama AS jenis_pengeluaran,
    p.tanggal_pengeluaran AS tanggal,
    COALESCE(SUM(p.nominal), 0)::NUMERIC(14,2) AS total_nominal
FROM public.pengeluaran p
JOIN public.jenis_pengeluaran jp ON jp.id = p.jenis_pengeluaran_id
GROUP BY jp.nama, p.tanggal_pengeluaran;

-- 10. Laba bersih harian (Margin Kotor - Total Pengeluaran)
CREATE VIEW public.v_laba_bersih_harian AS
SELECT
    COALESCE(m.tanggal, p.tanggal) AS tanggal,
    COALESCE(m.total_pembelian, 0)::NUMERIC(14,2) AS total_pembelian,
    COALESCE(m.total_penjualan, 0)::NUMERIC(14,2) AS total_penjualan,
    COALESCE(m.margin, 0)::NUMERIC(14,2) AS margin,
    COALESCE(p.total_pengeluaran, 0)::NUMERIC(14,2) AS total_pengeluaran,
    (COALESCE(m.margin, 0) - COALESCE(p.total_pengeluaran, 0))::NUMERIC(14,2) AS laba_bersih
FROM public.v_margin_harian m
FULL OUTER JOIN public.v_pengeluaran_harian p ON m.tanggal = p.tanggal;

-- 11. Ringkasan saldo dana modal kas ramp (Pemakaian HANYA dari transaksi Tunai)
CREATE VIEW public.v_saldo_ringkasan AS
SELECT
    (SELECT COALESCE(SUM(nominal), 0)::NUMERIC(14,2) FROM public.topup_saldo) AS total_topup,
    (SELECT COALESCE(SUM(total_nilai), 0)::NUMERIC(14,2)
       FROM public.v_transaksi_ringkasan
       WHERE status = 'selesai' AND jenis_pembayaran = 'tunai') AS total_pemakaian,
    (SELECT COALESCE(SUM(nominal), 0)::NUMERIC(14,2) FROM public.topup_saldo)
      - (SELECT COALESCE(SUM(total_nilai), 0)::NUMERIC(14,2)
           FROM public.v_transaksi_ringkasan
           WHERE status = 'selesai' AND jenis_pembayaran = 'tunai') AS sisa_saldo;

-- 12. Rekap harian transaksi non-tunai (Transfer)
CREATE VIEW public.v_transaksi_non_tunai_harian AS
SELECT
    tanggal_transaksi AS tanggal,
    COUNT(DISTINCT id)::INT AS jumlah_transaksi,
    SUM(total_nilai)::NUMERIC(14,2) AS total_nilai
FROM public.v_transaksi_ringkasan
WHERE status = 'selesai' AND jenis_pembayaran = 'non_tunai'
GROUP BY tanggal_transaksi
ORDER BY tanggal_transaksi;

-- ==============================================================================
-- 12. ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.penjual ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jenis_buah ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pabrik ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pengiriman_pabrik ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jenis_pengeluaran ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pengeluaran ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.topup_saldo ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transaksi ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transaksi_item ENABLE ROW LEVEL SECURITY;

-- Helper check admin: profile role = admin, user_metadata->role = admin, atau email mengandung admin
-- Profiles
DROP POLICY IF EXISTS "authenticated read profiles" ON public.profiles;
CREATE POLICY "authenticated read profiles" ON public.profiles
    FOR SELECT TO authenticated USING (TRUE);

-- Penjual
DROP POLICY IF EXISTS "authenticated all penjual" ON public.penjual;
CREATE POLICY "authenticated all penjual" ON public.penjual
    FOR ALL TO authenticated USING (TRUE) WITH CHECK (TRUE);

-- Jenis Buah
DROP POLICY IF EXISTS "authenticated read jenis_buah" ON public.jenis_buah;
CREATE POLICY "authenticated read jenis_buah" ON public.jenis_buah
    FOR SELECT TO authenticated USING (TRUE);

DROP POLICY IF EXISTS "admin manage jenis_buah" ON public.jenis_buah;
CREATE POLICY "admin manage jenis_buah" ON public.jenis_buah
    FOR INSERT TO authenticated WITH CHECK (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
        OR (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
        OR (auth.jwt() ->> 'email') ILIKE '%admin%'
    );

-- Pabrik
DROP POLICY IF EXISTS "authenticated read pabrik" ON public.pabrik;
CREATE POLICY "authenticated read pabrik" ON public.pabrik
    FOR SELECT TO authenticated USING (TRUE);

DROP POLICY IF EXISTS "authenticated write pabrik" ON public.pabrik;
CREATE POLICY "authenticated write pabrik" ON public.pabrik
    FOR INSERT TO authenticated WITH CHECK (TRUE);

DROP POLICY IF EXISTS "authenticated update pabrik" ON public.pabrik;
CREATE POLICY "authenticated update pabrik" ON public.pabrik
    FOR UPDATE TO authenticated USING (TRUE);

-- Pengiriman Pabrik
DROP POLICY IF EXISTS "authenticated all pengiriman_pabrik" ON public.pengiriman_pabrik;
CREATE POLICY "authenticated all pengiriman_pabrik" ON public.pengiriman_pabrik
    FOR ALL TO authenticated USING (TRUE) WITH CHECK (TRUE);

-- Jenis Pengeluaran
DROP POLICY IF EXISTS "authenticated read jenis_pengeluaran" ON public.jenis_pengeluaran;
CREATE POLICY "authenticated read jenis_pengeluaran" ON public.jenis_pengeluaran
    FOR SELECT TO authenticated USING (TRUE);

DROP POLICY IF EXISTS "admin manage jenis_pengeluaran" ON public.jenis_pengeluaran;
CREATE POLICY "admin manage jenis_pengeluaran" ON public.jenis_pengeluaran
    FOR INSERT TO authenticated WITH CHECK (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
        OR (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
        OR (auth.jwt() ->> 'email') ILIKE '%admin%'
    );

DROP POLICY IF EXISTS "admin update jenis_pengeluaran" ON public.jenis_pengeluaran;
CREATE POLICY "admin update jenis_pengeluaran" ON public.jenis_pengeluaran
    FOR UPDATE TO authenticated USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
        OR (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
        OR (auth.jwt() ->> 'email') ILIKE '%admin%'
    );

-- Pengeluaran
DROP POLICY IF EXISTS "authenticated all pengeluaran" ON public.pengeluaran;
CREATE POLICY "authenticated all pengeluaran" ON public.pengeluaran
    FOR ALL TO authenticated USING (TRUE) WITH CHECK (TRUE);

-- Topup Saldo (Admin Only)
DROP POLICY IF EXISTS "admin read topup_saldo" ON public.topup_saldo;
CREATE POLICY "admin read topup_saldo" ON public.topup_saldo
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
        OR (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
        OR (auth.jwt() ->> 'email') ILIKE '%admin%'
    );

DROP POLICY IF EXISTS "admin insert topup_saldo" ON public.topup_saldo;
CREATE POLICY "admin insert topup_saldo" ON public.topup_saldo
    FOR INSERT TO authenticated WITH CHECK (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
        OR (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
        OR (auth.jwt() ->> 'email') ILIKE '%admin%'
    );

DROP POLICY IF EXISTS "admin update topup_saldo" ON public.topup_saldo;
CREATE POLICY "admin update topup_saldo" ON public.topup_saldo
    FOR UPDATE TO authenticated USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
        OR (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
        OR (auth.jwt() ->> 'email') ILIKE '%admin%'
    );

DROP POLICY IF EXISTS "admin delete topup_saldo" ON public.topup_saldo;
CREATE POLICY "admin delete topup_saldo" ON public.topup_saldo
    FOR DELETE TO authenticated USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
        OR (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
        OR (auth.jwt() ->> 'email') ILIKE '%admin%'
    );

-- Transaksi & Transaksi Item
DROP POLICY IF EXISTS "authenticated all transaksi" ON public.transaksi;
CREATE POLICY "authenticated all transaksi" ON public.transaksi
    FOR ALL TO authenticated USING (TRUE) WITH CHECK (TRUE);

DROP POLICY IF EXISTS "authenticated all transaksi_item" ON public.transaksi_item;
CREATE POLICY "authenticated all transaksi_item" ON public.transaksi_item
    FOR ALL TO authenticated USING (TRUE) WITH CHECK (TRUE);

-- ==============================================================================
-- 13. HAK AKSES API POSTGREST (GRANTS)
-- ==============================================================================
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL ROUTINES IN SCHEMA public TO authenticated;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO anon;

-- Refresh cache schema PostgREST Supabase
NOTIFY pgrst, 'reload schema';

COMMIT;
