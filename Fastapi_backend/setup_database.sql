-- Setup script for LeafSense database
-- Run this as postgres superuser

-- Create user if not exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'leafsense_user') THEN
        CREATE USER leafsense_user WITH PASSWORD 'admin123';
    END IF;
END
$$;

-- Create database if not exists
SELECT 'CREATE DATABASE leafsense_db OWNER leafsense_user'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'leafsense_db')\gexec

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE leafsense_db TO leafsense_user;

-- Connect to the database and grant schema privileges
\c leafsense_db
GRANT ALL ON SCHEMA public TO leafsense_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO leafsense_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO leafsense_user;