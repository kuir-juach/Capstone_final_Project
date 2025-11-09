import sqlite3

# Connect to the database
conn = sqlite3.connect('leafsense.db')
cursor = conn.cursor()

# Check if plant_info table exists and has data
cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='plant_info';")
table_exists = cursor.fetchone()

if table_exists:
    print("plant_info table exists")
    
    # Get all plant data
    cursor.execute("SELECT * FROM plant_info")
    plants = cursor.fetchall()
    
    print(f"Found {len(plants)} plants in database:")
    for plant in plants:
        print(f"- {plant[1]} ({plant[2]})")  # name and scientific_name
else:
    print("plant_info table does not exist")

conn.close()