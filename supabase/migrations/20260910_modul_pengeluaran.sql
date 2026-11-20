-- ============================================================================
-- Migrasi: Modul Baru — Pencatatan Pengeluaran (Database.md §10 & PRD §7.9)
-- Tanggal: 2026-09-19
-- ============================================================================

BEGIN;

-- 1. Tabel Master Jenis Pengeluaran
CREATE TABLE IF NOT EXISTS public.jenis_pengeluaran (
    id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nama TEXT NOT NULL UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Seed data awal kategori pengeluaran
INSERT INTO public.jenis_pengeluaran (nama) VALUES
    ('BBM/Transportasi'),
    ('Gaji/Upah'),
    ('Perawatan Kendaraan'),
    ('Operasional Kantor'),
    ('Lain-lain')
ON CONFLICT (nama) DO NOTHING;

-- 2. Tabel Pengeluaran Operasional
CREATE TABLE IF NOT EXISTS public.pengeluaran (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tanggal_pengeluaran DATE NOT NULL DEFAULT CURRENT_DATE,
    jenis_pengeluaran_id SMALLINT NOT NULL REFERENCES public.jenis_pengeluaran(id),
    keterangan TEXT,
    nominal NUMERIC(14,2) NOT NULL CHECK (nominal > 0),
    created_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pengeluaran_tanggal ON public.pengeluaran (tanggal_pengeluaran DESC);

-- Trigger updated_at otomatis
DROP TRIGGER IF EXISTS trg_pengeluaran_updated_at ON public.pengeluaran;
CREATE TRIGGER trg_pengeluaran_updated_at
    BEFORE UPDATE ON public.pengeluaran
    FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

-- 3. Row Level Security (RLS)
ALTER TABLE public.jenis_pengeluaran ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pengeluaran ENABLE ROW LEVEL SECURITY;

-- Pastikan akun admin memiliki role 'admin' di tabel profiles
UPDATE public.profiles 
SET role = 'admin' 
WHERE id IN (
    SELECT id FROM auth.users WHERE email ILIKE '%admin%'
);

-- Policy jenis_pengeluaran: Semua user authenticated bisa membaca
DROP POLICY IF EXISTS "authenticated read jenis_pengeluaran" ON public.jenis_pengeluaran;
CREATE POLICY "authenticated read jenis_pengeluaran" ON public.jenis_pengeluaran
    FOR SELECT USING (auth.role() = 'authenticated');

-- Policy jenis_pengeluaran: Hanya admin yang boleh insert (FR-9.4)
DROP POLICY IF EXISTS "admin manage jenis_pengeluaran" ON public.jenis_pengeluaran;
CREATE POLICY "admin manage jenis_pengeluaran" ON public.jenis_pengeluaran
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
        OR (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
        OR (auth.jwt() ->> 'email') ILIKE '%admin%'
    );

-- Policy jenis_pengeluaran: Hanya admin yang boleh update (FR-9.4)
DROP POLICY IF EXISTS "admin update jenis_pengeluaran" ON public.jenis_pengeluaran;
CREATE POLICY "admin update jenis_pengeluaran" ON public.jenis_pengeluaran
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
        OR (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
        OR (auth.jwt() ->> 'email') ILIKE '%admin%'
    );

-- Policy pengeluaran: Terbuka untuk semua user authenticated (FR-9.5)
DROP POLICY IF EXISTS "authenticated all pengeluaran" ON public.pengeluaran;
CREATE POLICY "authenticated all pengeluaran" ON public.pengeluaran
    FOR ALL USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');

-- 4. View Agregasi Pengeluaran & Laba Bersih
CREATE OR REPLACE VIEW public.v_pengeluaran_harian AS
SELECT
    tanggal_pengeluaran AS tanggal,
    COALESCE(SUM(nominal), 0)::NUMERIC(14,2) AS total_pengeluaran,
    COUNT(*)::INT AS jumlah_transaksi_pengeluaran
FROM public.pengeluaran
GROUP BY tanggal_pengeluaran;

CREATE OR REPLACE VIEW public.v_breakdown_jenis_pengeluaran AS
SELECT
    jp.nama AS jenis_pengeluaran,
    p.tanggal_pengeluaran AS tanggal,
    COALESCE(SUM(p.nominal), 0)::NUMERIC(14,2) AS total_nominal
FROM public.pengeluaran p
JOIN public.jenis_pengeluaran jp ON jp.id = p.jenis_pengeluaran_id
GROUP BY jp.nama, p.tanggal_pengeluaran;

-- View gabungan Laba Bersih: Margin (v_margin_harian) dikurangi Total Pengeluaran (v_pengeluaran_harian)
CREATE OR REPLACE VIEW public.v_laba_bersih_harian AS
SELECT
    COALESCE(m.tanggal, p.tanggal) AS tanggal,
    COALESCE(m.total_pembelian, 0)::NUMERIC(14,2) AS total_pembelian,
    COALESCE(m.total_penjualan, 0)::NUMERIC(14,2) AS total_penjualan,
    COALESCE(m.margin, 0)::NUMERIC(14,2) AS margin,
    COALESCE(p.total_pengeluaran, 0)::NUMERIC(14,2) AS total_pengeluaran,
    (COALESCE(m.margin, 0) - COALESCE(p.total_pengeluaran, 0))::NUMERIC(14,2) AS laba_bersih
FROM public.v_margin_harian m
FULL OUTER JOIN public.v_pengeluaran_harian p ON m.tanggal = p.tanggal;

COMMIT;
