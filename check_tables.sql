-- SQL SCRIPT TO CHECK EXISTING TABLES STRUCTURE

-- Check users table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM 
    information_schema.columns
WHERE 
    table_name = 'users'
ORDER BY 
    ordinal_position;

-- Check doctors table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM 
    information_schema.columns
WHERE 
    table_name = 'doctors'
ORDER BY 
    ordinal_position;

-- Check appointments table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM 
    information_schema.columns
WHERE 
    table_name = 'appointments'
ORDER BY 
    ordinal_position;

-- Check if our test user exists
SELECT * FROM users WHERE id = 'd0e70ba1-0e15-49e0-a7e9-5d26dfdc07d1';

-- Check how many doctors we have
SELECT COUNT(*) FROM doctors;

-- Check how many appointments we have
SELECT COUNT(*) FROM appointments;
