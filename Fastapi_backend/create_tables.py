from database import engine, Base
from models import Appointment, Feedback, Prediction, UserProfile

def create_tables():
    try:
        Base.metadata.create_all(bind=engine)
        print("Database tables created successfully!")
        return True
    except Exception as e:
        print(f"Error creating tables: {e}")
        return False

if __name__ == "__main__":
    create_tables()