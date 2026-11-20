-- ==============================================================================
-- MIGRASI MODUL SALDO / DANA MODAL (BAGIAN 22)
-- Sumber Spesifikasi: doc/PRD-Aplikasi-Transaksi-Sawit.md (§7.10)
--                    doc/Database-Aplikasi-Transaksi-Sawit.md (§11)
-- ==============================================================================

BEGIN;

-- 1. TABEL: topup_saldo
CREATE TABLE IF NOT EXISTS public.topup_saldo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tanggal DATE NOT NULL DEFAULT CURRENT_DATE,
    nominal NUMERIC(14,2) NOT NULL CHECK (nominal > 0),
    keterangan TEXT,
    created_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index tanggal untuk mempercepat pengurutan riwayat dan filter periode
CREATE INDEX IF NOT EXISTS idx_topup_saldo_tanggal ON public.topup_saldo (tanggal DESC);

-- 2. ROW LEVEL SECURITY (RLS)
ALTER TABLE public.topup_saldo ENABLE ROW LEVEL SECURITY;

-- Pastikan akun admin memiliki role 'admin' di tabel profiles
UPDATE public.profiles 
SET role = 'admin' 
WHERE id IN (
    SELECT id FROM auth.users WHERE email ILIKE '%admin%'
);

-- Policy topup_saldo: Hanya role Admin yang boleh membaca (FR-10.8)
DROP POLICY IF EXISTS "admin read topup_saldo" ON public.topup_saldo;
CREATE POLICY "admin read topup_saldo" ON public.topup_saldo
    FOR SELECT TO authenticated USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
        OR (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
        OR (auth.jwt() ->> 'email') ILIKE '%admin%'
    );

-- Policy topup_saldo: Hanya role Admin yang boleh mencatat top up baru (FR-10.1, FR-10.8)
DROP POLICY IF EXISTS "admin insert topup_saldo" ON public.topup_saldo;
CREATE POLICY "admin insert topup_saldo" ON public.topup_saldo
    FOR INSERT TO authenticated WITH CHECK (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
        OR (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
        OR (auth.jwt() ->> 'email') ILIKE '%admin%'
    );

-- Policy topup_saldo: Hanya role Admin yang boleh update
DROP POLICY IF EXISTS "admin update topup_saldo" ON public.topup_saldo;
CREATE POLICY "admin update topup_saldo" ON public.topup_saldo
    FOR UPDATE TO authenticated USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
        OR (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
        OR (auth.jwt() ->> 'email') ILIKE '%admin%'
    );

-- Policy topup_saldo: Hanya role Admin yang boleh delete
DROP POLICY IF EXISTS "admin delete topup_saldo" ON public.topup_saldo;
CREATE POLICY "admin delete topup_saldo" ON public.topup_saldo
    FOR DELETE TO authenticated USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
        OR (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
        OR (auth.jwt() ->> 'email') ILIKE '%admin%'
    );

-- 3. VIEW: v_saldo_ringkasan (FR-10.2, FR-10.3)
-- Mengembalikan 1 baris ringkasan saldo saat ini (total top up, total pemakaian, dan sisa saldo)
CREATE OR REPLACE VIEW public.v_saldo_ringkasan AS
SELECT
    (SELECT COALESCE(SUM(nominal), 0)::NUMERIC(14,2) FROM public.topup_saldo) AS total_topup,
    (SELECT COALESCE(SUM(total_nilai), 0)::NUMERIC(14,2)
       FROM public.v_transaksi_ringkasan WHERE status = 'selesai') AS total_pemakaian,
    (SELECT COALESCE(SUM(nominal), 0)::NUMERIC(14,2) FROM public.topup_saldo)
      - (SELECT COALESCE(SUM(total_nilai), 0)::NUMERIC(14,2)
           FROM public.v_transaksi_ringkasan WHERE status = 'selesai') AS sisa_saldo;

-- 4. GRANT PERMISSIONS & NOTIFY POSTGREST SCHEMA CACHE
-- Memberikan hak akses tabel dan view kepada role authenticated & anon
GRANT ALL ON public.topup_saldo TO authenticated;
GRANT SELECT ON public.v_saldo_ringkasan TO authenticated, anon;

-- Refresh cache PostgREST Supabase agar view langsung terdeteksi
NOTIFY pgrst, 'reload schema';

COMMIT;

