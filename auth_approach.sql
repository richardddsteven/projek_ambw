-- ALTERNATIVE APPROACH USING SUPABASE AUTH

-- This approach requires that you sign in to your app using Supabase Auth
-- When using Supabase Auth, you get access to the auth.uid() function which
-- will contain the ID of the currently authenticated user

-- First, ensure our policy for appointments allows authenticated users to manage their own appointments
DROP POLICY IF EXISTS "Allow users to create own appointments" ON appointments;
DROP POLICY IF EXISTS "Allow users to read own appointments" ON appointments;
DROP POLICY IF EXISTS "Allow users to update own appointments" ON appointments;
DROP POLICY IF EXISTS "Allow public read access to appointments" ON appointments;
DROP POLICY IF EXISTS "Allow public insert access to appointments" ON appointments;
DROP POLICY IF EXISTS "Allow public update access to appointments" ON appointments;
DROP POLICY IF EXISTS "Allow test user to manage appointments" ON appointments;

-- Create proper RLS policies for authenticated users
CREATE POLICY "authenticated can read own appointments" ON appointments
  FOR SELECT USING (auth.uid()::text = user_id::text);

CREATE POLICY "authenticated can insert own appointments" ON appointments
  FOR INSERT WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "authenticated can update own appointments" ON appointments
  FOR UPDATE USING (auth.uid()::text = user_id::text);
