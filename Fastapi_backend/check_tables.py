from database_sqlite import engine
from sqlalchemy import inspect

def check_tables():
    inspector = inspect(engine)
    tables = inspector.get_table_names()
    
    print("Database tables created:")
    for table in tables:
        print(f"- {table}")
        columns = inspector.get_columns(table)
        for col in columns:
            print(f"  * {col['name']} ({col['type']})")
        print()

if __name__ == "__main__":
    check_tables()