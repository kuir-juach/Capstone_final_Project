#!/usr/bin/env python3
"""
Database migration script to add hidden_from_user column
"""
import sqlite3
import os

def migrate_database():
    db_path = "leafsense.db"
    
    if not os.path.exists(db_path):
        print(f"Database {db_path} not found!")
        return
    
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Check if column already exists
        cursor.execute("PRAGMA table_info(appointments)")
        columns = [column[1] for column in cursor.fetchall()]
        
        if 'hidden_from_user' not in columns:
            print("Adding hidden_from_user column to appointments table...")
            cursor.execute("ALTER TABLE appointments ADD COLUMN hidden_from_user INTEGER DEFAULT 0")
            conn.commit()
            print("Migration completed successfully!")
        else:
            print("Column hidden_from_user already exists!")
        
        conn.close()
        
    except Exception as e:
        print(f"Migration failed: {e}")

if __name__ == "__main__":
    migrate_database()