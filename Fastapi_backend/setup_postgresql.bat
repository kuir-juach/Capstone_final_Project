@echo off
echo Setting up PostgreSQL for LeafSense...

echo.
echo 1. Install PostgreSQL (if not installed):
echo    Download from: https://www.postgresql.org/download/windows/
echo.

echo 2. Create database and user:
echo    Run these commands in PostgreSQL command line (psql):
echo.
echo    CREATE DATABASE leafsense_db;
echo    CREATE USER leafsense_user WITH PASSWORD 'leafsense_password';
echo    GRANT ALL PRIVILEGES ON DATABASE leafsense_db TO leafsense_user;
echo    \q
echo.

echo 3. Install Python dependencies:
pip install -r requirements_google_meet.txt

echo.
echo 4. Run database migrations:
alembic upgrade head

echo.
echo 5. Start the FastAPI server:
python main.py

echo.
echo Setup complete! Your PostgreSQL database is ready.
pause