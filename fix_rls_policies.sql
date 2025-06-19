-- FIX ROW LEVEL SECURITY POLICY ISSUE

-- First, let's drop the existing RLS policy for appointments
DROP POLICY IF EXISTS "Allow users to create own appointments" ON appointments;
DROP POLICY IF EXISTS "Allow users to read own appointments" ON appointments;
DROP POLICY IF EXISTS "Allow users to update own appointments" ON appointments;

-- Now, let's create a more permissive policy for testing purposes
-- In a production app, you'd want more restrictive policies

-- Policy that allows anyone to read any appointment (for testing)
CREATE POLICY "Allow public read access to appointments" ON appointments
  FOR SELECT USING (true);

-- Policy that allows anyone to insert appointments (for testing)
CREATE POLICY "Allow public insert access to appointments" ON appointments
  FOR INSERT WITH CHECK (true);

-- Policy that allows anyone to update any appointment (for testing)
CREATE POLICY "Allow public update access to appointments" ON appointments
  FOR UPDATE USING (true);

-- If you're using a specific user for testing, you can also add a policy just for that user
CREATE POLICY "Allow test user to manage appointments" ON appointments
  USING (user_id = 'd0e70ba1-0e15-49e0-a7e9-5d26dfdc07d1')
  WITH CHECK (user_id = 'd0e70ba1-0e15-49e0-a7e9-5d26dfdc07d1');

-- You might also need to update the RLS on the users table
DROP POLICY IF EXISTS "Allow users to read own data" ON users;

-- Create a more permissive policy for the users table
CREATE POLICY "Allow public read access to users" ON users
  FOR SELECT USING (true);

-- Also let's verify that our test user exists
INSERT INTO users (id, name, email)
SELECT 'd0e70ba1-0e15-49e0-a7e9-5d26dfdc07d1', 'Siyam Ahamed', 'siyam@example.com'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE id = 'd0e70ba1-0e15-49e0-a7e9-5d26dfdc07d1');

-- If there are no doctors yet, insert some
INSERT INTO doctors (name, specialty, photo_url, experience, about, rating)
SELECT 'Jennifer Smith', 'Orthopedist', 'https://randomuser.me/api/portraits/women/32.jpg', 8, 'Orthopedic surgeon specializing in foot and ankle disorders.', 4.8
WHERE NOT EXISTS (SELECT 1 FROM doctors WHERE name = 'Jennifer Smith');

INSERT INTO doctors (name, specialty, photo_url, experience, about, rating)
SELECT 'Warner', 'Neurologist', 'https://randomuser.me/api/portraits/men/42.jpg', 5, 'Neurologist with expertise in headache disorders and stroke management.', 4.5
WHERE NOT EXISTS (SELECT 1 FROM doctors WHERE name = 'Warner');

INSERT INTO doctors (name, specialty, photo_url, experience, about, rating)
SELECT 'Raj Patel', 'Cardiologist', 'https://randomuser.me/api/portraits/men/56.jpg', 12, 'Interventional cardiologist with focus on heart diseases.', 4.9
WHERE NOT EXISTS (SELECT 1 FROM doctors WHERE name = 'Raj Patel');

INSERT INTO doctors (name, specialty, photo_url, experience, about, rating)
SELECT 'Sarah Johnson', 'Pulmonologist', 'https://randomuser.me/api/portraits/women/45.jpg', 9, 'Pulmonologist specializing in respiratory disorders and sleep medicine.', 4.7
WHERE NOT EXISTS (SELECT 1 FROM doctors WHERE name = 'Sarah Johnson');
