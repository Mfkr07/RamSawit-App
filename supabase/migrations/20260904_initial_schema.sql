-- ========================================================
-- SKEMA DATABASE APLIKASI TRANSAKSI JUAL BELI SAWIT (TBS)
-- Sesuai Bagian 8.3 & 8.4 PRD (PostgreSQL 15+ / Supabase)
-- ========================================================

-- ============================================
-- 1. EXTENSIONS
-- ============================================
create extension if not exists "pgcrypto"; -- untuk gen_random_uuid()
create extension if not exists pg_trgm;    -- untuk pencarian teks cepat nama penjual

-- ============================================
-- 2. TABEL: profiles (extend auth.users)
-- ============================================
create table if not exists public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    nama text not null,
    role text not null default 'kasir' check (role in ('admin','kasir')),
    created_at timestamptz not null default now()
);

-- Function & Trigger: Auto-create profile saat user baru register via Supabase Auth
create or replace function public.handle_new_user()
returns trigger as $$
begin
    insert into public.profiles (id, nama, role)
    values (new.id, coalesce(new.raw_user_meta_data->>'nama', new.email), 'kasir');
    return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
    after insert on auth.users
    for each row execute procedure public.handle_new_user();

-- ============================================
-- 3. TABEL: penjual
-- ============================================
create table if not exists public.penjual (
    id uuid primary key default gen_random_uuid(),
    nama text not null,
    no_telepon text,
    alamat text,
    catatan text,
    is_active boolean not null default true,
    created_by uuid references public.profiles(id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index if not exists idx_penjual_nama on public.penjual using gin (nama gin_trgm_ops);

-- ============================================
-- 4. TABEL: jenis_buah (master)
-- ============================================
create table if not exists public.jenis_buah (
    id smallint generated always as identity primary key,
    kode text not null unique,
    nama text not null unique,
    is_active boolean not null default true
);

-- Seed initial jenis_buah (idempotent)
insert into public.jenis_buah (kode, nama) values
    ('TB', 'Tandan Besar'),
    ('TK', 'Tandan Kecil'),
    ('BR', 'Berondolan')
on conflict (kode) do nothing;

-- ============================================
-- 5. TABEL: transaksi (header)
-- ============================================
create table if not exists public.transaksi (
    id uuid primary key default gen_random_uuid(),
    kode_transaksi text not null unique,
    penjual_id uuid not null references public.penjual(id),
    tanggal_transaksi date not null default current_date,
    status text not null default 'selesai' check (status in ('draft','selesai','dibatalkan')),
    catatan text,
    created_by uuid references public.profiles(id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index if not exists idx_transaksi_tanggal on public.transaksi (tanggal_transaksi desc);
create index if not exists idx_transaksi_penjual on public.transaksi (penjual_id);
create index if not exists idx_transaksi_status on public.transaksi (status);

-- ============================================
-- 6. TABEL: transaksi_item (detail per jenis buah)
-- ============================================
create table if not exists public.transaksi_item (
    id uuid primary key default gen_random_uuid(),
    transaksi_id uuid not null references public.transaksi(id) on delete cascade,
    jenis_buah_id smallint not null references public.jenis_buah(id),
    harga_per_kg numeric(12,2) not null check (harga_per_kg >= 0),
    berat_kg numeric(10,2) not null check (berat_kg > 0),
    subtotal numeric(14,2) generated always as (harga_per_kg * berat_kg) stored,
    created_at timestamptz not null default now(),
    unique (transaksi_id, jenis_buah_id) -- 1 jenis buah hanya boleh 1 baris per transaksi
);

create index if not exists idx_item_transaksi on public.transaksi_item (transaksi_id);

-- ============================================
-- 7. TRIGGER: auto-generate kode_transaksi (TRX-YYYYMMDD-0001)
-- ============================================
create sequence if not exists transaksi_harian_seq;

create or replace function public.generate_kode_transaksi()
returns trigger as $$
declare
    next_seq int;
    tanggal_str text;
begin
    if new.kode_transaksi is null or new.kode_transaksi = '' then
        tanggal_str := to_char(coalesce(new.tanggal_transaksi, current_date), 'YYYYMMDD');
        select coalesce(max(
            (regexp_match(kode_transaksi, 'TRX-' || tanggal_str || '-(\d+)'))[1]::int
        ), 0) + 1
        into next_seq
        from public.transaksi
        where kode_transaksi like 'TRX-' || tanggal_str || '-%';

        new.kode_transaksi := 'TRX-' || tanggal_str || '-' || lpad(next_seq::text, 4, '0');
    end if;
    return new;
end;
$$ language plpgsql;

drop trigger if exists trg_generate_kode_transaksi on public.transaksi;
create trigger trg_generate_kode_transaksi
    before insert on public.transaksi
    for each row execute procedure public.generate_kode_transaksi();

-- ============================================
-- 8. TRIGGER: auto-update updated_at
-- ============================================
create or replace function public.set_updated_at()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

drop trigger if exists trg_penjual_updated_at on public.penjual;
create trigger trg_penjual_updated_at
    before update on public.penjual
    for each row execute procedure public.set_updated_at();

drop trigger if exists trg_transaksi_updated_at on public.transaksi;
create trigger trg_transaksi_updated_at
    before update on public.transaksi
    for each row execute procedure public.set_updated_at();

-- ============================================
-- 9. ROW LEVEL SECURITY (RLS)
-- ============================================
alter table public.profiles enable row level security;
alter table public.penjual enable row level security;
alter table public.jenis_buah enable row level security;
alter table public.transaksi enable row level security;
alter table public.transaksi_item enable row level security;

-- Drop existing policies if exists to allow safe re-runs
drop policy if exists "authenticated read profiles" on public.profiles;
create policy "authenticated read profiles" on public.profiles
    for select using (auth.role() = 'authenticated');

drop policy if exists "authenticated all penjual" on public.penjual;
create policy "authenticated all penjual" on public.penjual
    for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

drop policy if exists "authenticated read jenis_buah" on public.jenis_buah;
create policy "authenticated read jenis_buah" on public.jenis_buah
    for select using (auth.role() = 'authenticated');

drop policy if exists "authenticated all transaksi" on public.transaksi;
create policy "authenticated all transaksi" on public.transaksi
    for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

drop policy if exists "authenticated all transaksi_item" on public.transaksi_item;
create policy "authenticated all transaksi_item" on public.transaksi_item
    for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

drop policy if exists "admin manage jenis_buah" on public.jenis_buah;
create policy "admin manage jenis_buah" on public.jenis_buah
    for insert with check (
        exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
    );

-- ============================================
-- 10. VIEWS UNTUK DASHBOARD & REPORTING
-- ============================================

-- Ringkasan per transaksi (total berat & total harga, dihitung dari item)
create or replace view public.v_transaksi_ringkasan as
select
    t.id,
    t.kode_transaksi,
    t.tanggal_transaksi,
    t.status,
    p.id as penjual_id,
    p.nama as nama_penjual,
    coalesce(sum(ti.berat_kg), 0) as total_berat_kg,
    coalesce(sum(ti.subtotal), 0) as total_harga,
    t.catatan,
    t.created_by,
    t.created_at,
    t.updated_at
from public.transaksi t
join public.penjual p on p.id = t.penjual_id
left join public.transaksi_item ti on ti.transaksi_id = t.id
group by t.id, t.kode_transaksi, t.tanggal_transaksi, t.status, p.id, p.nama, t.catatan, t.created_by, t.created_at, t.updated_at;

-- Agregasi harian (untuk grafik tren dashboard)
create or replace view public.v_transaksi_harian as
select
    tanggal_transaksi,
    count(distinct id) as jumlah_transaksi,
    sum(total_berat_kg) as total_berat_kg,
    sum(total_harga) as total_nilai
from public.v_transaksi_ringkasan
where status = 'selesai'
group by tanggal_transaksi
order by tanggal_transaksi;

-- Breakdown per jenis buah (untuk pie/bar chart)
create or replace view public.v_breakdown_jenis_buah as
select
    jb.nama as jenis_buah,
    date_trunc('day', t.tanggal_transaksi) as tanggal,
    sum(ti.berat_kg) as total_berat_kg,
    sum(ti.subtotal) as total_nilai
from public.transaksi_item ti
join public.transaksi t on t.id = ti.transaksi_id
join public.jenis_buah jb on jb.id = ti.jenis_buah_id
where t.status = 'selesai'
group by jb.nama, date_trunc('day', t.tanggal_transaksi);
