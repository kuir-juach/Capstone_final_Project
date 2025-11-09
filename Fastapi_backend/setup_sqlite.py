from database_sqlite import engine, Base
from models import Appointment, Feedback, Prediction, UserProfile

def setup_sqlite():
    Base.metadata.create_all(bind=engine)
    print("SQLite database created with all tables!")

if __name__ == "__main__":
    setup_sqlite()