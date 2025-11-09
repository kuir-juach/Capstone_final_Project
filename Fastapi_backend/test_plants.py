import requests

BASE_URL = "http://localhost:8000"

# Test getting plant info
plants = ["Neem", "Betle", "sinensis"]

for plant in plants:
    try:
        response = requests.get(f"{BASE_URL}/api/plant/{plant}")
        if response.status_code == 200:
            data = response.json()
            print(f"\n=== {plant.upper()} ===")
            print(f"Medicinal Values: {data['medicinal_values']}")
            print(f"Preparations: {data['preparations'][:100]}...")
        else:
            print(f"Error getting {plant}: {response.status_code}")
    except Exception as e:
        print(f"Error: {e}")

# Test getting all plants
try:
    response = requests.get(f"{BASE_URL}/api/plants")
    if response.status_code == 200:
        plants = response.json()
        print(f"\nAvailable plants: {plants}")
except Exception as e:
    print(f"Error getting plants: {e}")