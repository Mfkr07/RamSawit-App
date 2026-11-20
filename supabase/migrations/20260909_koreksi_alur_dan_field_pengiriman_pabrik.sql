-- ====================================================================
-- MIGRASI TUGAS BAGIAN 20: KOREKSI ALUR & FIELD PENJUALAN KE PABRIK
-- Sesuai doc/Database-Aplikasi-Transaksi-Sawit.md §9 & doc/PRD-Aplikasi-Transaksi-Sawit.md FR-8.x
-- ====================================================================

begin;

-- 1. Drop view sementara agar tidak terhalang dependency kolom generated
drop view if exists public.v_margin_harian cascade;
drop view if exists public.v_breakdown_pabrik cascade;
drop view if exists public.v_pengiriman_harian cascade;
drop view if exists public.v_pengiriman_ringkasan cascade;

-- 2. Rename berat_kotor_kg -> berat_dikirim_kg
alter table public.pengiriman_pabrik rename column berat_kotor_kg to berat_dikirim_kg;

-- 3. Tambah kolom BARU berat_sampai_kg (manual, timbangan pabrik)
alter table public.pengiriman_pabrik
    add column berat_sampai_kg numeric(10,2)
    check (berat_sampai_kg is null or berat_sampai_kg > 0);

-- 4. Backfill data lama yang sudah selesai (berat_ditolak_kg is not null):
--    Set berat_sampai_kg = berat_dikirim_kg sehingga nilai turunan tetap identik 100%
update public.pengiriman_pabrik
set berat_sampai_kg = berat_dikirim_kg
where berat_ditolak_kg is not null;

-- 5. Drop 4 kolom generated lama
alter table public.pengiriman_pabrik drop column berat_diterima_kg;
alter table public.pengiriman_pabrik drop column berat_bersih_kg;
alter table public.pengiriman_pabrik drop column nilai_potongan_rp;
alter table public.pengiriman_pabrik drop column total_nilai_jual;

-- 6. Buat ulang 4 kolom generated dengan basis berat_sampai_kg
alter table public.pengiriman_pabrik
    add column berat_diterima_kg numeric(10,2)
    generated always as (round(berat_sampai_kg - berat_ditolak_kg, 2)) stored;

alter table public.pengiriman_pabrik
    add column berat_bersih_kg numeric(10,2)
    generated always as (
        round((berat_sampai_kg - berat_ditolak_kg) * (1 - persentase_potongan_pabrik / 100), 2)
    ) stored;

alter table public.pengiriman_pabrik
    add column nilai_potongan_rp numeric(14,2)
    generated always as (
        round(harga_jual_per_kg * (berat_sampai_kg - berat_ditolak_kg) * persentase_potongan_pabrik / 100, 2)
    ) stored;

alter table public.pengiriman_pabrik
    add column total_nilai_jual numeric(14,2)
    generated always as (
        round(harga_jual_per_kg * (berat_sampai_kg - berat_ditolak_kg) * (1 - persentase_potongan_pabrik / 100), 2)
    ) stored;

-- 7. Tambah kolom BARU susut_buah_kg (selisih timbangan kirim vs sampai)
alter table public.pengiriman_pabrik
    add column susut_buah_kg numeric(10,2)
    generated always as (round(berat_dikirim_kg - berat_sampai_kg, 2)) stored;

-- 8. Ganti check constraint lama (pengiriman_pabrik_check)
alter table public.pengiriman_pabrik
    drop constraint pengiriman_pabrik_check;

alter table public.pengiriman_pabrik
    add constraint pengiriman_pabrik_ditolak_lte_sampai_check
    check (berat_sampai_kg is null or berat_ditolak_kg is null
           or berat_ditolak_kg <= berat_sampai_kg);

-- 9. Rekonstruksi views pelaporan
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
    pp.berat_dikirim_kg,
    pp.berat_sampai_kg,
    pp.berat_ditolak_kg,
    pp.berat_diterima_kg,
    pp.persentase_potongan_pabrik,
    pp.berat_bersih_kg,
    pp.susut_buah_kg,
    pp.harga_jual_per_kg,
    pp.nilai_potongan_rp,
    pp.total_nilai_jual,
    pp.created_at
from public.pengiriman_pabrik pp
join public.pabrik pb on pb.id = pp.pabrik_id;

create or replace view public.v_pengiriman_harian as
select
    tanggal_kirim,
    count(distinct id) as jumlah_pengiriman,
    sum(berat_dikirim_kg) as total_berat_dikirim_kg,
    sum(berat_ditolak_kg) as total_berat_ditolak_kg,
    sum(berat_bersih_kg) as total_berat_bersih_kg,
    sum(susut_buah_kg) as total_susut_buah_kg,
    sum(nilai_potongan_rp) as total_potongan_rp,
    sum(total_nilai_jual) as total_nilai_jual
from public.v_pengiriman_ringkasan
where status = 'selesai'
group by tanggal_kirim
order by tanggal_kirim;

create or replace view public.v_margin_harian as
select
    coalesce(t.tanggal_transaksi, p.tanggal_kirim) as tanggal,
    coalesce(t.total_nilai, 0) as total_pembelian,
    coalesce(p.total_nilai_jual, 0) as total_penjualan,
    coalesce(p.total_nilai_jual, 0) - coalesce(t.total_nilai, 0) as margin
from public.v_transaksi_harian t
full outer join public.v_pengiriman_harian p on p.tanggal_kirim = t.tanggal_transaksi
order by tanggal;

create or replace view public.v_breakdown_pabrik as
select
    pb.nama as nama_pabrik,
    date_trunc('day', pp.tanggal_kirim) as tanggal,
    sum(pp.berat_dikirim_kg) as total_berat_dikirim_kg,
    sum(pp.berat_dikirim_kg) as total_berat_kotor_kg,
    sum(pp.berat_bersih_kg) as total_berat_bersih_kg,
    sum(pp.total_nilai_jual) as total_nilai_jual
from public.pengiriman_pabrik pp
join public.pabrik pb on pb.id = pp.pabrik_id
where pp.status = 'selesai'
group by pb.nama, date_trunc('day', pp.tanggal_kirim);

commit;
