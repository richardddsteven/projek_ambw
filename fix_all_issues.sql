-- Fix all issues with Authentication and RLS permissions
-- Simplified version that works with standard Supabase permissions

-- 1. Make sure RLS is enabled on public.users table
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 2. Create simplified RLS policies for public.users table
-- Drop existing policies first to avoid conflicts
DROP POLICY IF EXISTS "users_select_policy" ON public.users;
DROP POLICY IF EXISTS "users_update_policy" ON public.users;
DROP POLICY IF EXISTS "users_insert_policy" ON public.users;
DROP POLICY IF EXISTS "users_delete_policy" ON public.users;
DROP POLICY IF EXISTS "Enable read access for all users" ON public.users;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.users;
DROP POLICY IF EXISTS "Enable update for users based on id" ON public.users;
DROP POLICY IF EXISTS "Enable delete for users based on id" ON public.users;

-- Create simplified policies that will work with standard permissions
-- Allow anyone to read user data
CREATE POLICY "Enable read access for all users" ON public.users
    FOR SELECT USING (true);

-- Allow authenticated users to insert their own data
CREATE POLICY "Enable insert for authenticated users only" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Allow users to update their own data
CREATE POLICY "Enable update for users based on id" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Allow users to delete their own data
CREATE POLICY "Enable delete for users based on id" ON public.users
    FOR DELETE USING (auth.uid() = id);

-- 3. Fix appointments table RLS policies
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "appointments_select_policy" ON public.appointments;
DROP POLICY IF EXISTS "appointments_insert_policy" ON public.appointments;
DROP POLICY IF EXISTS "appointments_update_policy" ON public.appointments;
DROP POLICY IF EXISTS "appointments_delete_policy" ON public.appointments;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.appointments;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.appointments;
DROP POLICY IF EXISTS "Enable update for users based on id" ON public.appointments;
DROP POLICY IF EXISTS "Enable delete for users based on id" ON public.appointments;

-- Create simplified policies
CREATE POLICY "Enable read access for authenticated users" ON public.appointments
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Enable insert for authenticated users only" ON public.appointments
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Enable update for users based on id" ON public.appointments
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Enable delete for users based on id" ON public.appointments
    FOR DELETE USING (auth.uid() = user_id);

-- 4. Make sure RLS is enabled on public.doctors table and allow read access
ALTER TABLE public.doctors ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read access for all users" ON public.doctors;
CREATE POLICY "Enable read access for all users" ON public.doctors
    FOR SELECT USING (true);

-- Note: We cannot create a trigger on auth.users with standard permissions.
-- Instead, you'll need to manually insert records into the public.users table
-- after registration, or modify the auth_service.dart file to handle this.

-- IMPORTANT: After running this script, you may need to:
-- 1. Make sure your users table has the expected columns (id, email, name, etc.)
-- 2. Make sure your auth_service.dart file creates a record in the users table after signup
-- 3. If existing users are having trouble, manually add their records to the users table
