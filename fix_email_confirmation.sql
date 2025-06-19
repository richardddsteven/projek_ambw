-- Script untuk memperbaiki masalah konfirmasi email
-- Jalankan ini di SQL Editor Supabase

-- Catatan: Kita tidak dapat mengakses auth.config langsung.
-- Sebagai gantinya, kita akan menandai semua pengguna yang ada sebagai sudah dikonfirmasi emailnya
-- dan menggunakan cara lain untuk menangani konfirmasi email untuk pengguna baru.

-- 1. Verifikasi semua email yang sudah terdaftar tetapi belum dikonfirmasi
-- Kita tidak dapat melakukan ini dengan SQL langsung karena batasan akses ke tabel auth.users
-- Sebagai gantinya, kita akan fokus pada tabel publik dan RLS

-- 2. Pastikan RLS pada tabel users sudah benar
-- Ulangi kebijakan untuk memastikan akses benar
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Reset dan buat ulang kebijakan untuk tabel users
DROP POLICY IF EXISTS "Enable read access for all users" ON public.users;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.users;
DROP POLICY IF EXISTS "Enable update for users based on id" ON public.users;
DROP POLICY IF EXISTS "Enable delete for users based on id" ON public.users;

-- Buat kebijakan baru yang lebih permisif untuk tahap pengembangan
-- Ini memungkinkan akses yang lebih mudah untuk testing
CREATE POLICY "Public users are viewable by everyone." ON public.users
    FOR SELECT USING (true);

-- Izinkan semua pengguna terotentikasi untuk insert ke tabel users
-- Ini penting untuk registrasi
CREATE POLICY "Users can insert data." ON public.users
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Users can update own data." ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can delete own data." ON public.users
    FOR DELETE USING (auth.uid() = id);

-- 3. Cek dan pastikan data di tabel users sudah benar
-- Untuk pengguna yang mendaftar tetapi tidak ada di tabel users, 
-- kode AuthService.dart akan menanganinya saat login

-- Catatan: Setelah menjalankan script ini, restart aplikasi dan coba login ulang
-- Untuk pengguna baru, gunakan fungsi signUp yang dimodifikasi di auth_service.dart
-- yang tidak bergantung pada konfirmasi email

-- PENTING: Untuk mengatasi masalah konfirmasi email, Anda harus:
-- 1. Buka Supabase Dashboard > Authentication > Email Templates
-- 2. Edit template konfirmasi email untuk menggunakan URL yang valid 
--    (bukan localhost). Contoh: URL produksi atau URL domain Anda.
-- 3. Atau nonaktifkan konfirmasi email di Dashboard > Authentication > 
--    Settings > Email > Enable email confirmations (matikan toggle ini)
