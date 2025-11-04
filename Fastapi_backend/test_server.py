import requests
import time

def test_server():
    url = "http://127.0.0.1:8000"
    
    print("Testing FastAPI server connection...")
    
    try:
        # Test health endpoint
        response = requests.get(f"{url}/health", timeout=5)
        if response.status_code == 200:
            print("✅ Server is running and healthy")
            print(f"Response: {response.json()}")
            return True
        else:
            print(f"❌ Server responded with status: {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to server. Is it running?")
        return False
    except requests.exceptions.Timeout:
        print("❌ Server request timed out")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    if test_server():
        print("\n✅ Server is ready for Flutter connections")
    else:
        print("\n❌ Please start the FastAPI server first:")
        print("   cd api")
        print("   python main.py")