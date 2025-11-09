@echo off
echo Setting up PostgreSQL for LeafSense...
echo.

echo Step 1: Running PostgreSQL setup script...
psql -U postgres -f setup_postgres.sql

echo.
echo Step 2: Testing connection...
psql -U leafsense_user -h localhost -p 5432 -d leafsense_db -c "SELECT 'Connection successful!' as status;"

echo.
echo Setup complete! You can now run your FastAPI application.
pause