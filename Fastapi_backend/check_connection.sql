-- Check PostgreSQL connection
SELECT current_database(), current_user;

-- List all databases
SELECT datname FROM pg_database WHERE datistemplate = false;

-- List all tables in current database
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

-- Check if our required tables exist
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'public' 
ORDER BY table_name, ordinal_position;