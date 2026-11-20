-- ==============================================================================
-- Migrasi Lanjutan: Jenis Pembayaran (Tunai/Non Tunai) pada Transaksi Pembelian
-- Modul: Pembelian (PRD §7.3 FR-3.8, §7.4 FR-4.1, FR-4.2) & Saldo (PRD §7.10 FR-10.2, 10.3, 10.4, 10.9, 10.10)
-- Acuan: Database.md Bagian 13
-- ==============================================================================

begin;

-- 1. Tambah kolom jenis_pembayaran, NOT NULL DEFAULT 'tunai'
--    Postgres otomatis mengisi seluruh baris lama dengan 'tunai' saat kolom dibuat.
--    Operasi ini metadata-only & instan di PostgreSQL 11+.
alter table public.transaksi
    add column if not exists jenis_pembayaran text not null default 'tunai'
    check (jenis_pembayaran in ('tunai', 'non_tunai'));

-- 2. Update v_transaksi_ringkasan agar menyertakan kolom jenis_pembayaran
--    Kolom diletakkan di akhir SELECT list agar tidak mengubah urutan kolom eksisting,
--    sehingga tidak memicu error Postgres 'cannot change name of view column'.
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
    t.created_at,
    t.jenis_pembayaran
from public.transaksi t
join public.penjual p on p.id = t.penjual_id
left join public.transaksi_item ti on ti.transaksi_id = t.id
group by t.id, t.kode_transaksi, t.tanggal_transaksi, t.status, p.id, p.nama, t.created_at, t.jenis_pembayaran;

-- 3. Update v_saldo_ringkasan: Total Pemakaian HANYA dari transaksi Tunai
--    Gunakan DROP VIEW IF EXISTS lalu CREATE VIEW untuk menghindari error 42P16
--    (PostgreSQL melarang CREATE OR REPLACE VIEW jika ada variasi tipe numeric/presisi).
--    View ini aman di-drop karena tidak memiliki view lain yang bergantung padanya.
drop view if exists public.v_saldo_ringkasan;

create view public.v_saldo_ringkasan as
select
    (select coalesce(sum(nominal), 0) from public.topup_saldo) as total_topup,
    (select coalesce(sum(total_nilai), 0)
       from public.v_transaksi_ringkasan
       where status = 'selesai' and jenis_pembayaran = 'tunai') as total_pemakaian,
    (select coalesce(sum(nominal), 0) from public.topup_saldo)
      - (select coalesce(sum(total_nilai), 0)
           from public.v_transaksi_ringkasan
           where status = 'selesai' and jenis_pembayaran = 'tunai') as sisa_saldo;

-- 4. View baru untuk Tab "Non Tunai" (FR-10.10) -- agregasi harian
drop view if exists public.v_transaksi_non_tunai_harian;

create view public.v_transaksi_non_tunai_harian as
select
    tanggal_transaksi as tanggal,
    count(distinct id) as jumlah_transaksi,
    sum(total_nilai) as total_nilai
from public.v_transaksi_ringkasan
where status = 'selesai' and jenis_pembayaran = 'non_tunai'
group by tanggal_transaksi
order by tanggal_transaksi;

-- 5. Hak akses API PostgREST Supabase
grant select on public.v_transaksi_ringkasan to authenticated, anon;
grant select on public.v_saldo_ringkasan to authenticated, anon;
grant select on public.v_transaksi_non_tunai_harian to authenticated, anon;

commit;
