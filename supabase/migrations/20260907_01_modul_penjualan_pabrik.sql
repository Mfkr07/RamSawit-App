-- ============================================================
-- MIGRASI TUGAS BAGIAN 11: MODUL PENJUALAN KE PABRIK (PKS)
-- Sesuai doc/Database-Aplikasi-Transaksi-Sawit.md §7.3 & §7.4
-- ============================================================

-- ============================================
-- 1. TABEL: pabrik (master data)
-- ============================================
create table if not exists public.pabrik (
    id uuid primary key default gen_random_uuid(),
    nama text not null,
    alamat text,
    kontak text,
    is_active boolean not null default true,
    created_by uuid references public.profiles(id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index if not exists idx_pabrik_nama on public.pabrik using gin (nama gin_trgm_ops);

drop trigger if exists trg_pabrik_updated_at on public.pabrik;
create trigger trg_pabrik_updated_at
    before update on public.pabrik
    for each row execute procedure public.set_updated_at();

-- ============================================
-- 2. TABEL: pengiriman_pabrik
-- ============================================
create table if not exists public.pengiriman_pabrik (
    id uuid primary key default gen_random_uuid(),
    kode_pengiriman text not null unique,
    pabrik_id uuid not null references public.pabrik(id),
    plat_nomor text not null,
    nama_sopir text not null,
    tanggal_kirim date not null default current_date,

    berat_kotor_kg numeric(10,2) not null check (berat_kotor_kg > 0),
    berat_ditolak_kg numeric(10,2) not null default 0 check (berat_ditolak_kg >= 0),
    berat_diterima_kg numeric(10,2)
        generated always as (round(berat_kotor_kg - berat_ditolak_kg, 2)) stored,

    persentase_potongan_pabrik numeric(5,2) not null default 0
        check (persentase_potongan_pabrik >= 0 and persentase_potongan_pabrik <= 100),
    berat_bersih_kg numeric(10,2)
        generated always as (
            round((berat_kotor_kg - berat_ditolak_kg) * (1 - persentase_potongan_pabrik / 100), 2)
        ) stored,

    harga_jual_per_kg numeric(12,2) not null check (harga_jual_per_kg >= 0),
    nilai_potongan_rp numeric(14,2)
        generated always as (
            round(harga_jual_per_kg * (berat_kotor_kg - berat_ditolak_kg) * persentase_potongan_pabrik / 100, 2)
        ) stored,
    total_nilai_jual numeric(14,2)
        generated always as (
            round(harga_jual_per_kg * (berat_kotor_kg - berat_ditolak_kg) * (1 - persentase_potongan_pabrik / 100), 2)
        ) stored,

    status text not null default 'selesai' check (status in ('draft','selesai','dibatalkan')),
    catatan text,
    created_by uuid references public.profiles(id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

    check (berat_ditolak_kg <= berat_kotor_kg)
);

create index if not exists idx_pengiriman_tanggal on public.pengiriman_pabrik (tanggal_kirim desc);
create index if not exists idx_pengiriman_pabrik on public.pengiriman_pabrik (pabrik_id);
create index if not exists idx_pengiriman_status on public.pengiriman_pabrik (status);

drop trigger if exists trg_pengiriman_updated_at on public.pengiriman_pabrik;
create trigger trg_pengiriman_updated_at
    before update on public.pengiriman_pabrik
    for each row execute procedure public.set_updated_at();

-- Auto-generate kode_pengiriman (KRM-YYYYMMDD-0001)
create or replace function public.generate_kode_pengiriman()
returns trigger as $$
declare
    next_seq int;
    tanggal_str text;
begin
    if new.kode_pengiriman is null or new.kode_pengiriman = '' then
        tanggal_str := to_char(coalesce(new.tanggal_kirim, current_date), 'YYYYMMDD');
        select coalesce(max(
            (regexp_match(kode_pengiriman, 'KRM-' || tanggal_str || '-(\d+)'))[1]::int
        ), 0) + 1
        into next_seq
        from public.pengiriman_pabrik
        where kode_pengiriman like 'KRM-' || tanggal_str || '-%';

        new.kode_pengiriman := 'KRM-' || tanggal_str || '-' || lpad(next_seq::text, 4, '0');
    end if;
    return new;
end;
$$ language plpgsql;

drop trigger if exists trg_generate_kode_pengiriman on public.pengiriman_pabrik;
create trigger trg_generate_kode_pengiriman
    before insert on public.pengiriman_pabrik
    for each row execute procedure public.generate_kode_pengiriman();

-- ============================================
-- 3. ROW LEVEL SECURITY (RLS)
-- ============================================
alter table public.pabrik enable row level security;
alter table public.pengiriman_pabrik enable row level security;

do $$
begin
    if not exists (
        select 1 from pg_policies where schemaname = 'public' and tablename = 'pabrik' and policyname = 'authenticated all pabrik'
    ) then
        create policy "authenticated all pabrik" on public.pabrik
            for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
    end if;

    if not exists (
        select 1 from pg_policies where schemaname = 'public' and tablename = 'pengiriman_pabrik' and policyname = 'authenticated all pengiriman_pabrik'
    ) then
        create policy "authenticated all pengiriman_pabrik" on public.pengiriman_pabrik
            for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
    end if;
end $$;

-- ============================================
-- 4. VIEWS: Pelaporan & Margin Pabrik
-- ============================================

-- Ringkasan per pengiriman
create or replace view public.v_pengiriman_ringkasan as
select
    pp.id,
    pp.kode_pengiriman,
    pp.tanggal_kirim,
    pp.status,
    pb.id as pabrik_id,
    pb.nama as nama_pabrik,
    pp.plat_nomor,
    pp.nama_sopir,
    pp.berat_kotor_kg,
    pp.berat_ditolak_kg,
    pp.berat_diterima_kg,
    pp.persentase_potongan_pabrik,
    pp.berat_bersih_kg,
    pp.harga_jual_per_kg,
    pp.nilai_potongan_rp,
    pp.total_nilai_jual,
    pp.created_at
from public.pengiriman_pabrik pp
join public.pabrik pb on pb.id = pp.pabrik_id;

-- Agregasi harian (untuk grafik & kartu dashboard)
create or replace view public.v_pengiriman_harian as
select
    tanggal_kirim,
    count(distinct id) as jumlah_pengiriman,
    sum(berat_kotor_kg) as total_berat_kotor_kg,
    sum(berat_ditolak_kg) as total_berat_ditolak_kg,
    sum(berat_bersih_kg) as total_berat_bersih_kg,
    sum(nilai_potongan_rp) as total_potongan_rp,
    sum(total_nilai_jual) as total_nilai_jual
from public.v_pengiriman_ringkasan
where status = 'selesai'
group by tanggal_kirim
order by tanggal_kirim;

-- Margin harian: total penjualan ke pabrik dikurangi total pembelian dari petani, per tanggal yang sama
create or replace view public.v_margin_harian as
select
    coalesce(t.tanggal_transaksi, p.tanggal_kirim) as tanggal,
    coalesce(t.total_nilai, 0) as total_pembelian,
    coalesce(p.total_nilai_jual, 0) as total_penjualan,
    coalesce(p.total_nilai_jual, 0) - coalesce(t.total_nilai, 0) as margin
from public.v_transaksi_harian t
full outer join public.v_pengiriman_harian p on p.tanggal_kirim = t.tanggal_transaksi
order by tanggal;
