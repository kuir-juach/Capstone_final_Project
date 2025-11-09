import requests
import json

# Test the plant information API
base_url = "http://localhost:8000"

def test_plant_api():
    # Test getting plant info for neem
    response = requests.get(f"{base_url}/api/plant/neem")
    print("Neem plant info:")
    print(json.dumps(response.json(), indent=2))
    print(f"Status: {response.status_code}\n")
    
    # Test getting plant info for betle
    response = requests.get(f"{base_url}/api/plant/betle")
    print("Betle plant info:")
    print(json.dumps(response.json(), indent=2))
    print(f"Status: {response.status_code}\n")
    
    # Test getting plant info for sinensis
    response = requests.get(f"{base_url}/api/plant/sinensis")
    print("Sinensis plant info:")
    print(json.dumps(response.json(), indent=2))
    print(f"Status: {response.status_code}\n")
    
    # Test getting all plants
    response = requests.get(f"{base_url}/api/plants")
    print("All plants:")
    print(json.dumps(response.json(), indent=2))
    print(f"Status: {response.status_code}\n")
    
    # Test non-existent plant
    response = requests.get(f"{base_url}/api/plant/unknown")
    print("Unknown plant:")
    print(f"Status: {response.status_code}")
    if response.status_code != 404:
        print(response.text)

if __name__ == "__main__":
    test_plant_api()