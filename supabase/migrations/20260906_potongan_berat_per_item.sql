-- ============================================================
-- MIGRASI TUGAS BAGIAN 10: POTONGAN LEVEL BERAT PER JENIS BUAH
-- Sesuai doc/Database-Aplikasi-Transaksi-Sawit.md Bagian 6
-- ============================================================

-- 1. Drop views terdahulu yang bergantung pada kolom subtotal lama
drop view if exists public.v_transaksi_harian cascade;
drop view if exists public.v_transaksi_ringkasan cascade;
drop view if exists public.v_breakdown_jenis_buah cascade;

-- 2. Ganti nama kolom berat_kg -> berat_kotor_kg di transaksi_item
alter table public.transaksi_item rename column berat_kg to berat_kotor_kg;

-- 3. Tambah kolom potongan per item (default 0% = tidak ada potongan, opsional diisi manual)
alter table public.transaksi_item
    add column if not exists persentase_potongan numeric(5,2) not null default 0
    check (persentase_potongan >= 0 and persentase_potongan <= 100);

-- 4. Hapus kolom subtotal lama (generated formula lama)
alter table public.transaksi_item drop column if exists subtotal;

-- 5. Tambah kolom berat_bersih_kg (generated, turunan berat kotor & potongan)
alter table public.transaksi_item
    add column if not exists berat_bersih_kg numeric(10,2)
    generated always as (round(berat_kotor_kg * (1 - persentase_potongan / 100), 2)) stored;

-- 6. Tambah kolom nilai_potongan_rp (generated, informasi rupiah potongan berat)
alter table public.transaksi_item
    add column if not exists nilai_potongan_rp numeric(14,2)
    generated always as (round(harga_per_kg * berat_kotor_kg * (persentase_potongan / 100), 2)) stored;

-- 7. Buat ulang kolom subtotal dengan formula baru: harga_per_kg x berat_bersih_kg
alter table public.transaksi_item
    add column if not exists subtotal numeric(14,2)
    generated always as (round(harga_per_kg * berat_kotor_kg * (1 - persentase_potongan / 100), 2)) stored;

-- 8. Re-create view ringkasan transaksi
create or replace view public.v_transaksi_ringkasan as
select
    t.id,
    t.kode_transaksi,
    t.tanggal_transaksi,
    t.status,
    p.id as penjual_id,
    p.nama as nama_penjual,
    coalesce(sum(ti.berat_kotor_kg), 0) as total_berat_kotor_kg,
    coalesce(sum(ti.berat_bersih_kg), 0) as total_berat_bersih_kg,
    coalesce(sum(ti.nilai_potongan_rp), 0) as total_potongan_rp,
    coalesce(sum(ti.subtotal), 0) as total_nilai,
    t.created_at
from public.transaksi t
join public.penjual p on p.id = t.penjual_id
left join public.transaksi_item ti on ti.transaksi_id = t.id
group by t.id, t.kode_transaksi, t.tanggal_transaksi, t.status, p.id, p.nama, t.created_at;

-- 9. Re-create view harian
create or replace view public.v_transaksi_harian as
select
    tanggal_transaksi,
    count(distinct id) as jumlah_transaksi,
    sum(total_berat_kotor_kg) as total_berat_kotor_kg,
    sum(total_berat_bersih_kg) as total_berat_bersih_kg,
    sum(total_potongan_rp) as total_potongan_rp,
    sum(total_nilai) as total_nilai
from public.v_transaksi_ringkasan
where status = 'selesai'
group by tanggal_transaksi
order by tanggal_transaksi;

-- 10. Re-create view breakdown per jenis buah
create or replace view public.v_breakdown_jenis_buah as
select
    jb.nama as jenis_buah,
    date_trunc('day', t.tanggal_transaksi) as tanggal,
    sum(ti.berat_kotor_kg) as total_berat_kotor_kg,
    sum(ti.berat_bersih_kg) as total_berat_bersih_kg,
    sum(ti.subtotal) as total_nilai
from public.transaksi_item ti
join public.transaksi t on t.id = ti.transaksi_id
join public.jenis_buah jb on jb.id = ti.jenis_buah_id
where t.status = 'selesai'
group by jb.nama, date_trunc('day', t.tanggal_transaksi);
