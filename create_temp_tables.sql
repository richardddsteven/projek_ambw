-- ALTERNATIVE APPROACH: CREATE TEMPORARY TABLES AND MIGRATE DATA

-- Create temporary tables with our desired structure
CREATE TABLE IF NOT EXISTS temp_users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR NOT NULL,
  email VARCHAR UNIQUE,
  photo_url VARCHAR,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS temp_doctors (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR NOT NULL,
  specialty VARCHAR NOT NULL,
  photo_url VARCHAR NOT NULL,
  experience INTEGER NOT NULL,
  about TEXT,
  rating DECIMAL(2,1),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS temp_appointments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES temp_users(id),
  doctor_id UUID NOT NULL REFERENCES temp_doctors(id),
  appointment_date TIMESTAMP WITH TIME ZONE NOT NULL,
  type VARCHAR NOT NULL,
  notes TEXT,
  status VARCHAR NOT NULL DEFAULT 'scheduled',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert our test user
INSERT INTO temp_users (id, name, email) VALUES
('d0e70ba1-0e15-49e0-a7e9-5d26dfdc07d1', 'Siyam Ahamed', 'siyam@example.com');

-- Insert sample doctors
INSERT INTO temp_doctors (name, specialty, photo_url, experience, about, rating) VALUES
('Jennifer Smith', 'Orthopedist', 'https://randomuser.me/api/portraits/women/32.jpg', 8, 'Orthopedic surgeon specializing in foot and ankle disorders.', 4.8),
('Warner', 'Neurologist', 'https://randomuser.me/api/portraits/men/42.jpg', 5, 'Neurologist with expertise in headache disorders and stroke management.', 4.5),
('Raj Patel', 'Cardiologist', 'https://randomuser.me/api/portraits/men/56.jpg', 12, 'Interventional cardiologist with focus on heart diseases.', 4.9),
('Sarah Johnson', 'Pulmonologist', 'https://randomuser.me/api/portraits/women/45.jpg', 9, 'Pulmonologist specializing in respiratory disorders and sleep medicine.', 4.7);
