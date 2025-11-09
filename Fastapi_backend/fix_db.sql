-- Quick fix for database setup
CREATE DATABASE IF NOT EXISTS leafsense_db;
CREATE USER IF NOT EXISTS leafsense_user WITH PASSWORD 'achol123';
GRANT ALL PRIVILEGES ON DATABASE leafsense_db TO leafsense_user;
GRANT ALL PRIVILEGES ON DATABASE leafsense_db TO postgres;