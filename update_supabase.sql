-- MODIFIED SUPABASE SQL SCRIPT THAT HANDLES EXISTING TABLES

-- First, let's check if we need to insert our test user
-- This will insert the user only if they don't exist yet
INSERT INTO users (id, name, email)
SELECT 'd0e70ba1-0e15-49e0-a7e9-5d26dfdc07d1', 'Siyam Ahamed', 'siyam@example.com'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE id = 'd0e70ba1-0e15-49e0-a7e9-5d26dfdc07d1');

-- Insert sample doctors data only if they don't exist yet
-- We'll check if any doctors exist first
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM doctors LIMIT 1) THEN
        -- Insert sample doctors
        INSERT INTO doctors (name, specialty, photo_url, experience, about, rating) VALUES
        ('Jennifer Smith', 'Orthopedist', 'https://randomuser.me/api/portraits/women/32.jpg', 8, 'Orthopedic surgeon specializing in foot and ankle disorders.', 4.8),
        ('Warner', 'Neurologist', 'https://randomuser.me/api/portraits/men/42.jpg', 5, 'Neurologist with expertise in headache disorders and stroke management.', 4.5),
        ('Raj Patel', 'Cardiologist', 'https://randomuser.me/api/portraits/men/56.jpg', 12, 'Interventional cardiologist with focus on heart diseases.', 4.9),
        ('Sarah Johnson', 'Pulmonologist', 'https://randomuser.me/api/portraits/women/45.jpg', 9, 'Pulmonologist specializing in respiratory disorders and sleep medicine.', 4.7);
    END IF;
END $$;

-- Set up Row Level Security (RLS) if it's not already set up
-- These commands are safe to run even if RLS is already enabled
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;

-- Create policies (these are idempotent - safe to run multiple times)
-- Check if policies exist first and only create them if they don't

-- Doctors policies
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'doctors' AND policyname = 'Allow public read access to doctors') THEN
        CREATE POLICY "Allow public read access to doctors" ON doctors FOR SELECT USING (true);
    END IF;
END $$;

-- Users policies
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'users' AND policyname = 'Allow users to read own data') THEN
        CREATE POLICY "Allow users to read own data" ON users 
          FOR SELECT USING (auth.uid() = id);
    END IF;
END $$;

-- Appointments policies
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'appointments' AND policyname = 'Allow users to read own appointments') THEN
        CREATE POLICY "Allow users to read own appointments" ON appointments 
          FOR SELECT USING (auth.uid() = user_id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'appointments' AND policyname = 'Allow users to create own appointments') THEN
        CREATE POLICY "Allow users to create own appointments" ON appointments 
          FOR INSERT WITH CHECK (auth.uid() = user_id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'appointments' AND policyname = 'Allow users to update own appointments') THEN
        CREATE POLICY "Allow users to update own appointments" ON appointments 
          FOR UPDATE USING (auth.uid() = user_id);
    END IF;
END $$;
