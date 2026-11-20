# Panduan Skema Database Supabase untuk Organisasi Baru (Multi-Tenant BYOD)

File [master_tenant_schema.sql](file:///c:/Users/yoru/Documents/College/Project/Kasir_TBS_Sawit/supabase/master_tenant_schema.sql) berisi seluruh DDL skema database (tabel, foreign key, index, view, trigger, RLS policies, seed awal, dan hak akses PostgREST) versi terbaru **v2.5.4**.

## Langkah Setup Database Baru (3 Menit)

1. **Buat Project Supabase**:
   - Masuk ke dashboard [Supabase](https://supabase.com).
   - Klik **New Project**, tentukan nama organisasi Anda (misal: `Ramp Sawit Berkah`), buat password database, dan pilih region terdekat (misal: `Singapore`).

2. **Eksekusi Master Schema**:
   - Buka menu **SQL Editor** pada sidebar kiri dashboard Supabase.
   - Klik **New Query**.
   - Buka file [master_tenant_schema.sql](file:///c:/Users/yoru/Documents/College/Project/Kasir_TBS_Sawit/supabase/master_tenant_schema.sql), salin (Ctrl+A, Ctrl+C) seluruh isinya, lalu tempelkan (Ctrl+V) ke SQL Editor Supabase.
   - Klik tombol hijau **Run**. Pastikan muncul keterangan *"Success. No rows returned"*.

3. **Buat Akun Admin Pertama**:
   - Buka menu **Authentication** -> **Users** -> **Add user**.
   - Masukkan email dan password (misal: `admin@rampsawit.com`).
   - Centang opsi *Auto Confirm User*.
   - Di SQL Editor, jalankan perintah berikut untuk memastikan role profil menjadi `admin`:
     ```sql
     UPDATE public.profiles SET role = 'admin' WHERE id IN (SELECT id FROM auth.users WHERE email = 'admin@rampsawit.com');
     ```

4. **Hubungkan Aplikasi RamSawit**:
   - Buka menu **Project Settings** -> **API** di Supabase.
   - Salin **Project URL** (`https://xxxxxxxxxxxx.supabase.co`) dan **anon public** key (`eyJh...`).
   - Buka aplikasi **RamSawit** (Windows atau Android).
   - Pada halaman Login, klik tombol **"Setup Organisasi & Database"**.
   - Tempelkan URL & Anon Key, lalu simpan.
   - Login menggunakan akun yang sudah dibuat.

5. **Selesai!**
   - Database ramp sawit Anda siap dipakai baik online maupun offline-first dengan sinkronisasi lokal.
