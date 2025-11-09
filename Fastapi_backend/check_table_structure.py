import sqlite3

conn = sqlite3.connect('leafsense.db')
cursor = conn.cursor()

# Get table structure
cursor.execute("PRAGMA table_info(plant_info)")
columns = cursor.fetchall()

print("plant_info table structure:")
for col in columns:
    print(f"  {col[1]} ({col[2]})")

# Get sample data
cursor.execute("SELECT * FROM plant_info LIMIT 1")
sample = cursor.fetchone()
if sample:
    print(f"\nSample row: {sample}")

conn.close()