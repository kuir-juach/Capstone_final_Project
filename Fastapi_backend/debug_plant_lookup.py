import sqlite3

# Test plant lookup with different cases
conn = sqlite3.connect('leafsense.db')
cursor = conn.cursor()

test_names = ['Neem', 'neem', 'NEEM', 'Betle', 'betle', 'sinensis', 'Sinensis']

for name in test_names:
    cursor.execute("SELECT name FROM plant_info WHERE LOWER(name) = LOWER(?)", (name,))
    result = cursor.fetchone()
    print(f"Searching for '{name}': {'Found' if result else 'Not found'}")
    if result:
        print(f"  -> Actual name in DB: '{result[0]}'")

print("\nAll plant names in database:")
cursor.execute("SELECT name FROM plant_info")
results = cursor.fetchall()
for result in results:
    print(f"  - '{result[0]}'")

conn.close()