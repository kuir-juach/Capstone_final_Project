#!/usr/bin/env python3
"""
Test PostgreSQL connection for LeafSense
"""

import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

def test_connection():
    load_dotenv()
    
    DATABASE_URL = os.getenv("DATABASE_URL")
    print(f"Testing connection to: {DATABASE_URL}")
    
    try:
        engine = create_engine(DATABASE_URL)
        with engine.connect() as connection:
            result = connection.execute(text("SELECT 'Connection successful!' as status"))
            print("✅ PostgreSQL connection successful!")
            for row in result:
                print(f"   {row.status}")
        return True
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        print("\nTo fix this issue:")
        print("1. Run: setup_db.bat")
        print("2. Or manually execute: psql -U postgres -f setup_postgres.sql")
        return False

if __name__ == "__main__":
    test_connection()