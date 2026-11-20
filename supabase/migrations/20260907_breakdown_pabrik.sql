-- ============================================================
-- MIGRASI TUGAS BAGIAN 13: VIEW BREAKDOWN PER PABRIK TUJUAN
-- Sesuai doc/Database-Aplikasi-Transaksi-Sawit.md §8.1
-- Sifat: 100% NON-DESTRUKTIF (CREATE OR REPLACE VIEW)
-- ============================================================

create or replace view public.v_breakdown_pabrik as
select
    pb.nama as nama_pabrik,
    date_trunc('day', pp.tanggal_kirim) as tanggal,
    sum(pp.berat_kotor_kg) as total_berat_kotor_kg,
    sum(pp.berat_bersih_kg) as total_berat_bersih_kg,
    sum(pp.total_nilai_jual) as total_nilai_jual
from public.pengiriman_pabrik pp
join public.pabrik pb on pb.id = pp.pabrik_id
where pp.status = 'selesai'
group by pb.nama, date_trunc('day', pp.tanggal_kirim);
