import sqlite3

def view_data():
    conn = sqlite3.connect('leafsense.db')
    cursor = conn.cursor()
    
    tables = ['user_profiles', 'appointments', 'feedback', 'predictions']
    
    for table in tables:
        print(f"\n=== {table.upper()} ===")
        cursor.execute(f"SELECT * FROM {table}")
        rows = cursor.fetchall()
        
        if rows:
            cursor.execute(f"PRAGMA table_info({table})")
            columns = [col[1] for col in cursor.fetchall()]
            print(" | ".join(columns))
            print("-" * 50)
            
            for row in rows:
                print(" | ".join(str(x) for x in row))
        else:
            print("No data")
    
    conn.close()

def clear_table(table_name):
    conn = sqlite3.connect('leafsense.db')
    cursor = conn.cursor()
    cursor.execute(f"DELETE FROM {table_name}")
    conn.commit()
    conn.close()
    print(f"Cleared {table_name}")

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        if sys.argv[1] == "clear":
            clear_table(sys.argv[2])
        else:
            view_data()
    else:
        view_data()