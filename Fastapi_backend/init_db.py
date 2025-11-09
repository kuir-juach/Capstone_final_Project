#!/usr/bin/env python3
"""
Database initialization script for LeafSense
Creates all necessary tables and ensures proper setup
"""

from database import engine, Base
from models import Appointment, Feedback, Prediction
import os
from dotenv import load_dotenv

def init_database():
    """Initialize database with all tables"""
    load_dotenv()
    
    print("🔄 Initializing LeafSense database...")
    
    try:
        # Create all tables
        Base.metadata.create_all(bind=engine)
        print("✅ Database tables created successfully!")
        
        # Print table information
        print("\n📊 Created tables:")
        print("- appointments (id, user_id, name, email, date, time, doctor, reason, status, meet_link, timestamp)")
        print("- feedback (id, user_id, message, timestamp)")
        print("- predictions (id, user_id, image_url, prediction_result, confidence, timestamp)")
        
        print(f"\n🔗 Database URL: {os.getenv('DATABASE_URL', 'Not configured')}")
        print("✅ Database initialization complete!")
        
    except Exception as e:
        print(f"❌ Database initialization failed: {e}")
        return False
    
    return True

if __name__ == "__main__":
    init_database()