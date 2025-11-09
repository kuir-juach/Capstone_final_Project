-- PostgreSQL setup script for LeafSense
-- Run this as postgres superuser

-- Create database if it doesn't exist
SELECT 'CREATE DATABASE leafsense_db'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'leafsense_db')\gexec

-- Create user if it doesn't exist
DO
$do$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'leafsense_user') THEN

      CREATE ROLE leafsense_user LOGIN PASSWORD 'achol123';
   END IF;
END
$do$;

-- Reset password for existing user
ALTER USER leafsense_user WITH PASSWORD 'achol123';

-- Grant all privileges on database
GRANT ALL PRIVILEGES ON DATABASE leafsense_db TO leafsense_user;

-- Connect to the database and grant schema privileges
\c leafsense_db

-- Grant privileges on public schema
GRANT ALL ON SCHEMA public TO leafsense_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO leafsense_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO leafsense_user;

-- Set default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO leafsense_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO leafsense_user;