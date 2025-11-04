import requests
import json

# Test the API endpoints
base_url = "http://127.0.0.1:8000"

def test_health():
    try:
        response = requests.get(f"{base_url}/health")
        print(f"Health check: {response.status_code} - {response.json()}")
        return response.status_code == 200
    except Exception as e:
        print(f"Health check failed: {e}")
        return False

def test_model_info():
    try:
        response = requests.get(f"{base_url}/model/info")
        print(f"Model info: {response.status_code} - {response.json()}")
        return response.status_code == 200
    except Exception as e:
        print(f"Model info failed: {e}")
        return False

def test_plants():
    try:
        response = requests.get(f"{base_url}/plants")
        print(f"Plants list: {response.status_code} - {response.json()}")
        return response.status_code == 200
    except Exception as e:
        print(f"Plants list failed: {e}")
        return False

if __name__ == "__main__":
    print("Testing FastAPI endpoints...")
    
    if test_health():
        print("✅ Health endpoint working")
    else:
        print("❌ Health endpoint failed")
    
    if test_model_info():
        print("✅ Model info endpoint working")
    else:
        print("❌ Model info endpoint failed")
    
    if test_plants():
        print("✅ Plants endpoint working")
    else:
        print("❌ Plants endpoint failed")