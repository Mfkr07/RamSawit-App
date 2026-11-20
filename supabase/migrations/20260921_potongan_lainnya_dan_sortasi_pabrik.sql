-- ====================================================================
-- MIGRASI TUGAS BAGIAN 23: POTONGAN LAINNYA & SORTASI PENJUALAN KE PABRIK
-- Sesuai doc/Database-Aplikasi-Transaksi-Sawit.md §12 & doc/PRD-Aplikasi-Transaksi-Sawit.md FR-8.x
-- ====================================================================

begin;

-- 1. Drop view-view dependen sementara dengan CASCADE agar alter/drop column tidak terhalang
drop view if exists public.v_laba_bersih_harian cascade;
drop view if exists public.v_margin_harian cascade;
drop view if exists public.v_pengiriman_harian cascade;
drop view if exists public.v_breakdown_pabrik cascade;
drop view if exists public.v_pengiriman_ringkasan cascade;

-- 2. Tambah 2 kolom baru, keduanya opsional (nullable, tanpa default -- boleh kosong)
alter table public.pengiriman_pabrik
    add column potongan_lainnya_rp numeric(14,2)
    check (potongan_lainnya_rp is null or potongan_lainnya_rp >= 0);

alter table public.pengiriman_pabrik
    add column potongan_sortasi_per_kg numeric(12,2)
    check (potongan_sortasi_per_kg is null or potongan_sortasi_per_kg >= 0);

-- 3. Drop kolom total_nilai_jual lama (formula berubah, generated column harus di-drop+add ulang)
alter table public.pengiriman_pabrik drop column total_nilai_jual;

-- 4. Tambah kolom baru: Nilai Potongan Sortasi (turunan) = Potongan Sortasi (Rp/kg) x Berat Sampai
--    coalesce(...,0) supaya baris yang belum/tidak mengisi field ini otomatis bernilai 0, bukan null
alter table public.pengiriman_pabrik
    add column nilai_potongan_sortasi_rp numeric(14,2)
    generated always as (round(coalesce(potongan_sortasi_per_kg, 0) * berat_sampai_kg, 2)) stored;

-- 5. Buat ulang total_nilai_jual dengan formula baru:
--    (Harga Jual/kg x Berat Bersih) - Potongan Lainnya - Nilai Potongan Sortasi
--    coalesce(...,0) pada potongan_lainnya_rp supaya baris lama/kosong tidak berubah nilainya
alter table public.pengiriman_pabrik
    add column total_nilai_jual numeric(14,2)
    generated always as (
        round(
            harga_jual_per_kg * (berat_sampai_kg - berat_ditolak_kg) * (1 - persentase_potongan_pabrik / 100)
            - coalesce(potongan_lainnya_rp, 0)
            - round(coalesce(potongan_sortasi_per_kg, 0) * berat_sampai_kg, 2)
        , 2)
    ) stored;

-- 6. Rekonstruksi view v_pengiriman_ringkasan (dengan kolom-kolom baru)
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
    pp.potongan_lainnya_rp,
    pp.potongan_sortasi_per_kg,
    pp.nilai_potongan_sortasi_rp,
    pp.total_nilai_jual,
    pp.created_at
from public.pengiriman_pabrik pp
join public.pabrik pb on pb.id = pp.pabrik_id;

-- 7. Rekonstruksi view v_pengiriman_harian
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

-- 8. Rekonstruksi view v_margin_harian
create or replace view public.v_margin_harian as
select
    coalesce(t.tanggal_transaksi, p.tanggal_kirim) as tanggal,
    coalesce(t.total_nilai, 0) as total_pembelian,
    coalesce(p.total_nilai_jual, 0) as total_penjualan,
    coalesce(p.total_nilai_jual, 0) - coalesce(t.total_nilai, 0) as margin
from public.v_transaksi_harian t
full outer join public.v_pengiriman_harian p on p.tanggal_kirim = t.tanggal_transaksi
order by tanggal;

-- 9. Rekonstruksi view v_laba_bersih_harian
create or replace view public.v_laba_bersih_harian as
select
    coalesce(m.tanggal, p.tanggal) as tanggal,
    coalesce(m.total_pembelian, 0)::numeric(14,2) as total_pembelian,
    coalesce(m.total_penjualan, 0)::numeric(14,2) as total_penjualan,
    coalesce(m.margin, 0)::numeric(14,2) as margin,
    coalesce(p.total_pengeluaran, 0)::numeric(14,2) as total_pengeluaran,
    (coalesce(m.margin, 0) - coalesce(p.total_pengeluaran, 0))::numeric(14,2) as laba_bersih
from public.v_margin_harian m
full outer join public.v_pengeluaran_harian p on m.tanggal = p.tanggal;

-- 10. Rekonstruksi view v_breakdown_pabrik
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

-- 11. Pulihkan hak akses (Grants) & reload schema cache
grant select on public.v_pengiriman_ringkasan to authenticated, anon;
grant select on public.v_pengiriman_harian to authenticated, anon;
grant select on public.v_margin_harian to authenticated, anon;
grant select on public.v_laba_bersih_harian to authenticated, anon;
grant select on public.v_breakdown_pabrik to authenticated, anon;
notify pgrst, 'reload schema';

commit;
