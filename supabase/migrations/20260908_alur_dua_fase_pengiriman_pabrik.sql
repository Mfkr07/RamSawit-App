-- ============================================================
-- MIGRASI TUGAS BAGIAN 12 & 15: ALUR DUA FASE PENGIRIMAN PABRIK
-- Sesuai doc/Database-Aplikasi-Transaksi-Sawit.md §8.2
-- ============================================================

-- 1. Jadikan kolom fase-2 boleh kosong (nullable)
alter table public.pengiriman_pabrik
    alter column berat_ditolak_kg drop not null,
    alter column berat_ditolak_kg drop default,
    alter column persentase_potongan_pabrik drop not null,
    alter column persentase_potongan_pabrik drop default,
    alter column harga_jual_per_kg drop not null;

-- 2. Tambahkan status "berangkat" ke constraint status check
alter table public.pengiriman_pabrik
    drop constraint if exists pengiriman_pabrik_status_check;

alter table public.pengiriman_pabrik
    add constraint pengiriman_pabrik_status_check
    check (status in ('berangkat', 'selesai', 'dibatalkan'));

-- 3. Status default sekarang "berangkat" (fase 1), bukan langsung "selesai"
alter table public.pengiriman_pabrik
    alter column status set default 'berangkat';
