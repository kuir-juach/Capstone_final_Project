#!/usr/bin/env python3
"""
LeafSense startup script with database initialization
Ensures database is properly set up before starting the server
"""

import os
import sys
import subprocess
from init_db import init_database

def check_postgresql_connection():
    """Check if PostgreSQL is accessible"""
    try:
        from database import engine
        connection = engine.connect()
        connection.close()
        print("✅ PostgreSQL connection successful")
        return True
    except Exception as e:
        print(f"❌ PostgreSQL connection failed: {e}")
        print("Please ensure PostgreSQL is running and the database exists.")
        return False

def main():
    """Main startup sequence"""
    print("🚀 Starting LeafSense with PostgreSQL")
    print("=" * 50)
    
    # Check PostgreSQL connection
    if not check_postgresql_connection():
        print("\n💡 To fix this:")
        print("1. Start PostgreSQL service")
        print("2. Create database: CREATE DATABASE leafsense_db;")
        print("3. Create user: CREATE USER leafsense_user WITH PASSWORD 'admin123';")
        print("4. Grant privileges: GRANT ALL PRIVILEGES ON DATABASE leafsense_db TO leafsense_user;")
        sys.exit(1)
    
    # Initialize database
    if not init_database():
        print("❌ Database initialization failed")
        sys.exit(1)
    
    print("\n🌟 Starting FastAPI server...")
    print("Server will be available at: http://localhost:8000")
    print("API documentation: http://localhost:8000/docs")
    print("=" * 50)
    
    # Start the server
    try:
        subprocess.run([
            sys.executable, "-m", "uvicorn", 
            "main:app", 
            "--host", "0.0.0.0", 
            "--port", "8000", 
            "--reload"
        ])
    except KeyboardInterrupt:
        print("\n👋 Server stopped by user")
    except Exception as e:
        print(f"❌ Server failed to start: {e}")

if __name__ == "__main__":
    main()