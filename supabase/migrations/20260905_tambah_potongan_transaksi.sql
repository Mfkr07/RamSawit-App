-- ============================================================
-- MIGRASI TAMBAHAN: POTONGAN TRANSAKSI (DEFAULT 5%)
-- Sesuai Database.md Bagian 5 & PRD FR-6.x
-- Sifat: 100% NON-DESTRUKTIF (ALTER TABLE & CREATE OR REPLACE VIEW)
-- TIDAK ADA: DROP TABLE, DROP COLUMN, TRUNCATE
-- ============================================================

-- 1. Tambah kolom persentase_potongan di tabel transaksi (default 5.00%)
alter table public.transaksi
    add column if not exists persentase_potongan numeric(5,2) not null default 5.00
    check (persentase_potongan >= 0 and persentase_potongan <= 100);

-- 2. Update view ringkasan agar menyertakan potongan & total bersih
-- Kolom 1 s/d 12 sama persis dengan urutan skema awal, 3 kolom potongan di-append di akhir (kolom 13, 14, 15)
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
    t.updated_at,
    t.persentase_potongan,
    round(coalesce(sum(ti.subtotal), 0) * t.persentase_potongan / 100, 2) as nilai_potongan,
    round(coalesce(sum(ti.subtotal), 0) * (1 - t.persentase_potongan / 100), 2) as total_bersih
from public.transaksi t
join public.penjual p on p.id = t.penjual_id
left join public.transaksi_item ti on ti.transaksi_id = t.id
group by 
    t.id, 
    t.kode_transaksi, 
    t.tanggal_transaksi, 
    t.status, 
    p.id, 
    p.nama, 
    t.catatan, 
    t.created_by, 
    t.created_at, 
    t.updated_at, 
    t.persentase_potongan;

-- 3. Perbarui view v_transaksi_harian (total_nilai menggunakan total_bersih)
-- Kolom 1 s/d 4 tetap sama namanya (total_nilai di kolom 4 menghitung total_bersih)
-- Kolom 5 & 6 (total_kotor, total_potongan) di-append di akhir
create or replace view public.v_transaksi_harian as
select
    tanggal_transaksi,
    count(distinct id) as jumlah_transaksi,
    sum(total_berat_kg) as total_berat_kg,
    sum(total_bersih) as total_nilai,
    sum(total_harga) as total_kotor,
    sum(nilai_potongan) as total_potongan
from public.v_transaksi_ringkasan
where status = 'selesai'
group by tanggal_transaksi
order by tanggal_transaksi;
