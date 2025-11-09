# PostgreSQL Setup Guide for LeafSense

## Step 1: Install PostgreSQL

1. Download PostgreSQL from: https://www.postgresql.org/download/windows/
2. Install with default settings
3. Remember the password you set for the `postgres` user

## Step 2: Create Database and User

Open PostgreSQL command line (psql) and run:

```sql
CREATE DATABASE leafsense_db;
CREATE USER leafsense_user WITH PASSWORD 'leafsense_password';
GRANT ALL PRIVILEGES ON DATABASE leafsense_db TO leafsense_user;
\q
```

## Step 3: Install Dependencies

```bash
pip install -r requirements_google_meet.txt
```

## Step 4: Environment Configuration

The `.env` file is already configured with:
```
DATABASE_URL=postgresql://leafsense_user:leafsense_password@localhost:5432/leafsense_db
```

## Step 5: Initialize Database Tables

```bash
python main.py
```

The tables will be created automatically on first run.

## Step 6: Verify Setup

1. Start the FastAPI server: `python main.py`
2. Visit: http://localhost:8000/docs
3. Test the endpoints

## Database Tables Created:

- **appointments** - User appointment bookings
- **feedback** - User feedback messages  
- **predictions** - Plant prediction history

## Features:

✅ **Persistent Storage** - Data survives server restarts
✅ **ACID Compliance** - Reliable transactions
✅ **Scalable** - Production-ready database
✅ **Backup Support** - Easy data backup/restore
✅ **Query Performance** - Indexed for fast queries

## Troubleshooting:

- **Connection Error**: Check if PostgreSQL service is running
- **Authentication Error**: Verify username/password in `.env`
- **Database Not Found**: Ensure database was created in Step 2